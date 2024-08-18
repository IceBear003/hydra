module port_rd_frontend(
    input clk,

    /* 读出IO */
    output reg rd_sop,
    output reg rd_eop,
    output rd_vld,
    output [15:0] rd_data,

    /*
     * 来自后端的读出数据传输IO
     * |- out_ready - 即将开始一个数据包的传输
     * |- out_data_vld - 传输数据有效信号
     * |- out_data - 传输数据
     * |- end_of_packet - 传输数据结束信号
     */
    input out_ready,
    input out_data_vld,
    input [15:0] out_data,
    input end_of_packet
);

assign rd_vld = out_data_vld;
assign rd_data = out_data;

always @(posedge clk) begin
    rd_sop <= out_ready;
end

always @(posedge clk) begin
    rd_eop <= end_of_packet;
end

endmodule