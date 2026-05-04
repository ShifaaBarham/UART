//`timescale 1ns/1ps
interface UART_if #(parameter DATA_WIDTH=32) (input logic clk,input logic rst) ; 
   logic tx;
   logic rx;

   //  to inject glitch directly on the hardware wire
  task inject_glitch(time duration);
    force rx = 1'b0;
    #(duration);
    force rx = 1'b1;
    #1ns;
    release rx;
  endtask

  endinterface 