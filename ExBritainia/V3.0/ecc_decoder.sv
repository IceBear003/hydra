module ecc_decoder(
    input clk,

    input [127:0] data,
    input [7:0] code,
    input enable,
    
    output reg [127:0] cr_data
);

reg [7:0] cur_code;

//TODO 时序性验证
always @(posedge enable) begin
    //6t(XOR)
    cur_code[0] <= (((((data[0] ^ data[2]) ^ (data[4] ^ data[6])) ^ ((data[8] ^ data[10]) ^ (data[12] ^ data[14]))) ^ (((data[16] ^ data[18]) ^ (data[20] ^ data[22])) ^ ((data[24] ^ data[26]) ^ (data[28] ^ data[30])))) ^ ((((data[32] ^ data[34]) ^ (data[36] ^ data[38])) ^ ((data[40] ^ data[42]) ^ (data[44] ^ data[46]))) ^ (((data[48] ^ data[50]) ^ (data[52] ^ data[54])) ^ ((data[56] ^ data[58]) ^ (data[60] ^ data[62]))))) ^ (((((data[64] ^ data[66]) ^ (data[68] ^ data[70])) ^ ((data[72] ^ data[74]) ^ (data[76] ^ data[78]))) ^ (((data[80] ^ data[82]) ^ (data[84] ^ data[86])) ^ ((data[88] ^ data[90]) ^ (data[92] ^ data[94])))) ^ ((((data[96] ^ data[98]) ^ (data[100] ^ data[102])) ^ ((data[104] ^ data[106]) ^ (data[108] ^ data[110]))) ^ (((data[112] ^ data[114]) ^ (data[116] ^ data[118])) ^ ((data[120] ^ data[122]) ^ (data[124] ^ data[126])))));
    cur_code[1] <= (((((data[1] ^ data[2]) ^ (data[5] ^ data[6])) ^ ((data[9] ^ data[10]) ^ (data[13] ^ data[14]))) ^ (((data[17] ^ data[18]) ^ (data[21] ^ data[22])) ^ ((data[25] ^ data[26]) ^ (data[29] ^ data[30])))) ^ ((((data[33] ^ data[34]) ^ (data[37] ^ data[38])) ^ ((data[41] ^ data[42]) ^ (data[45] ^ data[46]))) ^ (((data[49] ^ data[50]) ^ (data[53] ^ data[54])) ^ ((data[57] ^ data[58]) ^ (data[61] ^ data[62]))))) ^ (((((data[65] ^ data[66]) ^ (data[69] ^ data[70])) ^ ((data[73] ^ data[74]) ^ (data[77] ^ data[78]))) ^ (((data[81] ^ data[82]) ^ (data[85] ^ data[86])) ^ ((data[89] ^ data[90]) ^ (data[93] ^ data[94])))) ^ ((((data[97] ^ data[98]) ^ (data[101] ^ data[102])) ^ ((data[105] ^ data[106]) ^ (data[109] ^ data[110]))) ^ (((data[113] ^ data[114]) ^ (data[117] ^ data[118])) ^ ((data[121] ^ data[122]) ^ (data[125] ^ data[126])))));
    cur_code[2] <= (((((data[3] ^ data[4]) ^ (data[5] ^ data[6])) ^ ((data[11] ^ data[12]) ^ (data[13] ^ data[14]))) ^ (((data[19] ^ data[20]) ^ (data[21] ^ data[22])) ^ ((data[27] ^ data[28]) ^ (data[29] ^ data[30])))) ^ ((((data[35] ^ data[36]) ^ (data[37] ^ data[38])) ^ ((data[43] ^ data[44]) ^ (data[45] ^ data[46]))) ^ (((data[51] ^ data[52]) ^ (data[53] ^ data[54])) ^ ((data[59] ^ data[60]) ^ (data[61] ^ data[62]))))) ^ (((((data[67] ^ data[68]) ^ (data[69] ^ data[70])) ^ ((data[75] ^ data[76]) ^ (data[77] ^ data[78]))) ^ (((data[83] ^ data[84]) ^ (data[85] ^ data[86])) ^ ((data[91] ^ data[92]) ^ (data[93] ^ data[94])))) ^ ((((data[99] ^ data[100]) ^ (data[101] ^ data[102])) ^ ((data[107] ^ data[108]) ^ (data[109] ^ data[110]))) ^ (((data[115] ^ data[116]) ^ (data[117] ^ data[118])) ^ ((data[123] ^ data[124]) ^ (data[125] ^ data[126])))));
    cur_code[3] <= (((((data[7] ^ data[8]) ^ (data[9] ^ data[10])) ^ ((data[11] ^ data[12]) ^ (data[13] ^ data[14]))) ^ (((data[23] ^ data[24]) ^ (data[25] ^ data[26])) ^ ((data[27] ^ data[28]) ^ (data[29] ^ data[30])))) ^ ((((data[39] ^ data[40]) ^ (data[41] ^ data[42])) ^ ((data[43] ^ data[44]) ^ (data[45] ^ data[46]))) ^ (((data[55] ^ data[56]) ^ (data[57] ^ data[58])) ^ ((data[59] ^ data[60]) ^ (data[61] ^ data[62]))))) ^ (((((data[71] ^ data[72]) ^ (data[73] ^ data[74])) ^ ((data[75] ^ data[76]) ^ (data[77] ^ data[78]))) ^ (((data[87] ^ data[88]) ^ (data[89] ^ data[90])) ^ ((data[91] ^ data[92]) ^ (data[93] ^ data[94])))) ^ ((((data[103] ^ data[104]) ^ (data[105] ^ data[106])) ^ ((data[107] ^ data[108]) ^ (data[109] ^ data[110]))) ^ (((data[119] ^ data[120]) ^ (data[121] ^ data[122])) ^ ((data[123] ^ data[124]) ^ (data[125] ^ data[126])))));
    cur_code[4] <= (((((data[15] ^ data[16]) ^ (data[17] ^ data[18])) ^ ((data[19] ^ data[20]) ^ (data[21] ^ data[22]))) ^ (((data[23] ^ data[24]) ^ (data[25] ^ data[26])) ^ ((data[27] ^ data[28]) ^ (data[29] ^ data[30])))) ^ ((((data[47] ^ data[48]) ^ (data[49] ^ data[50])) ^ ((data[51] ^ data[52]) ^ (data[53] ^ data[54]))) ^ (((data[55] ^ data[56]) ^ (data[57] ^ data[58])) ^ ((data[59] ^ data[60]) ^ (data[61] ^ data[62]))))) ^ (((((data[79] ^ data[80]) ^ (data[81] ^ data[82])) ^ ((data[83] ^ data[84]) ^ (data[85] ^ data[86]))) ^ (((data[87] ^ data[88]) ^ (data[89] ^ data[90])) ^ ((data[91] ^ data[92]) ^ (data[93] ^ data[94])))) ^ ((((data[111] ^ data[112]) ^ (data[113] ^ data[114])) ^ ((data[115] ^ data[116]) ^ (data[117] ^ data[118]))) ^ (((data[119] ^ data[120]) ^ (data[121] ^ data[122])) ^ ((data[123] ^ data[124]) ^ (data[125] ^ data[126])))));
    cur_code[5] <= (((((data[31] ^ data[32]) ^ (data[33] ^ data[34])) ^ ((data[35] ^ data[36]) ^ (data[37] ^ data[38]))) ^ (((data[39] ^ data[40]) ^ (data[41] ^ data[42])) ^ ((data[43] ^ data[44]) ^ (data[45] ^ data[46])))) ^ ((((data[47] ^ data[48]) ^ (data[49] ^ data[50])) ^ ((data[51] ^ data[52]) ^ (data[53] ^ data[54]))) ^ (((data[55] ^ data[56]) ^ (data[57] ^ data[58])) ^ ((data[59] ^ data[60]) ^ (data[61] ^ data[62]))))) ^ (((((data[95] ^ data[96]) ^ (data[97] ^ data[98])) ^ ((data[99] ^ data[100]) ^ (data[101] ^ data[102]))) ^ (((data[103] ^ data[104]) ^ (data[105] ^ data[106])) ^ ((data[107] ^ data[108]) ^ (data[109] ^ data[110])))) ^ ((((data[111] ^ data[112]) ^ (data[113] ^ data[114])) ^ ((data[115] ^ data[116]) ^ (data[117] ^ data[118]))) ^ (((data[119] ^ data[120]) ^ (data[121] ^ data[122])) ^ ((data[123] ^ data[124]) ^ (data[125] ^ data[126])))));
    cur_code[6] <= (((((data[63] ^ data[64]) ^ (data[65] ^ data[66])) ^ ((data[67] ^ data[68]) ^ (data[69] ^ data[70]))) ^ (((data[71] ^ data[72]) ^ (data[73] ^ data[74])) ^ ((data[75] ^ data[76]) ^ (data[77] ^ data[78])))) ^ ((((data[79] ^ data[80]) ^ (data[81] ^ data[82])) ^ ((data[83] ^ data[84]) ^ (data[85] ^ data[86]))) ^ (((data[87] ^ data[88]) ^ (data[89] ^ data[90])) ^ ((data[91] ^ data[92]) ^ (data[93] ^ data[94]))))) ^ (((((data[95] ^ data[96]) ^ (data[97] ^ data[98])) ^ ((data[99] ^ data[100]) ^ (data[101] ^ data[102]))) ^ (((data[103] ^ data[104]) ^ (data[105] ^ data[106])) ^ ((data[107] ^ data[108]) ^ (data[109] ^ data[110])))) ^ ((((data[111] ^ data[112]) ^ (data[113] ^ data[114])) ^ ((data[115] ^ data[116]) ^ (data[117] ^ data[118]))) ^ (((data[119] ^ data[120]) ^ (data[121] ^ data[122])) ^ ((data[123] ^ data[124]) ^ (data[125] ^ data[126])))));
    cur_code[7] <= data[127];
end

always@(negedge clk) begin
    //1t(XOR)
    cur_code = cur_code ^ code;
        
    cr_data = data;
    if(cur_code != 0)
        cr_data[cur_code-1] = !data[cur_code-1];
end

endmodule