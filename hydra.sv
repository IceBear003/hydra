`include "port_wr_sram_matcher.sv"
`include "port_wr_frontend.sv"
`include "sram_interface.sv"
`include "decoder_16_4.sv"
`include "decoder_32_5.sv"

module hydra
(
    input clk,
    input rst_n,

    //基本IO口
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] [15:0] wr_data,
    input [15:0] pause,

    output reg full,
    output reg almost_full,

    input [15:0] ready,
    output reg [15:0] rd_sop,
    output reg [15:0] rd_eop,
    output reg [15:0] rd_vld,
    output reg [15:0] [15:0] rd_data,

    //配置IO口
    input [15:0] wrr_enable,
    input [4:0] match_threshold,
    input [1:0] match_mode,
    input [3:0] viscosity
);

reg [4:0] time_stamp;
always @(posedge clk) begin
    time_stamp <= time_stamp + 1;
end

wire wr_xfer_data_vld [15:0];
wire [15:0] wr_xfer_data [15:0];
wire wr_end_of_packet [15:0];

reg [15:0] queue_head [15:0] [7:0];
reg [15:0] queue_tail [15:0] [7:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    wire match_end;
    wire match_enable;
    wire [3:0] new_dest_port;
    wire [8:0] new_length;

    port_wr_frontend port_wr_frontend(
        .clk(clk),
        .rst_n(rst_n),

        .wr_sop(wr_sop[port]),
        .wr_vld(wr_vld[port]),
        .wr_data(wr_data[port]),
        .wr_eop(wr_eop[port]),
        .pause(pause[port]), 

        .xfer_data_vld(wr_xfer_data_vld[port]),
        .xfer_data(wr_xfer_data[port]),
        .end_of_packet(wr_end_of_packet[port]),
        
        .match_end(match_end),
        .match_enable(match_enable),
        .new_dest_port(new_dest_port),
        .new_length(new_length)
    );

    reg [4:0] next_matching_sram;
    reg [4:0] matching_sram;
    reg [8:0] packet_amount;
    /*
     * 生成下下周期尝试匹配的SRAM编号
     * PORT_IDX与时间戳的参与保证同一周期每个端口总尝试匹配不同的SRAM，避免进一步的仲裁
     */
    always @(posedge clk) begin
        case(match_mode)
            /* 静态分配模式，在端口绑定的2块SRAM之间来回搜索 */
            0: next_matching_sram <= {port[3:0], time_stamp[0]};
            /* 半动态分配模式，在端口绑定的1块SRAM和16块共享的SRAM中轮流搜索 */
            1: next_matching_sram <= time_stamp[0] ? {1'b0, time_stamp[4:1] + port[3:0]} : {1'b1, port[3:0]};
            /* 全动态分配模式，在32块共享的SRAM中轮流搜索 */
            default: next_matching_sram <= time_stamp + port[3:0];
        endcase
    end
    always @(posedge clk) begin
        matching_sram <= next_matching_sram;
        packet_amount <= packet_amounts[next_matching_sram];
    end
    
    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),
    
        .match_mode(match_mode),
        .match_threshold(match_threshold),

        .new_dest_port(new_dest_port),
        .new_length(new_length),
        .match_enable(match_enable),
        .match_end(match_end),

        .matching_sram(matching_sram)
    );
end endgenerate

wire [8:0] packet_amounts [31:0];
wire [10:0] free_spaces [31:0];

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    sram_interface sram_interface(
        .clk(clk),
        .rst_n(rst_n), 

        .time_stamp(time_stamp),
        .SRAM_IDX(sram[4:0]),
        .match_mode(match_mode),
        
        .packet_amount(packet_amounts[sram]),
        .free_space(free_spaces[sram])
    );
end endgenerate 
endmodule