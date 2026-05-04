class test_full_duplex_stress extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
    
    watchdog_limit = 5000ms; 
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST] Configuring DUT for Full Duplex STRESS Test", $time);
    
    write_register(8'h14, 8'h1E); 
    read_register(8'h14);
    
    env.cfg_uart_tx.parity_mode = EVEN;
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    env.cfg_uart_tx.stop_bits = 1;
    env.cfg_uart_tx.ppb_enable = 0;

    write_register(8'h24, 8'h0E); 
    read_register(8'h24);

    env.cfg_uart_rx.parity_mode = EVEN;
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    env.cfg_uart_rx.stop_bits = 1;
    env.cfg_uart_rx.ppb_enable = 0;
    env.cfg_uart_rx.err_drop_mode = 0; 

    #2ms; 
  endtask

  virtual task main_test();
    int num_packets = 50;

    $display("[%0t] [TEST] Executing test_full_duplex_stress", $time);
    $display("=================================================");
    $display("[%0t] [TEST] Injecting %0d BACK-TO-BACK packets on TX and RX Simultaneously @ 57600 baud!", $time, num_packets);

    fork
      begin
        gen_vr_tx.send_tx_traffic(num_packets, 0, 0, 0); 
      end
      
      begin
        gen_uart_rx.send_rx_traffic(num_packets, 0, 0, 0, 0, 0); 
      end
      
      begin
        gen_vr_rx.drive_rx_ready_responses(num_packets, 0, 0);
      end
    join_none
    
    $display("[%0t] [TEST] Max Throughput Traffic is running.", $time);
    
    #4ms; 
    
    wait(env.sb.expected_uart_tx_q.size() == 0 && env.sb.expected_vr_rx_q.size() == 0);
    #2ms;
    
    $display("[%0t] [TEST] Reading Counters to verify no packets were dropped.", $time);
    read_register(8'h18);
    read_register(8'h28);
    
  endtask
endclass