class test_rx_error_injection extends base_test;

  string mode_str = "DROP";       
  string err_str  = "CHECKSUM";   
  
  bit [7:0] rx_config_val;
  bit [1:0] mode_bits;            
  
  int parity_err_rate   = 0;     
  int checksum_err_rate = 0;
  int framing_err_rate  = 0;

  function new( virtual valid_ready_if #(8,8,1)  v_cfg,
                virtual valid_ready_if #(32,8,1) v_tx,
                virtual valid_ready_if #(32,8,1) v_rx,
                virtual UART_if        #(32)     u_tx,
                virtual UART_if        #(32)     u_rx );
    super.new(v_cfg, v_tx, v_rx, u_tx, u_rx);
    
    watchdog_limit = 1ms; 

    if ($value$plusargs("MODE=%s", mode_str)) begin
      $display("[%0t] [TEST] MODE selected: %s", $time, mode_str);
    end
    
          if      (mode_str == "DROP")   mode_bits = 2'b00;
          else if (mode_str == "IND")    mode_bits = 2'b01;
          else if (mode_str == "NO_IND") mode_bits = 2'b10;
          else                           mode_bits = 2'b00; 

      if ($value$plusargs("ERR_TYPE=%s", err_str)) begin
        $display("[%0t] [TEST] ERR_TYPE selected: %s", $time, err_str);
      end

      
      if (err_str == "PPB"||err_str == "PPB_CHK"||err_str == "PPB_FRM"||err_str == "ALL") begin
        parity_err_rate = 100;
      end
        
        if (err_str == "CHECKSUM"||err_str == "PPB_CHK"||err_str == "CHK_FRM"||err_str == "ALL") begin
          checksum_err_rate = 100;
        end
        
        if (err_str == "FRAMING"||err_str == "PPB_FRM"||err_str == "CHK_FRM"||err_str == "ALL") begin
          framing_err_rate = 100;
        end

            
        rx_config_val = 8'h00;
        rx_config_val[4:3] = mode_bits;   // Error Mode
        
        rx_config_val[2:1] = 2'b11;       // Baud Rate config for 57600 

        // PPB Error
        if (parity_err_rate > 0) begin
          rx_config_val[0] = 1'b1; 
          env.cfg_uart_rx.ppb_enable = 1;
        end else begin
          rx_config_val[0] = 1'b0;
          env.cfg_uart_rx.ppb_enable = 0;
        end

  endfunction

  virtual task configure_dut();
    $display("[%0t] [TEST] Configuring DUT: Mode=%s, ErrType=%s, ConfigReg=0x%0h", $time, mode_str, err_str, rx_config_val);
        
        write_register(8'h24, rx_config_val); 
        read_register(8'h24);

        env.cfg_uart_rx.parity_mode = EVEN;    
        env.cfg_uart_rx.cfg_baud_rate = B57600; 
        env.cfg_uart_rx.stop_bits = 1;         
        
        if (mode_bits == 2'b00) env.cfg_uart_rx.err_drop_mode = 1; 
        else                    env.cfg_uart_rx.err_drop_mode = 0;
          
        #100000; 
  endtask

  virtual task main_test();
    $display("[%0t] [TEST] Executing test_rx_error_injection", $time);
    $display("=================================================");

    fork
       gen_uart_rx.send_rx_traffic(5, parity_err_rate, checksum_err_rate, framing_err_rate, 500, 1000);
       gen_vr_rx.drive_rx_ready_responses(5, 0, 0); // ready to avoid backpressure
    join_none 
    
    $display("[%0t] [TEST] Traffic Generated. Waiting for processing.", $time);
    
    #15ms; 
    wait(env.sb.expected_vr_rx_q.size() == 0);
    #20ms; 
    
    $display("[%0t] [TEST] Reading Counters.", $time);
    read_register(8'h28); // RX_CNT
    read_register(8'h2C); // RX_ERR_CNT
    #100000000;
  endtask
endclass

/*
 vsim -c -do 'do run.do +MODE=DROP +ERR_TYPE=PPB'         # test_rx_err_drop_ppb
 vsim -c -do 'do run.do +MODE=DROP +ERR_TYPE=CHECKSUM'    # test_rx_err_drop_checksum
 vsim -c -do 'do run.do +MODE=DROP +ERR_TYPE=FRAMING'     # test_rx_err_drop_framing
 vsim -c -do 'do run.do +MODE=DROP +ERR_TYPE=PPB_CHK'     # test_rx_err_drop_comb_ppb_chk
 vsim -c -do 'do run.do +MODE=DROP +ERR_TYPE=PPB_FRM'    # test_rx_err_drop_comb_ppb_frm
 vsim -c -do 'do run.do +MODE=DROP +ERR_TYPE=CHK_FRM'     # test_rx_err_drop_comb_chk_frm
 vsim -c -do 'do run.do  +MODE=DROP +ERR_TYPE=ALL'         # test_rx_err_drop_all




 vsim -c -do 'do run.do  +MODE=IND +ERR_TYPE=PPB'          # test_rx_err_ind_parity 
 vsim -c -do 'do run.do  +MODE=IND +ERR_TYPE=CHECKSUM'    # test_rx_err_ind_checksum
 vsim -c -do 'do run.do  +MODE=IND +ERR_TYPE=FRAMING'      # test_rx_err_ind_framing
 vsim -c -do 'do run.do  +MODE=IND +ERR_TYPE=PPB_CHK'      # test_rx_err_ind_comb_par_chk
 vsim -c -do 'do run.do  +MODE=IND +ERR_TYPE=PPB_FRM'      # test_rx_err_ind_comb_par_frm
 vsim -c -do 'do run.do  +MODE=IND +ERR_TYPE=CHK_FRM'      # test_rx_err_ind_comb_chk_frm
 vsim -c -do 'do run.do  +MODE=IND +ERR_TYPE=ALL'          # test_rx_err_ind_comb_all



 vsim -c -do 'do run.do  +MODE=NO_IND +ERR_TYPE=PPB'       # test_rx_err_no_ind_parity 
 vsim -c -do 'do run.do  +MODE=NO_IND +ERR_TYPE=CHECKSUM'  # test_rx_err_no_ind_checksum
 vsim -c -do 'do run.do  +MODE=NO_IND +ERR_TYPE=FRAMING'   # test_rx_err_no_ind_framing
 vsim -c -do 'do run.do  +MODE=NO_IND +ERR_TYPE=PPB_CHK'   # test_rx_err_no_ind_comb_par_chk
 vsim -c -do 'do run.do  +MODE=NO_IND +ERR_TYPE=PPB_FRM'   # test_rx_err_no_ind_comb_par_frm
 vsim -c -do 'do run.do  +MODE=NO_IND +ERR_TYPE=CHK_FRM'   # test_rx_err_no_ind_comb_chk_frm
 vsim -c -do 'do run.do  +MODE=NO_IND +ERR_TYPE=ALL'       # test_rx_err_no_ind_comb_all
*/



