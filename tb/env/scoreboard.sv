class scoreboard;

  mailbox #(vr_Transaction)   mbx_config;  
  
  mailbox #(vr_Transaction)   mbx_vr_tx;    // 32-bit Expected Data
  mailbox #(uart_Transaction) mbx_uart_tx;  // 32-bit Actual Serial Data
  
  mailbox #(uart_Transaction) mbx_uart_rx;  // 32-bit Expected Serial Data
  mailbox #(vr_Transaction)   mbx_vr_rx;    // 32-bit Actual Data


  bit [7:0] tx_cfg_reg = 8'h00; 
  bit [7:0] rx_cfg_reg = 8'h00;
  bit       is_soft_reset = 0;  

  function new();
    mbx_config  = new();
    mbx_vr_tx   = new();
    mbx_uart_tx = new();
    mbx_uart_rx = new();
    mbx_vr_rx   = new();
  endfunction

  task run();
    $display("[%0t] [SCOREBOARD] Active...", $time);
    fork
      track_config();
      check_tx_path();
      check_rx_path();
    join_none
  endtask

  
  task track_config();
    vr_Transaction cfg_trans;
    forever begin
      mbx_config.get(cfg_trans);
      
      if (cfg_trans.we == 1) begin 
        case (cfg_trans.addr)
          8'h04: begin
            is_soft_reset = cfg_trans.data[0];
            $display("[%0t] [SCOREBOARD-CFG] Soft Reset set to: %0b", $time, is_soft_reset);
            if (is_soft_reset) flush_all_mailboxes();
          end
          
          // TX Config
          8'h14: begin
            tx_cfg_reg = cfg_trans.data;
            $display("[%0t] [SCOREBOARD-CFG] TX Config updated: %0h", $time, tx_cfg_reg);
          end
          
          // RX Config
          8'h24: begin
            rx_cfg_reg = cfg_trans.data;
            $display("[%0t] [SCOREBOARD-CFG] RX Config updated: %0h", $time, rx_cfg_reg);
          end
        endcase
      end
    end
  endtask

 
  task check_tx_path();
    vr_Transaction   exp_tx;
    uart_Transaction act_tx;
    
    forever begin
      mbx_vr_tx.get(exp_tx);
      mbx_uart_tx.get(act_tx);
      
      if (is_soft_reset) continue; 

      if(exp_tx.data == act_tx.data) begin
        $display("[%0t] [SCB-TX] PASS! Data: %0h", $time, exp_tx.data);
      end else begin
        $error("[%0t] [SCB-TX] FAIL! Exp: %0h | Act: %0h", $time, exp_tx.data, act_tx.data);
      end
    end
  endtask


  task check_rx_path();
    uart_Transaction exp_rx;
    vr_Transaction   act_rx;
    
    forever begin
      mbx_uart_rx.get(exp_rx);
      
      if (is_soft_reset) continue;

      
      if (exp_rx.has_error && rx_cfg_reg[5:4] == 2'b00) begin
         $display("[%0t] [SCB-RX] Error Detected & Mode is DROP. Ignoring data.", $time);
         continue;
      end

      mbx_vr_rx.get(act_rx);
      
      if(exp_rx.data == act_rx.data) begin
        $display("[%0t] [SCB-RX] PASS! Data: %0h", $time, act_rx.data);
      end else begin
        $error("[%0t] [SCB-RX] FAIL! Exp: %0h | Act: %0h", $time, exp_rx.data, act_rx.data);
      end
    end
  endtask


  function void flush_all_mailboxes();
    vr_Transaction   dummy_vr;
    uart_Transaction dummy_uart;
    while(mbx_vr_tx.try_get(dummy_vr));
    while(mbx_uart_tx.try_get(dummy_uart));
    while(mbx_uart_rx.try_get(dummy_uart));
    while(mbx_vr_rx.try_get(dummy_vr));
    $display("[%0t] [SCOREBOARD] All Queues Flushed due to Soft Reset!", $time);
  endfunction

endclass