class test_baud_rate_sweep extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(8)      u_tx,
                virtual UART_if        #(8)      u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    vr_Transaction #(32, 0, 0) tx_trans;
    uart_Transaction #(8) rx_trans;
    
    bit [7:0] baud_rates [3] = '{8'h01, 8'h05, 8'h0A}; 
    
    $display("[%0t] [TEST 13] Executing test_baud_rate_sweep", $time);
        $display("=================================================");

    foreach (baud_rates[i]) begin
      $display("[%0t] [TEST 13] Sweeping with Baud Rate Divisor: 0x%0h ", $time, baud_rates[i]);
      
      write_register(8'h14, baud_rates[i]); 
      write_register(8'h24, baud_rates[i]); 
      
      tx_trans = new();
      tx_trans.wdata = 32'h11223344 + i;
      env.agt_vr_tx.vr_drv_mbx.put(tx_trans);

      rx_trans = new();
      rx_trans.data = 8'hAA + i;
      env.agt_uart_rx.uart_drv_mbx.put(rx_trans);
      
      #1500; 
    end
    
  endtask

endclass