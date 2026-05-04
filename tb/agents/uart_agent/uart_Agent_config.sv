typedef enum {MASTER,SLAVE} agnt_type;
typedef enum {ODD,EVEN,NONE} parity_type;
typedef enum int {
B9600=9600,
B19200=19200,
B38400=38400,
B57600=57600
} baud_rate_e;

class uart_Agent_config #(parameter DATA_WIDTH=32) ;
  
    virtual interface UART_if #( DATA_WIDTH) vif;
    agnt_type agent_type = MASTER; 
    baud_rate_e cfg_baud_rate = B19200;
    parity_type parity_mode=EVEN;
    bit is_active =1 ;               //1 to activate the driver and 0 to make it monitor only agent
    bit ppb_enable = 0;              //parity per bit enable or disable
    int unsigned tb_clk_freq=576000; 
    bit is_tx = 0;                   //1 for tx agent and 0 for rx agent
    int unsigned  stop_bits=1;       //1 or 2 stop bits
    bit err_drop_mode = 0;
    
      function int get_clks_per_bit();
        return (tb_clk_freq/cfg_baud_rate);
      endfunction
    
            
endclass
