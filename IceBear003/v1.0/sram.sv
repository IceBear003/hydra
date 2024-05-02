module dual_port_sram
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

(*ram_style = "ultra"*) reg [DATA_WIDTH-1:0] d_latches [DATA_DEPTH-1:0];

//always @(negedge rst_n) begin
//    d_latches <= 0;
//end

always @(posedge clk) begin
    if(wr_en && rst_n)
        d_latches[wr_addr] = din;
end

always @(posedge clk) begin
    if(rd_en && rst_n)
        dout = d_latches[rd_addr];
end

endmodule