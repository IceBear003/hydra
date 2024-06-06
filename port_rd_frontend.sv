module port_rd_frontend(
    input clk,
    input rst_n,

    output reg rd_sop,
    output reg rd_eop,
    output reg rd_vld,
    output reg [15:0] rd_data,
    input ready,

    input xfer_data_vld,
    input [15:0] xfer_data,
    input end_of_packet
);

always @(posedge clk) begin
    rd_vld <= xfer_data_vld;
end

always @(posedge clk) begin
    rd_data <= xfer_data;
end

always @(posedge clk) begin
    if(~rst_n) begin
        rd_eop <= 0;
    end else if(end_of_packet && xfer_data_vld) begin
        rd_eop <= 1;
    end else begin
        rd_eop <= 0;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        rd_sop <= 0;
    end else if(ready) begin
        rd_sop <= 1;
    end else begin
        rd_sop <= 0;
    end
end

endmodule