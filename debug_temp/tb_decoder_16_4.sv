`timescale 1ns/1ns

module tb_decoder_16_4();

reg clk;
reg rst_n;

initial begin
    clk <= 0;
    rst_n <= 0;
    #42
    rst_n <= 1;
end

always #2 clk = ~clk;

reg [15:0] select;
reg cnt = 0;
reg [3:0] tem = 0;

always@(posedge clk) begin
    if(!rst_n) begin
        select <= 0;
    end else begin
        cnt <= cnt + 1;
        tem <= $random;
        if(cnt)
            select[tem] <= 1;
        else
            select <= 0;
    end
end

wire [3:0] idx;

decoder_16_4 decoder_16_4_inst
(
    .select(select),
    .idx(idx)

);

endmodule
