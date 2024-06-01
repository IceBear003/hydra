module mux_32
#(parameter DATA_WIDTH = 16)
(
    input [31:0] state,
    input [DATA_WIDTH-1:0] data_in [31:0],
    output data_vld,
    output [DATA_WIDTH-1:0] data_out
);

reg [4:0] select;

assign data_vld = state != 32'h00000000;
assign data_out = data_in[select];

always @(select) begin
    case(state)
        32'h00000001: select = 5'd0;
        32'h00000002: select = 5'd1;
        32'h00000004: select = 5'd2;
        32'h00000008: select = 5'd3;
        32'h00000010: select = 5'd4;
        32'h00000020: select = 5'd5;
        32'h00000040: select = 5'd6;
        32'h00000080: select = 5'd7;
        32'h00000100: select = 5'd8;
        32'h00000200: select = 5'd9;
        32'h00000400: select = 5'd10;
        32'h00000800: select = 5'd11;
        32'h00001000: select = 5'd12;
        32'h00002000: select = 5'd13;
        32'h00004000: select = 5'd14;
        32'h00008000: select = 5'd15;
        32'h00010000: select = 5'd16;
        32'h00020000: select = 5'd17;
        32'h00040000: select = 5'd18;
        32'h00080000: select = 5'd19;
        32'h00100000: select = 5'd20;
        32'h00200000: select = 5'd21;
        32'h00400000: select = 5'd22;
        32'h00800000: select = 5'd23;
        32'h01000000: select = 5'd24;
        32'h02000000: select = 5'd25;
        32'h04000000: select = 5'd26;
        32'h08000000: select = 5'd27;
        32'h10000000: select = 5'd28;
        32'h20000000: select = 5'd29;
        32'h40000000: select = 5'd30;
        32'h80000000: select = 5'd31;
        default: select = 5'd0;
    endcase
end

endmodule