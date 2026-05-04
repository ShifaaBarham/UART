class test_tx_err_drop_mode extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)      u_tx,
                virtual UART_if        #(32)      u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

 virtual task configure_dut();
    $display("[%0t] [TEST 18] Configuring DUT.", $time);
    
    write_register(8'h14, 8'h06); 
    read_register(8'h14);

    env.cfg_uart_tx.ppb_enable = 0;     
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    env.cfg_uart_tx.stop_bits = 1;         
    
    env.cfg_uart_tx.err_drop_mode = 1; 
      
    #1000; 
  endtask

  virtual task main_test();
    $display("[%0t] [TEST 18] Executing test_tx_err_drop_mode.", $time);
    $display("=================================================");

    $display("[%0t] [TEST 18] Generating 5 TX Transactions.", $time);
    
    #1000;
    
    gen_vr_tx.send_tx_traffic(5, 100, 0, 0);

    $display("[%0t] [TEST 18] Traffic Generated. Waiting for serialization.", $time);
    
    repeat (5000) begin
      #1000; 
    end
read_register(8'h18);
read_register(8'h1C);
#1000;
  endtask
endclass