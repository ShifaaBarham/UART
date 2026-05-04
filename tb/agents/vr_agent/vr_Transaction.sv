
class vr_Transaction #(parameter DATA_WIDTH=32 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=1) ;
  
 rand logic [DATA_WIDTH-1:0]    wdata;
      logic [DATA_WIDTH-1:0]    rdata;
 rand logic [CTRL_WIDTH-1:0]    ctrl;//1 for write and 0 for read
 rand logic [ADDRESS_WIDTH-1:0] addr;
 rand int unsigned ready_delay;
 rand int unsigned valid_delay;
      logic rx_err=0 ;
      logic tx_err=0 ;

  function void print();
    $display ("wdata=%0d rdata=%0d ctrl=%0d addr=%0d ",wdata,rdata,ctrl,addr);
  endfunction
  
  endclass
    