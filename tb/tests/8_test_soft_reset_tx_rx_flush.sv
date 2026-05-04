class test_soft_reset_tx_rx_flush extends base_test;

  // Constructor
  function new(virtual valid_ready_if #(8,8,1)  v_cfg,
               virtual valid_ready_if #(32,8,1) v_tx,
               virtual valid_ready_if #(32,8,1) v_rx,
               virtual UART_if        #(32)      u_tx,
               virtual UART_if        #(32)      u_rx);
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
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

  // Main Test Scenario
  virtual task main_test();
     $display("[%0t] [TEST] STARTING: test_soft_reset_tx_rx_flush", $time);
    $display("=================================================================");


    $display("[%0t] [TEST] Ensuring Soft Reset is De-asserted (Normal Mode) - Reg 0x04 = 1", $time);
    write_register(8'h04, 8'h01); 
    #100;


      $display("[%0t] [TEST] Starting TX and RX transactions in the background...", $time);

      fork
          begin
              gen_vr_tx.send_tx_traffic(1, 0, 0, 0); 
          end
          begin
              gen_uart_rx.send_rx_traffic(1, 0, 0, 0); 
              gen_vr_rx.drive_rx_ready_responses(1);
          end
      join_none

    #20ms; 


    $display("[%0t] [TEST] MID-TRANSACTION! Asserting Soft Reset (Reg 0x04 = 0x00)", $time);
    write_register(8'h04, 8'h00); 

    #500000;

   
    $display("[%0t] [TEST] Lifting Soft Reset (Reg 0x04 = 0x01)", $time);
    write_register(8'h04, 8'h01);
    
    #100000;

   
        $display("[%0t] [TEST] Reading Counters to verify NO packets were processed...", $time);

        read_register(8'h18); 
        #500000;

        read_register(8'h1C); 
      #500000;
    
 
  endtask

endclass