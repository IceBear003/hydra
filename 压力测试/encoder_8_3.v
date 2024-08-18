module encoder_8_3(
    /*
     * |- select - 8位选通信号
     * |- idx - 4位编码信号，检测选通信号中最低0的位置
     */
    input [7:0] select,
    output reg [3:0] idx
);

always @(select) begin
    casex(select)
        8'bxxxxxxx0: idx = 4'd0;
        8'bxxxxxx01: idx = 4'd1;
        8'bxxxxx011: idx = 4'd2;
        8'bxxxx0111: idx = 4'd3;
        8'bxxx01111: idx = 4'd4;
        8'bxx011111: idx = 4'd5;
        8'bx0111111: idx = 4'd6;
        8'b01111111: idx = 4'd7;
        8'b11111111: idx = 4'd8;
    endcase
end

endmodule