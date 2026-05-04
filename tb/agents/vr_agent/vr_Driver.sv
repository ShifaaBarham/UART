class vr_Driver #(parameter DATA_WIDTH=32 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=1) ;
  
               int wait_cycles = 0; // متغير مؤقت

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
      vif.tx_err = '0;
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
                  vif.tx_err <= t.tx_err;
                  repeat(t.valid_delay) @(posedge vif.clk);
                    vif.valid<=1;
              
              do begin 
                @(posedge vif.clk);
                wait_cycles++;
                if (wait_cycles % 1000 == 0) begin
                    $display("[%0t] [VR_DRV] Still waiting for TX_READY from DUT  Valid is HIGH. Cycles waited: %0d", $time, wait_cycles);
                end
              end
              while(vif.ready ==0) ;
              //@(posedge vif.clk);//لازم تنحذف لأنه ع الأغلب رح تسببلي مشكلة لأنها بتخلي الفاليد تضل 1 بعد ما الريدي يجي 1

                vif.valid<=0;
            end
        else begin // SLAVE
             vif.ready <= 1'b0;
             
             // 🚨 الحل السحري: نتقدم كلوك واحدة لضمان انتهاء الهاندشيك السابق
             // وإعطاء الديزاين فرصة لتحديث (تصفير) إشارة الـ valid
             @(posedge vif.clk);
             
             // ننتظر الديزاين حتى يرفع إشارة Valid لترانزاكشن جديد
             while (vif.valid == 1'b0) begin
                 @(posedge vif.clk);
             end
             
             // الآن نطبق التأخير (Delay)
             if (t.ready_delay > 0) begin
                 repeat(t.ready_delay) @(posedge vif.clk);
             end
             
             // نرفع إشارة الـ Ready لإتمام الهاندشيك
             vif.ready <= 1'b1;
             
             // ننتظر كلوك سايكل واحدة ليتم الهاندشيك الفعلي
             @(posedge vif.clk);
             
             // ننزل الـ Ready فوراً
             vif.ready <= 1'b0;
         end
      end 
    endtask
  
endclass

