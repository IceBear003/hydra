module sram
(
    input clk,
    input rst_n,
    
    input wr_en,
    input [13:0] wr_addr,
    input [15:0] din,
    input [4:0] sram_idx,
    
    input rd_en,
    input [13:0] rd_addr,
    output reg [15:0] dout
);

/* 8*36Kbit BRAM */
(* ram_style = "block" *) reg [15:0] d_latches [16383:0];

always @(posedge clk) begin
    if(wr_en && rst_n) begin 
        //$display("wr_addr = %d %d %d",wr_addr,din,sram_idx);
        d_latches[wr_addr] <= din;
    end
end

always @(posedge clk) begin
    if(rd_en && rst_n) begin
        dout <= d_latches[rd_addr];
        //$display("rd_addr = %d %d %d",rd_addr,d_latches[rd_addr],sram_idx);
    end
end

endmodule