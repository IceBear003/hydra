`include "port_wr_sram_matcher.sv"
`include "port_wr_frontend.sv"
`include "sram_interface.sv"
`include "decoder_16_4.sv"
`include "decoder_32_5.sv"

module hydra(
    input clk,
    input rst_n,

    //基本IO口
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] [15:0] wr_data,
    input [15:0] pause,

    output reg full,
    output reg almost_full,

    input [15:0] ready,
    output reg [15:0] rd_sop,
    output reg [15:0] rd_eop,
    output reg [15:0] rd_vld,
    output reg [15:0] [15:0] rd_data,

    //配置IO口
    input [15:0] wrr_en,
    input [4:0] match_threshold,
    input [1:0] match_mode,
    input [3:0] viscosity
);

reg [31:0] wr_select_sram [15:0];
reg [31:0] match_select_sram [15:0];

wire wr_xfer_data_vld [15:0];
wire [15:0] wr_xfer_data [15:0];
wire wr_end_of_packet [15:0];

wire accessible [31:0];
wire [10:0] free_space [31:0];
wire [8:0] check_amount [31:0];
wire [3:0] check_port [15:0];

reg [15:0] queue_head [15:0] [7:0];
reg [15:0] queue_tail [15:0] [7:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    wire [3:0] new_dest_port;
    assign check_port[port] = new_dest_port;
    wire [8:0] new_length;
    wire match_enable;
    wire match_end;

    wire [4:0] matching_next_sram;
    wire [4:0] matching_best_sram;

    reg [4:0] wr_sram;
    //SRAM绑定
    //粘滞周期

    reg viscous;
    reg [4:0] idle_tick;

    always @(posedge clk) begin
        if(~rst_n) begin
            viscous <= 0;
        end else if(match_end) begin
            viscous <= 1;
        end else if(idle_tick >= viscosity) begin
        end
    end

    //WR SRAM的保留

    port_wr_frontend port_wr_frontend(
        .clk(clk),
        .rst_n(rst_n),

        .wr_sop(wr_sop[port]),
        .wr_vld(wr_vld[port]),
        .wr_data(wr_data[port]),
        .wr_eop(wr_eop[port]),
        .pause(pause[port]),

        .xfer_data_vld(wr_xfer_data_vld[port]),
        .xfer_data(wr_xfer_data[port]),
        .end_of_packet(wr_end_of_packet[port]),
        
        .match_end(match_end),
        .match_enable(match_enable),
        .new_dest_port(new_dest_port),
        .new_length(new_length)
    );
    
    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),
    
        .match_mode(match_mode),
        .match_threshold(match_threshold),
    
        .new_dest_port(new_dest_port),
        .new_length(new_length),
        .match_enable(match_enable),
        .match_end(match_end),

        .viscous(viscous),
        .matching_next_sram(matching_next_sram),
        .matching_best_sram(matching_best_sram),
     
        .free_space(free_space[matching_next_sram]),
        .accessible(accessible[matching_next_sram]),
        .packet_amount(check_amount[matching_next_sram])
    );

end endgenerate

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    /* 端口选中 */
    wire [15:0] wr_select = {wr_select_sram[0][sram], wr_select_sram[1][sram], wr_select_sram[2][sram], wr_select_sram[3][sram], 
                             wr_select_sram[4][sram], wr_select_sram[5][sram], wr_select_sram[6][sram], wr_select_sram[7][sram], 
                             wr_select_sram[8][sram], wr_select_sram[9][sram], wr_select_sram[10][sram], wr_select_sram[11][sram], 
                             wr_select_sram[12][sram], wr_select_sram[13][sram], wr_select_sram[14][sram], wr_select_sram[15][sram]};
    wire [3:0] wr_port;
    decoder_16_4 decoder_16_4_wr(
        .select(wr_select),
        .idx(wr_port)
    );
    wire [15:0] match_select = {match_select_sram[0][sram], match_select_sram[1][sram], match_select_sram[2][sram], match_select_sram[3][sram], 
                             match_select_sram[4][sram], match_select_sram[5][sram], match_select_sram[6][sram], match_select_sram[7][sram], 
                             match_select_sram[8][sram], match_select_sram[9][sram], match_select_sram[10][sram], match_select_sram[11][sram], 
                             match_select_sram[12][sram], match_select_sram[13][sram], match_select_sram[14][sram], match_select_sram[15][sram]};
    wire [3:0] match_port;
    decoder_16_4 decoder_16_4_match(
        .select(match_select),
        .idx(match_port)
    );

    assign accessible[sram] = wr_select == 0 && match_select == 0;

    sram_interface #(.SRAM_IDX(sram)) sram_interface(
        .clk(clk),
        .rst_n(rst_n),

        .wr_xfer_data_vld(wr_xfer_data_vld[wr_port]),
        .wr_xfer_data(wr_xfer_data[wr_port]),
        .wr_end_of_packet(wr_end_of_packet[wr_port]),

        // .wr_packet_dest_port(wr_packet_dest_port),
        // .wr_packet_head_addr(wr_packet_head_addr),
        // .wr_packet_tail_addr(wr_packet_tail_addr),

        .check_port(check_port[match_port]),
        .check_amount(check_amount[sram]),
        .free_space(free_space[sram])
    );

end endgenerate 

endmodule