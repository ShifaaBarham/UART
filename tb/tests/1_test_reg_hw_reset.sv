class test_reg_hw_reset extends base_test;

  function new( virtual valid_ready_if v_cfg,
                virtual valid_ready_if v_tx,
                virtual valid_ready_if v_rx,
                virtual UART_if        u_tx,
                virtual UART_if        u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
    cfg_vr_tx.is_active   = 0;
    cfg_vr_rx.is_active   = 0;
    cfg_uart_tx.is_active = 0;
    cfg_uart_rx.is_active = 0;
  endfunction

  virtual task configure_dut(); 
  endtask
  
  virtual task lift_soft_reset(); 
  endtask

  virtual task main_test();
    $display("[%0t] [TEST-1] Running: test_reg_hw_reset", $time);
    $display("=================================================");

    read_register(8'h04); 
    read_register(8'h14); 
    read_register(8'h24); 
    
    read_register(8'h18); 
    read_register(8'h1A); 
    read_register(8'h1C);

    read_register(8'h28); 
    read_register(8'h2A); 
    read_register(8'h2C);

    #500;
    $display("[%0t] [TEST-1] Finished checking HW Reset Defaults.", $time);
  endtask

endclass