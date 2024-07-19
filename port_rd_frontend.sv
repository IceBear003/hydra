module port_rd_frontend(
    input clk,
    input rst_n,

    output reg rd_eop,
    output rd_vld,
    output [15:0] rd_data,
    input ready,

    input xfer_data_vld,
    input [15:0] xfer_data,
    input end_of_packet
);

assign rd_vld = xfer_data_vld;
assign rd_data = xfer_data;

always @(posedge clk) begin
    rd_eop <= end_of_packet;
end

endmodule