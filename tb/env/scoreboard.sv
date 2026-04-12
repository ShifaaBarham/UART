class scoreboard;


        mailbox #(vr_Transaction #(8,8,1))   mbx_config;
        mailbox #(vr_Transaction #(32,8,1))  mbx_vr_tx;
      mailbox #(vr_Transaction #(32,8,1))  mbx_vr_rx;
        mailbox #(uart_Transaction #(8))     mbx_uart_tx;
        mailbox #(uart_Transaction #(8))     mbx_uart_rx;
        bit soft_reset_n = 1; 
        bit [7:0] tx_config = 8'h18; 
    bit [7:0] rx_config = 8'h08; 

      bit [15:0] tx_count = 16'h0000;
      bit [7:0]  tx_err_count = 8'h00;
      bit [15:0] rx_count = 16'h0000;
      bit [7:0]  rx_err_count = 8'h00;

    //Internal FIFOs 
   vr_Transaction #(32,8,1)   expected_vr_rx_q[$];
  uart_Transaction #(8)      expected_uart_tx_q[$];

      function new();
      endfunction

          task run();
              $display("[%0t] [SCOREBOARD] Started Successfully", $time);
              fork
                  monitor_config();
                  predict_tx();
                  compare_tx();
                  predict_rx();
                  compare_rx();
              join_none
          endtask

  task monitor_config();
        vr_Transaction #(8,8,1) cfg_trans;
        forever begin
            mbx_config.get(cfg_trans);
            
            if (cfg_trans.ctrl == 1) begin 
                // write op
                case (cfg_trans.addr)
                    8'h04: begin
                        soft_reset_n = cfg_trans.wdata[0];
                        if (soft_reset_n == 0) begin
                            $display("[%0t] [SCB-CFG] SOFT RESET Asserted! Flushing Data Queues.", $time);
                            expected_uart_tx_q.delete(); 
                            expected_vr_rx_q.delete();   
                        end else begin
                            $display("[%0t] [SCB-CFG] SOFT RESET De-asserted!", $time);
                        end
                    end
                    8'h14: begin 
                        tx_config = cfg_trans.wdata;
                        $display("[%0t] [SCB-CFG] TX Config updated to: 0x%0h", $time, tx_config);
                    end
                    8'h24: begin 
                        rx_config = cfg_trans.wdata;
                        $display("[%0t] [SCB-CFG] RX Config updated to: 0x%0h", $time, rx_config);
                    end
                endcase
            end 
            else if (cfg_trans.ctrl == 0) begin 
                case (cfg_trans.addr)
                  
                    8'h14: begin
                        if (cfg_trans.rdata == tx_config) 
                            $display("[%0t] [SCB-CFG] PASS: TX Config Read = 0x%0h", $time, cfg_trans.rdata);
                        else 
                            $error("[%0t] [SCB-CFG] FAIL: TX Config Read Mismatch! Exp: 0x%0h, Act: 0x%0h", $time, tx_config, cfg_trans.rdata);
                    end
                    8'h24: begin
                        if (cfg_trans.rdata == rx_config) 
                            $display("[%0t] [SCB-CFG] PASS: RX Config Read = 0x%0h", $time, cfg_trans.rdata);
                        else 
                            $error("[%0t] [SCB-CFG] FAIL: RX Config Read Mismatch! Exp: 0x%0h, Act: 0x%0h", $time, rx_config, cfg_trans.rdata);
                    end

                    8'h18: check_and_clear_lsb("TX_CNT_LSB", tx_count, bit'(cfg_trans.rdata[7:0]));
                    8'h1A: check_and_clear_msb("TX_CNT_MSB", tx_count, bit'(cfg_trans.rdata[7:0]));
                    8'h1C: check_and_clear_8bit("TX_ERR_CNT", tx_err_count, bit'(cfg_trans.rdata[7:0]));
                    8'h28: check_and_clear_lsb("RX_CNT_LSB", rx_count, bit'(cfg_trans.rdata[7:0]));
                    8'h2A: check_and_clear_msb("RX_CNT_MSB", rx_count, bit'(cfg_trans.rdata[7:0]));
                    8'h2C: check_and_clear_8bit("RX_ERR_CNT", rx_err_count, bit'(cfg_trans.rdata[7:0]));
                endcase
            end
        end
    endtask

  
  
   task predict_tx();
     
     
         endtask

     task compare_tx();

     endtask
  
  
      task predict_rx();
      endtask
  
      task compare_rx();
      endtask
    function void check_and_clear_8bit(string name, ref bit [7:0] my_count, input bit [7:0] actual_rdata);
        bit [7:0] exp = my_count; 
        if (actual_rdata == exp) begin
            $display("[%0t] [SCB-COR] PASS: %s Read. Expected %0d, Actual %0d.", $time, name, exp, actual_rdata);
        end else begin
            $error("[%0t] [SCB-COR] FAIL: %s Mismatch! Expected %0d, Actual %0d.", $time, name, exp, actual_rdata);
        end 
        my_count = 8'h00; 
    endfunction

    function void check_and_clear_lsb(string name, ref bit [15:0] my_count, input bit [7:0] actual_rdata);
        bit [7:0] exp_lsb = my_count[7:0]; 
        if (actual_rdata == exp_lsb) begin
            $display("[%0t] [SCB-COR] PASS: %s Read. Expected %0d, Actual %0d.", $time, name, exp_lsb, actual_rdata);
        end else begin
            $error("[%0t] [SCB-COR] FAIL: %s Mismatch! Expected %0d, Actual %0d.", $time, name, exp_lsb, actual_rdata);
        end
        my_count[7:0] = 8'h00; 
    endfunction

    function void check_and_clear_msb(string name, ref bit [15:0] my_count, input bit [7:0] actual_rdata);
        bit [7:0] exp_msb = my_count[15:8]; 
        if (actual_rdata == exp_msb) begin
            $display("[%0t] [SCB-COR] PASS: %s Read. Expected %0d, Actual %0d.", $time, name, exp_msb, actual_rdata);
        end else begin
            $error("[%0t] [SCB-COR] FAIL: %s Mismatch! Expected %0d, Actual %0d.", $time, name, exp_msb, actual_rdata);
        end
        my_count[15:8] = 8'h00; 
    endfunction
endclass