class test_tx_sanity extends base_test;

 function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(8)      u_tx,
                virtual UART_if        #(8)      u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    vr_Transaction #(32, 0, 0) tx_trans;
    
    $display("[%0t] [TEST 11] Executing test_tx_sanity.", $time);
        $display("=================================================");

    for (int i = 0; i < 5; i++) begin
      tx_trans = new();
      tx_trans.wdata = 32'hAABBCC00 + i; 
      
      env.agt_vr_tx.vr_drv_mbx.put(tx_trans);
      $display("[%0t] [TEST 11] Pushed TX Packet %0d to Mailbox", $time, i);
      
      #10; 
    end
    
    #1000;
  endtask

endclass