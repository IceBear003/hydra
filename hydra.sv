`include "port_wr_frontend.sv"
`include "sram_interface.sv"
`include "mux_16.sv"
`include "mux_32.sv"

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

reg occupied [31:0];
reg [10:0] free_space [31:0];
reg [8:0] packet_amount [31:0] [15:0];

//TODO
wire [31:0] select_sram [15:0];

wire xfer_data_vld [15:0];
wire [15:0] xfer_data [15:0];
wire end_of_packet [15:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

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
        .end_of_packet(),
        .cur_dest_port(),
        .cur_prior(),
        .cur_length(),
        
        .match_end(),
        .match_enable(),
        .new_dest_port(),
        .new_prior(),
        .new_length()
    );

end endgenerate

wire [15:0] packet_head_addr [31:0];
wire [15:0] packet_tail_addr [31:0];

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

    mux_16 mux_16(
        .select(select),
        .idx(idx)
    );

    sram_interface #(.SRAM_IDX(sram)) sram_interface(
        .clk(clk),
        .rst_n(rst_n),

        .xfer_data_vld(xfer_data_vld[idx]),
        .xfer_data(xfer_data[idx]),
        .end_of_packet(end_of_packet[idx]),

        .packet_head_addr(packet_head_addr[sram]),
        .packet_tail_addr(packet_tail_addr[sram])
    );

end endgenerate

endmodule