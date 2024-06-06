`timescale 1ns/1ns

module tb_sram_ecc();

reg clk;
reg rst_n;

initial begin
    clk <= 0;
    rst_n <= 0;
    #42
    rst_n <= 1;
end

always #2 clk = ~clk;

reg [127:0] data;
reg update = 0;
reg [127:0] cnt;
reg [7:0] code_1;

wire [7:0] code;
wire [127:0] cr_data;

always @(posedge clk) begin
    if(!rst_n) begin
        data <= 0;
        cnt <= $random;
    end else begin
        update <= update + 1;
        cnt <= $random;
        if(update) begin
            data <= cnt;
        end else
            data[cnt % 128] <= ~data[cnt % 128];
            code_1 <= code;
    end
end

sram_ecc_encoder sram_ecc_encoder_inst( 
    .data_0(data[15:0]),
    .data_1(data[31:16]),
    .data_2(data[47:32]),
    .data_3(data[63:48]),
    .data_4(data[79:64]),
    .data_5(data[95:80]),
    .data_6(data[111:96]),
    .data_7(data[127:112]),
    .code(code)
);

sram_ecc_decoder sram_ecc_decoder(
    .update(update), 
    .data_0(data[15:0]),
    .data_1(data[31:16]),
    .data_2(data[47:32]),
    .data_3(data[63:48]),
    .data_4(data[79:64]),
    .data_5(data[95:80]),
    .data_6(data[111:96]),
    .data_7(data[127:112]),
    .code(code_1),
    .cr_data_0(cr_data[15:0]),
    .cr_data_1(cr_data[31:16]),
    .cr_data_2(cr_data[47:32]),
    .cr_data_3(cr_data[63:48]),
    .cr_data_4(cr_data[79:64]),
    .cr_data_5(cr_data[95:80]),
    .cr_data_6(cr_data[111:96]),
    .cr_data_7(cr_data[127:112])
);

endmodule