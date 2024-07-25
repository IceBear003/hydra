`timescale 1ns/1ns

module tb_hydra_top();

reg clk;
reg rst_n;

reg [15:0] wr_sop  ;
reg [15:0] wr_eop  ;
reg [15:0] wr_vld  ;
reg [15:0][15:0] wr_data;
//reg match_suc;

integer file;

reg [15:0] ready;

//reg    [15:0]   ready   ;

initial begin
    file = $fopen("D:/Engineer/Hydra_2/hydra/debug_temp/in.txt","r");
end

reg wrr_enable = 1;
reg [4:0] match_threshold = 15;
reg [1:0] match_mode = 2;
    //????????????????
//reg [3:0] viscosity = 0;

always@(posedge clk or  negedge rst_n) begin
    $fscanf(file,"%h %h %h %h %h %h %h %h %h %h",clk,rst_n,wr_sop,wr_eop,wr_vld,wr_data,wrr_enable,match_threshold,match_mode,ready);
end

wire full;
wire almost_full;
wire [15:0] rd_sop;
wire [15:0] rd_eop;
wire [15:0] rd_vld;
wire [15:0] [15:0] rd_data;

hydra hydra_inst
(
    .clk (clk),
    .rst_n (rst_n),

    .wr_sop (wr_sop),
    .wr_eop (wr_eop),
    .wr_vld (wr_vld),
    .wr_data (wr_data),

    .wrr_enable (wrr_enable),
    .match_threshold (match_threshold),
    .match_mode (match_mode),

    .full (full),
    .almost_full (almost_full),

    .ready (ready),
    .rd_sop (rd_sop),
    .rd_eop (rd_eop),
    .rd_vld (rd_vld),
    .rd_data (rd_data)

);

endmodule
