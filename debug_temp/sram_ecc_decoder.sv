module ecc_decoder(
    input clk,
    input rst_n,

    /*
     * 来自后端传输数据的IO
     * |- in_batch - 传输数据切片编号
     * |- in_data - 传输数据
     * |- ecc_code - 页的(136,128)ECC校验码
     */
    input [3:0] in_batch,
    input [15:0] in_data,
    input [7:0] ecc_code,

    /*
     * 向前端发送读出数据的IO
     * |- out_batch - 读出数据切片编号
     * |- out_data - 读出传输数据
     * |- end_of_packet - 数据包终止信号
     */
    output reg [3:0] out_batch,
    output [15:0] out_data,
    input end_of_packet
);

/* 
 * 纠错机制
 * |- data_buffer - 纠错缓冲区
 * |- code_diff - (136,128)ECC编码比对结果
 * |- wrong_pos - 错误位置
 */
reg [15:0] data_buffer [7:0];
/* 错误纠正 */
reg [7:0] code_diff;
wire [6:0] wrong_pos = code_diff - 1;

/* 
 * 读出数据
 * |- out_start - 已纠错一页数据的读出使能信号
 * |- out_cr_mask - 半字纠错掩码
 * |- out_data_pre - 预取读出数据缓冲
 */
reg out_start;
reg [15:0] out_cr_mask;
reg [15:0] out_data_pre;
assign out_data = (code_diff != 0 && wrong_pos[6:4] == out_batch) ? out_data_pre ^ out_cr_mask : out_data_pre;

always @(posedge clk) begin
    out_start <= in_batch == 4'd7;
end

always @(posedge clk) begin
    if(in_batch != 4'd8) begin
        /* if(in_batch == 4'd4) data_buffer[in_batch] <= in_data ^ 16'h0080; 这里是模拟SRAM出错，每一页的一位反转的情况
        else */data_buffer[in_batch] <= in_data;
    end
end

always @(posedge clk) begin
    if(~rst_n || end_of_packet) begin
        out_data_pre <= 16'd0;
        out_cr_mask <= 16'd0;
    end else if(out_batch != 4'd8 && out_batch != 4'd7) begin
        out_data_pre <= data_buffer[out_batch + 1];
    end else if(out_start) begin
        out_data_pre <= data_buffer[0];
        out_cr_mask <= 16'd1 << wrong_pos[3:0];
    end
end

always @(posedge clk) begin
    if(~rst_n || end_of_packet) begin
        out_batch <= 4'd8;
    end else if(out_start) begin
        out_batch <= 3'd0;
    end else if(out_batch != 4'd8) begin
        out_batch <= out_batch + 1;
    end
end

always @(posedge clk) begin
    if(in_batch == 4'd7) begin
        code_diff[0] <= ecc_code[0] ^ (((((data_buffer[0][0] ^ data_buffer[0][2]) ^ (data_buffer[0][4] ^ data_buffer[0][6])) ^ ((data_buffer[0][8] ^ data_buffer[0][10]) ^ (data_buffer[0][12] ^ data_buffer[0][14]))) ^ (((data_buffer[1][0] ^ data_buffer[1][2]) ^ (data_buffer[1][4] ^ data_buffer[1][6])) ^ ((data_buffer[1][8] ^ data_buffer[1][10]) ^ (data_buffer[1][12] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][0] ^ data_buffer[2][2]) ^ (data_buffer[2][4] ^ data_buffer[2][6])) ^ ((data_buffer[2][8] ^ data_buffer[2][10]) ^ (data_buffer[2][12] ^ data_buffer[2][14]))) ^ (((data_buffer[3][0] ^ data_buffer[3][2]) ^ (data_buffer[3][4] ^ data_buffer[3][6])) ^ ((data_buffer[3][8] ^ data_buffer[3][10]) ^ (data_buffer[3][12] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][0] ^ data_buffer[4][2]) ^ (data_buffer[4][4] ^ data_buffer[4][6])) ^ ((data_buffer[4][8] ^ data_buffer[4][10]) ^ (data_buffer[4][12] ^ data_buffer[4][14]))) ^ (((data_buffer[5][0] ^ data_buffer[5][2]) ^ (data_buffer[5][4] ^ data_buffer[5][6])) ^ ((data_buffer[5][8] ^ data_buffer[5][10]) ^ (data_buffer[5][12] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][0] ^ data_buffer[6][2]) ^ (data_buffer[6][4] ^ data_buffer[6][6])) ^ ((data_buffer[6][8] ^ data_buffer[6][10]) ^ (data_buffer[6][12] ^ data_buffer[6][14]))) ^ (((in_data[0] ^ in_data[2]) ^ (in_data[4] ^ in_data[6])) ^ ((in_data[8] ^ in_data[10]) ^ (in_data[12] ^ in_data[14])))));
        code_diff[1] <= ecc_code[1] ^ (((((data_buffer[0][1] ^ data_buffer[0][2]) ^ (data_buffer[0][5] ^ data_buffer[0][6])) ^ ((data_buffer[0][9] ^ data_buffer[0][10]) ^ (data_buffer[0][13] ^ data_buffer[0][14]))) ^ (((data_buffer[1][1] ^ data_buffer[1][2]) ^ (data_buffer[1][5] ^ data_buffer[1][6])) ^ ((data_buffer[1][9] ^ data_buffer[1][10]) ^ (data_buffer[1][13] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][1] ^ data_buffer[2][2]) ^ (data_buffer[2][5] ^ data_buffer[2][6])) ^ ((data_buffer[2][9] ^ data_buffer[2][10]) ^ (data_buffer[2][13] ^ data_buffer[2][14]))) ^ (((data_buffer[3][1] ^ data_buffer[3][2]) ^ (data_buffer[3][5] ^ data_buffer[3][6])) ^ ((data_buffer[3][9] ^ data_buffer[3][10]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][1] ^ data_buffer[4][2]) ^ (data_buffer[4][5] ^ data_buffer[4][6])) ^ ((data_buffer[4][9] ^ data_buffer[4][10]) ^ (data_buffer[4][13] ^ data_buffer[4][14]))) ^ (((data_buffer[5][1] ^ data_buffer[5][2]) ^ (data_buffer[5][5] ^ data_buffer[5][6])) ^ ((data_buffer[5][9] ^ data_buffer[5][10]) ^ (data_buffer[5][13] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][1] ^ data_buffer[6][2]) ^ (data_buffer[6][5] ^ data_buffer[6][6])) ^ ((data_buffer[6][9] ^ data_buffer[6][10]) ^ (data_buffer[6][13] ^ data_buffer[6][14]))) ^ (((in_data[1] ^ in_data[2]) ^ (in_data[5] ^ in_data[6])) ^ ((in_data[9] ^ in_data[10]) ^ (in_data[13] ^ in_data[14])))));
        code_diff[2] <= ecc_code[2] ^ (((((data_buffer[0][3] ^ data_buffer[0][4]) ^ (data_buffer[0][5] ^ data_buffer[0][6])) ^ ((data_buffer[0][11] ^ data_buffer[0][12]) ^ (data_buffer[0][13] ^ data_buffer[0][14]))) ^ (((data_buffer[1][3] ^ data_buffer[1][4]) ^ (data_buffer[1][5] ^ data_buffer[1][6])) ^ ((data_buffer[1][11] ^ data_buffer[1][12]) ^ (data_buffer[1][13] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][3] ^ data_buffer[2][4]) ^ (data_buffer[2][5] ^ data_buffer[2][6])) ^ ((data_buffer[2][11] ^ data_buffer[2][12]) ^ (data_buffer[2][13] ^ data_buffer[2][14]))) ^ (((data_buffer[3][3] ^ data_buffer[3][4]) ^ (data_buffer[3][5] ^ data_buffer[3][6])) ^ ((data_buffer[3][11] ^ data_buffer[3][12]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][3] ^ data_buffer[4][4]) ^ (data_buffer[4][5] ^ data_buffer[4][6])) ^ ((data_buffer[4][11] ^ data_buffer[4][12]) ^ (data_buffer[4][13] ^ data_buffer[4][14]))) ^ (((data_buffer[5][3] ^ data_buffer[5][4]) ^ (data_buffer[5][5] ^ data_buffer[5][6])) ^ ((data_buffer[5][11] ^ data_buffer[5][12]) ^ (data_buffer[5][13] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][3] ^ data_buffer[6][4]) ^ (data_buffer[6][5] ^ data_buffer[6][6])) ^ ((data_buffer[6][11] ^ data_buffer[6][12]) ^ (data_buffer[6][13] ^ data_buffer[6][14]))) ^ (((in_data[3] ^ in_data[4]) ^ (in_data[5] ^ in_data[6])) ^ ((in_data[11] ^ in_data[12]) ^ (in_data[13] ^ in_data[14])))));
        code_diff[3] <= ecc_code[3] ^ (((((data_buffer[0][7] ^ data_buffer[0][8]) ^ (data_buffer[0][9] ^ data_buffer[0][10])) ^ ((data_buffer[0][11] ^ data_buffer[0][12]) ^ (data_buffer[0][13] ^ data_buffer[0][14]))) ^ (((data_buffer[1][7] ^ data_buffer[1][8]) ^ (data_buffer[1][9] ^ data_buffer[1][10])) ^ ((data_buffer[1][11] ^ data_buffer[1][12]) ^ (data_buffer[1][13] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][7] ^ data_buffer[2][8]) ^ (data_buffer[2][9] ^ data_buffer[2][10])) ^ ((data_buffer[2][11] ^ data_buffer[2][12]) ^ (data_buffer[2][13] ^ data_buffer[2][14]))) ^ (((data_buffer[3][7] ^ data_buffer[3][8]) ^ (data_buffer[3][9] ^ data_buffer[3][10])) ^ ((data_buffer[3][11] ^ data_buffer[3][12]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][7] ^ data_buffer[4][8]) ^ (data_buffer[4][9] ^ data_buffer[4][10])) ^ ((data_buffer[4][11] ^ data_buffer[4][12]) ^ (data_buffer[4][13] ^ data_buffer[4][14]))) ^ (((data_buffer[5][7] ^ data_buffer[5][8]) ^ (data_buffer[5][9] ^ data_buffer[5][10])) ^ ((data_buffer[5][11] ^ data_buffer[5][12]) ^ (data_buffer[5][13] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][7] ^ data_buffer[6][8]) ^ (data_buffer[6][9] ^ data_buffer[6][10])) ^ ((data_buffer[6][11] ^ data_buffer[6][12]) ^ (data_buffer[6][13] ^ data_buffer[6][14]))) ^ (((in_data[7] ^ in_data[8]) ^ (in_data[9] ^ in_data[10])) ^ ((in_data[11] ^ in_data[12]) ^ (in_data[13] ^ in_data[14])))));
        code_diff[4] <= ecc_code[4] ^ (((((data_buffer[0][15] ^ data_buffer[1][0]) ^ (data_buffer[1][1] ^ data_buffer[1][2])) ^ ((data_buffer[1][3] ^ data_buffer[1][4]) ^ (data_buffer[1][5] ^ data_buffer[1][6]))) ^ (((data_buffer[1][7] ^ data_buffer[1][8]) ^ (data_buffer[1][9] ^ data_buffer[1][10])) ^ ((data_buffer[1][11] ^ data_buffer[1][12]) ^ (data_buffer[1][13] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][15] ^ data_buffer[3][0]) ^ (data_buffer[3][1] ^ data_buffer[3][2])) ^ ((data_buffer[3][3] ^ data_buffer[3][4]) ^ (data_buffer[3][5] ^ data_buffer[3][6]))) ^ (((data_buffer[3][7] ^ data_buffer[3][8]) ^ (data_buffer[3][9] ^ data_buffer[3][10])) ^ ((data_buffer[3][11] ^ data_buffer[3][12]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][15] ^ data_buffer[5][0]) ^ (data_buffer[5][1] ^ data_buffer[5][2])) ^ ((data_buffer[5][3] ^ data_buffer[5][4]) ^ (data_buffer[5][5] ^ data_buffer[5][6]))) ^ (((data_buffer[5][7] ^ data_buffer[5][8]) ^ (data_buffer[5][9] ^ data_buffer[5][10])) ^ ((data_buffer[5][11] ^ data_buffer[5][12]) ^ (data_buffer[5][13] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][15] ^ in_data[0]) ^ (in_data[1] ^ in_data[2])) ^ ((in_data[3] ^ in_data[4]) ^ (in_data[5] ^ in_data[6]))) ^ (((in_data[7] ^ in_data[8]) ^ (in_data[9] ^ in_data[10])) ^ ((in_data[11] ^ in_data[12]) ^ (in_data[13] ^ in_data[14])))));
        code_diff[5] <= ecc_code[5] ^ (((((data_buffer[1][15] ^ data_buffer[2][0]) ^ (data_buffer[2][1] ^ data_buffer[2][2])) ^ ((data_buffer[2][3] ^ data_buffer[2][4]) ^ (data_buffer[2][5] ^ data_buffer[2][6]))) ^ (((data_buffer[2][7] ^ data_buffer[2][8]) ^ (data_buffer[2][9] ^ data_buffer[2][10])) ^ ((data_buffer[2][11] ^ data_buffer[2][12]) ^ (data_buffer[2][13] ^ data_buffer[2][14])))) ^ ((((data_buffer[2][15] ^ data_buffer[3][0]) ^ (data_buffer[3][1] ^ data_buffer[3][2])) ^ ((data_buffer[3][3] ^ data_buffer[3][4]) ^ (data_buffer[3][5] ^ data_buffer[3][6]))) ^ (((data_buffer[3][7] ^ data_buffer[3][8]) ^ (data_buffer[3][9] ^ data_buffer[3][10])) ^ ((data_buffer[3][11] ^ data_buffer[3][12]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[5][15] ^ data_buffer[6][0]) ^ (data_buffer[6][1] ^ data_buffer[6][2])) ^ ((data_buffer[6][3] ^ data_buffer[6][4]) ^ (data_buffer[6][5] ^ data_buffer[6][6]))) ^ (((data_buffer[6][7] ^ data_buffer[6][8]) ^ (data_buffer[6][9] ^ data_buffer[6][10])) ^ ((data_buffer[6][11] ^ data_buffer[6][12]) ^ (data_buffer[6][13] ^ data_buffer[6][14])))) ^ ((((data_buffer[6][15] ^ in_data[0]) ^ (in_data[1] ^ in_data[2])) ^ ((in_data[3] ^ in_data[4]) ^ (in_data[5] ^ in_data[6]))) ^ (((in_data[7] ^ in_data[8]) ^ (in_data[9] ^ in_data[10])) ^ ((in_data[11] ^ in_data[12]) ^ (in_data[13] ^ in_data[14])))));
        code_diff[6] <= ecc_code[6] ^ (((((data_buffer[3][15] ^ data_buffer[4][0]) ^ (data_buffer[4][1] ^ data_buffer[4][2])) ^ ((data_buffer[4][3] ^ data_buffer[4][4]) ^ (data_buffer[4][5] ^ data_buffer[4][6]))) ^ (((data_buffer[4][7] ^ data_buffer[4][8]) ^ (data_buffer[4][9] ^ data_buffer[4][10])) ^ ((data_buffer[4][11] ^ data_buffer[4][12]) ^ (data_buffer[4][13] ^ data_buffer[4][14])))) ^ ((((data_buffer[4][15] ^ data_buffer[5][0]) ^ (data_buffer[5][1] ^ data_buffer[5][2])) ^ ((data_buffer[5][3] ^ data_buffer[5][4]) ^ (data_buffer[5][5] ^ data_buffer[5][6]))) ^ (((data_buffer[5][7] ^ data_buffer[5][8]) ^ (data_buffer[5][9] ^ data_buffer[5][10])) ^ ((data_buffer[5][11] ^ data_buffer[5][12]) ^ (data_buffer[5][13] ^ data_buffer[5][14]))))) ^ (((((data_buffer[5][15] ^ data_buffer[6][0]) ^ (data_buffer[6][1] ^ data_buffer[6][2])) ^ ((data_buffer[6][3] ^ data_buffer[6][4]) ^ (data_buffer[6][5] ^ data_buffer[6][6]))) ^ (((data_buffer[6][7] ^ data_buffer[6][8]) ^ (data_buffer[6][9] ^ data_buffer[6][10])) ^ ((data_buffer[6][11] ^ data_buffer[6][12]) ^ (data_buffer[6][13] ^ data_buffer[6][14])))) ^ ((((data_buffer[6][15] ^ in_data[0]) ^ (in_data[1] ^ in_data[2])) ^ ((in_data[3] ^ in_data[4]) ^ (in_data[5] ^ in_data[6]))) ^ (((in_data[7] ^ in_data[8]) ^ (in_data[9] ^ in_data[10])) ^ ((in_data[11] ^ in_data[12]) ^ (in_data[13] ^ in_data[14])))));
        code_diff[7] <= ecc_code[7] ^ in_data[15];
    end
end

endmodule