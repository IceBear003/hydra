module port_wr_sram_matcher(
    input clk,
    input rst_n,

    input [4:0] match_threshold,

    /* ????????????? */
    input [8:0] new_length,
    input match_enable,
    output reg match_suc,

    /*
     * ???????????? 
     * |- matching_sram - ???????????SRAM
     * |- matching_best_sram - ???????????SRAM
     */
    input [4:0] matching_sram,
    output reg [4:0] matching_best_sram,
    output update_matched_sram,

    /* 
     * ?????????SRAM????
     * |- accessible - SRAM??????
     * |- free_space - SRAM??????????
     * |- packet_amount - SRAM??????????????????????
     */
    input accessible,
    input [10:0] free_space,
    input [8:0] packet_amount
);

/* 
 * ?????
 * |- 0 - ?????
 * |- 1 - ?????(?????match_enable???)
 * |- 2 - ??????(??match_end???????)
 */
reg [1:0] match_state;

/* 
 * ??????
 * |- matching_find - ??????????????SRAM
 * |- matching_tick - ?????????
 * |- max_amount - ???????SRAM??????????????
 */
reg matching_find;
reg [7:0] matching_tick;
reg [8:0] max_amount;

assign update_matched_sram = match_enable && ~match_suc && matching_find;

always @(posedge clk) begin
    if(~rst_n) begin
        match_state <= 2'd0;
        match_suc <= 0;
    end else if(match_state == 2'd0 && match_enable) begin
        match_state <= 2'd1;
    end else if(match_state == 2'd1 && matching_find && matching_tick == match_threshold) begin
        /* ?????????(??????????????) */
        match_suc <= 1;
        match_state <= 2'd2;
        //$display("matching_best_sram = %d",matching_best_sram);
    end else if(match_state == 2'd2) begin
        match_suc <= 0;
        match_state <= 2'd0;
    end
end

always @(posedge clk) begin
    if(match_enable && matching_tick != match_threshold) begin
        matching_tick <= matching_tick + 1;
    end else begin
        matching_tick <= 0;
    end
end

always @(posedge clk) begin
    if(~match_enable || match_suc) begin
        matching_find <= 0;
        max_amount <= 0;
    end else if(~accessible) begin                  /* ??????? */
    end else if(free_space < new_length[8:3] + 1) begin      /* ????? */
    end else if(packet_amount >= max_amount) begin  /* ???????? */
        matching_best_sram <= matching_sram;
        max_amount <= packet_amount;
        matching_find <= 1;
        //$display("matching_sram = %d",matching_sram);
        //$display("packet_amount = %d",packet_amount);
        //$display("fr ee_space = %d %d",free_space,new_length);
    end
end

endmodule