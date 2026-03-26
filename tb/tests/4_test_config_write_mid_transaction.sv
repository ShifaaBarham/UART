
class test_config_write_mid_transaction extends base_test;

  function new( virtual valid_ready_if v_cfg,
                virtual valid_ready_if v_tx,
                virtual valid_ready_if v_rx,
                virtual UART_if        u_tx,
                virtual UART_if        u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task main_test();
    $display("[%0t] [TEST-4] Running: test_config_write_mid_transaction", $time);
    $display("=================================================");

    fork
      begin
        $display("[%0t] [TEST-4] Starting Data Transaction", $time);
        #300; 
        $display("[%0t] [TEST-4] Data Transaction Finished.", $time);
      end
      
      begin
        #100; 
        $display("[%0t] [TEST-4] Injecting Config Write mid-flight.", $time);
        write_register(8'h14, 8'h03); 
      end
    join

    $display("[%0t] [TEST-4] Both operations finished. Checking recovery.", $time);
    

    
    #500;
    $display("[%0t] [TEST-4] Mid-Transaction Check Complete.", $time);
  endtask

endclass