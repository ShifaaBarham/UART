class VR_Agent #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8) ;
  
  Driver #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) drv;
  Monitor #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) mon;
  Agent_config #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) agent_config;
  
  mailbox #(Trans #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) drv_mbx;
  mailbox #(Trans #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) mon_mbx;
  
  function new(Agent_config #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH) agent_config,
     mailbox #(Trans #( DATA_WIDTH,ADDRESS_WIDTH, CTRL_WIDTH)) drv_mbx, 
     mailbox #(Trans #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)) mon_mbx );
    
        this.agent_config=agent_config;
        this.drv_mbx=drv_mbx;
        this.mon_mbx=mon_mbx;

        mon=new(agent_config.vif,mon_mbx);

        if(agent_config.is_active == 1)
          drv=new(agent_config.vif , drv_mbx,agent_config);    
  endfunction 
      
      task run();
         fork
           mon.run();
           if(agent_config.is_active == 1)
            drv.run();
         join_none
        
    endtask

endclass