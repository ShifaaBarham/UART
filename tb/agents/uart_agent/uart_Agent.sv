
class UART_Agent #(parameter DATA_WIDTH=32) ;
  
  uart_Driver #( DATA_WIDTH) drv;
  uart_Monitor #( DATA_WIDTH) mon;
  uart_Agent_config #( DATA_WIDTH) agent_config;
  

  mailbox #(uart_Transaction #( DATA_WIDTH)) uart_drv_mbx;
  mailbox #(uart_Transaction #( DATA_WIDTH)) uart_mon_mbx;
  
  function new(
               uart_Agent_config #( DATA_WIDTH) agent_config,
               mailbox #(uart_Transaction #( DATA_WIDTH)) uart_mon_mbx,
               mailbox #(uart_Transaction #( DATA_WIDTH)) uart_drv_mbx = null // Optional for monitor-only agents
 );
       
        this.agent_config=agent_config;
        this.uart_drv_mbx=uart_drv_mbx;
        this.uart_mon_mbx=uart_mon_mbx;

    mon=new(agent_config.vif,uart_mon_mbx,agent_config);

        if(agent_config.is_active == 1)
          drv=new(agent_config.vif , uart_drv_mbx,agent_config);    
  endfunction 
      
      task run();
         fork
           mon.run();
           if(agent_config.is_active == 1)
            drv.run();
         join_none
        
    endtask

endclass