module decoder_32_5(
    input [31:0] select,
    output reg [4:0] idx
);

always @(select) begin
    case(select)
        32'h00000001: idx = 5'd0;
        32'h00000002: idx = 5'd1;
        32'h00000004: idx = 5'd2;
        32'h00000008: idx = 5'd3;
        32'h00000010: idx = 5'd4;
        32'h00000020: idx = 5'd5;
        32'h00000040: idx = 5'd6;
        32'h00000080: idx = 5'd7;
        32'h00000100: idx = 5'd8;
        32'h00000200: idx = 5'd9;
        32'h00000400: idx = 5'd10;
        32'h00000800: idx = 5'd11;
        32'h00001000: idx = 5'd12;
        32'h00002000: idx = 5'd13;
        32'h00004000: idx = 5'd14;
        32'h00008000: idx = 5'd15;
        32'h00010000: idx = 5'd16;
        32'h00020000: idx = 5'd17;
        32'h00040000: idx = 5'd18;
        32'h00080000: idx = 5'd19;
        32'h00100000: idx = 5'd20;
        32'h00200000: idx = 5'd21;
        32'h00400000: idx = 5'd22;
        32'h00800000: idx = 5'd23;
        32'h01000000: idx = 5'd24;
        32'h02000000: idx = 5'd25;
        32'h04000000: idx = 5'd26;
        32'h08000000: idx = 5'd27;
        32'h10000000: idx = 5'd28;
        32'h20000000: idx = 5'd29;
        32'h40000000: idx = 5'd30;
        32'h80000000: idx = 5'd31;
        default: idx = 5'd0;
    endcase
end

endmodule