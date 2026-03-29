interface valid_ready_if  #(parameter DATA_WIDTH=8 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=8) (input logic clk,input logic rst) ;
  
  
  
   logic [DATA_WIDTH-1:0] wdata; 
   logic [DATA_WIDTH-1:0] rdata;
   logic [CTRL_WIDTH-1:0]  ctrl;
   logic [ADDRESS_WIDTH-1:0] addr;
   logic valid;
   logic ready;
  
   modport MASTER_DR (output valid, wdata, addr, ctrl, input clk, rst, ready, rdata);
    modport SLAVE_DR  (output ready, rdata, input clk, rst, ctrl, valid, wdata, addr);
    modport Mon       (input valid, wdata, rdata, addr, ctrl, clk, rst, ready);
  
  
endinterface 