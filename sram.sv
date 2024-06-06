module sram
(
    input clk,
    input rst_n,
    
    input wr_en,
    input [13:0] wr_addr,
    input [15:0] din,
    
    input rd_en,
    input [13:0] rd_addr,
    output reg [15:0] dout
);

/* 8*36Kbit BRAM */
(* ram_style = "block" *) reg [15:0] d_latches [16383:0];

always @(posedge clk) begin
    if(wr_en && rst_n) begin 
        d_latches[wr_addr] <= din;
    end
end

always @(posedge clk) begin
    if(rd_en && rst_n) begin
        dout <= d_latches[rd_addr];
    end
end

endmodule