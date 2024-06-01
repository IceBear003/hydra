module port_sram_matcher
#(parameter PORT_IDX = 0)
(
    input clk,
    input rst_n,

    input [4:0] threshold,

    input match_enable,
    input [3:0] cnt_16,
    output reg matching_find,   //组合逻辑式更新匹配结果
    output reg [4:0] matching_sram,

    output reg match_end,
    output reg [4:0] matched_sram,

    input [3:0] new_dest_port,
    input [2:0] new_prior,
    input [8:0] new_length
);

// 0 - 空闲
// 1 - 匹配中
// 2 - 匹配完成 end在此时拉高 下一刻跳转到3
// 3 - 重置阶段 enable在此时拉低 下一刻跳转到0
reg [1:0] state;

reg [7:0] matching_tick;

always @(posedge clk) begin
    if(!rst_n) begin
        state <= 2'd0;
    end else if(state == 0 && match_enable == 1) begin
        state <= 2'd1;
        match_end <= 0;
    end else if(state == 1 && matching_tick >= threshold && matching_find == 1) begin
        state <= 2'd2;
        match_end <= 1;
    end else if(state == 2) begin
        state <= 2'd3;
    end else if(state == 3) begin
        state <= 2'd0;
    end
end

endmodule