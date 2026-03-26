class test_rx_total_parity_sanity extends base_test;

  function new( virtual valid_ready_if #(8, 8, 8)  v_cfg,
                virtual valid_ready_if #(32, 0, 0) v_tx,
                virtual valid_ready_if #(32, 0, 0) v_rx,
                virtual UART_if        #(8)        u_tx,
                virtual UART_if        #(8)        u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    uart_Transaction #(8) rx_trans;
    
    $display("[%0t] [TEST 16] Executing test_rx_total_parity_sanity.", $time);
        $display("=================================================");

    write_register(8'h24, 8'h00);
    
    
    for (int i = 0; i < 4; i++) begin
      rx_trans = new();
      rx_trans.data = 8'h5A; 
      
      env.agt_uart_rx.drv_mbx.put(rx_trans);
      $display("[%0t] [TEST 16] Injected RX Byte %0d.", $time, i);
      
      #20;
    end
    
    $display("[%0t] [TEST 16] Finished injecting 32-bit frame. DUT should verify ONE total parity bit.", $time);
    
    #1000;
  endtask

endclass