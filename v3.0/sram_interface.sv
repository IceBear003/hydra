`include "./v3.0/fifo_null_pages.sv"

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

    input wr_op,
    input [3:0] wr_port,
    input rd_op,
    input [3:0] rd_port,
    input [10:0] rd_addr,

    //SRAM State
    output reg writting = 0,

    //LOCK
    input reg lock_en,
    input reg lock_dis,
    output reg locking = 0,

    //TODO READ MECHANISM

    //Null Pages
    output [10:0] null_ptr,
    output reg [10:0] free_space = 2047,
    output reg full = 0
);

reg [ECC_STORAGE_DATA_WIDTH-1:0] ecc_storage [ECC_STORAGE_DATA_DEPTH-1:0];

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

endmodule