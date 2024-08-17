module encoder_32_5(
    /*
     * |- select - 32位选通信号
     * |- idx - 6位编码信号，检测选通信号中最低1的位置
     */
    input [31:0] select,
    output reg [5:0] idx
);

always @(select) begin
    casex(select)
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1: idx = 6'd0;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx10: idx = 6'd1;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx100: idx = 6'd2;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxx1000: idx = 6'd3;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxx10000: idx = 6'd4;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxx100000: idx = 6'd5;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxx1000000: idx = 6'd6;
        32'bxxxxxxxxxxxxxxxxxxxxxxxx10000000: idx = 6'd7;
        32'bxxxxxxxxxxxxxxxxxxxxxxx100000000: idx = 6'd8;
        32'bxxxxxxxxxxxxxxxxxxxxxx1000000000: idx = 6'd9;
        32'bxxxxxxxxxxxxxxxxxxxxx10000000000: idx = 6'd10;
        32'bxxxxxxxxxxxxxxxxxxxx100000000000: idx = 6'd11;
        32'bxxxxxxxxxxxxxxxxxxx1000000000000: idx = 6'd12;
        32'bxxxxxxxxxxxxxxxxxx10000000000000: idx = 6'd13;
        32'bxxxxxxxxxxxxxxxxx100000000000000: idx = 6'd14;
        32'bxxxxxxxxxxxxxxxx1000000000000000: idx = 6'd15;
        32'bxxxxxxxxxxxxxxx10000000000000000: idx = 6'd16;
        32'bxxxxxxxxxxxxxx100000000000000000: idx = 6'd17;
        32'bxxxxxxxxxxxxx1000000000000000000: idx = 6'd18;
        32'bxxxxxxxxxxxx10000000000000000000: idx = 6'd19;
        32'bxxxxxxxxxxx100000000000000000000: idx = 6'd20;
        32'bxxxxxxxxxx1000000000000000000000: idx = 6'd21;
        32'bxxxxxxxxx10000000000000000000000: idx = 6'd22;
        32'bxxxxxxxx100000000000000000000000: idx = 6'd23;
        32'bxxxxxxx1000000000000000000000000: idx = 6'd24;
        32'bxxxxxx10000000000000000000000000: idx = 6'd25;
        32'bxxxxx100000000000000000000000000: idx = 6'd26;
        32'bxxxx1000000000000000000000000000: idx = 6'd27;
        32'bxxx10000000000000000000000000000: idx = 6'd28;
        32'bxx100000000000000000000000000000: idx = 6'd29;
        32'bx1000000000000000000000000000000: idx = 6'd30;
        32'b10000000000000000000000000000000: idx = 6'd31;
        32'b00000000000000000000000000000000: idx = 6'd32;
    endcase
end

endmodule