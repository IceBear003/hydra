`timescale 1ns/1ps
`include "ecc_decoder.v"
`include "ecc_encoder.v"

module tb_test_ecc();
  parameter PERIOD  = 10;

  // mux Inputs
  reg   [127:0]  data = 0;
  reg   [127:0]  wr_data = 0;
  wire   [127:0]  cr_data;

  // mux Outputs
  wire  [7:0]  sec_code                     ;

  reg clk = 0;


  initial
  begin
    forever
      #(PERIOD/2)  clk=~clk;
  end

  ecc_encoder encoder(.data(data),
                      .sec_code(sec_code));
  ecc_decoder decoder(.data(wr_data),
                      .sec_code(sec_code),
                      .cr_data(cr_data));
  initial
  begin
    $dumpfile("test.vcd");
    $dumpvars();
    #10 data=127'hBEC327A2;
    #10 wr_data=127'hBEC327A3;
    #10
    #10
    #10
    #10
    #10
    $finish;
  end

endmodule
