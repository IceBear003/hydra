module port_sram_matcher
#(parameter PORT_IDX = 0)
(
    input clk,
    input rst_n,

    // code -     mode          - threshold(max)
    // 0    -    static         - 1
    // 1    -    semi-dynamic   - 17
    // 2    -    dynamic        - 32
    input [1:0] match_mode,
    input [4:0] threshold,

    input match_enable,
    output reg [4:0] matching_best_sram,

    output reg match_end,
    output reg [4:0] matched_sram,

    input [3:0] new_dest_port,
    input [8:0] new_length,

    input [10:0] free_space [31:0],
    input occupied [31:0],
    input [8:0] packet_amount,

    input rd_sop
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
        if(new_dest_port == old_dest_port && free_space[matched_sram] >= new_length) begin
            match_end <= 1;
            state <= 2'd2;
        end else begin
            match_end <= 0;
            state <= 2'd1;
        end
    end else if(state == 1 && matching_tick >= threshold && matching_find == 1) begin
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
        matching_sram <= PORT_IDX;
    end else begin
        case(match_mode)
            0: matching_sram <= {PORT_IDX, matching_sram == {PORT_IDX,1'b0} ? 1'b1 : 1'b1};
            1: if(matching_sram <= 15) matching_sram <= matching_sram + 16;
               else if(matching_sram == 31) matching_sram <= PORT_IDX;
               else matching_sram <= matching_sram + 1;
            default: matching_sram <= matching_sram + 1;
        endcase
    end
end

always @(posedge clk) begin
    if(state != 1) begin
        matching_find <= 0;
        max_amount <= 0;
    end else if(free_space[matching_sram] < new_length) begin
    end else if(occupied[matching_sram] == 1) begin
    end else if(packet_amount > max_amount) begin
        matching_best_sram <= matching_sram;
        max_amount <= packet_amount;
        matching_find <= 1;
    end
end

endmodule