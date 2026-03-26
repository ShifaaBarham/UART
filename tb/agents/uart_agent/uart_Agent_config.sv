typedef enum {MASTER,SLAVE} agent_typee;
typedef enum {ODD,EVEN,NONE} parity_type;

class uart_Agent_config #(parameter DATA_WIDTH=8) ;
  
    virtual interface UART_if   vif;
    bit is_active =1 ;
    agent_typee agent_type = MASTER; 
      
    int unsigned  cfg_baud_rate = 9600;
    int unsigned tb_clk_freq=100000000;
      
    parity_type parity_typee=ODD;
    int unsigned  stop_bits=1;
      
      
      function int get_clks_per_bit();
        return (tb_clk_freq/cfg_baud_rate);
      endfunction
    
            
endclass
