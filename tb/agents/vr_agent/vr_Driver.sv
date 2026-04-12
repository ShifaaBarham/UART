class vr_Driver #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8) ;
  
  
     virtual interface valid_ready_if #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)  vif;
     mailbox #(vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) vr_drv_mbx;
     vr_Agent_config #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) cfg;
    
    
       function new( virtual interface valid_ready_if #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) vif, 
                     mailbox #(vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) vr_drv_mbx,
                     vr_Agent_config #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) cfg);
            this.vif=vif;
            this.vr_drv_mbx=vr_drv_mbx;
            this.cfg=cfg;
      
      endfunction
      
    task run();
      vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) t;
       
      if(cfg.agent_type==MASTER)
        begin 
          vif.valid = 0;
      vif.wdata  = '0;
      vif.ctrl  = '0;
      vif.addr  = '0;
        end
     else 
        vif.ready  = 0;

    
      forever 
        begin
         vr_drv_mbx.get(t);

          if(cfg.agent_type==MASTER)
            begin
                 @(posedge vif.clk);
                 
                  vif.wdata<=t.wdata;
                  vif.ctrl<=t.ctrl;
                  vif.addr<=t.addr;
                  repeat(t.valid_delay) @(posedge vif.clk);
                    vif.valid<=1;
              do begin 
                @(posedge vif.clk);
                end
              while(vif.ready ==0) ;
              //@(posedge vif.clk);//لازم تنحذف لأنه ع الأغلب رح تسببلي مشكلة لأنها بتخلي الفاليد تضل 1 بعد ما الريدي يجي 1

                vif.valid<=0;
            end
         
          else 
            begin
              vif.ready<=0;
              repeat(t.ready_delay) @(posedge vif.clk);
             
             vif.ready<=1;

              while (vif.valid==0)
                begin 
                 @(posedge vif.clk);
                  vif.ready<=1;
                end
              @(posedge vif.clk);
              
              vif.ready<=0;
              
            end 
        
      end 
    endtask
  
endclass