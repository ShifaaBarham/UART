
class vr_Transaction #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8) ;
  
 rand logic [DATA_WIDTH-1:0] wdata;
logic [DATA_WIDTH-1:0] rdata;
 rand logic [CTRL_WIDTH-1:0]  ctrl;//1 for write and 0 for read
 rand logic [ADDRESS_WIDTH-1:0] addr;
 rand int    ready_delay;
  
  function void print();
    $display ("wdata=%0d rdata=%0d ctrl=%0d addr=%0d ",wdata,rdata,ctrl,addr);
    
  endfunction
  
  endclass
    