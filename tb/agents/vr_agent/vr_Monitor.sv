class vr_Monitor #(parameter DATA_WIDTH=32,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=1);
  
    virtual interface valid_ready_if #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) vif;
    mailbox #(vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) vr_mon_mbx;
    vr_Agent_config #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) cfg; 
    
    function new( virtual interface valid_ready_if #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)  vif,
                  mailbox #(vr_Transaction#( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) vr_mon_mbx,
                  vr_Agent_config #(DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) cfg);
          this.vif=vif;
          this.vr_mon_mbx=vr_mon_mbx;
          this.cfg=cfg;
    endfunction
      
    task run();
      vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) t;
      string mon_name;
      
      forever 
        begin 
          @(posedge vif.clk);
             if(vif.valid == 1'b1 && vif.ready == 1'b1)
               begin
                 mon_name = (cfg.agent_type == MASTER) ? "VR_MST_MON" : "VR_SLV_MON";
                 
                 t = new();
                 t.wdata  = vif.wdata;
                 t.rdata  = vif.rdata;
                 t.ctrl   = vif.ctrl;
                 t.addr   = vif.addr;
                 t.tx_err = vif.tx_err;
                 t.rx_err = vif.rx_err;
                 
                 $display("[%0t] [%s]  Handshake! wdata=0x%0h, rdata=0x%0h, addr=0x%0h, ctrl=%0b, tx_err=%0b, rx_err=%0b", 
                          $time, mon_name, t.wdata, t.rdata, t.addr, t.ctrl, t.tx_err, t.rx_err);
                 
                 vr_mon_mbx.put(t);
               end
        end 
    endtask
endclass





