`timescale 1ns/1ns

module tb_port_rd_frontend();

reg clk;
reg rst_n;

reg ready;

reg xfer_data_vld;
reg [15:0] xfer_data;
reg end_of_packet;

reg [7:0] length;

initial begin
    clk <= 0;
    rst_n <= 0;
    #40
    rst_n <= 1;
    #40
    ready <= 1;
    #22
    xfer_data_vld <= 1;
    #202
    xfer_data_vld <= 0;
    end_of_packet <= 1;
    #4
    end_of_packet <= 0;
end

always #2 clk = ~clk;

always @(posedge clk) begin
    if(~rst_n) begin
        length <= 0;
    end else if(ready) begin
        length <= $random;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        xfer_data <= 0;
    end else if(xfer_data_vld) begin
        xfer_data <= $random;
    end
end
    
wire rd_sop;
wire rd_eop;
wire rd_vld;
wire [15:0] rd_data;

port_rd_frontend port_rd_frontend_inst
(
    .clk(clk),
    .rst_n(rst_n),

    .ready(ready),
    .xfer_data_vld(xfer_data_vld),
    .xfer_data(xfer_data),
    .end_of_packet(end_of_packet),

    .rd_sop(rd_sop),
    .rd_eop(rd_eop),
    .rd_vld(rd_vld),
    .rd_data(rd_data)

);

endmodule
