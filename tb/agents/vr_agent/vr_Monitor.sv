class vr_Monitor #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8);
  
  
    virtual interface valid_ready_if #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) vif;
    mailbox #(vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) vr_mon_mbx;
    
    function new( virtual interface valid_ready_if #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)  vif,
                  mailbox #(vr_Transaction#( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) vr_mon_mbx);
      
          this.vif=vif;
          this.vr_mon_mbx=vr_mon_mbx;
      endfunction
      
    task run();
      vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) t;
      forever 
        begin 
          @(posedge vif.clk);
             if(vif.valid==1 && vif.ready==1)
               begin
                 t=new();
                 t.wdata = vif.wdata;
                 t.rdata = vif.rdata;
                 t.ctrl=vif.ctrl;
                 t.addr=vif.addr;
                 t.tx_err = vif.tx_err;
                 t.rx_err = vif.rx_err;
                 vr_mon_mbx.put(t);
               end
             
           end 
        
      
    endtask
    
    
endclass 