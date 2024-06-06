`include "sram.sv"
`include "sram_ecc_encoder.sv"
`include "sram_ecc_decoder.sv"
`include "sram_rd_round.sv"

module sram_interface
#(parameter SRAM_IDX = 0)
(
    input clk,
    input rst_n,

    /*
     * 写入数据
     */
    input wr_xfer_data_vld,
    input [15:0] wr_xfer_data,
    input wr_end_of_packet,

    output reg [3:0] wr_packet_dest_port,
    output reg [15:0] wr_packet_head_addr,
    output reg [15:0] wr_packet_tail_addr,

    input [3:0] check_port,
    output [8:0] check_amount,
    output reg [10:0] free_space
);

/*
 * ECC编码存储器
 * 8*2048 = 16Kbit (1*18Kbit BRAM)
 */

(* ram_style = "block" *) reg [7:0] ecc_codes [2047:0];

reg [10:0] ec_wr_addr;
reg [7:0] ec_din;
reg [10:0] ec_rd_addr;
reg [7:0] ec_dout;

always @(posedge clk) begin
    ecc_codes[ec_wr_addr] <= ec_din;
end

always @(posedge clk) begin
    ec_dout <= ecc_codes[ec_rd_addr];
end

/*
 * 跳转表
 * 16*2048 = 32Kbit (1*36Kbit BRAM)
 */

(* ram_style = "block" *) reg [15:0] jump_table [2047:0];

reg [10:0] jt_wr_addr;
reg [15:0] jt_din;
reg [10:0] jt_rd_addr;
reg [15:0] jt_dout;

always @(posedge clk) begin
    jump_table[jt_wr_addr] <= jt_din;
end

always @(posedge clk) begin
    jt_dout <= jump_table[jt_rd_addr];
end

/*
 * 空闲队列
 * LUTRAM
 */

(* ram_style = "block" *) reg [10:0] null_pages [2047:0];

reg np_init;
reg [10:0] np_head;
reg [10:0] np_tail;

/******************************************************************************
 *                                  写入处理                                   *
 ******************************************************************************/

/*
 * 数据包写入状态
 * |- 0 - 无数据包写入
 * |- 1 - 正在写入数据包的第一页
 * |- 2 - 正在写入数据包的后续页
 */
reg [1:0] wr_state;

always @(posedge clk) begin
    if(!rst_n) begin
        wr_state <= 2'd0;
    end else if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_state <= 2'd1;
    end else if(wr_state == 2'd1 && wr_batch == 3'd7 && wr_xfer_data_vld) begin
        wr_state <= 2'd2;
    end else if(wr_state == 2'd2 && wr_end_of_packet) begin
        wr_state <= 2'd0;
    end
end

wire is_ctrl_batch = wr_state == 2'd0 && wr_xfer_data_vld;
wire wr_page = null_pages[np_head];
wire sram_wr_addr = {wr_page, wr_batch};

/* 数据包写入切片下标 */
reg [2:0] wr_batch;

always @(posedge clk) begin
    if(!rst_n) begin
        wr_batch <= 0;
    end else if(wr_xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
    end else if(wr_end_of_packet) begin
        wr_batch <= 0;
    end
end

/* 数据包开始写入时，获取其头尾地址 */
always @(posedge clk) begin
    if(is_ctrl_batch) begin
        wr_packet_head_addr <= {SRAM_IDX, wr_page};
        wr_packet_tail_addr <= {SRAM_IDX, null_pages[wr_page + wr_xfer_data[15:10]]};
    end
end

reg [15:0] ecc_encoder_buffer;
always @(posedge clk) begin
    if(wr_xfer_data_vld) begin
        ecc_encoder_buffer[wr_batch] <= xfer_data;
    end
end

endmodule