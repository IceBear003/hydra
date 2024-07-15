module decoder_8_3(
    input [7:0] select,
    output reg [2:0] idx
);

always @(select) begin
    if(select[0]) idx = 3'd0;
    else if(select[1]) idx = 3'd1;
    else if(select[2]) idx = 3'd2;
    else if(select[3]) idx = 3'd3;
    else if(select[4]) idx = 3'd4;
    else if(select[5]) idx = 3'd5;
    else if(select[6]) idx = 3'd6;
    else if(select[7]) idx = 3'd7;
    else idx = 'dx;     
end

endmodule