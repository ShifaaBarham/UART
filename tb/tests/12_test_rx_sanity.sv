class test_rx_sanity extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST 11] Configuring DUT...", $time);
    
    write_register(8'h24, 8'h0F); // PPB=0, Parity=Even, Baud=9600, Stop=1 0000 1000
    read_register(8'h24);

    env.cfg_uart_rx.ppb_enable =1;        
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    env.cfg_uart_rx.stop_bits = 1;         
      
    #1000000; 
  endtask

  virtual task main_test();
   $display("[%0t] [TEST_RX_SANITY] Running: test_rx_sanity", $time);
  $display("=================================================");

      fork
    gen_uart_rx.send_rx_traffic(5, 0, 0, 0, 500,1000);
        gen_vr_rx.drive_rx_ready_responses(5, 100, 200);
      join

repeat (20000) @(posedge vif_config.clk);
  if (env.sb.expected_vr_rx_q.size() > 0)
    $error("[%0t] [TEST_RX_SANITY] FAIL: queue size=%0d", $time, env.sb.expected_vr_rx_q.size());
  else
    $display("[%0t] [TEST_RX_SANITY] PASS", $time);
endtask
endclass