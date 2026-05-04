class test_rx_backpressure_error extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST-RX-BP-ERR] Configuring DUT for RX Error Backpressure.", $time);
    
    write_register(8'h24, 8'h0E); 
    read_register(8'h24);

    env.cfg_uart_rx.ppb_enable = 0;     
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    env.cfg_uart_rx.stop_bits = 1;         
    #1000; 
  endtask

  virtual task main_test();
    int num_trans = 15;
    
    $display("[%0t] [TEST-RX-BP-ERR] Executing test_rx_backpressure_error.", $time);
    $display("=====================================================================");
    $display("[%0t] [TEST-RX-BP-ERR] Strategy: Injecting 100%% Parity Errors.", $time);
    $display("[%0t] [TEST-RX-BP-ERR] Strategy: TB delays ready by 100-300 cycles to check rx_err stability.", $time);
    
    #1000;
    
    fork
        gen_vr_rx.drive_rx_ready_responses(num_trans, 100, 300);
    join_none

    gen_uart_rx.send_rx_traffic(num_trans, 0, 100, 0, 1000, 2000);

    $display("[%0t] [TEST-RX-BP-ERR] Corrupted Traffic Generated. Waiting for reception...", $time);
    
    repeat (num_trans * 150000) begin 
      #1000; 
    end

    $display("[%0t] [TEST-RX-BP-ERR] Reading RX Counters.", $time);
    read_register(8'h28);
    read_register(8'h2C);
    #10000;
  endtask
endclass