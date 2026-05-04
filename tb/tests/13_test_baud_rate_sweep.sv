class test_baud_rate_sweep extends base_test;

  function new(virtual valid_ready_if #(8,8,1)  v_cfg,
               virtual valid_ready_if #(32,8,1) v_tx,
               virtual valid_ready_if #(32,8,1) v_rx,
               virtual UART_if        #(32)      u_tx,
               virtual UART_if        #(32)      u_rx);
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    $display("[%0t] [TEST 13] Running: test_baud_rate_sweep ", $time);
    $display("=================================================");

  
    $display("[%0t] [TEST 13] Testing Baud Rate: 9600", $time);
        $display("=================================================");

    write_register(8'h04, 8'h00); 
    #10000;
    
    write_register(8'h14, 8'h18); // TX Config for 9600
    write_register(8'h24, 8'h08); // RX Config for 9600

    env.cfg_uart_tx.ppb_enable = 0;      
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B9600; 
    env.cfg_uart_tx.stop_bits = 1; 

    env.cfg_uart_rx.ppb_enable = 0;        
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B9600; 
    env.cfg_uart_rx.stop_bits = 1;

    write_register(8'h04, 8'h01); 
    #5000000; 

    gen_vr_tx.send_tx_traffic(1, 0, 0, 0);
    #10000000; 

    fork
      gen_uart_rx.send_rx_traffic(1, 0, 0, 0, 500, 1000);
      gen_vr_rx.drive_rx_ready_responses(1, 100, 200);
    join_none
    #10000000; 


    
    $display("[%0t] [TEST 13] Testing Baud Rate: 19200", $time);
        $display("=================================================");

    write_register(8'h04, 8'h00);
    #10000;
    
    write_register(8'h14, 8'h1A); // TX Config for 19200
    write_register(8'h24, 8'h0A); // RX Config for 19200

    env.cfg_uart_tx.ppb_enable = 0;      
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B19200; 
    env.cfg_uart_tx.stop_bits = 1; 

    env.cfg_uart_rx.ppb_enable = 0;        
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B19200; 
    env.cfg_uart_rx.stop_bits = 1;

    write_register(8'h04, 8'h01);
    #500000; 

    gen_vr_tx.send_tx_traffic(1, 0, 0, 0);
    #10000000; 

    fork
      gen_uart_rx.send_rx_traffic(1, 0, 0, 0, 500, 1000);
      gen_vr_rx.drive_rx_ready_responses(1, 100, 200);
    join_none
    #10000000; 


    
    $display("[%0t] [TEST 13] Testing Baud Rate: 38400", $time);
        $display("=================================================");

    write_register(8'h04, 8'h00); 
    #10000;
    
    write_register(8'h14, 8'h1C); // TX Config for 38400
    write_register(8'h24, 8'h0C); // RX Config for 38400

    env.cfg_uart_tx.ppb_enable = 0;      
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B38400; 
    env.cfg_uart_tx.stop_bits = 1; 

    env.cfg_uart_rx.ppb_enable = 0;        
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B38400; 
    env.cfg_uart_rx.stop_bits = 1;

    write_register(8'h04, 8'h01);
    #500000; 

    gen_vr_tx.send_tx_traffic(1, 0, 0, 0);
    #10000000; 

    fork
      gen_uart_rx.send_rx_traffic(1, 0, 0, 0, 500, 1000);
      gen_vr_rx.drive_rx_ready_responses(1, 100, 200);
    join_none
    #10000000; 


    $display("[%0t] [TEST 13] Testing Baud Rate: 57600", $time);
        $display("=================================================");

    write_register(8'h04, 8'h00); 
    #10000;
    
    write_register(8'h14, 8'h1E); // TX Config for 57600
    write_register(8'h24, 8'h0E); // RX Config for 57600

    env.cfg_uart_tx.ppb_enable = 0;      
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    env.cfg_uart_tx.stop_bits = 1; 

    env.cfg_uart_rx.ppb_enable = 0;        
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    env.cfg_uart_rx.stop_bits = 1;

    write_register(8'h04, 8'h01); 
    #500000; 

    gen_vr_tx.send_tx_traffic(1, 0, 0, 0);
    #10000000; 

    fork
      gen_uart_rx.send_rx_traffic(1, 0, 0, 0, 500, 1000);
      gen_vr_rx.drive_rx_ready_responses(1, 100, 200);
    join_none
    #10000000; 


  
    $display("=================================================");
    $display("[%0t] [TEST 13] All Baud Rates Swept. Checking Queues ", $time);

    if (env.sb.expected_uart_tx_q.size() > 0 || env.sb.expected_vr_rx_q.size() > 0) begin
      $error("[%0t] [TEST 13]  Missing transactions! TX Queue: %0d, RX Queue: %0d", 
             $time, env.sb.expected_uart_tx_q.size(), env.sb.expected_vr_rx_q.size());
    end else begin
      $display("[%0t] [TEST 13] PASS: DUT successfully operated on all 4 Baud Rates!", $time);
    end

  endtask
endclass