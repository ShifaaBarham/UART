
class test_rx_sanity extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(8)      u_tx,
                virtual UART_if        #(8)      u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    uart_Transaction #(8) rx_trans;
    
    $display("[%0t] [TEST 12] Executing test_rx_sanity.", $time);
        $display("=================================================");

    for (int i = 0; i < 5; i++) begin
      rx_trans = new();
      rx_trans.data = 8'h50 + i; 
      
      env.agt_uart_rx.uart_drv_mbx.put(rx_trans);
      $display("[%0t] [TEST 12] Pushed RX Byte %0d to Mailbox", $time, i);
      
      #10;
    end
    
    #1000; 
  endtask

endclass