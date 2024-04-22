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
    output reg [31:0] prefer = 0
);

(*ram_style = "block"*) reg [7:0] ecc_codes [2047:0];
reg [2:0] wr_batch = 0;
reg [2:0] rd_batch = 0;
reg [10:0] port_amount [15:0];

integer i, j;

always @(negedge rst_n) 
    for(i = 0; i < 16; i = i + 1)
        port_amount[i] = 0;

always @(posedge clk) begin
    for(j = 0; j < 16; j = j + 1) begin
        if(port_amount[j] == 0) begin
            prefer[2*j] = 0;
            prefer[2*j+1] = 0;
        end else if(port_amount[j] < 512) begin
            prefer[2*j] = 1;
            prefer[2*j+1] = 0;
        end else if(port_amount[j] < 1536) begin
            prefer[2*j] = 0;
            prefer[2*j+1] = 1;
        end else begin
            prefer[2*j] = 1;
            prefer[2*j+1] = 1;
        end
    end
end

always @(posedge clk)
    if(wr_ecc_en)
        ecc_codes[wr_ecc_addr] = wr_ecc_code;

always @(posedge clk)
    rd_ecc_code = ecc_codes[rd_ecc_addr];

always @(posedge clk)
    if(free_space <= 1)
        full = 1;

always @(posedge clk) begin
    if(wr_batch < 7)
        wr_batch = wr_batch + 1;
    else
        writting = 0;

    if(rd_batch < 7)
        rd_batch = rd_batch + 1;
    else
        reading = 0;

    if(wr_op) begin
        free_space = free_space - 1;
        port_amount[wr_port] += 1;
        wr_batch = 0;
        writting = 1;
    end

    if(rd_op) begin
        free_space = free_space + 1;
        port_amount[rd_port] -= 1;
        rd_batch = 0;
        reading = 1;
    end
end

fifo_null_pages fifo(
    .clk(clk),
    .rst_n(rst_n),

    .pop_head(wr_op),
    .head_addr(null_ptr),

    .push_tail(rd_op),
    .tail_addr(rd_addr)
);

endmodule