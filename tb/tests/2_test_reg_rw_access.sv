class test_reg_rw_access extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(8)      u_tx,
                virtual UART_if        #(8)      u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
    cfg_vr_tx.is_active   = 0;
  endfunction
virtual task main_test();
    $display("[%0t] [TEST-2] Running: test_reg_rw_access", $time);
    $display("=================================================");

    // 1. Write to valid RW Registers
    write_register(8'h14, 8'hFF);
    write_register(8'h24, 8'hFF); 
    
    // 2. Attempt to write to ALL Read-Only (RO) Registers (Should be ignored)
    write_register(8'h18, 8'hFF); // TX LSB
    write_register(8'h1A, 8'hFF); // TX MSB
    write_register(8'h1C, 8'hFF); // TX ERR
        write_register(8'h2C, 8'hFF); // RX ERR

    write_register(8'h28, 8'hFF); // RX LSB
    write_register(8'h2A, 8'hFF); // RX MSB


    // 3. Read back to verify
    read_register(8'h14); // Expected 0xFF
    read_register(8'h24); // Expected 0xFF
     read_register(8'h2C); 
    read_register(8'h18); 
    read_register(8'h1A); 
    read_register(8'h1C); 
    read_register(8'h28); 
    read_register(8'h2A); 
   

    #500;
    $display("[%0t] [TEST-2] RW Access Check Complete.", $time);
  endtask
endclass