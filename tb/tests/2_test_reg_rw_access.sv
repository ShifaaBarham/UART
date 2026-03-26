class test_reg_rw_access extends base_test;

  function new( virtual valid_ready_if v_cfg,
                virtual valid_ready_if v_tx,
                virtual valid_ready_if v_rx,
                virtual UART_if        u_tx,
                virtual UART_if        u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    $display("[%0t] [TEST-2] Running: test_reg_rw_access", $time);
    $display("=================================================");

    write_register(8'h14, 8'hFF);
    write_register(8'h24, 8'hFF); 
    
    write_register(8'h1C, 8'hFF); 

    read_register(8'h14); 
    read_register(8'h24); 
    read_register(8'h1C); 

    #500;
    $display("[%0t] [TEST-2] RW Access Check Complete.", $time);
  endtask

endclass