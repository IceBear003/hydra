module decoder_32_5(
    input [31:0] select,
    output reg [5:0] idx
);

always @(select) begin
    if(select[0]) idx = 6'd0;
    else if(select[1]) idx = 6'd1;
    else if(select[2]) idx = 6'd2;
    else if(select[3]) idx = 6'd3;
    else if(select[4]) idx = 6'd4;
    else if(select[5]) idx = 6'd5;
    else if(select[6]) idx = 6'd6;
    else if(select[7]) idx = 6'd7;
    else if(select[8]) idx = 6'd8;
    else if(select[9]) idx = 6'd9;
    else if(select[10]) idx = 6'd10;
    else if(select[11]) idx = 6'd11;
    else if(select[12]) idx = 6'd12;
    else if(select[13]) idx = 6'd13;
    else if(select[14]) idx = 6'd14;
    else if(select[15]) idx = 6'd15;
    else if(select[16]) idx = 6'd16;
    else if(select[17]) idx = 6'd17;
    else if(select[18]) idx = 6'd18;
    else if(select[19]) idx = 6'd19;
    else if(select[20]) idx = 6'd20;
    else if(select[21]) idx = 6'd21;
    else if(select[22]) idx = 6'd22;
    else if(select[23]) idx = 6'd23;
    else if(select[24]) idx = 6'd24;
    else if(select[25]) idx = 6'd25;
    else if(select[26]) idx = 6'd26;
    else if(select[27]) idx = 6'd27;
    else if(select[28]) idx = 6'd28;
    else if(select[29]) idx = 6'd29;
    else if(select[30]) idx = 6'd30;
    else if(select[31]) idx = 6'd31;
    else idx = 6'd32;
end

endmodule