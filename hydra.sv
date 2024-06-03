`include "port_wr_frontend.sv"
`include "sram_interface.sv"
`include "decoder_16_4.sv"
`include "port_wr_sram_matcher.sv"

module hydra(
    input clk,
    input rst_n,

    //Config
    input [15:0] wrr_en,

    input [4:0] match_threshold,
    input [1:0] match_mode,

    //Ports
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] wr_data [15:0],
    input [15:0] pause,

    output reg full,
    output reg almost_full,

    input [15:0] ready,
    output reg [15:0] rd_sop,
    output reg [15:0] rd_eop,
    output reg [15:0] rd_vld,
    output reg [15:0] rd_data [15:0]
);

reg [4:0] cnt_32;
always @(posedge clk) begin
    if(!rst_n) begin
        cnt_32 <= 0;
    end else begin
        cnt_32 <= cnt_32 + 1;
    end
end

//SRAM状态描述
reg occupied [31:0];
reg [10:0] free_space [31:0];
reg [8:0] packet_amount [31:0] [15:0];

//SRAM选PORT，16to4译码器
reg [31:0] select_sram [15:0];
//PORT传输给SRAM的信号
wire xfer_data_vld [15:0];
wire [15:0] xfer_data [15:0];
wire end_of_packet [15:0];

//PORT选PORT，16to4译码器
reg [15:0] select_port [15:0];
reg [2:0] dest_prior [15:0];

reg [4:0] queue_head_sram [15:0] [7:0];
reg [10:0] queue_head_page [15:0] [7:0];
reg [4:0] queue_tail_sram [15:0] [7:0];
reg [10:0] queue_tail_page [15:0] [7:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    wire [3:0] new_dest_port;
    wire [8:0] new_length;

    wire [3:0] cur_dest_port;
    wire [2:0] cur_prior;

    port_wr_frontend port_wr_frontend(
        .clk(clk),
        .rst_n(rst_n),

        .wr_sop(wr_sop[port]),
        .wr_vld(wr_vld[port]),
        .wr_data(wr_data[port]),
        .wr_eop(wr_eop[port]),
        .pause(pause[port]),

        .xfer_data_vld(xfer_data_vld[port]),
        .xfer_data(xfer_data[port]),
        .end_of_packet(end_of_packet[port]),
        .cur_dest_port(cur_dest_port),
        .cur_prior(cur_prior),
        
        .match_end(match_end),
        .match_enable(match_enable),
        .new_dest_port(new_dest_port),
        .new_length(new_length)
    );

    wire match_enable;
    wire [4:0] matching_next_sram;
    wire [4:0] matching_best_sram;
    wire match_end;

    always@(posedge clk) begin
        if(match_end) begin
            select_sram[port] <= 1 << matching_best_sram;
        end
    end

    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),
    
        .match_mode(match_mode),
        .match_threshold(match_threshold),
    
        .match_enable(match_enable),
        .matching_next_sram(matching_next_sram),
        .matching_best_sram(matching_best_sram),
        .match_end(match_end),
    
        .new_dest_port(new_dest_port),
        .new_length(new_length),
    
        .free_space(free_space[matching_next_sram]),
        .occupied(occupied[matching_next_sram]),
        .packet_amount(packet_amount[matching_next_sram][new_dest_port])
    );
end endgenerate

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    wire [15:0] select = {
        select_sram[0][sram],
        select_sram[1][sram],
        select_sram[2][sram],
        select_sram[3][sram],
        select_sram[4][sram],
        select_sram[5][sram],
        select_sram[6][sram],
        select_sram[7][sram],
        select_sram[8][sram],
        select_sram[9][sram],
        select_sram[10][sram],
        select_sram[11][sram],
        select_sram[12][sram],
        select_sram[13][sram],
        select_sram[14][sram],
        select_sram[15][sram]
    };

    wire [3:0] idx;

    decoder_16_4 decoder_16_4(
        .select(select),
        .idx(idx)
    );

    wire [15:0] packet_head_addr;
    wire [15:0] packet_tail_addr;

    sram_interface #(.SRAM_IDX(sram)) sram_interface(
        .clk(clk),
        .rst_n(rst_n),

        .xfer_data_vld(xfer_data_vld[idx]),
        .xfer_data(xfer_data[idx]),
        .end_of_packet(end_of_packet[idx]),

        .packet_head_addr(packet_head_addr),
        .packet_tail_addr(packet_tail_addr)
    );

end endgenerate

endmodule