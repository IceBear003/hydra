`timescale 1ns/1ns

module tb_decoder_32_5();

reg clk;
reg rst_n;

initial begin
    clk <= 0;
    rst_n <= 0;
    #42
    rst_n <= 1;
end

always #2 clk = ~clk;

reg [31:0] select;
reg cnt = 0;
reg [4:0] tem = 0;

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

wire [4:0] idx;

decoder_32_5 decoder_32_5_inst
(
    .select(select),
    .idx(idx)

);

endmodule
