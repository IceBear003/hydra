module port_rd_dispatch(
    input clk,
    input rst_n,

    input wrr_en,

    input [7:0] queue_empty,
    input update,
    output reg [3:0] rd_prior
);

/* WRR???? */
reg [7:0] wrr_mask_set [8:0];
always @(posedge clk) begin
    if(~rst_n) begin
        wrr_mask_set[8] <= 8'h00;
        wrr_mask_set[0] <= 8'h01;
        wrr_mask_set[1] <= 8'h03;
        wrr_mask_set[2] <= 8'h07;
        wrr_mask_set[3] <= 8'h0F;
        wrr_mask_set[4] <= 8'h1F;
        wrr_mask_set[5] <= 8'h3F;
        wrr_mask_set[6] <= 8'h7F;
        wrr_mask_set[7] <= 8'hFF;
    end
end

reg [7:0] wrr_mask;
reg [3:0] wrr_round;
wire [7:0] masked_queue_empty = wrr_mask | queue_empty;

/* 
 * WRR?????????
 * |- 0 - ?????
 * |- 1 - ?????????wrr_mask???(??????????????????????)????????????????????????2???????????0
 * |- 2 - ????wrr_round(???????)
 * |- 3 - ???????wrr_round?????????wrr_mask
 * |- 4 - ?????????wrr_mask???(????????????????)????????????????????????5???????????0
 * |- 5 - ????wrr_round??wrr_mask
 */

reg [2:0] update_state;

always @(posedge clk) begin
    if(~rst_n || ~wrr_en) begin
         update_state <= 3'd0;
    end else if(update_state == 3'd0 && update) begin
        update_state <= 3'd1;
    end else if(update_state == 3'd1) begin
        if(masked_queue_empty == 8'hFF) begin
            update_state <= 3'd2;
        end else begin
            update_state <= 3'd0;
        end
    end else if(update_state == 3'd2) begin
        update_state <= 3'd3; 
    end else if(update_state == 3'd3) begin
        update_state <= 3'd4; 
    end else if(update_state == 3'd4) begin
        if(masked_queue_empty == 8'hFF) begin
            update_state <= 3'd5;
        end else begin
            update_state <= 3'd0;
        end
    end else if(update_state == 3'd5) begin
        update_state <= 3'd0;
    end
end

always @(posedge clk) begin
    if(~rst_n || ~wrr_en) begin
        wrr_mask <= 8'h00;
    end else if(update) begin
        wrr_mask <= wrr_mask_set[rd_prior];
    end else if(update_state == 3'd2) begin
        wrr_mask <= wrr_mask_set[wrr_round];
        $display("wrr_round = %d",wrr_round);
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        wrr_round <= 4'd0;
    end else if(update_state == 3'd3) begin
        wrr_round <= wrr_round + 1;
    end else if(update_state == 3'd5) begin
        wrr_round <= 4'd0;
    end
end

wire [3:0] wire_rd_prior;

/* ??????????????? */
always @(posedge clk) begin
    rd_prior <= wire_rd_prior;
end

decoder_8_3 decoder_8_3(
    .select(masked_queue_empty),
    .idx(wire_rd_prior)
);

endmodule