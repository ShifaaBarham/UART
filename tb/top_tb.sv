`timescale 1ns/1ps
import tests_pkg::*;


module tb_top;
  bit clk;
  bit rst_n;

  always #5 clk = ~clk;

  // Interfaces
  valid_ready_if #(8,8,1)  vif_config(clk, rst_n);
  valid_ready_if #(32,8,1) vif_vr_tx(clk, rst_n);
  valid_ready_if #(32,8,1) vif_vr_rx(clk, rst_n);
  UART_if        #(8)      vif_uart_tx(clk, rst_n);
  UART_if        #(8)      vif_uart_rx(clk, rst_n);

  // DUT Instantiation - الربط مع مراعاة أسماء الـ Ports في الديزاين تبعك
  UART DUT (
    .clk(clk),
    .rstn(rst_n), // تأكد إذا الاسم rstn أو rst_n في الديزاين
    
    // Config IF
    .cfg_valid(vif_config.valid),
    .cfg_ready(vif_config.ready),
    .cfg_addr(vif_config.addr),
    .cfg_data_in(vif_config.wdata),  // الربط الصحيح
    .cfg_data_out(vif_config.rdata), // الربط الصحيح
    .cfg_op(vif_config.ctrl),        // الربط الصحيح (op = ctrl)
    
    // TX VR IF
    .tx_valid(vif_vr_tx.valid),
    .tx_ready(vif_vr_tx.ready),
    .tx_err(vif_vr_tx.tx_err),       // تأكد أن الـ IF فيه tx_err
    .tx_data(vif_vr_tx.wdata),
    
    // RX VR IF
    .rx_valid(vif_vr_rx.valid),
    .rx_ready(vif_vr_rx.ready),
    .rx_data(vif_vr_rx.rdata),
    .Rx_err(vif_vr_rx.rx_err),       // مخرج الخطأ من الديزاين للـ Monitor
    
    // UART Serial
    .RX(vif_uart_rx.rx), // Driver drives this
    .TX(vif_uart_tx.rx)  // Monitor monitors this (DUT TX -> Monitor RX)
  );

  // Reset Sequence
  initial begin
    rst_n = 1;
    #15 rst_n = 0;
    #30 rst_n = 1;
  end

  initial begin
    test_reg_rw_access test; // أو أي تست فرعي 
    test = new(vif_config, vif_vr_tx, vif_vr_rx, vif_uart_tx, vif_uart_rx);
    test.run();
  end

endmodule