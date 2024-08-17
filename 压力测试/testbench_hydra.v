`timescale  1ns / 1ps
`include "hydra.sv"
module testbench_hydra();

reg clk = 0;
reg rst_n;
integer tick = 0;

initial
begin 
    forever
    #(5) clk=~clk;
end

always @(posedge clk) begin
    tick = tick + 1;
end

reg [15:0] wr_sop;
reg [15:0] wr_eop;
reg [15:0] wr_vld;
reg [15:0] [15:0] wr_data;
wire [15:0] pause;

reg [15:0] ready;
wire [15:0] rd_sop;
wire [15:0] rd_eop;
wire [15:0] rd_vld; 
wire [15:0] [15:0] rd_data;
reg [31:0] left_packet_amounts[15:0] ;

hydra hydra(
    .clk(clk),
    .rst_n(rst_n),
    .wr_sop(wr_sop),
    .wr_eop(wr_eop),
    .wr_vld(wr_vld),
    .wr_data(wr_data),
    .pause(pause),
    
    .ready(ready),
    .rd_sop(rd_sop), 
    .rd_eop(rd_eop),
    .rd_vld(rd_vld),
    .rd_data(rd_data),

    .wrr_en(16'hFFFF),
    .match_threshold(5'd30),
    .match_mode(2'd2)
);

reg [15:0] finish_wr = 16'hFFFF;
reg [15:0] finish_rd = 16'hFFFF;

integer out_file;
initial begin
    out_file = $fopen("statistic.txt");
    // $dumpfile("testbench_hydra.vcd");
    // $dumpvars();
    #5 
    rst_n <= 0;
    ready <= 16'h0000;
    wr_sop <= 16'h0000;
    wr_vld <= 16'h0000;
    wr_eop <= 16'h0000;
    #10 
    rst_n <= 1;
end

genvar port_wr;
generate for(port_wr = 0; port_wr < 16; port_wr = port_wr + 1) begin : port_wr_loop
    integer packet_amount;
    integer length;
    integer prior;
    integer dest_port;
    integer i;
    wire [31:0] left = left_packet_amounts[port_wr];
    initial begin
        left_packet_amounts[port_wr] = 0;
        #525
        for(packet_amount = 0; packet_amount < 30; packet_amount = packet_amount + 1) begin
            length = $urandom_range(31,511);
            prior = $urandom_range(0,7);
            dest_port = $urandom_range(0,15);
            left_packet_amounts[dest_port] = left_packet_amounts[dest_port] + 1; 
            wr_sop[port_wr] <= 1;
            wr_eop[port_wr] <= 0;
            #10
            wr_sop[port_wr] <= 0;
            wr_vld[port_wr] <= 1;
            wr_data[port_wr] <= {length[8:0], prior[2:0], dest_port[3:0]};
            #10
            for(i = 0; i < length; i = i + 1) begin
                wr_data[port_wr] <= i[15:0];
                #10;
            end
            wr_vld[port_wr] <= 0;
            wr_eop[port_wr] <= 1;
            #10;
        end
        finish_wr[port_wr] <= 0;
    end
end endgenerate

integer rd_cnt = 0;

genvar port_rd;
generate for(port_rd = 0; port_rd < 16; port_rd = port_rd + 1) begin : port_rd_loop
    integer start_tick;
    integer response_tick;
    integer end_tick;
    integer packet_length;
    initial begin
        #1000
        while(finish_wr != 0) begin
            #10;
        end
        ready[port_rd] <= 1;
        while(left_packet_amounts[port_rd] > 0) begin
            #10;
            ready[port_rd] <= 0;
            if(rd_sop[port_rd]) begin
                start_tick = tick;
                response_tick = 0;
                left_packet_amounts[port_rd] = left_packet_amounts[port_rd] - 1;
                rd_cnt = rd_cnt + 1;
                while(rd_eop[port_rd] != 1) begin
                    #10;
                    if(rd_vld[port_rd] == 1 && response_tick == 0) begin
                        response_tick = tick;
                        packet_length = rd_data[port_rd][15:7];
                    end 
                end
                end_tick = tick;
                $fdisplay(out_file, "%d %d %d %d %d", port_rd, start_tick, end_tick, response_tick, packet_length);
                ready[port_rd] <= 1;
            end
        end
        #10;
        ready[port_rd] <= 0;
        finish_rd[port_rd] <= 0;
    end
end endgenerate

always @(posedge clk) begin
    if(finish_rd == 0) begin
        #1000
        $finish;
    end
end

endmodule