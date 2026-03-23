
class UART_Agent #(parameter DATA_WIDTH=8) ;
  
  Driver #( DATA_WIDTH) drv;
  Monitor #( DATA_WIDTH) mon;
  Agent_config #( DATA_WIDTH) agent_config;
  
  virtual interface UART_if #(DATA_WIDTH) vif;
  mailbox #(Trans #( DATA_WIDTH)) drv_mbx;
  mailbox #(Trans #( DATA_WIDTH)) mon_mbx;
  
  function new(virtual interface UART_if #(DATA_WIDTH) vif,
               Agent_config #( DATA_WIDTH) agent_config,
               mailbox #(Trans #( DATA_WIDTH)) drv_mbx, 
               mailbox #(Trans #( DATA_WIDTH)) mon_mbx );
       
        this.vif = vif;
        this.agent_config=agent_config;
        this.drv_mbx=drv_mbx;
        this.mon_mbx=mon_mbx;

    mon=new(vif,mon_mbx,agent_config);

        if(agent_config.is_active == 1)
          drv=new(vif , drv_mbx,agent_config);    
  endfunction 
      
      task run();
         fork
           mon.run();
           if(agent_config.is_active == 1)
            drv.run();
         join_none
        
    endtask

endclass