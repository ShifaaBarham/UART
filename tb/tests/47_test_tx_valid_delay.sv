class test_tx_valid_delay extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST-VALID-DELAY] Configuring DUT.", $time);
    
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
    
    num_trans = $urandom_range(20, 50); 

    $display("[%0t] [TEST 32] Executing test_tx_valid_delay.", $time);
    $display("=========================================================");
    $display("[%0t] [TEST 32] Generating %0d TX Transactions with random valid delay (1-100).", $time, num_trans);
    
    #1000;
   
    gen_vr_tx.send_tx_traffic(num_trans, 0, 1, 100);

    $display("[%0t] [TEST 32] Traffic Generated. Waiting for serialization.", $time);
    
    repeat (num_trans * 5000) begin
      #1000; 
    end

    $display("[%0t] [TEST 32] Reading Counters.", $time);
    read_register(8'h18); 
    read_register(8'h1C);
    #1000;
  endtask
endclass