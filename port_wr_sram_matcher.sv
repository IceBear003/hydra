module port_wr_sram_matcher
#(parameter PORT_IDX = 0) /* 本匹配器所属的端口编号(0~15) */
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
     *      |- 静态分配模式 最大为0
     *      |- 半动态分配模式 最大为16
     *      |- 全动态分配模式 最大为31
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
     * |- accessible - SRAM是否可用
     * |- free_space - SRAM剩余空间（半字）
     * |- packet_amount - SRAM中新包端口对应的数据包数量
     */
    input accessible,
    input [10:0] free_space,
    input [8:0] packet_amount
);

/* 
 * 匹配状态
 * |- 0 - 未匹配
 * |- 1 - 匹配中(落后于match_enable一拍)
 * |- 2 - 匹配完成(与match_end同步拉高)
 */
reg [1:0] state;

/* 
 * 匹配信号
 * |- matching_find - 是否已经匹配到可用的SRAM
 * |- matching_tick - 当前匹配时长
 * |- matching_sram - 当前尝试匹配的SRAM(matching_next_sram打一拍)
 * |- max_amount - 当前最优SRAM中目的端口的数据量
 */
reg matching_find;
reg [7:0] matching_tick;
reg [4:0] matching_sram;
reg [8:0] max_amount;

/* 粘性匹配支持
 * |- old_dest_port - 上一匹配数据包的目的端口
 * |- old_free_space - 上一匹配到的SRAM的剩余空间
 */
reg [3:0] old_dest_port;
reg [10:0] old_free_space;

always @(posedge clk) begin
    if(~rst_n) begin
        state <= 2'd0;
    end else if(state == 2'd0 && match_enable == 1) begin
        if(new_dest_port == old_dest_port && old_free_space >= new_length && viscous) begin
            /* 粘滞匹配成功(新旧目的端口相同，SRAM有足够空间且仍处于粘滞状态)，直接跳过常规匹配阶段 */
            match_end <= 1;
            state <= 2'd2;
            old_free_space <= old_free_space - new_length;
        end else begin
            match_end <= 0;
            state <= 2'd1;
        end
    end else if(state == 2'd1 && matching_find && matching_tick >= match_threshold) begin
        /* 常规匹配成功(时间达到阈值且有结果) */
        match_end <= 1;
        state <= 2'd2;
        old_free_space <= free_space - new_length;
        old_dest_port <= new_dest_port;
    end else if(state == 2'd2) begin
        match_end <= 0;
        state <= 2'd0;
    end
end

always @(posedge clk) begin
    if(state == 2'd1) begin
        matching_tick <= matching_tick + 1;
    end else begin
        matching_tick <= 0;
    end
end

/*
 * 预先生成下一周期要尝试匹配的SRAM编号
 * 生成后的编号传入后端，反馈得到匹配所需的free_space等信号
 *
 * PORT_IDX的参与保证同一周期每个端口总尝试匹配不同的SRAM，避免进一步的仲裁
 */
always @(posedge clk) begin
    if(~rst_n) begin
        case(match_mode)
            1: matching_next_sram <= 5'd16 + PORT_IDX;
            default: matching_next_sram <= {PORT_IDX, 1'b0};
        endcase;
    end else begin
        case(match_mode)
            /* 静态分配模式，在端口绑定的2块SRAM之间来回搜索 */
            0: matching_next_sram <= matching_next_sram ^ 5'b00001;
            /* 半动态分配模式，在端口绑定的1块SRAM和16块共享的SRAM中轮流搜索 */
            1: if(matching_next_sram <= 15) matching_next_sram <= matching_next_sram + 16;
               else if(matching_next_sram == 31) matching_next_sram <= {1'b0, PORT_IDX};
               else matching_next_sram <= matching_next_sram + 1;
            /* 全动态分配模式，在32块共享的SRAM中轮流搜索 */
            default: matching_next_sram <= matching_next_sram + 1;
        endcase
    end
end

always @(posedge clk) begin
    matching_sram <= matching_next_sram;
end

always @(posedge clk) begin
    if(state != 2'd1) begin
        matching_find <= 0;
        max_amount <= 0;
    end else if(accessible) begin                   /* 未被占用 */
    end else if(free_space < new_length) begin      /* 空间足够 */
    end else if(packet_amount >= max_amount) begin  /* 比当前更优 */
        matching_best_sram <= matching_sram;
        max_amount <= packet_amount;
        matching_find <= 1;
    end
end

endmodule