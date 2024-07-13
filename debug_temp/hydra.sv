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

reg [5:0] wr_sram [15:0];
reg [5:0] matched_sram [15:0];
wire wr_xfer_data_vld [15:0];
wire [15:0] wr_xfer_data [15:0];
wire wr_end_of_packet [15:0];

reg [15:0] queue_head [15:0] [7:0];
reg [15:0] queue_tail [15:0] [7:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    wire ready_to_xfer;
    wire xfer_data_vld;
    wire [15:0] xfer_data;
    wire end_of_packet;
    assign wr_xfer_data_vld[port] = xfer_data_vld;
    assign wr_xfer_data[port] = xfer_data;
    assign wr_end_of_packet[port] = end_of_packet;

    wire match_suc;
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

        .ready_to_xfer(ready_to_xfer),
        .xfer_data_vld(xfer_data_vld),
        .xfer_data(xfer_data),
        .end_of_packet(end_of_packet),
        
        .match_suc(match_suc),
        .match_enable(match_enable),
        .new_dest_port(new_dest_port),
        .new_length(new_length)
    );

    reg [4:0] next_matching_sram;
    reg [4:0] matching_sram;
    
    /*
     * 生成下周期尝试匹配的SRAM编号
     * PORT_IDX与时间戳的参与保证同一周期每个端口总尝试匹配不同的SRAM，避免进一步的仲裁
     */
    always @(posedge clk) begin
        case(match_mode)
            /* 静态分配模式，在端口绑定的2块SRAM之间来回搜索 */
            0: next_matching_sram <= {port[3:0], time_stamp[0]};
            /* 半动态分配模式，在端口绑定的1块SRAM和16块共享的SRAM中轮流搜索 */
            1: next_matching_sram <= time_stamp[0] ? time_stamp + {port[3:0], 1'b0} : {port[3:0], 1'b0};
            /* 全动态分配模式，在32块共享的SRAM中轮流搜索 */
            default: next_matching_sram <= time_stamp + {port[3:0], 1'b0};
        endcase
    end

    reg [10:0] free_space;
    reg [8:0] packet_amount;

    always @(posedge clk) begin
        matching_sram <= next_matching_sram;
        free_space <= free_space[next_matching_sram];
        packet_amount <= packet_amounts[next_matching_sram][port];
    end

    reg [3:0] viscous_tick;
    wire viscous = viscous_tick > 0;

    always @(posedge clk) begin
        if(!rst_n) begin
            viscous_tick <= 4'd0;
        end else if(end_of_packet) begin
            viscous_tick <= viscosity;
        end else if(viscous_tick > 0) begin
            viscous_tick <= viscous_tick - 1;
        end
    end

    wire [4:0] matching_best_sram;
    wire update_matched_sram;

    always @(posedge clk) begin
        if(!rst_n) begin
            wr_sram[port] <= 6'd32;
        end else if(ready_to_xfer) begin
            wr_sram[port] <= matching_best_sram;
        end else if(end_of_packet) begin
            wr_sram[port] <= 6'd32;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            matched_sram[port] <= 6'd32;
        end else if(update_matched_sram) begin
            matched_sram[port] <= matching_best_sram;
        end else begin
            matched_sram[port] <= 6'd32;
        end
    end
    
    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),
    
        .match_mode(match_mode),
        .match_threshold(match_threshold),

        .new_dest_port(new_dest_port),
        .new_length(new_length),
        .match_enable(match_enable),
        .match_suc(match_suc),

        .viscous(viscous),
        .matching_sram(matching_sram),
        .matching_best_sram(matching_best_sram),
        .update_matched_sram(update_matched_sram),

        .accessible(accessible),
        .free_space(free_space),
        .packet_amount(packet_amount)
    );
end endgenerate

reg [8:0] packet_amounts [31:0][15:0];
reg [10:0] free_spaces [31:0];
reg accessibilities [31:0];

reg [3:0] wr_packet_dest_port [31:0];
reg [2:0] wr_packet_prior [31:0];
reg [15:0] wr_packet_head_addr [31:0];
reg [15:0] wr_packet_tail_addr [31:0];

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    reg [3:0] matching_port;

    wire [15:0] select_wr = {wr_sram[0] == sram, wr_sram[1] == sram, wr_sram[2] == sram, wr_sram[3] == sram, wr_sram[4] == sram, wr_sram[5] == sram, wr_sram[6] == sram, wr_sram[7] == sram, wr_sram[8] == sram, wr_sram[9] == sram, wr_sram[10] == sram, wr_sram[11] == sram, wr_sram[12] == sram, wr_sram[13] == sram, wr_sram[14] == sram, wr_sram[15] == sram};
    wire [15:0] select_matched = {wr_sram[0] == sram, wr_sram[1] == sram, wr_sram[2] == sram, wr_sram[3] == sram, wr_sram[4] == sram, wr_sram[5] == sram, wr_sram[6] == sram, wr_sram[7] == sram, wr_sram[8] == sram, wr_sram[9] == sram, wr_sram[10] == sram, wr_sram[11] == sram, wr_sram[12] == sram, wr_sram[13] == sram, wr_sram[14] == sram, wr_sram[15] == sram};
    
    always @(posedge clk) begin
        accessibilities[sram] <= select_wr == 0 && select_matched == 0;
    end

    wire [3:0] wr_port;
    decoder_16_4 decoder_16_4(
        .select(select_wr),
        .idx(wr_port)
    );

    sram_interface sram_interface(
        .clk(clk),
        .rst_n(rst_n), 

        .SRAM_IDX(sram[4:0]),
        .match_mode(match_mode),

        .wr_xfer_data_vld(wr_xfer_data_vld[wr_port]),
        .wr_xfer_data(wr_xfer_data[wr_port]),
        .wr_end_of_packet(wr_end_of_packet[wr_port]),

        .wr_packet_dest_port(wr_packet_dest_port[sram]),
        .wr_packet_prior(wr_packet_prior[sram]),
        .wr_packet_head_addr(wr_packet_head_addr[sram]),
        .wr_packet_tail_addr(wr_packet_tail_addr[sram])
    );
end endgenerate 
endmodule