module port_wr_sram_matcher(
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
     *      |- 全动态分配模式 最大为30
     */
    input [1:0] match_mode,
    input [4:0] match_threshold,

    /* 与前端交互的信号 */
    input [3:0] new_dest_port,
    input [8:0] new_length,
    input match_enable,
    output reg match_suc,

    /*
     * 与后端交互的信号 
     * |- viscous - 端口是否处于粘滞状态
     * |- matching_sram - 当前尝试匹配的SRAM
     * |- matching_best_sram - 当前匹配到最优的SRAM
     */
    input viscous,
    input [4:0] matching_sram,
    output reg [4:0] matching_best_sram,
    output update_matched_sram,

    /* 
     * 当前锚定的SRAM的状态
     * |- accessible - SRAM是否可用
     * |- free_space - SRAM剩余空间（半字）
     * |- packet_amount - SRAM中新包端口对应的数据包数量
     */
    input accessible,
    input [10:0] free_space,
    input [8:0] packet_amount,

    output reg [1:0] match_state
);

/* 
 * 匹配状态
 * |- 0 - 未匹配
 * |- 1 - 匹配中(落后于match_enable一拍)
 * |- 2 - 匹配完成(与match_end同步拉高)
 */


/* 
 * 匹配信号
 * |- matching_find - 是否已经匹配到可用的SRAM
 * |- matching_tick - 当前匹配时长
 * |- max_amount - 当前最优SRAM中目的端口的数据量
 */
reg matching_find;
reg [7:0] matching_tick;
reg [8:0] max_amount;

/* 粘性匹配支持
 * |- old_dest_port - 上一匹配数据包的目的端口
 * |- old_free_space - 上一匹配到的SRAM的剩余空间
 */
reg [3:0] old_dest_port;
reg [10:0] old_free_space;
reg [10:0] best_free_space;

assign update_matched_sram = match_enable && ~match_suc && matching_find;

always @(posedge clk) begin
    if(~rst_n) begin
        match_state <= 2'd0;
        match_suc <= 0;
    end else if(match_state == 2'd0 && match_enable) begin
        if(new_dest_port == old_dest_port && old_free_space >= new_length && viscous) begin
            /* 粘滞匹配成功(新旧目的端口相同，SRAM有足够空间且仍处于粘滞状态)，直接跳过常规匹配阶段 */
            match_suc <= 1;
            match_state <= 2'd2;
            old_free_space <= old_free_space - new_length;
        end else begin
            match_state <= 2'd1;
        end
    end else if(match_state == 2'd1 && matching_find && matching_tick >= match_threshold) begin
        /* 常规匹配成功(时间达到阈值且有结果) */
        match_suc <= 1;
        match_state <= 2'd2;
        old_free_space <= best_free_space - new_length;
        old_dest_port <= new_dest_port;
    end else if(match_state == 2'd2) begin
        match_suc <= 0;
        match_state <= 2'd0;
    end
end

always @(posedge clk) begin
    if(match_enable) begin
        matching_tick <= matching_tick + 1;
    end else begin
        matching_tick <= 0;
    end
end

always @(posedge clk) begin
    if(~match_enable || match_suc) begin
        matching_find <= 0;
        max_amount <= 0;
    end else if(~accessible) begin                  /* 未被占用 */
    end else if(free_space < new_length) begin      /* 空间足够 */
    end else if(packet_amount >= max_amount) begin  /* 比当前更优 */
        best_free_space <= free_space;
        matching_best_sram <= matching_sram;
        max_amount <= packet_amount;
        matching_find <= 1;
    end
end

endmodule

//粘滞碰撞问题