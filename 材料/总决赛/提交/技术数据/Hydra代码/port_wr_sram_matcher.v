module port_wr_sram_matcher(
    input clk,
    input rst_n,

    input [4:0] match_threshold,

    /* 与前端交互的信号 */
    input [5:0] new_length,
    input match_enable,
    input xfer_ready,
    output reg match_suc,

    /*
     * 与后端交互的信号 
     * |- match_sram - 当前尝试匹配的SRAM
     * |- match_best_sram - 当前已匹配到最优的SRAM
     * |- accessible - SRAM是否可用
     * |- free_space - SRAM剩余空间（半字）
     * |- packet_amount - SRAM中新包端口对应的数据包数量
     */
    input [4:0] match_sram,
    output reg [5:0] match_best_sram,
    input accessible,
    input [10:0] free_space,
    input [8:0] packet_amount
);

/* 
 * match_state - 匹配状态
 *             |- 0 - 未匹配
 *             |- 1 - 匹配中(落后于match_enable一拍)
 *             |- 2 - 匹配完成(与match_end同步拉高)
 */
reg [1:0] match_state;

/* 
 * 匹配信号
 * |- match_find - 是否已经匹配到可用的SRAM
 * |- match_tick - 当前匹配时长
 * |- max_amount - 当前最优SRAM中目的端口的数据量
 */
reg match_find;
reg [7:0] match_tick;
reg [8:0] max_amount;

always @(posedge clk) begin
    if(~rst_n) begin
        match_state <= 2'd0;
        match_suc <= 0;
    end else if(match_state == 2'd0 && match_enable) begin
        match_state <= 2'd1;
    end else if(match_state == 2'd1 && match_find && match_tick == match_threshold) begin
        /* 常规匹配成功(时间达到阈值且有结果) */
        match_suc <= 1;
        match_state <= 2'd2;
    end else if(match_state == 2'd2) begin
        match_suc <= 0;
        match_state <= 2'd0;
    end
end

always @(posedge clk) begin
    if(~rst_n || match_state == 2'd2) begin
        match_tick <= 0;
    end if(match_enable && match_tick != match_threshold) begin
        match_tick <= match_tick + 1;
    end
end

always @(posedge clk) begin
    if(~match_enable || xfer_ready) begin
        match_find <= 0;
        max_amount <= 0;
        match_best_sram <= 6'd32;
    end else if(~accessible) begin                  /* 未被占用 */
    end else if(free_space < new_length + 1) begin  /* 空间足够 */
    end else if(packet_amount >= max_amount) begin  /* 比当前更优 */
        match_best_sram <= match_sram;
        max_amount <= packet_amount;
        match_find <= 1;
    end
end

endmodule