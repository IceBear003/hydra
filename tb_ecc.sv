`timescale 1ns/1ns

module tb_ecc();

reg [127:0] data;
reg [7:0] code;

wire [127:0] cr_data;

reg clk;
reg rst_n;

initial begin
    clk <= 1'b1;
    rst_n <= 1'b0;
    #40
    rst_n <= 1'b1;
end

always #2 clk =   ~clk;

reg cnt;
reg [6:0] c;

always@(posedge clk or negedge rst_n)
    if(rst_n == 0) begin
        data <= 0;
        cnt <= 0;
        c <= 0;
    end
    else begin
        cnt <= cnt + 1;
        if(cnt == 0) begin
            data <= $random;
            c <= $random % 128;
        end
        if(cnt == 1) begin
            data[c] <= ~data[c];
        end
    end

ecc_encoder ecc_encoder_inst
(
    .data   (data   )   ,
    .code   (code   )   

);

ecc_decoder ecc_decoder_inst
(
    .data   (data   )   ,
    .code   (code   )   ,

    .cr_data(cr_data)   

);

endmodule