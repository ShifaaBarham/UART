typedef enum {MASTER,SLAVE} agent_typee;

class vr_Agent_config  #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8);
  
    virtual interface valid_ready_if  #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)  vif;
    bit is_active =1 ;
    agent_typee agent_type = MASTER; 
       
endclass
