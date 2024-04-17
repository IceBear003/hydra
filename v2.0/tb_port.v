//~ `New testbench
`timescale  1ns / 1ps
`include "port.sv"

module tb_port();

    reg clk = 1;

    // mux Parameters
    parameter PERIOD  = 10;

    output reg wr_sop = 0;
    output reg wr_eop = 0;
    output reg wr_vld = 0;
    output reg [15:0] wr_data = 0;
    wire full;
    wire almost_full;

    wire wr_en;
    wire is_ctrl_frame;
    wire [2:0] batch;
    wire [2:0] prior;
    wire [3:0] dest_port;
    wire [15:0] data;

    initial
    begin
        forever
        #(PERIOD/2)  clk=~clk;
    end

    port port_0(
        .clk(clk),
        .wr_sop(wr_sop),
        .wr_eop(wr_eop),
        .wr_vld(wr_vld),
        .wr_data(wr_data),
        .full(full),
        .almost_full(almost_full),

        .wr_en(wr_en),
        .is_ctrl_frame(is_ctrl_frame),
        .batch(batch),
        .prior(prior),
        .dest_port(dest_port),
        .data(data)
    );

    initial
    begin
        $dumpfile("test_port.vcd");
        $dumpvars();
        #10 
        #10 
        wr_sop = 1;
        #10 
        wr_sop = 0;
        #10
        wr_data = 16'h0A0F;
        #10
        wr_vld = 1;
        wr_data = 16'b0001111010010010;
        #10
        wr_data = 16'b0101000010111011;
        #10
        wr_data = 16'b0100001111010000;
        #10
        wr_data = 16'b0111111000100000;
        #10
        wr_data = 16'b0000000000001100;
        #10
        wr_data = 16'b0111111111111110;
        #10
        wr_data = 16'b0000000001000001;
        #10
        wr_data = 16'b0111110001000001;
        #10
        wr_data = 16'b0000000000001100;
        #10
        wr_data = 16'b0111111111111110;
        #10 
        wr_vld = 0;
        wr_eop = 1;
        #10 
        #10 
        wr_sop = 1;
        #10 
        wr_sop = 0;
        #10 
        $finish;
    end

endmodule
