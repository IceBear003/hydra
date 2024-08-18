module encoder_16_4(
    /*
     * |- select - 16位选通信号
     * |- idx - 5位编码信号，检测选通信号中最低1的位置
     */
    input [15:0] select,
    output reg [4:0] idx
);

always @(select) begin
    casex(select)
        16'bxxxxxxxxxxxxxxx1: idx = 5'd0;
        16'bxxxxxxxxxxxxxx10: idx = 5'd1;
        16'bxxxxxxxxxxxxx100: idx = 5'd2;
        16'bxxxxxxxxxxxx1000: idx = 5'd3;
        16'bxxxxxxxxxxx10000: idx = 5'd4;
        16'bxxxxxxxxxx100000: idx = 5'd5;
        16'bxxxxxxxxx1000000: idx = 5'd6;
        16'bxxxxxxxx10000000: idx = 5'd7;
        16'bxxxxxxx100000000: idx = 5'd8;
        16'bxxxxxx1000000000: idx = 5'd9;
        16'bxxxxx10000000000: idx = 5'd10;
        16'bxxxx100000000000: idx = 5'd11;
        16'bxxx1000000000000: idx = 5'd12;
        16'bxx10000000000000: idx = 5'd13;
        16'bx100000000000000: idx = 5'd14;
        16'b1000000000000000: idx = 5'd15;
        16'b0000000000000000: idx = 5'd16;
    endcase
end

endmodule