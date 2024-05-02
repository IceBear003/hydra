`timescale 1ns/1ps
`include "controller.sv"

module tb_test_ecc();
  parameter PERIOD  = 10;
  
  reg clk = 0;


  initial
  begin
    forever
      #(PERIOD/2)  clk=~clk;
  end

  controller controller();

  initial
  begin
    $dumpfile("test.vcd");
    $dumpvars();
    $finish;
  end

endmodule
