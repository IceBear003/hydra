`include "decoder_8_3.sv"

module port_rd_dispatch(
    input clk,
    input rst_n,

    input wrr_en,
    input [7:0] queue_empty,
    input next,
    output [3:0] rd_prior
);

//TODO FIXME

reg [2:0] wrr_round;

always @(posedge clk) begin
    if(~rst_n) begin
        wrr_round <= 3'd7;
    end else if(next && rd_prior == 0) begin
        wrr_round <= wrr_round - 3'd1;
    end else if(rd_prior == 4'd8) begin
        wrr_round <= 3'd7;
    end
end

/* WRR掩码集 */
reg [7:0] wrr_mask_set [7:0];
always @(posedge clk) begin
    if(~rst_n) begin
        wrr_mask_set[7] <= 8'h00;
        wrr_mask_set[6] <= 8'h01;
        wrr_mask_set[5] <= 8'h03;
        wrr_mask_set[4] <= 8'h07;
        wrr_mask_set[3] <= 8'h0F;
        wrr_mask_set[2] <= 8'h1F;
        wrr_mask_set[1] <= 8'h3F;
        wrr_mask_set[0] <= 8'h7F;
    end
end

reg [7:0] select_mask;
wire [7:0] masked_queue_empty = select_mask | queue_empty;

always @(posedge clk) begin
    if(~rst_n || ~wrr_en) begin
        select_mask <= wrr_mask_set[7];
    end else if(next && rd_prior != 0) begin
        select_mask <= wrr_mask_set[rd_prior - 1];
    end else if(next && rd_prior == 0) begin
        select_mask <= wrr_mask_set[wrr_round];
    end else if(rd_prior == 4'd8) begin
        select_mask <= wrr_mask_set[7];
    end
end

decoder_8_3 decoder_8_3(
    .select(masked_queue_empty),
    .idx(rd_prior)
);

endmodule