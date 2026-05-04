class test_config_write_mid_transaction extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)      u_tx,
                virtual UART_if        #(32)      u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST-4] Configuring DUT...", $time);
    
    // نضبط الإعدادات على Even Parity للـ TX و RX
    write_register(8'h14, 8'h16); 
    write_register(8'h24, 8'h16); 

    env.cfg_uart_tx.ppb_enable = 0;      
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    env.cfg_uart_tx.stop_bits = 1;         
      
    env.cfg_uart_rx.ppb_enable = 0;      
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    env.cfg_uart_rx.stop_bits = 1; 

    #1000000; 
  endtask
virtual task main_test();
    $display("[%0t] [TEST-4] Running: test_config_write_mid_transaction", $time);
    $display("=================================================");

    // =========================================================================
    // 1. TX MID-FLIGHT COLLISION & RECOVERY
    // =========================================================================
    $display("[%0t] [TEST-4] --- STARTING TX MID-FLIGHT TEST ---", $time);
    
    env.sb.disable_checking = 1; 

    $display("[%0t] [TEST-4] TX: Sending packet...", $time);
    gen_vr_tx.send_tx_traffic(1); 
    
    #300000; // ننتظر لتكون الداتا في نص السلك

    $display("[%0t] [TEST-4] TX: Injecting Soft Reset mid-flight!", $time);
    write_register(8'h04, 8'h00); // 1. Assert Soft Reset
    
    #4000000; // 🚨 زدنا الوقت لـ 4 مليون لضمان السلك يفضى تماماً
    
    write_register(8'h04, 8'h01); // 2. De-assert Soft Reset
    #500000; // وقت استقرار بعد الريست
      
    // 🚨 إعادة برمجة الـ Config لأن الريست غالباً بيمسحهم
    write_register(8'h14, 8'h16); 
    write_register(8'h24, 8'h16);

    $display("[%0t] [TEST-4] TX Collision done. Flushing TB queues.", $time);
    env.sb.flush_queues();
    env.sb.disable_checking = 0; 

    $display("[%0t] [TEST-4] TX: Sending RECOVERY packet.", $time);
    gen_vr_tx.send_tx_traffic(1); 
    
    #3000000; // ننتظر الباكيت يوصل وينفحص بالكامل
    
    if (env.sb.expected_uart_tx_q.size() > 0) begin
      $error("[%0t] [TEST-4] TX BUG CAUGHT! DUT swallowed the Recovery packet!", $time);
    end else begin
      $display("[%0t] [TEST-4] PASS: TX Recovery Successful.", $time);
    end 

    // =========================================================================
    // 2. RX MID-FLIGHT COLLISION & RECOVERY
    // =========================================================================
    $display("[%0t] [TEST-4] --- STARTING RX MID-FLIGHT TEST ---", $time);
    
    env.sb.disable_checking = 1; 

    $display("[%0t] [TEST-4] RX: Sending packet...", $time);
    fork
        gen_uart_rx.send_rx_traffic(1, 0,0,0,0,0); 
        gen_vr_rx.drive_rx_ready_responses(2, 0,0); 
    join_none
      
    #300000; // ننتظر الداتا لتوصل نص السلك
      
    $display("[%0t] [TEST-4] RX: Injecting Soft Reset mid-flight!", $time);
    write_register(8'h04, 8'h00); // Assert Soft Reset
      
    #4000000; // 🚨 ننتظر 4 مليون لحد ما الدرايفر يخلص يكب الباكيت المقطوع على السلك

    write_register(8'h04, 8'h01); // De-assert Soft Reset
    #500000; // وقت استقرار
      
    // 🚨 إعادة برمجة الـ Config لأن الريست غالباً بيمسحهم
    write_register(8'h14, 8'h16); 
    write_register(8'h24, 8'h16);
    
    $display("[%0t] [TEST-4] RX Collision done. Flushing TB queues...", $time);
    env.sb.flush_queues();
    env.sb.disable_checking = 0; 

    $display("[%0t] [TEST-4] RX: Sending RECOVERY packet.", $time);
    fork 
       gen_uart_rx.send_rx_traffic(1, 0,0,0,0,0); 
       gen_vr_rx.drive_rx_ready_responses(1, 0,0); 
    join_none

    #3000000; // وقت كافي جداً لوصول الباكيت الجديد

    $display("[%0t] [TEST-4] Mid-Transaction Check Complete.", $time);

    if (env.sb.expected_vr_rx_q.size() > 0) begin
      $error("[%0t] [TEST-4] FATAL FAIL: RX DUT swallowed packets! State Machine might be stuck.", $time);
    end else begin
      $display("[%0t] [TEST-4] PASS: RX Recovery Successful.", $time);
    end
  endtask
endclass