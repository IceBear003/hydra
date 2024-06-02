module decoder_16_4(
    input [15:0] select,
    output reg [3:0] idx
);

always @(select) begin
    case(select)
        16'h0001: idx = 4'd0;
        16'h0002: idx = 4'd1;
        16'h0004: idx = 4'd2;
        16'h0008: idx = 4'd3;
        16'h0010: idx = 4'd4;
        16'h0020: idx = 4'd5;
        16'h0040: idx = 4'd6;
        16'h0080: idx = 4'd7;
        16'h0100: idx = 4'd8;
        16'h0200: idx = 4'd9;
        16'h0400: idx = 4'd10;
        16'h0800: idx = 4'd11;
        16'h1000: idx = 4'd12;
        16'h2000: idx = 4'd13;
        16'h4000: idx = 4'd14;
        16'h8000: idx = 4'd15;
        default: idx = 4'd0;
    endcase
end

endmodule