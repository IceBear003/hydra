`timescale 1ns/1ns

module tb_wr_sram_matcher();

reg clk;
reg rst_n;

initial begin
    clk <= 0;
    rst_n <= 0;
    #42
    rst_n <= 1;
end

always #2 clk = ~clk;

reg [1:0] match_mode = 2;
reg [4:0] match_threshold = 31;

reg [3:0] new_dest_port;
reg [8:0] new_length;
reg match_enable;

reg match_end;

always @(posedge clk) begin
    if(!rst_n) begin
        match_enable <= 0;
        new_dest_port <= 0;
        new_length <= 0;
    end else if(match_end) begin
        match_enable <= 0;
        new_dest_port <= 0;
        new_length <= 0;
    end else if(!match_enable) begin
        match_enable <= 1;
        new_dest_port <= $random;
        new_length <= $random;
    end
end

reg [10:0] free_space;
reg accessible;
reg [8:0] packet_amount;
reg [10:0] cnt;

always @(posedge clk) begin
    cnt <= $random;
end

always @(posedge clk) begin
    if(!rst_n) begin
        free_space <= 0;
        accessible <= 0;
        packet_amount <= 0;
    end else begin
        free_space <= cnt;
        accessible <= cnt;
        packet_amount <= cnt;
    end
end

wire [4:0] matching_next_sram;
wire [4:0] matching_best_sram;

port_wr_sram_matcher port_wr_sram_matcher(
    .clk(clk),
    .rst_n(rst_n),
    
    .match_mode(match_mode),
    .match_threshold(match_threshold),

    .match_enable(match_enable),
    //.viscous(viscous),
    .matching_next_sram(matching_next_sram),
    .matching_best_sram(matching_best_sram),
    .match_end(match_end),
 
    .new_dest_port(new_dest_port),
    .new_length(new_length),
    
    .free_space(free_space),
    .accessible(accessible),
    .packet_amount(packet_amount)
    
);

endmodule
