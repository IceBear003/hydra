module port_wr_ecc(
    input clk,
    input rst_n,

    input xfer_data_vld,
    input [15:0] xfer_data,
    
    output [7:0] ecc_result
);

reg [2:0] ecc_batch;

reg [15:0] encoder_buffer [7:0];

always @(posedge clk) begin
    if(rst_n) begin
        ecc_batch <= 0;
    end else if(xfer_data_vld) begin
        ecc_batch <= ecc_batch + 1;
    end
end

always @(posedge clk) begin
    if(xfer_data_vld == 0) begin
    end else if(ecc_batch == 3'd0) begin
        encoder_buffer[0] <= xfer_data;
        encoder_buffer[1] <= 0;
        encoder_buffer[2] <= 0;
        encoder_buffer[3] <= 0;
        encoder_buffer[4] <= 0;
        encoder_buffer[5] <= 0;
        encoder_buffer[6] <= 0;
        encoder_buffer[7] <= 0;
    end else begin
        encoder_buffer[ecc_batch] <= xfer_data;
    end
end

endmodule