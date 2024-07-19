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

wire wrr_en = 0;

reg [7:0] queue_empty;
reg update;
wire [3:0] rd_prior;

reg [6:0] cnt;

always @(posedge clk) begin
    if(!rst_n) begin
        cnt <= 0;
    end else begin
        cnt <= cnt + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        queue_empty <= 8'hFF;
    end else if(cnt == 0) begin
        queue_empty <= $random;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        update <= 0;
    end else if(cnt[3:0] == 0) begin
        update <= 1;
    end else begin
        update <= 0;
    end
end

port_rd_dispatch port_rd_dispatch_inst
(
    .clk(clk),
    .rst_n(rst_n),

    .wrr_en(wrr_en),
    .queue_empty(queue_empty),
    .update(update),

    .rd_prior(rd_prior)

);

endmodule