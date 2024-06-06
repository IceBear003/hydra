module sram_ecc_decoder(
    input update,
    input [15:0] data_0,
    input [15:0] data_1,
    input [15:0] data_2,
    input [15:0] data_3,
    input [15:0] data_4,
    input [15:0] data_5,
    input [15:0] data_6,
    input [15:0] data_7,
    input [7:0] code,

    output [15:0] cr_data_0,
    output [15:0] cr_data_1,
    output [15:0] cr_data_2,
    output [15:0] cr_data_3,
    output [15:0] cr_data_4,
    output [15:0] cr_data_5,
    output [15:0] cr_data_6,
    output [15:0] cr_data_7
);

reg [127:0] cr_data;

assign cr_data_0 = cr_data[15:0];
assign cr_data_1 = cr_data[31:16];
assign cr_data_2 = cr_data[47:32];
assign cr_data_3 = cr_data[63:48];
assign cr_data_4 = cr_data[79:64];
assign cr_data_5 = cr_data[95:80];
assign cr_data_6 = cr_data[111:96];
assign cr_data_7 = cr_data[127:112];

reg [7:0] cur_code;
reg [7:0] wrong_pos;

assign cur_code[0] = (((((data_0[0] ^ data_0[2]) ^ (data_0[4] ^ data_0[6])) ^ ((data_0[8] ^ data_0[10]) ^ (data_0[12] ^ data_0[14]))) ^ (((data_1[0] ^ data_1[2]) ^ (data_1[4] ^ data_1[6])) ^ ((data_1[8] ^ data_1[10]) ^ (data_1[12] ^ data_1[14])))) ^ ((((data_2[0] ^ data_2[2]) ^ (data_2[4] ^ data_2[6])) ^ ((data_2[8] ^ data_2[10]) ^ (data_2[12] ^ data_2[14]))) ^ (((data_3[0] ^ data_3[2]) ^ (data_3[4] ^ data_3[6])) ^ ((data_3[8] ^ data_3[10]) ^ (data_3[12] ^ data_3[14]))))) ^ (((((data_4[0] ^ data_4[2]) ^ (data_4[4] ^ data_4[6])) ^ ((data_4[8] ^ data_4[10]) ^ (data_4[12] ^ data_4[14]))) ^ (((data_5[0] ^ data_5[2]) ^ (data_5[4] ^ data_5[6])) ^ ((data_5[8] ^ data_5[10]) ^ (data_5[12] ^ data_5[14])))) ^ ((((data_6[0] ^ data_6[2]) ^ (data_6[4] ^ data_6[6])) ^ ((data_6[8] ^ data_6[10]) ^ (data_6[12] ^ data_6[14]))) ^ (((data_7[0] ^ data_7[2]) ^ (data_7[4] ^ data_7[6])) ^ ((data_7[8] ^ data_7[10]) ^ (data_7[12] ^ data_7[14])))));
assign cur_code[1] = (((((data_0[1] ^ data_0[2]) ^ (data_0[5] ^ data_0[6])) ^ ((data_0[9] ^ data_0[10]) ^ (data_0[13] ^ data_0[14]))) ^ (((data_1[1] ^ data_1[2]) ^ (data_1[5] ^ data_1[6])) ^ ((data_1[9] ^ data_1[10]) ^ (data_1[13] ^ data_1[14])))) ^ ((((data_2[1] ^ data_2[2]) ^ (data_2[5] ^ data_2[6])) ^ ((data_2[9] ^ data_2[10]) ^ (data_2[13] ^ data_2[14]))) ^ (((data_3[1] ^ data_3[2]) ^ (data_3[5] ^ data_3[6])) ^ ((data_3[9] ^ data_3[10]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_4[1] ^ data_4[2]) ^ (data_4[5] ^ data_4[6])) ^ ((data_4[9] ^ data_4[10]) ^ (data_4[13] ^ data_4[14]))) ^ (((data_5[1] ^ data_5[2]) ^ (data_5[5] ^ data_5[6])) ^ ((data_5[9] ^ data_5[10]) ^ (data_5[13] ^ data_5[14])))) ^ ((((data_6[1] ^ data_6[2]) ^ (data_6[5] ^ data_6[6])) ^ ((data_6[9] ^ data_6[10]) ^ (data_6[13] ^ data_6[14]))) ^ (((data_7[1] ^ data_7[2]) ^ (data_7[5] ^ data_7[6])) ^ ((data_7[9] ^ data_7[10]) ^ (data_7[13] ^ data_7[14])))));
assign cur_code[2] = (((((data_0[3] ^ data_0[4]) ^ (data_0[5] ^ data_0[6])) ^ ((data_0[11] ^ data_0[12]) ^ (data_0[13] ^ data_0[14]))) ^ (((data_1[3] ^ data_1[4]) ^ (data_1[5] ^ data_1[6])) ^ ((data_1[11] ^ data_1[12]) ^ (data_1[13] ^ data_1[14])))) ^ ((((data_2[3] ^ data_2[4]) ^ (data_2[5] ^ data_2[6])) ^ ((data_2[11] ^ data_2[12]) ^ (data_2[13] ^ data_2[14]))) ^ (((data_3[3] ^ data_3[4]) ^ (data_3[5] ^ data_3[6])) ^ ((data_3[11] ^ data_3[12]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_4[3] ^ data_4[4]) ^ (data_4[5] ^ data_4[6])) ^ ((data_4[11] ^ data_4[12]) ^ (data_4[13] ^ data_4[14]))) ^ (((data_5[3] ^ data_5[4]) ^ (data_5[5] ^ data_5[6])) ^ ((data_5[11] ^ data_5[12]) ^ (data_5[13] ^ data_5[14])))) ^ ((((data_6[3] ^ data_6[4]) ^ (data_6[5] ^ data_6[6])) ^ ((data_6[11] ^ data_6[12]) ^ (data_6[13] ^ data_6[14]))) ^ (((data_7[3] ^ data_7[4]) ^ (data_7[5] ^ data_7[6])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
assign cur_code[3] = (((((data_0[7] ^ data_0[8]) ^ (data_0[9] ^ data_0[10])) ^ ((data_0[11] ^ data_0[12]) ^ (data_0[13] ^ data_0[14]))) ^ (((data_1[7] ^ data_1[8]) ^ (data_1[9] ^ data_1[10])) ^ ((data_1[11] ^ data_1[12]) ^ (data_1[13] ^ data_1[14])))) ^ ((((data_2[7] ^ data_2[8]) ^ (data_2[9] ^ data_2[10])) ^ ((data_2[11] ^ data_2[12]) ^ (data_2[13] ^ data_2[14]))) ^ (((data_3[7] ^ data_3[8]) ^ (data_3[9] ^ data_3[10])) ^ ((data_3[11] ^ data_3[12]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_4[7] ^ data_4[8]) ^ (data_4[9] ^ data_4[10])) ^ ((data_4[11] ^ data_4[12]) ^ (data_4[13] ^ data_4[14]))) ^ (((data_5[7] ^ data_5[8]) ^ (data_5[9] ^ data_5[10])) ^ ((data_5[11] ^ data_5[12]) ^ (data_5[13] ^ data_5[14])))) ^ ((((data_6[7] ^ data_6[8]) ^ (data_6[9] ^ data_6[10])) ^ ((data_6[11] ^ data_6[12]) ^ (data_6[13] ^ data_6[14]))) ^ (((data_7[7] ^ data_7[8]) ^ (data_7[9] ^ data_7[10])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
assign cur_code[4] = (((((data_0[15] ^ data_1[0]) ^ (data_1[1] ^ data_1[2])) ^ ((data_1[3] ^ data_1[4]) ^ (data_1[5] ^ data_1[6]))) ^ (((data_1[7] ^ data_1[8]) ^ (data_1[9] ^ data_1[10])) ^ ((data_1[11] ^ data_1[12]) ^ (data_1[13] ^ data_1[14])))) ^ ((((data_2[15] ^ data_3[0]) ^ (data_3[1] ^ data_3[2])) ^ ((data_3[3] ^ data_3[4]) ^ (data_3[5] ^ data_3[6]))) ^ (((data_3[7] ^ data_3[8]) ^ (data_3[9] ^ data_3[10])) ^ ((data_3[11] ^ data_3[12]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_4[15] ^ data_5[0]) ^ (data_5[1] ^ data_5[2])) ^ ((data_5[3] ^ data_5[4]) ^ (data_5[5] ^ data_5[6]))) ^ (((data_5[7] ^ data_5[8]) ^ (data_5[9] ^ data_5[10])) ^ ((data_5[11] ^ data_5[12]) ^ (data_5[13] ^ data_5[14])))) ^ ((((data_6[15] ^ data_7[0]) ^ (data_7[1] ^ data_7[2])) ^ ((data_7[3] ^ data_7[4]) ^ (data_7[5] ^ data_7[6]))) ^ (((data_7[7] ^ data_7[8]) ^ (data_7[9] ^ data_7[10])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
assign cur_code[5] = (((((data_1[15] ^ data_2[0]) ^ (data_2[1] ^ data_2[2])) ^ ((data_2[3] ^ data_2[4]) ^ (data_2[5] ^ data_2[6]))) ^ (((data_2[7] ^ data_2[8]) ^ (data_2[9] ^ data_2[10])) ^ ((data_2[11] ^ data_2[12]) ^ (data_2[13] ^ data_2[14])))) ^ ((((data_2[15] ^ data_3[0]) ^ (data_3[1] ^ data_3[2])) ^ ((data_3[3] ^ data_3[4]) ^ (data_3[5] ^ data_3[6]))) ^ (((data_3[7] ^ data_3[8]) ^ (data_3[9] ^ data_3[10])) ^ ((data_3[11] ^ data_3[12]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_5[15] ^ data_6[0]) ^ (data_6[1] ^ data_6[2])) ^ ((data_6[3] ^ data_6[4]) ^ (data_6[5] ^ data_6[6]))) ^ (((data_6[7] ^ data_6[8]) ^ (data_6[9] ^ data_6[10])) ^ ((data_6[11] ^ data_6[12]) ^ (data_6[13] ^ data_6[14])))) ^ ((((data_6[15] ^ data_7[0]) ^ (data_7[1] ^ data_7[2])) ^ ((data_7[3] ^ data_7[4]) ^ (data_7[5] ^ data_7[6]))) ^ (((data_7[7] ^ data_7[8]) ^ (data_7[9] ^ data_7[10])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
assign cur_code[6] = (((((data_3[15] ^ data_4[0]) ^ (data_4[1] ^ data_4[2])) ^ ((data_4[3] ^ data_4[4]) ^ (data_4[5] ^ data_4[6]))) ^ (((data_4[7] ^ data_4[8]) ^ (data_4[9] ^ data_4[10])) ^ ((data_4[11] ^ data_4[12]) ^ (data_4[13] ^ data_4[14])))) ^ ((((data_4[15] ^ data_5[0]) ^ (data_5[1] ^ data_5[2])) ^ ((data_5[3] ^ data_5[4]) ^ (data_5[5] ^ data_5[6]))) ^ (((data_5[7] ^ data_5[8]) ^ (data_5[9] ^ data_5[10])) ^ ((data_5[11] ^ data_5[12]) ^ (data_5[13] ^ data_5[14]))))) ^ (((((data_5[15] ^ data_6[0]) ^ (data_6[1] ^ data_6[2])) ^ ((data_6[3] ^ data_6[4]) ^ (data_6[5] ^ data_6[6]))) ^ (((data_6[7] ^ data_6[8]) ^ (data_6[9] ^ data_6[10])) ^ ((data_6[11] ^ data_6[12]) ^ (data_6[13] ^ data_6[14])))) ^ ((((data_6[15] ^ data_7[0]) ^ (data_7[1] ^ data_7[2])) ^ ((data_7[3] ^ data_7[4]) ^ (data_7[5] ^ data_7[6]))) ^ (((data_7[7] ^ data_7[8]) ^ (data_7[9] ^ data_7[10])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
assign cur_code[7] = data_7[15];
assign wrong_pos = cur_code ^ code;

always@(posedge update) begin
    cr_data = {data_7,data_6,data_5,data_4,data_3,data_2,data_1,data_0};
    if(wrong_pos != 0)
        cr_data[wrong_pos-1] = !cr_data[wrong_pos-1];
end

endmodule