class test_tx_parity_mode extends base_test;

  function new(virtual valid_ready_if #(8,8,1)  v_cfg,
               virtual valid_ready_if #(32,8,1) v_tx,
               virtual valid_ready_if #(32,8,1) v_rx,
               virtual UART_if        #(32)      u_tx,
               virtual UART_if        #(32)      u_rx);
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    $display("[%0t] [TEST 5] STARTING: test_tx_parity_mode_config", $time);
    $display("=================================================================");


    $display("[%0t] [TEST 5] PHASE 1: Testing EVEN Parity", $time);
    
    write_register(8'h04, 8'h00); 
    #10000;

    write_register(8'h14, 8'h0F); 
    
    env.cfg_uart_tx.parity_mode = EVEN;
    env.cfg_uart_tx.ppb_enable  = 1;
    env.cfg_uart_tx.stop_bits   = 1;
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    
    write_register(8'h04, 8'h01); 
    
    #500000; 

    $display("[%0t] [TEST 5] Driving 1 TX transaction (Expecting EVEN Parity on UART)", $time);
    gen_vr_tx.send_tx_traffic(1, 0, 0, 0);

    #5000000; 


  
    $display("[%0t] [TEST 5] --- PHASE 2: Testing ODD Parity ---", $time);
    
    write_register(8'h04, 8'h00); 
    #10000;

    write_register(8'h14, 8'h2F); 
    
    env.cfg_uart_tx.parity_mode = ODD; 
    env.cfg_uart_tx.ppb_enable  = 1;
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    
    write_register(8'h04, 8'h01); 
    
    #500000;

    $display("[%0t] [TEST] Driving 1 TX transaction (Expecting ODD Parity on UART)", $time);
    gen_vr_tx.send_tx_traffic(1, 0, 0, 0);

    #5000000;

    $display("=================================================================");
    $display("[%0t] [TEST] COMPLETED: test_tx_parity_mode_config", $time);
    $display("=================================================================");
  endtask
endclass