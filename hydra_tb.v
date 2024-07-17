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
    output reg [15:0] pause;

    hydra hydra(
        .clk(clk),
        .rst_n(rst_n),
        .wr_sop(wr_sop),
        .wr_eop(wr_eop),
        .wr_vld(wr_vld),
        .wr_data(wr_data),
        .pause(pause),
        .wrr_enable(16'hFFFF),
        .match_threshold(5'd20),
        .match_mode(2'd2)
    );

    always @(posedge clk) begin
        cnt <= cnt + 1;
    end

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars();
        #5 
        rst_n <= 0;
        #10 
        rst_n <= 1;
        wr_sop <= 16'h0007;
        wr_vld <= 16'h0000;
        #10 
        wr_sop <= 16'h0000;
        wr_vld <= 16'h0007;
        wr_data <= {{9'd31, 3'd4, 4'd3}, {9'd31, 3'd4, 4'd3}, {9'd34, 3'd4, 4'd3}};
        cnt = 0;
        #10 
        wr_vld <= 16'h0007;
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= {cnt-16'd1, cnt};
        #10 wr_data <= 0;
        wr_vld <= 16'h0001;
        #10 
        #10 
        wr_vld <= 16'h0000;
        #10 
        #10 
        #10 
        wr_eop <= 16'h0007;
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
