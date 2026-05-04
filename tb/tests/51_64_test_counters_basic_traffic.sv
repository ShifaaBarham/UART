class test_counters_basic_traffic extends base_test;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST] Configuring DUT.", $time);
    
    write_register(8'h24, 8'h0E); 
    read_register(8'h24);

    write_register(8'h14, 8'h0E); 
    read_register(8'h14);

        env.cfg_uart_tx.parity_mode = EVEN;
        env.cfg_uart_tx.cfg_baud_rate = B57600; 
        env.cfg_uart_tx.stop_bits = 1;
        env.cfg_uart_tx.ppb_enable = 0;
    
        env.cfg_uart_rx.parity_mode = EVEN;
        env.cfg_uart_rx.cfg_baud_rate = B57600; 
        env.cfg_uart_rx.stop_bits = 1;
        env.cfg_uart_rx.ppb_enable = 0;
    #1000; 
  endtask

  virtual task main_test();
    string dir = "TX";           
    string traffic_type = "VALID"; 
    int err_pct = 0;             
    int num_trans = 65536;          
    
    void'($value$plusargs("DIR=%s", dir));
    void'($value$plusargs("TRAFFIC_TYPE=%s", traffic_type));

    if (traffic_type == "VALID")      err_pct = 0;
    else if (traffic_type == "ERROR") err_pct = 100;

    $display("[%0t] Running Basic Counters Test", $time);
    $display("Direction: %s | Traffic: %s | Error: %0d%%", dir, traffic_type, err_pct);
    $display("=================================================");

    #1000;

    if (dir == "TX") begin
      $display("[%0t] Sending %0d TX Transactions.", $time, num_trans);
      
      if (traffic_type == "MIXED") begin
        for (int i = 0; i < num_trans/2; i++) begin
              $display("[%0t] Transaction %0d", $time, i);
          gen_vr_tx.send_tx_traffic(1, 0);   
          gen_vr_tx.send_tx_traffic(1, 100); 
        end
      end else begin
        gen_vr_tx.send_tx_traffic(num_trans, err_pct);
      end
      
wait(env.sb.expected_uart_tx_q.size() == 0);
#10us;
    end else if (dir == "RX") begin
      $display("[%0t] Sending %0d RX Transactions.", $time, num_trans);
      
      fork
        gen_vr_rx.drive_rx_ready_responses(num_trans, 0, 10); 
      join_none

      if (traffic_type == "MIXED") begin
        for (int i = 0; i < num_trans/2; i++) begin
            $display("[%0t] Transaction %0d", $time, i);
          gen_uart_rx.send_rx_traffic(1, 0, 0, 0, 1000, 2000);  
          gen_uart_rx.send_rx_traffic(1, 0, 100, 0, 1000, 2000);
        end
      end else begin
        gen_uart_rx.send_rx_traffic(num_trans, 0, err_pct, 0, 1000, 2000);
      end
      
wait(env.sb.expected_vr_rx_q.size() == 0);
#10us;
    end

    $display("[%0t] Reading ALL Counters to check isolation.", $time);
    
    read_register(8'h18); 
    read_register(8'h1A); 
    read_register(8'h1C); 
    
    read_register(8'h28); 
    read_register(8'h2A); 
    read_register(8'h2C); 

     read_register(8'h18); 
    read_register(8'h1A); 
    read_register(8'h1C); 
    
    read_register(8'h28); 
    read_register(8'h2A); 
    read_register(8'h2C); 


    #1000;
  endtask

endclass
/*
vsim -c -do 'do run.do  +DIR=TX +TRAFFIC_TYPE=VALID'    # test_tx_counters_valid_only
vsim -c -do 'do run.do  +DIR=RX +TRAFFIC_TYPE=VALID'    # test_rx_counters_valid_only
vsim -c -do 'do run.do  +DIR=TX +TRAFFIC_TYPE=ERROR'    # test_tx_counters_error_only
vsim -c -do 'do run.do  +DIR=RX +TRAFFIC_TYPE=ERROR'    # test_rx_counters_error_only
vsim -c -do 'do run.do  +DIR=TX +TRAFFIC_TYPE=MIXED'    # test_tx_counters_mixed_traffic
vsim -c -do 'do run.do  +DIR=RX +TRAFFIC_TYPE=MIXED'    # test_rx_counters_mixed_traffic
 */