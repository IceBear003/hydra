module port_wr_sram_matcher
#(parameter PORT_IDX = 0)
(
    input clk,
    input rst_n,

    /*
     * 可配置参数
     * |- match_mode - SRAM分配模式
     *      |- 0 - 静态分配模式
     *      |- 1 - 半动态分配模式
     *      |- 2/3 - 全动态分配模式
     * |- match_threshold - 匹配阈值，当匹配时长超过该值后，一旦有任何可用的即完成匹配
     *      |- 静态分配模式 最大为1
     *      |- 半动态分配模式 最大为17
     *      |- 全动态分配模式 最大为32
     */
    input [1:0] match_mode,
    input [4:0] match_threshold,

    /* 与前端交互的信号 */
    input [3:0] new_dest_port,
    input [8:0] new_length,
    input match_enable,
    output reg match_end,

    /*
     * 与后端交互的信号 
     * |- viscous - 端口是否处于粘滞状态
     * |- matching_next_sram - 下一周期尝试匹配的SRAM
     * |- matching_best_sram - 当前匹配到最优的SRAM
     */
    input viscous,
    output reg [4:0] matching_next_sram,
    output reg [4:0] matching_best_sram,

    /* 
     * 当前锚定的SRAM的状态
     * |- free_space - SRAM剩余空间（半字）
     * |- accessible - SRAM是否可用
     * |- packet_amount - SRAM中新包端口对应的数据包数量
     */
    input [10:0] free_space,
    input accessible,
    input [8:0] packet_amount
);

reg [1:0] state;

reg [3:0] old_dest_port;

reg matching_find;
reg [7:0] matching_tick;
reg [4:0] matching_sram;
reg [8:0] max_amount;

always @(posedge clk) begin
    if(!rst_n) begin
        state <= 2'd0;
    end else if(state == 0 && match_enable == 1) begin
        if(new_dest_port == old_dest_port && viscous &&
           free_space[matching_best_sram] >= new_length) begin
            match_end <= 1;
            state <= 2'd2;
        end else begin
            match_end <= 0;
            state <= 2'd1;
        end
    end else if(state == 1 && matching_tick >= match_threshold && matching_find == 1) begin
        match_end <= 1;
        state <= 2'd2;
    end else if(state == 2) begin
        state <= 2'd0;
    end
end

always @(posedge clk) begin
    if(state == 1) begin
        matching_tick <= matching_tick + 1;
    end else begin
        matching_tick <= 0;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        matching_next_sram <= PORT_IDX;
    end else begin
        case(match_mode)
            0: matching_next_sram <= {PORT_IDX, matching_next_sram == {PORT_IDX,1'b0} ? 1'b1 : 1'b1};
            1: if(matching_next_sram <= 15) matching_next_sram <= matching_next_sram + 16;
               else if(matching_next_sram == 31) matching_next_sram <= PORT_IDX;
               else matching_next_sram <= matching_next_sram + 1;
            default: matching_next_sram <= matching_next_sram + 1;
        endcase
    end
end

always @(posedge clk) begin
    matching_sram <= matching_next_sram;
end

always @(posedge clk) begin
    if(state != 1) begin
        matching_find <= 0;
        max_amount <= 0;
    end else if(free_space < new_length) begin
    end else if(accessible == 1) begin
    end else if(packet_amount > max_amount) begin
        matching_best_sram <= matching_sram;
        max_amount <= packet_amount;
        matching_find <= 1;
    end
end

endmodule