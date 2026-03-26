class test_config_read_backpressure extends base_test;

  function new( virtual valid_ready_if v_cfg,
                virtual valid_ready_if v_tx,
                virtual valid_ready_if v_rx,
                virtual UART_if        u_tx,
                virtual UART_if        u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    $display("[%0t] [TEST-3] Running: test_config_read_backpressure", $time);
    $display("=================================================");

    read_register(8'h14, 15); 
    
    read_register(8'h24, $urandom_range(5, 20));

    #500;
    $display("[%0t] [TEST-3] Backpressure Check Complete.", $time);
  endtask

endclass