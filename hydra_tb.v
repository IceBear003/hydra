//~ `New testbench
`timescale  1ns / 1ps
`include "hydra.sv"
module tb_test;
    reg clk = 0;
    initial
    begin 
        forever
        #(5)  clk=~clk;
    end
    reg [15:0] cnt = 0;
    output reg rst_n;
    //基本IO口
    output reg [15:0] wr_sop;
    output reg [15:0] wr_eop;
    output reg [15:0] wr_vld;
    output reg [15:0] [15:0] wr_data;
    input [15:0] pause;
    output reg [15:0] ready;
    input [15:0] rd_sop;
    input [15:0] rd_eop;
    input [15:0] rd_vld;
    input [15:0] [15:0] rd_data;
    hydra hydra(
        .clk(clk),
        .rst_n(rst_n),
        .wr_sop(wr_sop),
        .wr_eop(wr_eop),
        .wr_vld(wr_vld),
        .wr_data(wr_data),
        .pause(pause),
        
        .ready(ready),
        .rd_sop(rd_sop), 
        .rd_eop(rd_eop),
        .rd_vld(rd_vld),
        .rd_data(rd_data),
        .wrr_enable(16'hFFFF),
        .match_threshold(5'd20),
        .match_mode(2'd2)
    );
    always @(posedge clk) begin
        cnt <= cnt + 1;
    end
    reg re;
    always @(posedge clk) begin
        if(rd_eop != 0) begin
            ready <= 16'h0008;
            re <= 1;
        end else if(re) begin
            ready <= 16'h0000;
        end
    end
    integer i;
    initial
    begin
        $dumpfile("test_7_1_2.vcd");
        $dumpvars();
        #5 
        rst_n <= 0;
        wr_sop <= 16'h0000;
        wr_vld <= 16'h0000;
        wr_eop <= 16'h0000;
        #10 
        rst_n <= 1;
        #10 
        wr_sop <= 16'h0001;
        #10 
        wr_sop <= 16'h0000;
        wr_vld <= 16'h0001;
        wr_data <= {9'd63, 3'd4, 4'd3};
        cnt <= 0;
        for(i=0;i<62;i++) begin
            #10 
            if(i == 32) begin
                ready <= 16'h0008;
            end else begin
                ready <= 16'h0000;
            end
            wr_data <= cnt;
        end
        #10 wr_vld <= 16'h0000; wr_eop <= 16'h0001;
        #10 wr_eop <= 16'h0000;
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        #10 
        $finish;
    end
endmodule