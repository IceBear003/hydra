module ecc_decoder(
    input clk,
    input rst_n,

    input [3:0] in_batch,
    input [15:0] data,
    input [7:0] code,

    input out_end_of_packet,
    output reg [3:0] out_batch,
    output [15:0] out_data
);

reg page_out;
always @(posedge clk) begin
    page_out <= in_batch == 4'd7;
    if(in_batch != 4'd8) begin
        data_buffer[in_batch] <= data;
    end
end

reg [15:0] data_buffer [7:0];

reg [15:0] out_mask;
reg [15:0] out_data_buf;
assign out_data = (tmp != 0 && wrong_pos[6:4] == out_batch) ? out_data_buf ^ out_mask : out_data_buf;

always @(posedge clk) begin
    if(~rst_n || out_end_of_packet) begin
        out_batch <= 4'd8;
        out_data_buf <= 16'd0;
        out_mask <= 16'd0;
    end else if(out_batch != 4'd8 && out_batch != 4'd7) begin
        out_batch <= out_batch + 1;
        out_data_buf <= data_buffer[out_batch + 1];
    end else if(page_out) begin
        out_batch <= 3'd0;
        out_data_buf <= data_buffer[0];
        out_mask <= 16'd1 << wrong_pos[3:0];
    end
end

reg [7:0] cur_code;

/* 错误纠正 */
wire [7:0] tmp = cur_code ^ code; 
wire [6:0] wrong_pos = tmp - 1;

always @(posedge clk) begin
    if(in_batch == 4'd7) begin
        cur_code[0] <= (((((data_buffer[0][0] ^ data_buffer[0][2]) ^ (data_buffer[0][4] ^ data_buffer[0][6])) ^ ((data_buffer[0][8] ^ data_buffer[0][10]) ^ (data_buffer[0][12] ^ data_buffer[0][14]))) ^ (((data_buffer[1][0] ^ data_buffer[1][2]) ^ (data_buffer[1][4] ^ data_buffer[1][6])) ^ ((data_buffer[1][8] ^ data_buffer[1][10]) ^ (data_buffer[1][12] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][0] ^ data_buffer[2][2]) ^ (data_buffer[2][4] ^ data_buffer[2][6])) ^ ((data_buffer[2][8] ^ data_buffer[2][10]) ^ (data_buffer[2][12] ^ data_buffer[2][14]))) ^ (((data_buffer[3][0] ^ data_buffer[3][2]) ^ (data_buffer[3][4] ^ data_buffer[3][6])) ^ ((data_buffer[3][8] ^ data_buffer[3][10]) ^ (data_buffer[3][12] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][0] ^ data_buffer[4][2]) ^ (data_buffer[4][4] ^ data_buffer[4][6])) ^ ((data_buffer[4][8] ^ data_buffer[4][10]) ^ (data_buffer[4][12] ^ data_buffer[4][14]))) ^ (((data_buffer[5][0] ^ data_buffer[5][2]) ^ (data_buffer[5][4] ^ data_buffer[5][6])) ^ ((data_buffer[5][8] ^ data_buffer[5][10]) ^ (data_buffer[5][12] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][0] ^ data_buffer[6][2]) ^ (data_buffer[6][4] ^ data_buffer[6][6])) ^ ((data_buffer[6][8] ^ data_buffer[6][10]) ^ (data_buffer[6][12] ^ data_buffer[6][14]))) ^ (((data[0] ^ data[2]) ^ (data[4] ^ data[6])) ^ ((data[8] ^ data[10]) ^ (data[12] ^ data[14])))));
        cur_code[1] <= (((((data_buffer[0][1] ^ data_buffer[0][2]) ^ (data_buffer[0][5] ^ data_buffer[0][6])) ^ ((data_buffer[0][9] ^ data_buffer[0][10]) ^ (data_buffer[0][13] ^ data_buffer[0][14]))) ^ (((data_buffer[1][1] ^ data_buffer[1][2]) ^ (data_buffer[1][5] ^ data_buffer[1][6])) ^ ((data_buffer[1][9] ^ data_buffer[1][10]) ^ (data_buffer[1][13] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][1] ^ data_buffer[2][2]) ^ (data_buffer[2][5] ^ data_buffer[2][6])) ^ ((data_buffer[2][9] ^ data_buffer[2][10]) ^ (data_buffer[2][13] ^ data_buffer[2][14]))) ^ (((data_buffer[3][1] ^ data_buffer[3][2]) ^ (data_buffer[3][5] ^ data_buffer[3][6])) ^ ((data_buffer[3][9] ^ data_buffer[3][10]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][1] ^ data_buffer[4][2]) ^ (data_buffer[4][5] ^ data_buffer[4][6])) ^ ((data_buffer[4][9] ^ data_buffer[4][10]) ^ (data_buffer[4][13] ^ data_buffer[4][14]))) ^ (((data_buffer[5][1] ^ data_buffer[5][2]) ^ (data_buffer[5][5] ^ data_buffer[5][6])) ^ ((data_buffer[5][9] ^ data_buffer[5][10]) ^ (data_buffer[5][13] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][1] ^ data_buffer[6][2]) ^ (data_buffer[6][5] ^ data_buffer[6][6])) ^ ((data_buffer[6][9] ^ data_buffer[6][10]) ^ (data_buffer[6][13] ^ data_buffer[6][14]))) ^ (((data[1] ^ data[2]) ^ (data[5] ^ data[6])) ^ ((data[9] ^ data[10]) ^ (data[13] ^ data[14])))));
        cur_code[2] <= (((((data_buffer[0][3] ^ data_buffer[0][4]) ^ (data_buffer[0][5] ^ data_buffer[0][6])) ^ ((data_buffer[0][11] ^ data_buffer[0][12]) ^ (data_buffer[0][13] ^ data_buffer[0][14]))) ^ (((data_buffer[1][3] ^ data_buffer[1][4]) ^ (data_buffer[1][5] ^ data_buffer[1][6])) ^ ((data_buffer[1][11] ^ data_buffer[1][12]) ^ (data_buffer[1][13] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][3] ^ data_buffer[2][4]) ^ (data_buffer[2][5] ^ data_buffer[2][6])) ^ ((data_buffer[2][11] ^ data_buffer[2][12]) ^ (data_buffer[2][13] ^ data_buffer[2][14]))) ^ (((data_buffer[3][3] ^ data_buffer[3][4]) ^ (data_buffer[3][5] ^ data_buffer[3][6])) ^ ((data_buffer[3][11] ^ data_buffer[3][12]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][3] ^ data_buffer[4][4]) ^ (data_buffer[4][5] ^ data_buffer[4][6])) ^ ((data_buffer[4][11] ^ data_buffer[4][12]) ^ (data_buffer[4][13] ^ data_buffer[4][14]))) ^ (((data_buffer[5][3] ^ data_buffer[5][4]) ^ (data_buffer[5][5] ^ data_buffer[5][6])) ^ ((data_buffer[5][11] ^ data_buffer[5][12]) ^ (data_buffer[5][13] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][3] ^ data_buffer[6][4]) ^ (data_buffer[6][5] ^ data_buffer[6][6])) ^ ((data_buffer[6][11] ^ data_buffer[6][12]) ^ (data_buffer[6][13] ^ data_buffer[6][14]))) ^ (((data[3] ^ data[4]) ^ (data[5] ^ data[6])) ^ ((data[11] ^ data[12]) ^ (data[13] ^ data[14])))));
        cur_code[3] <= (((((data_buffer[0][7] ^ data_buffer[0][8]) ^ (data_buffer[0][9] ^ data_buffer[0][10])) ^ ((data_buffer[0][11] ^ data_buffer[0][12]) ^ (data_buffer[0][13] ^ data_buffer[0][14]))) ^ (((data_buffer[1][7] ^ data_buffer[1][8]) ^ (data_buffer[1][9] ^ data_buffer[1][10])) ^ ((data_buffer[1][11] ^ data_buffer[1][12]) ^ (data_buffer[1][13] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][7] ^ data_buffer[2][8]) ^ (data_buffer[2][9] ^ data_buffer[2][10])) ^ ((data_buffer[2][11] ^ data_buffer[2][12]) ^ (data_buffer[2][13] ^ data_buffer[2][14]))) ^ (((data_buffer[3][7] ^ data_buffer[3][8]) ^ (data_buffer[3][9] ^ data_buffer[3][10])) ^ ((data_buffer[3][11] ^ data_buffer[3][12]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][7] ^ data_buffer[4][8]) ^ (data_buffer[4][9] ^ data_buffer[4][10])) ^ ((data_buffer[4][11] ^ data_buffer[4][12]) ^ (data_buffer[4][13] ^ data_buffer[4][14]))) ^ (((data_buffer[5][7] ^ data_buffer[5][8]) ^ (data_buffer[5][9] ^ data_buffer[5][10])) ^ ((data_buffer[5][11] ^ data_buffer[5][12]) ^ (data_buffer[5][13] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][7] ^ data_buffer[6][8]) ^ (data_buffer[6][9] ^ data_buffer[6][10])) ^ ((data_buffer[6][11] ^ data_buffer[6][12]) ^ (data_buffer[6][13] ^ data_buffer[6][14]))) ^ (((data[7] ^ data[8]) ^ (data[9] ^ data[10])) ^ ((data[11] ^ data[12]) ^ (data[13] ^ data[14])))));
        cur_code[4] <= (((((data_buffer[0][15] ^ data_buffer[1][0]) ^ (data_buffer[1][1] ^ data_buffer[1][2])) ^ ((data_buffer[1][3] ^ data_buffer[1][4]) ^ (data_buffer[1][5] ^ data_buffer[1][6]))) ^ (((data_buffer[1][7] ^ data_buffer[1][8]) ^ (data_buffer[1][9] ^ data_buffer[1][10])) ^ ((data_buffer[1][11] ^ data_buffer[1][12]) ^ (data_buffer[1][13] ^ data_buffer[1][14])))) ^ ((((data_buffer[2][15] ^ data_buffer[3][0]) ^ (data_buffer[3][1] ^ data_buffer[3][2])) ^ ((data_buffer[3][3] ^ data_buffer[3][4]) ^ (data_buffer[3][5] ^ data_buffer[3][6]))) ^ (((data_buffer[3][7] ^ data_buffer[3][8]) ^ (data_buffer[3][9] ^ data_buffer[3][10])) ^ ((data_buffer[3][11] ^ data_buffer[3][12]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[4][15] ^ data_buffer[5][0]) ^ (data_buffer[5][1] ^ data_buffer[5][2])) ^ ((data_buffer[5][3] ^ data_buffer[5][4]) ^ (data_buffer[5][5] ^ data_buffer[5][6]))) ^ (((data_buffer[5][7] ^ data_buffer[5][8]) ^ (data_buffer[5][9] ^ data_buffer[5][10])) ^ ((data_buffer[5][11] ^ data_buffer[5][12]) ^ (data_buffer[5][13] ^ data_buffer[5][14])))) ^ ((((data_buffer[6][15] ^ data[0]) ^ (data[1] ^ data[2])) ^ ((data[3] ^ data[4]) ^ (data[5] ^ data[6]))) ^ (((data[7] ^ data[8]) ^ (data[9] ^ data[10])) ^ ((data[11] ^ data[12]) ^ (data[13] ^ data[14])))));
        cur_code[5] <= (((((data_buffer[1][15] ^ data_buffer[2][0]) ^ (data_buffer[2][1] ^ data_buffer[2][2])) ^ ((data_buffer[2][3] ^ data_buffer[2][4]) ^ (data_buffer[2][5] ^ data_buffer[2][6]))) ^ (((data_buffer[2][7] ^ data_buffer[2][8]) ^ (data_buffer[2][9] ^ data_buffer[2][10])) ^ ((data_buffer[2][11] ^ data_buffer[2][12]) ^ (data_buffer[2][13] ^ data_buffer[2][14])))) ^ ((((data_buffer[2][15] ^ data_buffer[3][0]) ^ (data_buffer[3][1] ^ data_buffer[3][2])) ^ ((data_buffer[3][3] ^ data_buffer[3][4]) ^ (data_buffer[3][5] ^ data_buffer[3][6]))) ^ (((data_buffer[3][7] ^ data_buffer[3][8]) ^ (data_buffer[3][9] ^ data_buffer[3][10])) ^ ((data_buffer[3][11] ^ data_buffer[3][12]) ^ (data_buffer[3][13] ^ data_buffer[3][14]))))) ^ (((((data_buffer[5][15] ^ data_buffer[6][0]) ^ (data_buffer[6][1] ^ data_buffer[6][2])) ^ ((data_buffer[6][3] ^ data_buffer[6][4]) ^ (data_buffer[6][5] ^ data_buffer[6][6]))) ^ (((data_buffer[6][7] ^ data_buffer[6][8]) ^ (data_buffer[6][9] ^ data_buffer[6][10])) ^ ((data_buffer[6][11] ^ data_buffer[6][12]) ^ (data_buffer[6][13] ^ data_buffer[6][14])))) ^ ((((data_buffer[6][15] ^ data[0]) ^ (data[1] ^ data[2])) ^ ((data[3] ^ data[4]) ^ (data[5] ^ data[6]))) ^ (((data[7] ^ data[8]) ^ (data[9] ^ data[10])) ^ ((data[11] ^ data[12]) ^ (data[13] ^ data[14])))));
        cur_code[6] <= (((((data_buffer[3][15] ^ data_buffer[4][0]) ^ (data_buffer[4][1] ^ data_buffer[4][2])) ^ ((data_buffer[4][3] ^ data_buffer[4][4]) ^ (data_buffer[4][5] ^ data_buffer[4][6]))) ^ (((data_buffer[4][7] ^ data_buffer[4][8]) ^ (data_buffer[4][9] ^ data_buffer[4][10])) ^ ((data_buffer[4][11] ^ data_buffer[4][12]) ^ (data_buffer[4][13] ^ data_buffer[4][14])))) ^ ((((data_buffer[4][15] ^ data_buffer[5][0]) ^ (data_buffer[5][1] ^ data_buffer[5][2])) ^ ((data_buffer[5][3] ^ data_buffer[5][4]) ^ (data_buffer[5][5] ^ data_buffer[5][6]))) ^ (((data_buffer[5][7] ^ data_buffer[5][8]) ^ (data_buffer[5][9] ^ data_buffer[5][10])) ^ ((data_buffer[5][11] ^ data_buffer[5][12]) ^ (data_buffer[5][13] ^ data_buffer[5][14]))))) ^ (((((data_buffer[5][15] ^ data_buffer[6][0]) ^ (data_buffer[6][1] ^ data_buffer[6][2])) ^ ((data_buffer[6][3] ^ data_buffer[6][4]) ^ (data_buffer[6][5] ^ data_buffer[6][6]))) ^ (((data_buffer[6][7] ^ data_buffer[6][8]) ^ (data_buffer[6][9] ^ data_buffer[6][10])) ^ ((data_buffer[6][11] ^ data_buffer[6][12]) ^ (data_buffer[6][13] ^ data_buffer[6][14])))) ^ ((((data_buffer[6][15] ^ data[0]) ^ (data[1] ^ data[2])) ^ ((data[3] ^ data[4]) ^ (data[5] ^ data[6]))) ^ (((data[7] ^ data[8]) ^ (data[9] ^ data[10])) ^ ((data[11] ^ data[12]) ^ (data[13] ^ data[14])))));
        cur_code[7] <= data[15];
    end
end

endmodule