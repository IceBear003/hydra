`include "./IceBear003/v3.0/fifo_null_pages.sv"

module sram_state
#(
    parameter ECC_STORAGE_ADDR_WIDTH = 11,
    parameter ECC_STORAGE_DATA_WIDTH = 8,
    parameter ECC_STORAGE_DATA_DEPTH = 2048
)
(
    input clk,
    input rst_n,
 
    //ECC Storage 
    input ecc_wr_en,
    input [10:0] ecc_wr_addr,
    input [7:0] ecc_din,

    input ecc_rd_en,
    input [10:0] ecc_rd_addr,
    output reg [7:0] ecc_dout = 0,

    //Jump Table Storage
    input jt_wr_en,
    input [10:0] jt_wr_addr,
    input [15:0] jt_din,

    input jt_rd_en,
    input [10:0] jt_rd_addr,
    output reg [15:0] jt_dout = 0,

    //SRAM Operations
    input wr_op,
    input [3:0] wr_port,
    input rd_op,
    input [3:0] rd_port,
    input [10:0] rd_addr,

    //Check the amount of an port's pages
    input [3:0] request_port,
    output [10:0] page_amount,

    //Null Pages
    output [10:0] null_ptr,
    output reg [10:0] free_space = 2047
);

(* ram_style = "block" *) reg [ECC_STORAGE_DATA_WIDTH-1:0] ecc_storage [ECC_STORAGE_DATA_DEPTH-1:0];
(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
reg [15:0][10:0] port_amount = 0;

assign page_amount = port_amount[request_port];

always @(posedge clk) begin
    if(ecc_wr_en && rst_n) begin 
        ecc_storage[ecc_wr_addr] <= ecc_din;
    end
end

always @(posedge clk) begin
    if(ecc_rd_en && rst_n) begin
        ecc_dout <= ecc_storage[ecc_rd_addr];
    end
end

always @(posedge clk) begin
    if(jt_wr_en && rst_n) begin 
        jump_table[jt_wr_addr] <= jt_din;
    end
end

always @(posedge clk) begin
    if(jt_rd_en && rst_n) begin
        jt_dout <= jump_table[jt_rd_addr];
    end
end

always @(posedge clk) begin
    if(!rst_n) begin 
        port_amount <= 0;
    end else if(wr_op && !rd_op) begin
        free_space <= free_space - 1;
        port_amount[wr_port] <= port_amount[wr_port] + 1;
    end else if(rd_op && !wr_op) begin
        free_space <= free_space + 1;
        port_amount[rd_port] <= port_amount[rd_port] - 1;
    end else if(rd_op && wr_op) begin
        if(wr_port != rd_port) begin
            port_amount[wr_port] <= port_amount[wr_port] + 1;
            port_amount[rd_port] <= port_amount[rd_port] - 1;
        end
    end
end

fifo_null_pages null_pages
(
    .clk(clk),
    .rst_n(rst_n),
    .pop_head(wr_op),
    .head_addr(null_ptr),
    .push_tail(rd_op),
    .tail_addr(rd_addr)
);

endmodule