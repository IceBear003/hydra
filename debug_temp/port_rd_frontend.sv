module port_rd_frontend(
    input clk,

    output reg rd_sop,
    output reg rd_eop,
    output rd_vld,
    output [15:0] rd_data,

    input xfer_ready,
    input xfer_data_vld,
    input [15:0] xfer_data,
    input end_of_packet
);

assign rd_vld = xfer_data_vld;
assign rd_data = xfer_data;

always @(posedge clk) begin
    rd_sop <= xfer_ready;
    rd_eop <= end_of_packet;
end

endmodule