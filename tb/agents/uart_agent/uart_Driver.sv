class uart_Driver #(parameter DATA_WIDTH=32) ;
  
  
     virtual interface UART_if #( DATA_WIDTH)  vif;
     mailbox #(uart_Transaction #( DATA_WIDTH)) uart_drv_mbx;
     uart_Agent_config #( DATA_WIDTH) cfg;
    
       
   
       function new( virtual interface UART_if #( DATA_WIDTH) vif, 
                     mailbox #(uart_Transaction #( DATA_WIDTH)) uart_drv_mbx,
                     uart_Agent_config #( DATA_WIDTH) cfg);
         
            this.vif=vif;
            this.uart_drv_mbx=uart_drv_mbx;
            this.cfg=cfg;
      
      endfunction
      
   task run();

            uart_Transaction #(DATA_WIDTH) t;
            int total_bytes = DATA_WIDTH/8;
            logic [7:0] current_byte;
            logic calc_parity;

            wait(vif.rst == 1);
            vif.rx = 1'b1;

            forever begin
              if(cfg.agent_type == MASTER) begin
                uart_drv_mbx.get(t);

                repeat(t.tx_delay) @(posedge vif.clk);

                // start bit
                vif.rx = 1'b0;
                repeat(cfg.get_clks_per_bit()) @(posedge vif.clk);

                // send data bytes
                for (int byte_idx = 0; byte_idx < total_bytes; byte_idx++) begin
                  current_byte = t.data[(byte_idx*8) +: 8];

                  for (int bit_index = 0; bit_index < 8; bit_index++) begin
                    vif.rx = current_byte[bit_index];
                    repeat(cfg.get_clks_per_bit()) @(posedge vif.clk);
                  end

                  // send parity only if ppb_enable=1 and parity_mode is enabled
                  if (cfg.ppb_enable) begin
                    if (cfg.parity_mode == EVEN)
                      calc_parity = ^current_byte;
                    else
                      calc_parity = ~^current_byte;

                    if (t.inject_parity_err)
                      vif.rx = ~calc_parity;
                    else
                      vif.rx = calc_parity;

                    repeat(cfg.get_clks_per_bit()) @(posedge vif.clk);
                  end
                end

                // checksum
               t.calc_checksum(cfg.parity_mode);
                if (t.inject_checksum_err)
                  vif.rx = ~t.checksum;
                else
                  vif.rx = t.checksum;

                repeat(cfg.get_clks_per_bit()) @(posedge vif.clk);

                // stop bit(s)
                for (int s = 0; s < cfg.stop_bits; s++) begin
                  if (t.inject_framing_err)
                    vif.rx = 1'b0;
                  else
                    vif.rx = 1'b1;

                  repeat(cfg.get_clks_per_bit()) @(posedge vif.clk);
                end
              end
              else begin
                @(posedge vif.clk);
              end
            end
endtask
endclass