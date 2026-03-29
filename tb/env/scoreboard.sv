   class scoreboard;

        mailbox #(vr_Transaction)   mbx_config;
        mailbox #(vr_Transaction)   mbx_vr_tx;
        mailbox #(vr_Transaction)   mbx_vr_rx;
        mailbox #(uart_Transaction) mbx_uart_tx;
        mailbox #(uart_Transaction) mbx_uart_rx;

        bit soft_reset_n = 1; // Active Low -> 1 : normal operation, 0 : reset
        bit [7:0] tx_config = 8'h00; // Default 0x14
        bit [7:0] rx_config = 8'h01; // Default 0x24
        
                int unsigned tx_count = 0;
                int unsigned tx_err_count = 0;
                int unsigned rx_count = 0;
                int unsigned rx_err_count = 0;

                function new();
                endfunction

            task run();
                $display("[%0t] [SCOREBOARD] Started", $time);
                
                fork
                monitor_config();
                check_tx_path();
                check_rx_path();
                join_none
            endtask

        task monitor_config();
            vr_Transaction cfg_trans;
            forever begin
            mbx_config.get(cfg_trans);
            
            if (cfg_trans.ctrl == 1) begin 
                case (cfg_trans.addr)
                8'h04: begin
                    soft_reset_n = cfg_trans.wdata[0];
                    if (soft_reset_n == 0) begin
                    $display("[%0t] [SCB] SOFT RESET DETECTED! Clearing Counters.", $time);
                    clear_counters();
                    end
                end
                8'h14: tx_config = cfg_trans.wdata;
                8'h24: rx_config = cfg_trans.wdata;
                endcase
            end
            
            else if (cfg_trans.ctrl == 0) begin
            end
            end
        endtask

        task check_tx_path();
            vr_Transaction   vr_in;
            uart_Transaction uart_out;
            forever begin
            mbx_vr_tx.get(vr_in);
            
            mbx_uart_tx.get(uart_out);
            
        
            if (soft_reset_n == 1) begin
                tx_count++; 
                
                if (vr_in.wdata == uart_out.data) begin
                    $display("[%0t] [SCB-TX] PASS: Data matched %0h", $time, vr_in.wdata);
                end else begin
                    $error("[%0t] [SCB-TX] FAIL: VR in: %0h, UART out: %0h", $time, vr_in.wdata, uart_out.data);
                end

        
            end
            end
        endtask

        task check_rx_path();
            uart_Transaction uart_in;
            vr_Transaction   vr_out;
            bit has_error;

            forever begin
            mbx_uart_rx.get(uart_in);
            
            has_error = check_for_rx_errors(uart_in); 

            if (rx_config[5:4] == 2'b00 && has_error) begin
                if (soft_reset_n == 1) begin
                    rx_count++;
                    rx_err_count++;
                end
                $display("[%0t] [SCB-RX] Error dropped by design as configured.", $time);
            end 
            else begin
                mbx_vr_rx.get(vr_out);
                
                if (soft_reset_n == 1) begin
                    rx_count++;
                    if (has_error) rx_err_count++;

                    if (uart_in.data == vr_out.rdata) begin
                        $display("[%0t] [SCB-RX] PASS: Data matched %0h", $time, uart_in.data);
                    end else begin
                        $error("[%0t] [SCB-RX] FAIL: UART in: %0h, VR out: %0h", $time, uart_in.data, vr_out.rdata);
                    end
                end
            end
            end
        endtask

                function void clear_counters();
                    tx_count = 0;
                    tx_err_count = 0;
                    rx_count = 0;
                    rx_err_count = 0;
                endfunction

        function bit check_for_rx_errors(uart_Transaction t);
            return 0; 
        endfunction

        endclass