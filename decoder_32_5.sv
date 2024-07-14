module decoder_32_5(
    input [31:0] select,
    output reg [4:0] idx
);

always @(select) begin
    if(select[0]) idx = 5'd0;
    else if(select[1]) idx = 5'd1;
    else if(select[2]) idx = 5'd2;
    else if(select[3]) idx = 5'd3;
    else if(select[4]) idx = 5'd4;
    else if(select[5]) idx = 5'd5;
    else if(select[6]) idx = 5'd6;
    else if(select[7]) idx = 5'd7;
    else if(select[8]) idx = 5'd8;
    else if(select[9]) idx = 5'd9;
    else if (select[10]) idx = 5'd10;
    else if (select[11]) idx = 5'd11;
    else if (select[12]) idx = 5'd12;
    else if (select[13]) idx = 5'd13;
    else if (select[14]) idx = 5'd14;
    else if(select[15]) idx = 5'd15;
    else if(select[16]) idx = 5'd16;
    else if(select[17]) idx = 5'd17;
    else if(select[18]) idx = 5'd18;
    else if(select[19]) idx = 5'd19;
    else if(select[20]) idx = 5'd20;
    else if(select[21]) idx = 5'd21;
    else if(select[22]) idx = 5'd22;
    else if(select[23]) idx = 5'd23;
    else if(select[24]) idx = 5'd24;
    else if (select[25]) idx = 5'd25;
    else if (select[26]) idx = 5'd26;
    else if (select[27]) idx = 5'd27;
    else if (select[28]) idx = 5'd28;
    else if (select[29]) idx = 5'd29;
    else if (select[30]) idx = 5'd30;
    else if (select[31]) idx = 5'd31;
    else idx = 'dx;                                          
end

endmodule