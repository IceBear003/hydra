`timescale 1ns/1ns

module tb_port_rd_dispatch();

reg clk;
reg rst_n;

initial begin
    clk <= 0;
    rst_n <= 0;
    #40
    rst_n <= 1;
end

always #2 clk = ~clk;

wire wrr_en = 1;

reg next = 1;
reg [7:0] queue_available;

reg [5:0] cnt;

always @(posedge clk) begin
    if(!rst_n) begin
        cnt <= 0;
    end else begin
        cnt <= cnt + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        queue_available <= 0;
    end else if(cnt == 1) begin
        queue_available <= $random;
    end
end

wire [2:0] prior;

port_rd_dispatch port_rd_dispatch_inst
(
    .clk(clk),
    .rst_n(rst_n),
    .wrr_en(wrr_en),
    .queue_available(queue_available),
    .next(next),

    .prior(prior)

);

endmodule