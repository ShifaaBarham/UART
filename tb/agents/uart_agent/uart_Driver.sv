class Driver #(parameter DATA_WIDTH=8) ;
  
  
     virtual interface UART_if #( DATA_WIDTH)  vif;
     mailbox #(Trans#( DATA_WIDTH)) drv_mbx;
     Agent_config #( DATA_WIDTH) cfg;
    
       
   
       function new( virtual interface UART_if #( DATA_WIDTH) vif, 
                     mailbox #(Trans #( DATA_WIDTH)) drv_mbx,
                     Agent_config #( DATA_WIDTH) cfg);
         
            this.vif=vif;
            this.drv_mbx=drv_mbx;
            this.cfg=cfg;
      
      endfunction
      
    task run();
      Trans #( DATA_WIDTH) t;
      int total_bytes=DATA_WIDTH/8;
      logic [7:0] current_byte;
      logic calc_parity;
      
      wait(vif.rst ==0);
      vif.tx=1;

     forever 
        begin
           
          if(cfg.agent_type==MASTER)
            begin
              
          drv_mbx.get(t);
          
          repeat(t.tx_delay)  @(posedge vif.clk);
              
          vif.tx=0;
          repeat (cfg.get_clks_per_bit()) @(posedge vif.clk);
              
              
          begin
            for (int byte_idx=0; byte_idx < total_bytes; byte_idx++) begin
                        current_byte = t.data[(byte_idx*8) +: 8];
              
            for(int bit_index=0;bit_index<8;bit_index++)
            begin
                 vif.tx = t.data[(byte_idx*8) + bit_index];
              repeat (cfg.get_clks_per_bit()) @(posedge vif.clk);
            end
            
          
            if(cfg.parity_typee !=NONE)begin
              if(cfg.parity_typee ==EVEN) calc_parity=^current_byte;
              else 
                calc_parity= ~^current_byte;
              
              if(t.inject_parity_err)vif.tx= ~calc_parity;
              else
                vif.tx=calc_parity;
              
              repeat (cfg.get_clks_per_bit()) @(posedge vif.clk);
              
              
            end
             
            end 
      end 
              
              //send checksum
              t.calc_checksum();
              if(t.inject_checksum_err)
                 vif.tx=~t.checksum;
              else
                 vif.tx=t.checksum;
              repeat (cfg.get_clks_per_bit()) @(posedge vif.clk);
              
              //sed stop bit(s)
              for(int s=0;s<cfg.stop_bits;s++)
                begin
                  if(t.inject_framing_err)
                    vif.tx=0;
                  else
                    vif.tx=1;
                repeat (cfg.get_clks_per_bit()) @(posedge vif.clk);
 
                end
              
            end
          else
            @(posedge vif.clk);
        end
              
    endtask
  
endclass