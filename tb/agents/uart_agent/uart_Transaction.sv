
class uart_Transaction #(parameter DATA_WIDTH=8) ;
  
       rand logic [DATA_WIDTH-1:0] data;
       rand logic Mon_direction;//mabe used in future for direction indication in case of half duplex

       rand int tx_delay ;
       logic checksum;
  
       rand logic inject_parity_err;
       rand logic inject_checksum_err;
       rand logic inject_framing_err;

        logic detect_parity_err;
        logic detect_checksum_err;
        logic detect_framing_err;  

  function void calc_checksum();
     checksum= ^data;
  endfunction
  
  endclass
    