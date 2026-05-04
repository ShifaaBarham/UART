class test_asymmetric_baud_rates extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
    
    watchdog_limit = 5000ms; 
  endfunction

  virtual task configure_dut();

    $display("[%0t] [TEST] Configuring DUT for Asymmetric Baud Rates", $time);
    
    
  
    write_register(8'h14, 8'h1E);
    read_register(8'h14);
    
    env.cfg_uart_tx.parity_mode = EVEN;
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    env.cfg_uart_tx.stop_bits = 1;
    env.cfg_uart_tx.ppb_enable = 0;

    
    write_register(8'h24, 8'h08);
    read_register(8'h24);

    env.cfg_uart_rx.parity_mode = EVEN;
    env.cfg_uart_rx.cfg_baud_rate = B9600; 
    env.cfg_uart_rx.stop_bits = 1;
    env.cfg_uart_rx.ppb_enable = 0;

    #2ms; 
  endtask

  virtual task main_test();
    $display("[%0t] [TEST] Executing test_asymmetric_baud_rates", $time);
    $display("=================================================");

    $display("[%0t] [TEST] Starting Full-Duplex Traffic: TX @ 57600, RX @ 19200", $time);

    fork
        //Thread1:sending 15 packets on TX side 
      begin
        gen_vr_tx.send_tx_traffic(15, 0, 0, 0); 
      end
      //Thread2:simultaneously sending 5 packets on RX side with slower baud rate
      begin
        gen_uart_rx.send_rx_traffic(5, 0, 0, 0, 500, 1000); 
      end
      //Thread3: driving ready responses for RX to ensure reception continues without backpressure
      begin
        gen_vr_rx.drive_rx_ready_responses(5, 0, 0);
      end
    join_none
    
    $display("[%0t] [TEST] Traffic is running simultaneously on both paths.", $time);
    
  
    #1ms; 
    
    wait(env.sb.expected_uart_tx_q.size() == 0 && env.sb.expected_vr_rx_q.size() == 0);
    #2ms;
    
    $display("[%0t] [TEST] Reading Counters to ensure independence.", $time);
    read_register(8'h18); 
    read_register(8'h28); 
    #1000000;
  endtask
endclass