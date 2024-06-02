`include "sram.sv"

module sram_interface
#(parameter SRAM_IDX = 0)
(
    input clk,
    input rst_n,

    input xfer_data_vld,
    input [15:0] xfer_data,
    input end_of_packet,
    input cur_dest_port,
    input cur_length,

    input [7:0] ecc_result,

    output reg [15:0] packet_head_addr,
    output reg [15:0] packet_tail_addr,

    output reg [10:0] free_space,

    input [3:0] amount_request,
    output [8:0] amount
);

// 0 - idle
// 1 - packet writting the first page
// 2 - packet writting the left pages
reg [1:0] state;

reg [2:0] wr_batch;

reg [2:0] rd_batch;
reg [2:0] rd_addr;

(* ram_style = "block" *) reg [10:0] null_pages [2047:0];
reg np_initialized;
reg [10:0] np_head_ptr;
reg [10:0] np_tail_ptr;
reg [10:0] np_head_addr;

(* ram_style = "block" *) reg [7:0] ecc_storage [2047:0];
reg [10:0] es_wr_addr;
reg [7:0] es_din;
reg [10:0] es_rd_addr;
reg [7:0] es_dout;

(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
reg [10:0] jt_wr_addr;
reg [10:0] jt_rd_addr;
reg [15:0] jt_dout;

reg [8:0] packet_amount [15:0];

//state维护
always @(posedge clk) begin
    if(!rst_n) begin
        state <= 2'd0;
    end else if(state == 2'd0 && xfer_data_vld) begin
        state <= 2'd1;
    end else if(state == 2'd1 && wr_batch == 3'd7 && xfer_data_vld) begin
        state <= 2'd2;
    end else if(state == 2'd2 && end_of_packet) begin
        state <= 2'd0;
    end
end

//wr batch维护
always @(posedge clk) begin
    if(!rst_n || end_of_packet) begin
        wr_batch <= 0;
    end else if(xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
    end
end

//空闲链表
always @(posedge clk) begin
    if(!rst_n) begin
        np_tail_ptr <= 0;
    end else if(rd_batch == 7) begin
        null_pages[np_tail_ptr] <= rd_addr;
        np_tail_ptr <= np_tail_ptr + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        np_head_ptr <= 0;
        np_head_addr <= 2047;
        np_initialized <= 1;
    end if(wr_batch != 7) begin
    end else if(np_initialized == 1 & np_head_addr != 0) begin
        np_head_addr <= np_head_addr - 1;
    end else begin
        np_initialized <= 0;
        np_head_addr <= null_pages[np_head_ptr + 1];
        np_head_ptr <= np_head_ptr + 1;
    end
end

//ECC存储
always @(posedge clk) begin
    if(wr_batch == 7 || end_of_packet) begin
        es_wr_addr <= np_head_addr;
        es_din <= ecc_result;
    end
end

always @(posedge clk) begin
    ecc_storage[es_wr_addr] <= es_din;
end

always @(posedge clk) begin
    es_dout <= ecc_storage[es_rd_addr];
end

always @(posedge clk) begin
    ecc_storage[es_wr_addr] <= es_din;
end

always @(posedge clk) begin
    es_dout <= ecc_storage[es_rd_addr];
end

//跳转表
always @(posedge clk) begin
    if(wr_batch == 7) begin
        jt_wr_addr <= np_head_addr;
    end
end

always @(posedge clk) begin
    if(state == 2'd1) begin
        packet_head_addr <= np_head_addr;
    end else if(state != 2'd2) begin
    end else if(end_of_packet == 0) begin
        jump_table[jt_wr_addr] <= np_head_addr;
    end else begin
        packet_tail_addr <= np_head_addr;
    end
end

always @(posedge clk) begin
    jt_dout <= jump_table[jt_rd_addr];
end

//统计信息管理
always @(posedge clk) begin
    if(!rst_n) begin
        free_space <= 11'd2047;
    end else if(state == 0 && xfer_data_vld) begin
        free_space <= free_space - cur_length;
    end
end

integer port_idx;
always @(posedge clk) begin
    if(!rst_n) begin
        for(port_idx = 0; port_idx < 16; port_idx = port_idx + 1) begin
            packet_amount[port_idx] <= 0;
        end
    end else if(state == 0 && xfer_data_vld) begin
        packet_amount[cur_dest_port] <= packet_amount[cur_dest_port] + 1;
    end
end

assign amount = packet_amount[amount_request];

sram sram(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(xfer_data_vld),
    .wr_addr({np_head_addr, wr_batch}),
    .din(xfer_data)/*,
    .rd_en(),
    .rd_addr(),
    .dout()*/
);

endmodule