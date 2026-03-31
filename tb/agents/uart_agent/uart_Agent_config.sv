typedef enum {MASTER,SLAVE} agnt_type;
typedef enum {ODD,EVEN,NONE} parity_type;

class uart_Agent_config #(parameter DATA_WIDTH=8) ;
  
    virtual interface UART_if   vif;
    bit is_active =1 ; //for tx path or rx path activation
    agnt_type agent_type = MASTER; 
      bit ppb_enable = 0;
    int unsigned  cfg_baud_rate = 9600;
    int unsigned tb_clk_freq=100000000;
      
    parity_type parity_mode=EVEN;
    int unsigned  stop_bits=1;//1 or 2 stop bits
      
      
      function int get_clks_per_bit();
        return (tb_clk_freq/cfg_baud_rate);
      endfunction
    
            
endclass
