class VR_Agent #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8) ;
  
  Driver #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) drv;
  Monitor #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) mon;
  vr_Agent_config #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) agent_config;
  
  mailbox #(vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) vr_drv_mbx;
  mailbox #(vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) vr_mon_mbx;
  
  function new(vr_Agent_config #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) agent_config,
     mailbox #(vr_Transaction #( DATA_WIDTH,ADDRESS_WIDTH, CTRL_WIDTH)) vr_drv_mbx, 
     mailbox #(vr_Transaction #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) vr_mon_mbx );
    
        this.agent_config=agent_config;
        this.vr_drv_mbx=vr_drv_mbx;
        this.vr_mon_mbx=vr_mon_mbx;

        mon=new(agent_config.vif,vr_mon_mbx);

        if(agent_config.is_active == 1)
          drv=new(agent_config.vif , vr_drv_mbx,agent_config);    
  endfunction 
      
      task run();
         fork
           mon.run();
           if(agent_config.is_active == 1)
            drv.run();
         join_none
        
    endtask

endclass