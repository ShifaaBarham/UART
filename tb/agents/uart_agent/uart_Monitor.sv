class Monitor #(parameter DATA_WIDTH=8);
  
  
    virtual interface UART_if #( DATA_WIDTH) vif;
    mailbox #(Trans #( DATA_WIDTH)) mon_mbx;
    Agent_config #( DATA_WIDTH) cfg;

      
    function new( virtual interface UART_if #( DATA_WIDTH)  vif,
                  mailbox #(Trans#( DATA_WIDTH)) mon_mbx,
                  Agent_config #( DATA_WIDTH) cfg);
      
          this.vif=vif;
          this.mon_mbx=mon_mbx;
          this.cfg=cfg; 
      endfunction
      
    task run();
      Trans #( DATA_WIDTH) t;
      int unsigned clks_per_bit;
      int unsigned half_clks;
      int total_bytes = DATA_WIDTH / 8;
      logic [7:0] current_byte;
      logic expected_parity;

        wait(vif.rst == 0);
        clks_per_bit = cfg.get_clks_per_bit();
        half_clks = clks_per_bit / 2;
      
      forever 
        begin 
            t = new();
            t.detect_parity_err = 0; 
            t.detect_checksum_err = 0;
            t.detect_framing_err = 0;
          
          repeat(half_clks) @(posedge vif.clk);
            if (vif.rx !== 0) continue;
            
          repeat(clks_per_bit) @(posedge vif.clk);
          
          begin 
            
          for (int byte_idx=0; byte_idx < total_bytes; byte_idx++)
            begin
                    
              for(int bit_indx=0; bit_indx < 8; bit_indx++) 
                    begin
                      current_byte[bit_indx] = vif.rx;
                        repeat(clks_per_bit) @(posedge vif.clk);
                    end
              
                    t.data[(byte_idx*8) +: 8] = current_byte;
                    
                    if (cfg.parity_typee != NONE) 
                      begin

                        if(cfg.parity_typee == EVEN) expected_parity = ^current_byte;
                        else expected_parity = ~^current_byte;
                        
                        if (vif.rx !== expected_parity)
                          begin
                            t.detect_parity_err = 1;
                        end
                        repeat(clks_per_bit) @(posedge vif.clk);
                  
                      
                      end
               
            end
          
          end
            //checksum
            t.calc_checksum(); 
            if (vif.rx !== t.checksum) 
              begin
                t.detect_checksum_err = 1;
            end
            t.checksum = vif.rx; 
            repeat(clks_per_bit) @(posedge vif.clk);
            //stop bit
          
            for (int s=0; s < cfg.stop_bits; s++)
              begin
                if (vif.rx !== 1) t.detect_framing_err = 1; 
                repeat(clks_per_bit) @(posedge vif.clk);
            end
            
            mon_mbx.put(t);
        end 
    endtask
endclass