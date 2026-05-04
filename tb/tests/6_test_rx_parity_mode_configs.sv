class test_rx_parity_mode_config extends base_test;

  function new(virtual valid_ready_if #(8,8,1)  v_cfg,
               virtual valid_ready_if #(32,8,1) v_tx,
               virtual valid_ready_if #(32,8,1) v_rx,
               virtual UART_if        #(32)      u_tx,
               virtual UART_if        #(32)      u_rx);
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    $display("[%0t] [TEST 6] STARTING: test_rx_parity_mode_config", $time);
    $display("=================================================================");


    $display("[%0t] [TEST 6] PHASE 1: Testing EVEN Parity", $time);
    
    write_register(8'h04, 8'h00); 
    #10000;

    write_register(8'h24, 8'h0F); 
    
    env.cfg_uart_rx.parity_mode = EVEN;
    env.cfg_uart_rx.ppb_enable  = 1;
    env.cfg_uart_rx.stop_bits   = 1;
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    
    write_register(8'h04, 8'h01); 
    
    #500000; 

    $display("[%0t] [TEST 6] Driving 1 RX transaction (Expecting EVEN Parity on UART)", $time);
        gen_uart_rx.send_rx_traffic(1, 0, 0, 0); 
        gen_vr_rx.drive_rx_ready_responses(1);
    #5000000; 


  
    $display("[%0t] [TEST 5] --- PHASE 2: Testing ODD Parity ---", $time);
    
    write_register(8'h04, 8'h00); 
    #10000;

    write_register(8'h24, 8'h2F); 
    
    env.cfg_uart_rx.parity_mode = ODD; 
    env.cfg_uart_rx.ppb_enable  = 1;
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    
    write_register(8'h04, 8'h01); 
    
    #500000;

    $display("[%0t] [TEST 6] Driving 1 RX transaction (Expecting ODD Parity on UART)", $time);
  gen_uart_rx.send_rx_traffic(1, 0, 0, 0); 
        gen_vr_rx.drive_rx_ready_responses(1);
    #50000000;

    $display("=================================================================");
    $display("[%0t] [TEST 6] COMPLETED: test_rx_parity_mode_config", $time);
    $display("=================================================================");
  endtask
endclass