module port_wr_backend(
    input clk,
    input rst_n,

    input [15:0] xfer_data,
    input xfer_data_vld,

    input end_of_packet,
    input [3:0] cur_dest_port,
    input [2:0] cur_prior,
    input [8:0] cur_length
);

/*
 * ecc_encoder_state:
 *      0~7: Writting ecc encoder buffer #N.
 */
reg ecc_encoder_enable;
reg [2:0] ecc_encoder_state;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        ecc_encoder_state <= 0;
    end else if(end_of_packet) begin
        ecc_encoder_state <= 0;
    end else if(xfer_data_vld) begin
        ecc_encoder_state <= ecc_encoder_state + 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        ecc_encoder_enable <= 0;
    end else if(end_of_packet) begin
        ecc_encoder_enable <= 1;
    end else if(ecc_encoder_state == 7 && xfer_data_vld) begin
        ecc_encoder_enable <= 1;
    end else begin
        ecc_encoder_enable <= 0;
    end
end

endmodule