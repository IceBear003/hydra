module sram_rd_round(
    input clk,
    input rst_n,

    input [15:0] select,
    input next,
    output reg [3:0] port
);

reg [15:0] mask;

always @(posedge clk) begin
    if(!rst_n) begin
        mask <= 16'hFFFF;
    end else if(next) begin
        mask[port] <= 0;
    end else if(mask & select == 0) begin
        mask <= 16'hFFFF;
    end
end

wire [15:0] masked = mask & select;

//急需优化 多路16to4译码器
always @(posedge clk) begin
    if(!next) begin end
    else if(masked[0]) port <= 4'h0;
    else if(masked[1]) port <= 4'h1;
    else if(masked[2]) port <= 4'h2;
    else if(masked[3]) port <= 4'h3;
    else if(masked[4]) port <= 4'h4;
    else if(masked[5]) port <= 4'h5;
    else if(masked[6]) port <= 4'h6;
    else if(masked[7]) port <= 4'h7;
    else if(masked[8]) port <= 4'h8;
    else if(masked[9]) port <= 4'h9;
    else if(masked[10]) port <= 4'hA;
    else if(masked[11]) port <= 4'hB;
    else if(masked[12]) port <= 4'hC;
    else if(masked[13]) port <= 4'hD;
    else if(masked[14]) port <= 4'hE;
    else if(masked[15]) port <= 4'hF;
    else begin end
end

endmodule