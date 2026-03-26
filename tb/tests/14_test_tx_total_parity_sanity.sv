class test_tx_total_parity_sanity extends base_test;

  function new( virtual valid_ready_if #(8, 8, 8)  v_cfg,
                virtual valid_ready_if #(32, 0, 0) v_tx,
                virtual valid_ready_if #(32, 0, 0) v_rx,
                virtual UART_if        #(8)        u_tx,
                virtual UART_if        #(8)        u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    vr_Transaction #(32, 0, 0) tx_trans;
    
    $display("[%0t] [TEST 14] Executing test_tx_total_parity_sanity...", $time);
        $display("=================================================");

 
    write_register(8'h14, 8'h00); 
    
    tx_trans = new();
    tx_trans.data = 32'hA5A5A5A5;
    env.agt_vr_tx.drv_mbx.put(tx_trans);
    
    $display("[%0t] [TEST 14] Sent 32-bit data (Total Parity mode). Monitor should check for exactly 1 parity bit at the end.", $time);
    
    #1000; 
  endtask

endclass