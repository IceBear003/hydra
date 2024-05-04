module ecc_encoder(
    input clk,

    //TODO ENABLE

    input [15:0] data_0,
    input [15:0] data_1,
    input [15:0] data_2,
    input [15:0] data_3,
    input [15:0] data_4,
    input [15:0] data_5,
    input [15:0] data_6,
    input [15:0] data_7,
    output reg [7:0] code
);

always @(posedge clk) begin
    //6t(XOR)
    code[0] <= (((((data_0[0] ^ data_0[2]) ^ (data_0[4] ^ data_0[6])) ^ ((data_0[8] ^ data_0[10]) ^ (data_0[12] ^ data_0[14]))) ^ (((data_1[0] ^ data_1[2]) ^ (data_1[4] ^ data_1[6])) ^ ((data_1[8] ^ data_1[10]) ^ (data_1[12] ^ data_1[14])))) ^ ((((data_2[0] ^ data_2[2]) ^ (data_2[4] ^ data_2[6])) ^ ((data_2[8] ^ data_2[10]) ^ (data_2[12] ^ data_2[14]))) ^ (((data_3[0] ^ data_3[2]) ^ (data_3[4] ^ data_3[6])) ^ ((data_3[8] ^ data_3[10]) ^ (data_3[12] ^ data_3[14]))))) ^ (((((data_4[0] ^ data_4[2]) ^ (data_4[4] ^ data_4[6])) ^ ((data_4[8] ^ data_4[10]) ^ (data_4[12] ^ data_4[14]))) ^ (((data_5[0] ^ data_5[2]) ^ (data_5[4] ^ data_5[6])) ^ ((data_5[8] ^ data_5[10]) ^ (data_5[12] ^ data_5[14])))) ^ ((((data_6[0] ^ data_6[2]) ^ (data_6[4] ^ data_6[6])) ^ ((data_6[8] ^ data_6[10]) ^ (data_6[12] ^ data_6[14]))) ^ (((data_7[0] ^ data_7[2]) ^ (data_7[4] ^ data_7[6])) ^ ((data_7[8] ^ data_7[10]) ^ (data_7[12] ^ data_7[14])))));
    code[1] <= (((((data_0[1] ^ data_0[2]) ^ (data_0[5] ^ data_0[6])) ^ ((data_0[9] ^ data_0[10]) ^ (data_0[13] ^ data_0[14]))) ^ (((data_1[1] ^ data_1[2]) ^ (data_1[5] ^ data_1[6])) ^ ((data_1[9] ^ data_1[10]) ^ (data_1[13] ^ data_1[14])))) ^ ((((data_2[1] ^ data_2[2]) ^ (data_2[5] ^ data_2[6])) ^ ((data_2[9] ^ data_2[10]) ^ (data_2[13] ^ data_2[14]))) ^ (((data_3[1] ^ data_3[2]) ^ (data_3[5] ^ data_3[6])) ^ ((data_3[9] ^ data_3[10]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_4[1] ^ data_4[2]) ^ (data_4[5] ^ data_4[6])) ^ ((data_4[9] ^ data_4[10]) ^ (data_4[13] ^ data_4[14]))) ^ (((data_5[1] ^ data_5[2]) ^ (data_5[5] ^ data_5[6])) ^ ((data_5[9] ^ data_5[10]) ^ (data_5[13] ^ data_5[14])))) ^ ((((data_6[1] ^ data_6[2]) ^ (data_6[5] ^ data_6[6])) ^ ((data_6[9] ^ data_6[10]) ^ (data_6[13] ^ data_6[14]))) ^ (((data_7[1] ^ data_7[2]) ^ (data_7[5] ^ data_7[6])) ^ ((data_7[9] ^ data_7[10]) ^ (data_7[13] ^ data_7[14])))));
    code[2] <= (((((data_0[3] ^ data_0[4]) ^ (data_0[5] ^ data_0[6])) ^ ((data_0[11] ^ data_0[12]) ^ (data_0[13] ^ data_0[14]))) ^ (((data_1[3] ^ data_1[4]) ^ (data_1[5] ^ data_1[6])) ^ ((data_1[11] ^ data_1[12]) ^ (data_1[13] ^ data_1[14])))) ^ ((((data_2[3] ^ data_2[4]) ^ (data_2[5] ^ data_2[6])) ^ ((data_2[11] ^ data_2[12]) ^ (data_2[13] ^ data_2[14]))) ^ (((data_3[3] ^ data_3[4]) ^ (data_3[5] ^ data_3[6])) ^ ((data_3[11] ^ data_3[12]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_4[3] ^ data_4[4]) ^ (data_4[5] ^ data_4[6])) ^ ((data_4[11] ^ data_4[12]) ^ (data_4[13] ^ data_4[14]))) ^ (((data_5[3] ^ data_5[4]) ^ (data_5[5] ^ data_5[6])) ^ ((data_5[11] ^ data_5[12]) ^ (data_5[13] ^ data_5[14])))) ^ ((((data_6[3] ^ data_6[4]) ^ (data_6[5] ^ data_6[6])) ^ ((data_6[11] ^ data_6[12]) ^ (data_6[13] ^ data_6[14]))) ^ (((data_7[3] ^ data_7[4]) ^ (data_7[5] ^ data_7[6])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
    code[3] <= (((((data_0[7] ^ data_0[8]) ^ (data_0[9] ^ data_0[10])) ^ ((data_0[11] ^ data_0[12]) ^ (data_0[13] ^ data_0[14]))) ^ (((data_1[7] ^ data_1[8]) ^ (data_1[9] ^ data_1[10])) ^ ((data_1[11] ^ data_1[12]) ^ (data_1[13] ^ data_1[14])))) ^ ((((data_2[7] ^ data_2[8]) ^ (data_2[9] ^ data_2[10])) ^ ((data_2[11] ^ data_2[12]) ^ (data_2[13] ^ data_2[14]))) ^ (((data_3[7] ^ data_3[8]) ^ (data_3[9] ^ data_3[10])) ^ ((data_3[11] ^ data_3[12]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_4[7] ^ data_4[8]) ^ (data_4[9] ^ data_4[10])) ^ ((data_4[11] ^ data_4[12]) ^ (data_4[13] ^ data_4[14]))) ^ (((data_5[7] ^ data_5[8]) ^ (data_5[9] ^ data_5[10])) ^ ((data_5[11] ^ data_5[12]) ^ (data_5[13] ^ data_5[14])))) ^ ((((data_6[7] ^ data_6[8]) ^ (data_6[9] ^ data_6[10])) ^ ((data_6[11] ^ data_6[12]) ^ (data_6[13] ^ data_6[14]))) ^ (((data_7[7] ^ data_7[8]) ^ (data_7[9] ^ data_7[10])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
    code[4] <= (((((data_0[15] ^ data_1[0]) ^ (data_1[1] ^ data_1[2])) ^ ((data_1[3] ^ data_1[4]) ^ (data_1[5] ^ data_1[6]))) ^ (((data_1[7] ^ data_1[8]) ^ (data_1[9] ^ data_1[10])) ^ ((data_1[11] ^ data_1[12]) ^ (data_1[13] ^ data_1[14])))) ^ ((((data_2[15] ^ data_3[0]) ^ (data_3[1] ^ data_3[2])) ^ ((data_3[3] ^ data_3[4]) ^ (data_3[5] ^ data_3[6]))) ^ (((data_3[7] ^ data_3[8]) ^ (data_3[9] ^ data_3[10])) ^ ((data_3[11] ^ data_3[12]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_4[15] ^ data_5[0]) ^ (data_5[1] ^ data_5[2])) ^ ((data_5[3] ^ data_5[4]) ^ (data_5[5] ^ data_5[6]))) ^ (((data_5[7] ^ data_5[8]) ^ (data_5[9] ^ data_5[10])) ^ ((data_5[11] ^ data_5[12]) ^ (data_5[13] ^ data_5[14])))) ^ ((((data_6[15] ^ data_7[0]) ^ (data_7[1] ^ data_7[2])) ^ ((data_7[3] ^ data_7[4]) ^ (data_7[5] ^ data_7[6]))) ^ (((data_7[7] ^ data_7[8]) ^ (data_7[9] ^ data_7[10])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
    code[5] <= (((((data_1[15] ^ data_2[0]) ^ (data_2[1] ^ data_2[2])) ^ ((data_2[3] ^ data_2[4]) ^ (data_2[5] ^ data_2[6]))) ^ (((data_2[7] ^ data_2[8]) ^ (data_2[9] ^ data_2[10])) ^ ((data_2[11] ^ data_2[12]) ^ (data_2[13] ^ data_2[14])))) ^ ((((data_2[15] ^ data_3[0]) ^ (data_3[1] ^ data_3[2])) ^ ((data_3[3] ^ data_3[4]) ^ (data_3[5] ^ data_3[6]))) ^ (((data_3[7] ^ data_3[8]) ^ (data_3[9] ^ data_3[10])) ^ ((data_3[11] ^ data_3[12]) ^ (data_3[13] ^ data_3[14]))))) ^ (((((data_5[15] ^ data_6[0]) ^ (data_6[1] ^ data_6[2])) ^ ((data_6[3] ^ data_6[4]) ^ (data_6[5] ^ data_6[6]))) ^ (((data_6[7] ^ data_6[8]) ^ (data_6[9] ^ data_6[10])) ^ ((data_6[11] ^ data_6[12]) ^ (data_6[13] ^ data_6[14])))) ^ ((((data_6[15] ^ data_7[0]) ^ (data_7[1] ^ data_7[2])) ^ ((data_7[3] ^ data_7[4]) ^ (data_7[5] ^ data_7[6]))) ^ (((data_7[7] ^ data_7[8]) ^ (data_7[9] ^ data_7[10])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
    code[6] <= (((((data_3[15] ^ data_4[0]) ^ (data_4[1] ^ data_4[2])) ^ ((data_4[3] ^ data_4[4]) ^ (data_4[5] ^ data_4[6]))) ^ (((data_4[7] ^ data_4[8]) ^ (data_4[9] ^ data_4[10])) ^ ((data_4[11] ^ data_4[12]) ^ (data_4[13] ^ data_4[14])))) ^ ((((data_4[15] ^ data_5[0]) ^ (data_5[1] ^ data_5[2])) ^ ((data_5[3] ^ data_5[4]) ^ (data_5[5] ^ data_5[6]))) ^ (((data_5[7] ^ data_5[8]) ^ (data_5[9] ^ data_5[10])) ^ ((data_5[11] ^ data_5[12]) ^ (data_5[13] ^ data_5[14]))))) ^ (((((data_5[15] ^ data_6[0]) ^ (data_6[1] ^ data_6[2])) ^ ((data_6[3] ^ data_6[4]) ^ (data_6[5] ^ data_6[6]))) ^ (((data_6[7] ^ data_6[8]) ^ (data_6[9] ^ data_6[10])) ^ ((data_6[11] ^ data_6[12]) ^ (data_6[13] ^ data_6[14])))) ^ ((((data_6[15] ^ data_7[0]) ^ (data_7[1] ^ data_7[2])) ^ ((data_7[3] ^ data_7[4]) ^ (data_7[5] ^ data_7[6]))) ^ (((data_7[7] ^ data_7[8]) ^ (data_7[9] ^ data_7[10])) ^ ((data_7[11] ^ data_7[12]) ^ (data_7[13] ^ data_7[14])))));
    code[7] <= data_7[15];
    $display("data_0 = %b",data_0);
    $display("data_1 = %b",data_1);
    $display("data_2 = %b",data_2);
    $display("data_3 = %b",data_3);
    $display("data_4 = %b",data_4);
    $display("data_5 = %b",data_5);
    $display("data_6 = %b",data_6);
    $display("data_7 = %b",data_7);
end

endmodule