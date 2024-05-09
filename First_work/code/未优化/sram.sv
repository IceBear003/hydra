module sram
#(
    parameter ADDR_WIDTH = 14,
    parameter DATA_WIDTH = 16,
    parameter DATA_DEPTH = 16384
)
(
    input clk,
    input rst_n,
    
    input wr_en,
    input [ADDR_WIDTH-1:0] wr_addr,
    input [DATA_WIDTH-1:0] din,
    
    input rd_en,
    input [ADDR_WIDTH-1:0] rd_addr,
    output reg [DATA_WIDTH-1:0] dout
);

reg [DATA_WIDTH-1:0] d_latches [DATA_DEPTH-1:0];

always @(posedge clk) begin
    if(wr_en && rst_n) begin 
        d_latches[wr_addr] <= din;
        $display("wr_addr = %d",wr_addr);
        $display("din = %d",din);
    end
end

always @(posedge clk) begin
    if(rd_en && rst_n) begin
        dout <= d_latches[rd_addr];
    end
end

endmodule