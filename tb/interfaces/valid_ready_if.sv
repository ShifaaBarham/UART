interface valid_ready_if  #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8) (input logic clk,input logic rst) ;
  
  
   logic [DATA_WIDTH-1:0] data;
   logic [CTRL_WIDTH-1:0]  ctrl;
   logic [ADDRESS_WIDTH-1:0] addr;
   logic valid;
   logic ready;
  
    modport MASTER_DR (output valid ,output data ,output addr,output ctrl , input clk,rst ,ready);
    modport SLAVE_DR (output ready  , input clk,rst ,ctrl ,valid,data,addr);
    modport Mon (input valid , data ,addr, ctrl ,clk,rst ,ready);
  
  
endinterface 