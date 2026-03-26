
class vr_Transaction #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8) ;
  
 rand logic [DATA_WIDTH-1:0] data;
 rand logic [CTRL_WIDTH-1:0]  ctrl;
 rand logic [ADDRESS_WIDTH-1:0] addr;
 rand int    ready_delay;
  
  function void print();
    $display ("data=%0d ctrl=%0d addr=%0d ",data,ctrl,addr);
    
  endfunction
  
  endclass
    