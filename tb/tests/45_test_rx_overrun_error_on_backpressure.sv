class test_rx_overrun_error_on_backpressure extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST-OVERRUN] Configuring DUT for Overrun Test.", $time);
    
    write_register(8'h24, 8'h0E); 
    read_register(8'h24);

    env.cfg_uart_rx.ppb_enable = 0;     
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    env.cfg_uart_rx.stop_bits = 1;         
    #1000; 
  endtask

  virtual task main_test();
    $display("[%0t] [TEST-OVERRUN] Executing test_rx_overrun_error_on_backpressure.", $time);
    $display("=====================================================================");
    $display("[%0t] [TEST-OVERRUN] Strategy: TB delays ready by 2000 cycles.", $time);
    $display("[%0t] [TEST-OVERRUN] Strategy: Injecting 2 valid packets from Serial RX.", $time);
    
    #1000;
    
    fork
       
        gen_vr_rx.drive_rx_ready_responses(1, 2000, 2000);
    join_none
    
   
    gen_uart_rx.send_rx_traffic(2, 0, 0, 0, 50, 100);

    $display("[%0t] [TEST-OVERRUN] Traffic Generated. Waiting for collision...", $time);
    
    repeat (5000000) begin 
      #1000; 
    end

    $display("[%0t] [TEST-OVERRUN] Reading RX Counters to verify Overrun Handling.", $time);
    read_register(8'h28); 
    read_register(8'h2C); 
    #100000;
  endtask
endclass