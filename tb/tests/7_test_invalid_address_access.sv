class test_invalid_address_access extends base_test;

  function new( virtual valid_ready_if #(8, 8, 8)  v_cfg,
                virtual valid_ready_if #(32, 0, 0) v_tx,
                virtual valid_ready_if #(32, 0, 0) v_rx,
                virtual UART_if        #(8)        u_tx,
                virtual UART_if        #(8)        u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    $display("[%0t] [TEST 7] Executing test_invalid_address_access.", $time);
        $display("=================================================");

    write_register(8'h08, 8'hFF);
    write_register(8'h1F, 8'hAA);
    write_register(8'h99, 8'h12);
    
    read_register(8'h08);
    read_register(8'h1F);
    
    read_register(8'h14); 
    
    #200;
  endtask

endclass