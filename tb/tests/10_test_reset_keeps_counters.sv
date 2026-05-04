class test_reset_keeps_counters extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

 
  virtual task configure_dut();
    $display("[%0t] [TEST_RST_CNT] Configuring DUT (TX Parity Disabled)...", $time);
    
    write_register(8'h14, 8'h08); 
    read_register(8'h14); 

    write_register(8'h24, 8'h0E); 
    read_register(8'h24);

    env.cfg_uart_tx.ppb_enable = 0;        
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B9600; 
    env.cfg_uart_tx.stop_bits = 1;   

     env.cfg_uart_rx.ppb_enable = 0;        
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    env.cfg_uart_rx.stop_bits = 1;         
      
    #1000000; 
  endtask


  virtual task main_test();
    int NUM_PKTS = 5;

    $display("[%0t] [TEST_RST_CNT] Running: test_reset_keeps_counters", $time);
    $display("=================================================");

    $display("[%0t] [TEST_RST_CNT] Step 1: Driving %0d TX packets...", $time, NUM_PKTS);
    fork
      begin
        gen_vr_tx.send_tx_traffic(NUM_PKTS, 0, 0, 0); 
      end

    join
    
    #5000000; 
        gen_uart_rx.send_rx_traffic(5, 0, 0, 0, 500,1000);
        gen_vr_rx.drive_rx_ready_responses(5, 100, 200);
    $display("[%0t] [TEST_RST_CNT] Step 2: Asserting Soft Reset ", $time);
    write_register(8'h04, 8'h00);
    #100000; 

    $display("[%0t] [TEST_RST_CNT] Step 3: De-asserting Soft Reset ", $time);
    write_register(8'h04, 8'h01);
    #100000; 

    $display("[%0t] [TEST_RST_CNT] Step 4: Reading TX Counters ", $time);
    
    read_register(8'h18); // TX
    read_register(8'h28); // RX


    #500000; 

    $display("[%0t] [TEST_RST_CNT] Test Finished. Check Scoreboard for results!", $time);
  endtask

endclass