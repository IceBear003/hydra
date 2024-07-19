module decoder_8_3(
    input [7:0] select,
    output reg [3:0] idx
);

always @(select) begin
    if(~select[0]) idx = 4'd0;
    else if(~select[1]) idx = 4'd1;
    else if(~select[2]) idx = 4'd2;
    else if(~select[3]) idx = 4'd3;
    else if(~select[4]) idx = 4'd4;
    else if(~select[5]) idx = 4'd5;
    else if(~select[6]) idx = 4'd6;
    else if(~select[7]) idx = 4'd7;
    else idx = 4'd8;
end