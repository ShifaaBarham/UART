class test_tx_back_to_back extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)      u_tx,
                virtual UART_if        #(32)      u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

 virtual task configure_dut();
    $display("[%0t] [TEST 31] Configuring DUT.", $time);
    
   write_register(8'h14, 8'h0E); 
    read_register(8'h14);

    env.cfg_uart_tx.ppb_enable = 0;     
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    env.cfg_uart_tx.stop_bits = 1;         
            
      
    #1000; 
  endtask
  virtual task main_test();
      int num_trans;
   num_trans = $urandom_range(150, 500); 

    $display("[%0t] [TEST 31] Executing test_tx_back_to_back.", $time);
    $display("=================================================");

    $display("[%0t] [TEST 31] Generating %0d TX Transactions...", $time, num_trans);
    
    #1000;
    
    gen_vr_tx.send_tx_traffic(num_trans, 0, 0, 0);

    $display("[%0t] [TEST 31] Traffic Generated. Waiting for serialization.", $time);
    
    repeat (5000) begin
      #1000; 
    end
    $display("[%0t] [TEST-FLOW] Reading Counters to verify no data was dropped.", $time);
    read_register(8'h18); 
    read_register(8'h1C);
  endtask
 
endclass