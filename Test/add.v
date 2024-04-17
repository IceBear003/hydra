module sum(
    input [3:0] a,
    input [3:0] b,
    input carry_in,
    output reg [3:0] sum,
    output reg carry_out
);

wire tmp_wire;
reg [3:0] tmp_reg;

always @(a or b) begin
    sum = a + b;
end

endmodule