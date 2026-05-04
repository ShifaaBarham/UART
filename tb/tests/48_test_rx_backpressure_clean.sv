class test_rx_backpressure_clean extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST 33] Configuring DUT for RX Clean Backpressure.", $time);
    
    write_register(8'h24, 8'h0E); 
    read_register(8'h24);

    env.cfg_uart_rx.ppb_enable = 0;     
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    env.cfg_uart_rx.stop_bits = 1;         
    #1000; 
  endtask

  virtual task main_test();
    int num_trans;
    
    num_trans = $urandom_range(20, 50); 

    $display("[%0t] [TEST 33] Executing test_rx_backpressure_clean.", $time);
    $display("=========================================================");
    $display("[%0t] [TEST 33] Generating %0d RX Transactions with TB ready delay .", $time, num_trans);
    
    #1000;
    
    fork
    
gen_vr_rx.drive_rx_ready_responses(num_trans, 10, 400);
    join_none
    
    
gen_uart_rx.send_rx_traffic(num_trans, 0, 0, 0, 500, 1000);
    $display("[%0t] [TEST 33] Traffic Generated. Waiting for reception.", $time);
    
    repeat (num_trans * 15000000) begin 
      #10; 
    end

    $display("[%0t] [TEST 33] Reading RX Counters.", $time);
    read_register(8'h28); 
    read_register(8'h2C); 
    #100000;
  endtask
endclass