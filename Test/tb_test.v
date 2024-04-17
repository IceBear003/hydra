//~ `New testbench
`timescale  1ns / 1ps
`include "test.v"

module tb_test;

  // mux Parameters
  parameter PERIOD  = 10;


  // mux Inputs
  reg [7:0] data = 8'b0;
  wire [3:0] position;

  reg clk = 1;

  initial
  begin 
    forever
      #(PERIOD/2)  clk=~clk;
  end

  find_first_one ffo (
         .clk(clk),
         .data(data),
         .cnt(position)
       );

  initial
  begin
    $dumpfile("test.vcd");
    $dumpvars();
    #10 
    data = 8'b11110000;
    #10
    data = 8'b11110110;
    #10 
    data = 8'b11100000;
    #10 
    data = 8'b10111111;
    #10
     $finish;
  end

endmodule
