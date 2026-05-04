class test_config_update_during_soft_reset extends base_test;

  // Constructor
  function new(virtual valid_ready_if #(8,8,1)  v_cfg,
               virtual valid_ready_if #(32,8,1) v_tx,
               virtual valid_ready_if #(32,8,1) v_rx,
               virtual UART_if        #(32)      u_tx,
               virtual UART_if        #(32)      u_rx);
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST] Skipping static configuration for dynamic flow.", $time);
  endtask

  virtual task main_test();
    $display("=================================================================");
    $display("[%0t] [TEST] STARTING: test_config_update_during_soft_reset", $time);
    $display("=================================================================");

    $display("[%0t] [TEST] Step 1: Asserting Soft Reset (Reg 0x04 = 0x00)", $time);
    #100;


    $display("[%0t] [TEST] Step 2: Attempting to write new configs to TX (0x14) and RX (0x24)...", $time);
    write_register(8'h14, 8'hA5); 
    write_register(8'h24, 8'h5A); 
    #100;

    $display("[%0t] [TEST] Step 3: Reading back configs to verify DUT accepted them...", $time);
    read_register(8'h14); 
    read_register(8'h24); 
    #100;

   
    $display("[%0t] [TEST] Step 4: Attempting to send TX traffic while in Soft Reset...", $time);
    fork
        gen_vr_tx.send_tx_traffic(1, 0, 0, 0); 
    join_none
    
    #200000; 

    $display("[%0t] [TEST] Step 5: Lifting Soft Reset to return to normal operation", $time);
    #1000;

    $display("=================================================================");
    $display("[%0t] [TEST] COMPLETED: test_config_update_during_soft_reset", $time);
    $display("=================================================================");
  endtask

endclass