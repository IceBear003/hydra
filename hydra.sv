`include "port_wr_sram_matcher.sv"
`include "port_wr_frontend.sv"
`include "port_rd_dispatch.sv"
`include "port_rd_frontend.sv"

`include "sram_rd_round.sv"
`include "sram_interface.sv"
`include "decoder_16_4.sv"
`include "decoder_32_5.sv"

module hydra(
    input clk,
    input rst_n,

    //Config
    input [15:0] wrr_en,

    input [4:0] match_threshold,
    input [1:0] match_mode,
    input [3:0] match_viscosity,

    //Ports
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
    output reg [15:0] [15:0] rd_data
);

//SRAM状态描述
wire match_accessible [31:0];

//SRAM选PORT，16to4译码器
reg [31:0] wr_select_sram [15:0];
wire wr_xfer_data_vld [15:0];
wire [15:0] wr_xfer_data [15:0];
wire wr_end_of_packet [15:0];

//SRAM正在应答的端口
wire [3:0] rd_select_port [31:0];
//端口正在请求的SRAM
reg [31:0] rd_select_sram [15:0];
wire [10:0] rd_page [15:0];
wire rd_xfer_data_vld [31:0];
wire [15:0] rd_xfer_data [31:0];
wire rd_end_of_packet [31:0];

//16*8个队列的首尾地址
reg [15:0] queue_head [15:0] [7:0];
reg [15:0] queue_tail [15:0] [7:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    wire [3:0] new_dest_port;
    wire [8:0] new_length;

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

    wire match_enable;
    wire [4:0] matching_next_sram;
    wire [4:0] matching_best_sram;
    wire match_end;

    wire viscous;
    reg [4:0] viscosity;
    assign viscous = viscosity < match_viscosity;

    //匹配时、写入时、粘滞时 FIXME
    always @(posedge clk) begin
        if(viscous) begin
            wr_select_sram[port] <= 1 << matching_best_sram;
        end else begin
            wr_select_sram[port] <= 0;
        end
    end

    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),
    
        .match_mode(match_mode),
        .match_threshold(match_threshold),
    
        .match_enable(match_enable),
        .viscous(viscous),
        .matching_next_sram(matching_next_sram),
        .matching_best_sram(matching_best_sram),
        .match_end(match_end),
     
        .new_dest_port(new_dest_port),
        .new_length(new_length),
    
        .free_space(free_space[matching_next_sram]),
        .accessible(match_accessible[matching_next_sram]),
        .packet_amount(check_amount[matching_next_sram])
    );

    //READ

    wire rd_sram = queue_head[port][rd_prior][15:11];
    assign rd_page = queue_head[port][rd_prior][10:0];

    always @(posedge clk) begin
        //if(READING)
        rd_select_sram[port] <= 1 << rd_sram;
    end

    port_rd_frontend port_rd_frontend(
        .clk(clk),
        .rst_n(rst_n),
    
        .rd_sop(rd_sop[port]),
        .rd_eop(rd_eop[port]),
        .rd_vld(rd_vld[port]),
        .rd_data(rd_data[port]),
        .ready(ready[port]),
    
        .xfer_data_vld(rd_xfer_data_vld[rd_sram] & (rd_select_port[rd_sram] == port)),
        .xfer_data(rd_xfer_data[rd_sram]),
        .end_of_packet(rd_end_of_packet[rd_sram])
    );

    reg [7:0] queue_available;

    always @(posedge clk) begin
        queue_available <= {
            queue_head[port][0] != queue_tail[port][0],
            queue_head[port][1] != queue_tail[port][1],
            queue_head[port][2] != queue_tail[port][2],
            queue_head[port][3] != queue_tail[port][3],
            queue_head[port][4] != queue_tail[port][4],
            queue_head[port][5] != queue_tail[port][5],
            queue_head[port][6] != queue_tail[port][6],
            queue_head[port][7] != queue_tail[port][7]
        };
    end

    wire rd_available = queue_available != 0;
    reg [2:0] rd_prior;

    port_rd_dispatch port_rd_dispatch(
        .clk(clk),
        .rst_n(rst_n),

        .wrr_en(wrr_en[port]),
        .queue_available(queue_available),
        .next(rd_end_of_packet[rd_sram] & (rd_select_port[rd_sram] == port)),
        .prior(rd_prior)
    );
end endgenerate

wire [10:0] free_space [31:0];
wire [8:0] check_amount [31:0];
wire [3:0] check_port [31:0];

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs
    
    wire [15:0] wr_select = {
        wr_select_sram[0][sram],
        wr_select_sram[1][sram],
        wr_select_sram[2][sram],
        wr_select_sram[3][sram],
        wr_select_sram[4][sram],
        wr_select_sram[5][sram],
        wr_select_sram[6][sram],
        wr_select_sram[7][sram],
        wr_select_sram[8][sram],
        wr_select_sram[9][sram],
        wr_select_sram[10][sram],
        wr_select_sram[11][sram],
        wr_select_sram[12][sram],
        wr_select_sram[13][sram],
        wr_select_sram[14][sram],
        wr_select_sram[15][sram]
    };

    wire [3:0] wr_port;

    decoder_16_4 decoder_16_4(
        .select(wr_select),
        .idx(wr_port)
    );

    wire [15:0] wr_packet_head_addr;
    wire [15:0] wr_packet_tail_addr;
    //JT TODO

    assign match_accessible[sram] = wr_select != 0;
    // assign check_port[sram] = new_dest_port[idx];
    //MATCH TODO

    wire [15:0] rd_select = {
        rd_select_sram[0][sram],
        rd_select_sram[1][sram],
        rd_select_sram[2][sram],
        rd_select_sram[3][sram],
        rd_select_sram[4][sram],
        rd_select_sram[5][sram],
        rd_select_sram[6][sram],
        rd_select_sram[7][sram],
        rd_select_sram[8][sram],
        rd_select_sram[9][sram],
        rd_select_sram[10][sram],
        rd_select_sram[11][sram],
        rd_select_sram[12][sram],
        rd_select_sram[13][sram],
        rd_select_sram[14][sram],
        rd_select_sram[15][sram]
    };

    wire rd_round_next; //SRAM封装口连接

    sram_rd_round sram_rd_round(
        .clk(clk),
        .rst_n(rst_n),

        .select(rd_select),
        .next(rd_round_next),
        .port(rd_select_port[sram])
    );

    sram_interface #(.SRAM_IDX(sram)) sram_interface(
        .clk(clk),
        .rst_n(rst_n),

        .wr_xfer_data_vld(wr_xfer_data_vld[wr_port]),
        .wr_xfer_data(wr_xfer_data[wr_port]),
        .wr_end_of_packet(wr_end_of_packet[wr_port]),

        .wr_packet_head_addr(wr_packet_head_addr),
        .wr_packet_tail_addr(wr_packet_tail_addr),

        .check_port(check_port[sram]),
        .check_amount(check_amount[sram]),
        .free_space(free_space[sram])
    );

end endgenerate

endmodule