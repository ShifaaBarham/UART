class test_tx_ppb_parity_sanity extends base_test;

  function new( virtual valid_ready_if #(8, 8, 8)  v_cfg,
                virtual valid_ready_if #(32, 0, 0) v_tx,
                virtual valid_ready_if #(32, 0, 0) v_rx,
                virtual UART_if        #(8)        u_tx,
                virtual UART_if        #(8)        u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    vr_Transaction #(32, 0, 0) tx_trans;
    
    $display("[%0t] [TEST 15] Executing test_tx_ppb_parity_sanity", $time);
        $display("=================================================");

    write_register(8'h14, 8'h08); 
    
    tx_trans = new();
    tx_trans.data = 32'hC3C3C3C3;
    env.agt_vr_tx.vr_drv_mbx.put(tx_trans);
    
    $display("[%0t] [TEST 15] Sent 32-bit data (PPB mode). Monitor should check for 4 parity bits .", $time);
    
    #1000; 
  endtask

endclass