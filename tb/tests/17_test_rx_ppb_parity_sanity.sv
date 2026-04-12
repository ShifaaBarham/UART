class test_rx_ppb_parity_sanity extends base_test;

 function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(8)      u_tx,
                virtual UART_if        #(8)      u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    uart_Transaction #(8) rx_trans;
    
    $display("[%0t] [TEST] Executing test_rx_ppb_parity_sanity.", $time);
    $display("=================================================");

   
    write_register(8'h24, 8'h09);
    

    env.cfg_uart_rx.ppb_enable = 1; 
    
    for (int i = 0; i < 4; i++) begin
      rx_trans = new();
      rx_trans.data = 8'hA5 + i; 
      
      env.agt_uart_rx.uart_drv_mbx.put(rx_trans);
      $display("[%0t] [TEST] Injected RX Byte %0d Data: %0h.", $time, i, rx_trans.data);
      
      #20;
    end
    
    $display("[%0t] [TEST] Finished injecting 32-bit frame..", $time);
    
    #1000;
  endtask

endclass