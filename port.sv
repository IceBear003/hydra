`include "port_wr_frontend.sv"

module port(
    input clk,
    input rst_n,

    //IOs of the TOP module
    input wr_sop,
    input wr_vld,
    input [15:0] wr_data,
    input wr_eop,
    output pause,

    output rd_sop,
    output rd_vld,
    output [15:0] rd_data,
    output rd_eop,
    input ready,

    //IOs related to the interaction with the SRAMs
    output reg [31:0] sram_wr_select,
    output [15:0] sram_wr_data,
    output [7:0] sram_wr_ecc_code,

    input [15:0] packet_head_addr,
    input [15:0] packet_tail_addr

    //SRAM返回头尾地址√
);

wire xfer_data_vld;
wire [15:0] xfer_data;

wire end_of_packet;
wire [3:0] cur_dest_port;
wire [2:0] cur_prior;
wire [8:0] cur_length;

wire match_suc;
wire match_enable;
wire [3:0] new_dest_port;
wire [2:0] new_prior;
wire [8:0] new_length;

port_wr_frontend wr_frontend(
    .clk(clk),
    .rst_n(rst_n),
    .wr_sop(wr_sop),
    .wr_vld(wr_vld),
    .wr_data(wr_data),
    .wr_eop(wr_eop),
    .pause(pause),
    .xfer_data_vld(xfer_data_vld),
    .xfer_data(xfer_data),
    .end_of_packet(end_of_packet),
    .cur_dest_port(cur_dest_port),
    .cur_prior(cur_prior),
    .cur_length(cur_length),
    .match_suc(match_suc),
    .match_enable(match_enable),
    .new_dest_port(new_dest_port),
    .new_prior(new_prior),
    .new_length(new_length)
);

endmodule