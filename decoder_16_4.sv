module decoder_16_4(
    input [15:0] select,
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
    else if(select[10]) idx = 5'd10;
    else if(select[11]) idx = 5'd11;
    else if(select[12]) idx = 5'd12;
    else if(select[13]) idx = 5'd13;
    else if(select[14]) idx = 5'd14;
    else if(select[15]) idx = 5'd15;
    else idx = 5'd16;     
end

endmodule