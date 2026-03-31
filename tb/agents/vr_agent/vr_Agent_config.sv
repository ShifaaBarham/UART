typedef enum {MASTER,SLAVE} agnt_type;

class vr_Agent_config  #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8);
  
    virtual interface valid_ready_if  #( DATA_WIDTH, ADDRESS_WIDTH, CTRL_WIDTH)  vif;
    bit is_active =1 ;
    agnt_type agent_type = MASTER; 
       
endclass
