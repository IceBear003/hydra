module mux_16
#(parameter DATA_WIDTH = 16)
(
    input [15:0] state,
    input [DATA_WIDTH-1:0] data_in [15:0],
    output data_vld,
    output reg [3:0] data_idx,
    output [DATA_WIDTH-1:0] data_out
);

assign data_vld = state != 16'h0000;
assign data_out = data_in[data_idx];

always @(state) begin
    case(state)
        16'h0001: data_idx = 4'd0;
        16'h0002: data_idx = 4'd1;
        16'h0004: data_idx = 4'd2;
        16'h0008: data_idx = 4'd3;
        16'h0010: data_idx = 4'd4;
        16'h0020: data_idx = 4'd5;
        16'h0040: data_idx = 4'd6;
        16'h0080: data_idx = 4'd7;
        16'h0100: data_idx = 4'd8;
        16'h0200: data_idx = 4'd9;
        16'h0400: data_idx = 4'd10;
        16'h0800: data_idx = 4'd11;
        16'h1000: data_idx = 4'd12;
        16'h2000: data_idx = 4'd13;
        16'h4000: data_idx = 4'd14;
        16'h8000: data_idx = 4'd15;
        default: data_idx = 4'd0;
    endcase
end

endmodule