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

reg [4:0] time_stamp = 0;
always @(posedge clk) begin
    time_stamp <= time_stamp + 1;
end

reg [4:0] port = 8;

//genvar port;
//generate for(port = 0; port < 16; port = port + 1) begin : Ports

    reg [1:0] match_mode = 2;
    reg [4:0] match_threshold = 15;

    reg [3:0] new_dest_port;
    reg [8:0] new_length;
    reg match_enable;

    reg [1:0] match_state;

    always @(posedge clk) begin
        if(!rst_n) begin
            match_enable <= 0;
            new_dest_port <= 0;
            new_length <= 0;
        end else if(match_state == 2) begin
            match_enable <= 0;
            new_dest_port <= 0;
            new_length <= 0;
        end else if(!match_enable) begin
            match_enable <= 1;
            new_dest_port <= 10;
            new_length <= 1;
        end
    end

    reg [4:0] next_matching_sram;
    reg [4:0] matching_sram;
    
    /*
     * ?????????????????SRAM???
     * PORT_IDX???????????????????????????????????SRAM???????????????
     */
    always @(posedge clk) begin
        case(match_mode)
            /* ?????????????????2??SRAM??????????? */
            0: next_matching_sram <= {port[3:0], time_stamp[0]};
            /* ?????????????????1??SRAM??16??s????SRAM?????????? */
            1: next_matching_sram <= time_stamp[0] ? time_stamp + {port[3:0], 1'b0} : {port[3:0], 1'b0};
            /* ??????????????32??s????SRAM?????????? */
            default: next_matching_sram <= time_stamp + {port[3:0], 1'b0};
        endcase
        //$display("next_matching_sram = %d",next_matching_sram);
    end

    reg [10:0] free_space;
    reg [8:0] packet_amount;

    always @(posedge clk) begin
        matching_sram <= next_matching_sram;
    end
    reg [10:0] cnt;

    always @(posedge clk) begin
        cnt <= $random;
    end

    reg accessible;

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

    wire match_suc;
    wire [4:0] matching_best_sram;

    reg viscous = 1;

    port_wr_sram_matcher  port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),
        
        .match_mode(match_mode),
        .match_threshold(match_threshold),

        .match_enable(match_enable),
        .viscous(viscous),
        .matching_sram(matching_sram),
        .matching_best_sram(matching_best_sram),
        .match_state(match_state),
    
        .new_dest_port(new_dest_port),
        .new_length(new_length),
        .match_suc(match_suc),
        
        .free_space(free_space),
        .accessible(accessible),
        .packet_amount(packet_amount)
        
    );

//end endgenerate

endmodule
