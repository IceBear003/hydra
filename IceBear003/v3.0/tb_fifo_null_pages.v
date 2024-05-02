//~ `New testbench
`timescale  1ns / 1ps
`include "./v3.0/fifo_null_pages.sv"

module tb_fifo_null_pages();

    reg clk = 1;
    reg rst_n = 1;

    reg pop_head = 0;
    wire [10:0] head_addr;

    reg push_tail = 0;
    reg [10:0] tail_addr = 0;

    // mux Parameters
    parameter PERIOD  = 10;

    initial
    begin
        forever
        #(PERIOD/2)  clk=~clk;
    end

    fifo_null_pages fifo(
        .clk(clk),
        .rst_n(rst_n),
        .pop_head(pop_head),
        .head_addr(head_addr),
        .push_tail(push_tail),
        .tail_addr(tail_addr)
    );

    initial
    begin
        $dumpfile("test_fifo_null_pages.vcd");
        $dumpvars();
        #10
        rst_n = 0;
        #10 
        rst_n = 1;
        #10 
        pop_head = 1;
        #10
        #10
        #10
        #10
        #10
        #10
        pop_head = 0;
        push_tail = 1;
        tail_addr = 11'd0;
        #10
        tail_addr = 11'd1;
        #10
        tail_addr = 11'd2;
        #10
        tail_addr = 11'd3;
        #10
        $finish;
    end

endmodule
