class test_tx_backpressure_ready_toggle extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST-TX-BP] Configuring DUT for TX Backpressure Test.", $time);
    
    write_register(8'h14, 8'h18); 
    read_register(8'h14);

    env.cfg_uart_tx.ppb_enable = 0;     
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B9600; 
    env.cfg_uart_tx.stop_bits = 1;         
    #1000; 
  endtask

  virtual task main_test();
    int num_trans = 10; 
    
    $display("[%0t] [TEST-TX-BP] Executing test_tx_backpressure_ready_toggle.", $time);
    $display("=====================================================================");
    $display("[%0t] [TEST-TX-BP] Bombarding DUT with %0d transactions (0 delay)...", $time, num_trans);
    
    #1000;
    

    gen_vr_tx.send_tx_traffic(num_trans, 0, 0, 0);

    $display("[%0t] [TEST-TX-BP] All parallel data driven. Waiting for slow serial transmission...", $time);
    
   
    repeat (1500000) begin 
      #1000; 
    end

    $display("[%0t] [TEST-TX-BP] Reading TX Counters to verify completely sent packets.", $time);
    read_register(8'h18); 
    read_register(8'h1C);
    #10000;
  endtask
endclass