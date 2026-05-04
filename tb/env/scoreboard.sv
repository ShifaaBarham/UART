class scoreboard;

    mailbox #(vr_Transaction #(8,8,1))   mbx_config;
    mailbox #(vr_Transaction #(32,8,1))  mbx_vr_tx;
    mailbox #(vr_Transaction #(32,8,1))  mbx_vr_rx;
    mailbox #(uart_Transaction #(32))     mbx_uart_tx;
    mailbox #(uart_Transaction #(32))     mbx_uart_rx;
    //colloision mode variables
int total_expected_counts = 0; 
int total_read_counts = 0;   //total number of scb reads from the dut
bit collision_test_mode = 0; //activate collision mode test 



    bit soft_reset_n = 1; 
    bit [7:0] tx_config = 8'h18; // Default 0x14 (Mode 3)
    bit [7:0] rx_config = 8'h08; // Default 0x24 (Mode 1)
    
    bit [15:0] tx_count = 16'h0000;
    bit [7:0]  tx_err_count = 8'h00;
    bit [15:0] rx_count = 16'h0000;
    bit [7:0]  rx_err_count = 8'h00;

    bit disable_checking = 0; // Can be set by test to ignore scoreboard checking during certain phases
    bit force_rx_drop    = 0; //

    //Internal FIFOs 
    vr_Transaction #(32,8,1)   expected_vr_rx_q[$];
    uart_Transaction #(32)      expected_uart_tx_q[$];
    int unread_packets = 0;
    function new();
    endfunction

    function void hard_reset();
        tx_config = 8'h18;
        rx_config = 8'h08;
        tx_count = 16'h0000;
        tx_err_count = 8'h00;
        rx_count = 16'h0000;
        rx_err_count = 8'h00;
        soft_reset_n = 1;
        disable_checking = 0;
        force_rx_drop = 0;
        expected_vr_rx_q.delete();
        expected_uart_tx_q.delete();
        $display("[%0t] [SCOREBOARD] HARD RESET APPLIED. Registers back to defaults.", $time);
    endfunction

    function void flush_queues();
        expected_vr_rx_q.delete();
        expected_uart_tx_q.delete();
        $display("[%0t] [SCOREBOARD] QUEUES FLUSHED by Test.", $time);
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

    // 1. Config Monitor (Read/Write, Soft Reset & Clear-on-Read Logic)
    task monitor_config();
        vr_Transaction #(8,8,1) cfg_trans;
        forever begin
            mbx_config.get(cfg_trans);
            
            if (cfg_trans.ctrl == 1) begin 
                //  WRITE OPERATIONS 
                case (cfg_trans.addr)
                    8'h04: begin
                        soft_reset_n = cfg_trans.wdata[0];
                        if (soft_reset_n == 0) begin
                            $display("[%0t] [SCB-CFG] SOFT RESET Asserted! Flushing Data Queues (Counters persist).", $time);
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
                //READ OPERATIONS (CLEAR ON READ & COLLISION TOLERANCE)
                
                if (!disable_checking) begin
                
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

                        8'h18: check_and_clear_lsb("TX_CNT_LSB", tx_count, cfg_trans.rdata);
                        8'h1A: check_and_clear_msb("TX_CNT_MSB", tx_count, cfg_trans.rdata);
                        8'h1C: check_and_clear_8bit("TX_ERR_CNT", tx_err_count, cfg_trans.rdata);
                        8'h28: check_and_clear_lsb("RX_CNT_LSB", rx_count, cfg_trans.rdata);
                        8'h2A: check_and_clear_msb("RX_CNT_MSB", rx_count, cfg_trans.rdata);
                        8'h2C: check_and_clear_8bit("RX_ERR_CNT", rx_err_count, cfg_trans.rdata);
                    endcase
                    
                end
            end
        end
    endtask

    // 2. TX Predictor (Error Injection & Config Handling)
    task predict_tx();
        vr_Transaction #(32,8,1) vr_in;
        uart_Transaction #(32) expected_uart;
        bit calc_parity;
        bit ppb_en, is_even;
        bit [1:0] mode;

        forever begin
            mbx_vr_tx.get(vr_in); 
            if (soft_reset_n == 1) begin
                
                ppb_en  = tx_config[0];
                mode    = tx_config[4:3];
                is_even = (tx_config[5] == 1'b0);
                
                expected_uart = new();
                expected_uart.data = vr_in.wdata; 
                expected_uart.inject_parity_err = 0; 
                expected_uart.inject_checksum_err = 0;
                if (is_even) calc_parity = ^vr_in.wdata;
                else         calc_parity = ~(^vr_in.wdata);

                if (vr_in.tx_err == 1'b1) begin// Test intends to inject an error in this transaction
                    if (tx_err_count == 8'hFF) begin
                        tx_err_count = 8'h80; 
                        end else begin
                            tx_err_count++; 
                        end

                    if (mode == 2'b00) begin
                        // Mode 0: Drop Transaction
                        $display("[%0t] [SCB-TX] Mode 0 Drop Triggered. Packet destroyed internally.", $time);
                        continue; 
                    end 
                    else if (mode == 2'b01) begin
                        // Mode 1: Flip Total Parity
                        calc_parity = ~calc_parity;
                        expected_uart.inject_checksum_err = 1;
                    end
                    else if (mode == 2'b10) begin
                        // Mode 2: Flip Byte Parity
                        if (ppb_en) $display("[%0t] [SCB-TX] Mode 2: Byte Parity Flipped.", $time);
                        expected_uart.inject_parity_err = 1;
                    end
                    else if (mode == 2'b11) begin
                        // Mode 3: Flip All
                        calc_parity = ~calc_parity;
                        expected_uart.inject_checksum_err = 1;
                        if (ppb_en) expected_uart.inject_parity_err = 1;
                    end
                end

                if (tx_count == 16'hFFFF) begin
                    tx_count = 16'h8000; 
                end else begin
                    tx_count++; 
                end 
                expected_uart.checksum = calc_parity;
                expected_uart_tx_q.push_back(expected_uart);
            end
        end
    endtask

    // 3. TX Comparator
    task compare_tx();
        uart_Transaction #(32) actual_uart;
        uart_Transaction #(32) exp_uart;
        forever begin
            mbx_uart_tx.get(actual_uart); 
            if (soft_reset_n == 1 && !disable_checking) begin
                wait(expected_uart_tx_q.size() > 0);
                if (expected_uart_tx_q.size() > 0) begin
                    exp_uart = expected_uart_tx_q.pop_front(); 
                    
                    if (exp_uart.data == actual_uart.data && 
                        exp_uart.inject_parity_err == actual_uart.detect_parity_err && 
                        exp_uart.inject_checksum_err == actual_uart.detect_checksum_err) begin
                        
                        $display("[%0t] [SCB-TX] PASS: Data & Frame Format Matched! (Parity_Err=%0b, Checksum_Err=%0b)", 
                                $time, actual_uart.detect_parity_err, actual_uart.detect_checksum_err);
                                
                    end else begin
                        $error("[%0t] [SCB-TX] FAIL: Exp[Data=0x%0h, ParErr=%0b, ChkErr=%0b] | Act[Data=0x%0h, ParErr=%0b, ChkErr=%0b]", 
                            $time, exp_uart.data, exp_uart.inject_parity_err, exp_uart.inject_checksum_err, 
                            actual_uart.data, actual_uart.detect_parity_err, actual_uart.detect_checksum_err);
                    end
                end else begin
                    $error("[%0t] [SCB-TX] FAIL: Unexpected TX Output from DUT! Expected queue is empty.", $time);
                end
            end
        end
    endtask

    // 4. RX Predictor 
    task predict_rx();
        uart_Transaction #(32) uart_in;
        vr_Transaction #(32,8,1) exp_vr;
        bit total_error; //flag to indicate if any error is detected in the incoming UART transaction
        bit [1:0] mode;

        forever begin
            mbx_uart_rx.get(uart_in); 
            if (soft_reset_n == 1) begin
                
                mode = rx_config[4:3];

                if (force_rx_drop) begin
                     if (rx_err_count == 8'hFF) begin
                            rx_err_count = 8'h80; 
                        end else begin
                            rx_err_count++; 
                        end
                    continue; 
                end

                total_error = uart_in.detect_parity_err | uart_in.detect_framing_err | uart_in.detect_checksum_err;
                if (unread_packets == 1) begin
                        $display("[%0t] [SCB-PREDICT] Overrun Detected! Expecting packet to be dropped and error incremented.", $time);
                       if (rx_err_count == 8'hFF) begin
                            rx_err_count = 8'h80; 
                        end else begin
                            rx_err_count++;  
                        end
                        continue; 
                    end
                if (total_error) begin
                     if (rx_err_count == 8'hFF) begin
                            rx_err_count = 8'h80; 
                        end else begin
                            rx_err_count++;  
                        end
                    
                    if (mode == 2'b00) begin
                        // Mode 0: Drop
                        $display("[%0t] [SCB-RX] Mode 0 Drop. Corrupted RX frame dropped internally.", $time);
                        continue; 
                    end 
                end

                if (rx_count == 16'hFFFF) begin
                            rx_count = 16'h8000;
                        end else begin
                            rx_count++; 
                        end
                unread_packets++;
                exp_vr = new();
                exp_vr.rdata = uart_in.data;
                
                if (total_error && mode == 2'b01) begin
                    exp_vr.rx_err = 1'b1; // Pass with indication
                end else begin
                    exp_vr.rx_err = 1'b0; // Pass without indication
                end

                expected_vr_rx_q.push_back(exp_vr);
            end
        end
    endtask

    // 5. RX Comparator
    task compare_rx();
        vr_Transaction #(32,8,1) actual_vr;
        vr_Transaction #(32,8,1) exp_vr;
        forever begin
            mbx_vr_rx.get(actual_vr); 
            if (soft_reset_n == 1 && !disable_checking) begin
                if (expected_vr_rx_q.size() > 0) begin
                    exp_vr = expected_vr_rx_q.pop_front();
                    unread_packets--;
                    if (exp_vr.rdata == actual_vr.rdata && exp_vr.rx_err == actual_vr.rx_err) begin
                        $display("[%0t] [SCB-RX] PASS: Data=0x%0h, rx_err=%0b", $time, actual_vr.rdata, actual_vr.rx_err);
                        
                    end else begin
                        $error("[%0t] [SCB-RX] FAIL: Mismatch! Exp[Data=0x%0h, Err=%0b] | Act[Data=0x%0h, Err=%0b]", 
                               $time, exp_vr.rdata, exp_vr.rx_err, actual_vr.rdata, actual_vr.rx_err);
                    end
                end else begin
                    $error("[%0t] [SCB-RX] FAIL: Unexpected RX Output on VR bus! Expected queue is empty.", $time);
                end
            end
        end
    endtask



    function void check_and_clear_8bit(string name, ref bit [7:0] my_count, input bit [7:0] actual_rdata);
          bit [7:0] exp = my_count;
        if (collision_test_mode) begin
            // collision mode: just accumulate without checking
            total_read_counts += actual_rdata;
            my_count = 8'h00; // clear the counter after reading
            return; 
        end
        
        // normal mode: check against expected count and then clear
       
        if (actual_rdata == exp) begin
            $display("[%0t] [SCB-COR] PASS: %s Read. Expected %0d, Actual %0d.", $time, name, exp, actual_rdata);
        end else begin
            $error("[%0t] [SCB-COR] FAIL: %s Mismatch! Expected %0d, Actual %0d.", $time, name, exp, actual_rdata);
        end 
        my_count = 8'h00; 
    endfunction




    function void check_and_clear_lsb(string name, ref bit [15:0] my_count, input bit [7:0] actual_rdata);
        bit [7:0] exp_lsb = my_count[7:0]; 
        if (collision_test_mode) begin
            // collision mode: just accumulate without checking
            total_read_counts += actual_rdata;
            my_count[7:0] = 8'h00;
            return;
        end
        
        
        if (actual_rdata == exp_lsb) begin
            $display("[%0t] [SCB-COR] PASS: %s Read. Expected %0d, Actual %0d.", $time, name, exp_lsb, actual_rdata);
        end else begin
            $error("[%0t] [SCB-COR] FAIL: %s Mismatch! Expected %0d, Actual %0d.", $time, name, exp_lsb, actual_rdata);
        end
        my_count[7:0] = 8'h00; 
    endfunction

    function void check_and_clear_msb(string name, ref bit [15:0] my_count, input bit [7:0] actual_rdata);
         bit [7:0] exp_msb = my_count[15:8]; 
        if (collision_test_mode) begin
            // collision mode: just accumulate without checking
            total_read_counts += actual_rdata;
            my_count[15:8] = 8'h00;
            return;
        end
        
       
        if (actual_rdata == exp_msb) begin
            $display("[%0t] [SCB-COR] PASS: %s Read. Expected %0d, Actual %0d.", $time, name, exp_msb, actual_rdata);
        end else begin
            $error("[%0t] [SCB-COR] FAIL: %s Mismatch! Expected %0d, Actual %0d.", $time, name, exp_msb, actual_rdata);
        end
        my_count[15:8] = 8'h00; 
    endfunction



   /*  function void check_and_clear_8bit(string name, ref bit [7:0] my_count, input bit [7:0] actual_rdata);
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
    endfunction*/
endclass