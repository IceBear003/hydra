`include "fifo_null_pages.sv"

module sram_state(
    input clk,
    input rst_n,
 
    input wr_ecc_en,
    input [10:0] wr_ecc_addr,
    input [7:0] wr_ecc_code,
    
    input [10:0] rd_ecc_addr,
    output reg [7:0] rd_ecc_code = 0,

    input wr_op,
    input [3:0] wr_port,
    input rd_op,
    input [3:0] rd_port,
    input [10:0] rd_addr,

    output reg writting = 0,
    output reg reading = 0,
    output reg full = 0,

    output [10:0] null_ptr,

    output reg [10:0] free_space = 2047,
);

endmodule