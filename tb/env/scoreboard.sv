
import uart_agent_pkg::*;
import vr_agent_pkg::*;
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
     
    join_none
  endtask

  

 


  



endclass