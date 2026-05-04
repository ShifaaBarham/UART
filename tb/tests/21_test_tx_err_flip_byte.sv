class test_tx_err_flip_byte extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)      u_tx,
                virtual UART_if        #(32)      u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

 virtual task configure_dut();
    $display("[%0t] [TEST 20] Configuring DUT.", $time);
    
    write_register(8'h14, 8'h17); 
    read_register(8'h14);

    env.cfg_uart_tx.ppb_enable = 1;     
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    env.cfg_uart_tx.stop_bits = 1;         
    
    
      
    #1000; 
  endtask

  virtual task main_test();
    $display("[%0t] [TEST 21] Executing test_tx_err_flip_byte.", $time);
    $display("=================================================");

    $display("[%0t] [TEST 21] Generating TX Transactions without flipping byte parity .", $time);
    
    #320000;
        gen_vr_tx.send_tx_traffic(2, 0, 0, 0);
$display("[%0t] [TEST 21] Generating TX Transactions  flipping byte parity .", $time);
    
    #1000;
    gen_vr_tx.send_tx_traffic(2, 100, 0, 0);

    $display("[%0t] [TEST 21] Traffic Generated. Waiting for serialization.", $time);
    
    repeat (5000) begin
      #1000; 
    end
read_register(8'h18);
read_register(8'h1C);
#100000;
  endtask
endclass