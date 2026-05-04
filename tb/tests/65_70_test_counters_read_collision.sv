class test_rx_err_read_collision extends base_test;
   function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST collision] Configuring DUT.", $time);
    
    write_register(8'h14, 8'h0E); 
    read_register(8'h14);
      write_register(8'h24, 8'h0E); 
    read_register(8'h24);

    env.cfg_uart_tx.ppb_enable = 0;     
    env.cfg_uart_tx.parity_mode = EVEN;    
    env.cfg_uart_tx.cfg_baud_rate = B57600; 
    env.cfg_uart_tx.stop_bits = 1;         

    env.cfg_uart_rx.ppb_enable = 0;     
    env.cfg_uart_rx.parity_mode = EVEN;    
    env.cfg_uart_rx.cfg_baud_rate = B57600; 
    env.cfg_uart_rx.stop_bits = 1;   

    #1000; 
  endtask

  virtual task main_test();
    int num_packets_to_send = 100;
     bit test_is_done = 0;
 
    $display("[%0t] Running RX  Read Collision Test", $time);
    $display("=================================================");

    env.sb.collision_test_mode = 1;
    env.sb.total_expected_counts = num_packets_to_send;
    env.sb.total_read_counts = 0;

    fork
    
      begin
        $display("[%0t] [THREAD 1] Sending %0d  Transactions.", $time, num_packets_to_send);
              fork
                 gen_uart_rx.send_rx_traffic(num_packets_to_send, 0, 0, 0, 1000, 2000); 
                 gen_vr_rx.drive_rx_ready_responses(num_packets_to_send, 0, 10); 
             join        
             
        wait(env.sb.expected_vr_rx_q.size() == 0);
        #2ms; 
        
        test_is_done = 1; 
      end


      begin
        $display("[%0t] [THREAD 2] Starting Random Read Spamming.", $time);
        
        while (!test_is_done) begin 
           #( $urandom_range(100, 1000) * 1ns ); 
           
           read_register(8'h28); 
            $display("[%0t] [THREAD 2] read counter %0d", $time, env.sb.total_read_counts);
        end
        $display("[%0t] [THREAD 2] Traffic finished. Stopping spam.", $time);
      end
    join

  
    $display("[%0t] Doing one FINAL read to flush the counter.", $time);
    read_register(8'h28); 
    

    #2ms; 

    if (env.sb.total_read_counts == env.sb.total_expected_counts) begin
       $display("PASS: BULLETPROOF DESIGN! No counts lost during collisions.");
       $display("Expected: %0d | Accumulated Reads: %0d", env.sb.total_expected_counts, env.sb.total_read_counts);
       $display("=================================================");
    end else begin
       $error("FAIL: COLLISION BUG DETECTED! Design lost a count!");
       $error("Expected: %0d | Accumulated Reads: %0d", env.sb.total_expected_counts, env.sb.total_read_counts);
       $error("=================================================");
    end
    
    env.sb.collision_test_mode = 0;
  endtask
endclass