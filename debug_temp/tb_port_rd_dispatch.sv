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

reg [7:0] queue_empty;
reg update;
reg [3:0] rd_prior;

reg [6:0] cnt;

reg [7:0][7:0] queue_num;

always @(posedge clk) begin
    if(!rst_n) begin
        cnt <= 0;
    end else begin
        cnt <= cnt + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        queue_num[0] <= 14;
        queue_num[1] <= 9;
        queue_num[2] <= 7;
        queue_num[3] <= 11;
        queue_num[4] <= 17;
        queue_num[5] <= 11;
        queue_num[6] <= 14;
        queue_num[7] <= 16;
    end else if(update) begin
        queue_num[rd_prior] <= queue_num[rd_prior] - 1;
    end
end

integer i;

always @(posedge clk) begin
    if(!rst_n) begin
        queue_empty <= 8'hFF;
    end else begin
        for(i = 0; i < 8; i = i+1)
            queue_empty[i] <= queue_num[i] == 0;
    end
end

reg [10:0] cnt_out;

always @(posedge clk) begin
    if(!rst_n) begin
        cnt_out <= 0;
    end else if(update && rd_prior != 8) begin
        cnt_out <= cnt_out + 1;
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