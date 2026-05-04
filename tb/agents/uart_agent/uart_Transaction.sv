
class uart_Transaction #(parameter DATA_WIDTH=32) ;
  
       rand logic [DATA_WIDTH-1:0] data;
       rand logic Mon_direction;//mabe used in future for direction indication in case of half duplex

       rand int unsigned tx_delay ;
       logic checksum;
  
       rand logic inject_parity_err;
       rand logic inject_checksum_err;
       rand logic inject_framing_err;

        logic detect_parity_err;
        logic detect_checksum_err;
        logic detect_framing_err; 

function void calc_checksum(parity_type p_mode);
      if (p_mode == EVEN)
          checksum = ^data;   // Even 
      else
          checksum = ~^data;  // Odd Parity 
  endfunction
  
  endclass
    