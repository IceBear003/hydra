module port_rd_dispatch(
    input clk,
    input rst_n,

    input wrr_en,
    input [7:0] queue_available,
    input next,

    output available,
    output reg [2:0] prior
);

assign available = queue_available != 0;
assign one_hot = queue_available ^ (~queue_available - 1);

always @(one_hot) begin
    case(one_hot) 
        8'h01: prior = 3'd0;
        8'h02: prior = 3'd1;
        8'h04: prior = 3'd2;
        8'h08: prior = 3'd3;
        8'h10: prior = 3'd4;
        8'h20: prior = 3'd5;
        8'h40: prior = 3'd6;
        8'h80: prior = 3'd7;
        default: prior = 3'd0;
    endcase;
end

reg [7:0] wrr_mask;


endmodule