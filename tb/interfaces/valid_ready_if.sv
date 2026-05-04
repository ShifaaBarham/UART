interface valid_ready_if  #(parameter DATA_WIDTH=32 ,parameter ADDRESS_WIDTH=8,parameter CTRL_WIDTH=1) (input logic clk,input logic rst) ;
  
  
     
   logic [DATA_WIDTH-1:0] wdata; 
   logic [DATA_WIDTH-1:0] rdata;
   logic [CTRL_WIDTH-1:0]  ctrl;
   logic [ADDRESS_WIDTH-1:0] addr;
   logic valid;
   logic ready;
   logic tx_err ;
   logic rx_err ;
  
    modport MASTER_DR (output valid, wdata, addr, ctrl,tx_err, input clk, rst, ready, rdata,rx_err);
    modport SLAVE_DR  (output ready, rdata,rx_err, input clk, rst, ctrl, valid, wdata, addr,tx_err);
    modport Mon       (input valid, wdata, rdata, addr, ctrl, clk, rst, ready,tx_err,rx_err);
  
  
endinterface 