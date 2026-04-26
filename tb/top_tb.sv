import tests_pkg::*;

module tb_top;
  bit clk;
  bit rst_n;

  always #868 clk = ~clk;

  // Interfaces
  valid_ready_if #(8,8,1)  vif_config(clk, rst_n);
  valid_ready_if #(32,8,1) vif_vr_tx(clk, rst_n);
  valid_ready_if #(32,8,1) vif_vr_rx(clk, rst_n);
 UART_if        #(32)     vif_uart_tx(clk, rst_n); 
  UART_if        #(32)     vif_uart_rx(clk, rst_n);

  UART DUT (
    .clk(clk),
    .rstn(rst_n), 
    
    .cfg_valid(vif_config.valid),
    .cfg_ready(vif_config.ready),
    .cfg_addr(vif_config.addr),
    .cfg_data_in(vif_config.wdata),  
    .cfg_data_out(vif_config.rdata), 
    .cfg_op(vif_config.ctrl),       
    
    // TX VR IF
    .tx_valid(vif_vr_tx.valid),
    .tx_ready(vif_vr_tx.ready),
    .tx_err(vif_vr_tx.tx_err),     
    .tx_data(vif_vr_tx.wdata),
    
    // RX VR IF
    .rx_valid(vif_vr_rx.valid),
    .rx_ready(vif_vr_rx.ready),
    .rx_data(vif_vr_rx.rdata),
    .rx_err(vif_vr_rx.rx_err),       
    
    // UART Serial
    .RX(vif_uart_rx.rx), 
    .TX(vif_uart_tx.tx)  
  );



  // Reset Sequence
 initial begin
    rst_n = 1;
    
    vif_vr_tx.valid = 0;
    vif_vr_tx.wdata = 0;
    
    #20000;       
    rst_n = 0;   
    #100000;      
    rst_n = 1;   
  end

  initial begin
    test_rx_backpressure_clean test; 
    test = new(vif_config, vif_vr_tx, vif_vr_rx, vif_uart_tx, vif_uart_rx);
    test.run();
  end
  initial begin
    wait (rst_n == 1'b1);
    
    wait (vif_uart_tx.tx == 1'b0); 
    
    fork
      begin
        time t1, t2;
        int calculated_baud_rate;
        int actual_clks_per_bit;
                t1 = $time;
        
        wait (vif_uart_tx.tx == 1'b1);
        t2 = $time;
        actual_clks_per_bit = ((t2 - t1) / 1736) / 2; 
        calculated_baud_rate = 576000 / actual_clks_per_bit;
       
        $display("=================================================");
        $display("DUT clks_per_bit = %0d", actual_clks_per_bit);
        $display(" Calculated Baud Rate = %0d", calculated_baud_rate);
        $display("=================================================");
      end
    join_none
  end

endmodule