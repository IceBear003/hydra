`include "port_wr_frontend.sv"
`include "port_wr_sram_matcher.sv"
`include "port_rd_frontend.sv"
`include "port_rd_dispatch.sv"
`include "sram_interface.sv"
`include "decoder_16_4.sv"
`include "decoder_32_5.sv"

module hydra
(
    input clk,
    input rst_n,

    //????IO??
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] [15:0] wr_data,
    output [15:0] pause,

    output reg full,
    output reg almost_full,

    input [15:0] ready,
    output reg [15:0] rd_sop,
    output [15:0] rd_eop,
    output [15:0] rd_vld,
    output [15:0] [15:0] rd_data,
 
    
    /*
     * ??????????
     * |- wrr_enable - ??????????WRR????
     * |- match_mode - SRAM??????
     *      |- 0 - ?????????
     *      |- 1 - ?????????
     *      |- 2/3 - ??????????
     * |- match_threshold - ?????????????????????????????????????????????
     *      |- ????????? ????0
     *      |- ????????? ????16
     *      |- ?????????? ????30
     */
    input [15:0] wrr_enable,
    input [4:0] match_threshold,
    input [1:0] match_mode
    
    /* SRAM??????????? */
    // ,output [31:0] wr_en,
    // output [31:0] [13:0] wr_addr,
    // output [31:0] [15:0] din,
    
    // output [31:0] rd_en,
    // output [31:0] [13:0] rd_addr,
    // input [31:0] [15:0] dout
);

/* ????????????SRAM??????*/
reg [5:0] wr_sram [15:0]; /* ??????? */
wire [5:0] matched_sram [15:0]; /* ??????? */
wire [5:0] rd_srams [15:0]; /* ??????? */

/* ??????????SRAM???????????? */
wire wr_xfer_data_vld [15:0];
wire [15:0] wr_xfer_data [15:0];
wire wr_end_of_packet [15:0];

/* ??????????SRAM???????????? */
wire [10:0] rd_pages [15:0];
reg [4:0] rd_ports [31:0];
wire rd_xfer_data_vlds [31:0];
wire [15:0] rd_xfer_datas [31:0];
(*DONT_TOUCH="YES"*) wire [7:0] rd_ecc_codes [31:0];  /* ????????????? */
wire [15:0] rd_next_pages [31:0]; /* ????????????????queue_head */

/* ???????SRAM??????????? */
reg [8:0] packet_amounts [15:0][31:0];

/* ???? */
reg [4:0] time_stamp;
always @(posedge clk) begin
    if(~rst_n) begin
        time_stamp <= 0;
    end else begin
        time_stamp <= time_stamp + 1;
    end
end

/* SRAM?? */ 
wire [10:0] free_spaces [31:0];
wire [31:0] accessibilities;

always @(posedge clk) begin
    full <= accessibilities == 0;
    almost_full <= (~accessibilities & {free_spaces[0][10], free_spaces[1][10], free_spaces[2][10], free_spaces[3][10],
                                        free_spaces[4][10], free_spaces[5][10], free_spaces[6][10], free_spaces[7][10], 
                                        free_spaces[8][10], free_spaces[9][10], free_spaces[10][10], free_spaces[11][10], 
                                        free_spaces[12][10], free_spaces[13][10], free_spaces[14][10], free_spaces[15][10], 
                                        free_spaces[16][10], free_spaces[17][10], free_spaces[18][10], free_spaces[19][10], 
                                        free_spaces[20][10], free_spaces[21][10], free_spaces[22][10], free_spaces[23][10], 
                                        free_spaces[24][10], free_spaces[25][10], free_spaces[26][10], free_spaces[27][10], 
                                        free_spaces[28][10], free_spaces[29][10], free_spaces[30][10], free_spaces[31][10]} == 0);
end

/* SRAM->Port ???????????? */
wire [3:0] wr_packet_dest_port [31:0];
wire [2:0] wr_packet_prior [31:0];
wire [15:0] wr_packet_head_addr [31:0];
wire [15:0] wr_packet_tail_addr [31:0];
wire [31:0] wr_packet_join_request;
wire [5:0] wr_packet_join_time_stamp [31:0];

/* ??????? */ 
reg [4:0] ts_fifo [31:0];
reg [4:0] ts_head_ptr;
reg [4:0] ts_tail_ptr;

/* ????????????? */
wire [5:0] processing_time_stamp = ts_head_ptr == ts_tail_ptr ? 6'd33 : ts_fifo[ts_head_ptr];
/* ???????????????????? */
reg [31:0] processing_join_mask;
/* ????????????????????? */
wire [31:0] processing_join_select = processing_join_mask & 
                                    {wr_packet_join_time_stamp[31] == processing_time_stamp, wr_packet_join_time_stamp[30] == processing_time_stamp, wr_packet_join_time_stamp[29] == processing_time_stamp, wr_packet_join_time_stamp[28] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[27] == processing_time_stamp, wr_packet_join_time_stamp[26] == processing_time_stamp, wr_packet_join_time_stamp[25] == processing_time_stamp, wr_packet_join_time_stamp[24] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[23] == processing_time_stamp, wr_packet_join_time_stamp[22] == processing_time_stamp, wr_packet_join_time_stamp[21] == processing_time_stamp, wr_packet_join_time_stamp[20] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[19] == processing_time_stamp, wr_packet_join_time_stamp[18] == processing_time_stamp, wr_packet_join_time_stamp[17] == processing_time_stamp, wr_packet_join_time_stamp[16] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[15] == processing_time_stamp, wr_packet_join_time_stamp[14] == processing_time_stamp, wr_packet_join_time_stamp[13] == processing_time_stamp, wr_packet_join_time_stamp[12] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[11] == processing_time_stamp, wr_packet_join_time_stamp[10] == processing_time_stamp, wr_packet_join_time_stamp[9] == processing_time_stamp, wr_packet_join_time_stamp[8] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[7] == processing_time_stamp, wr_packet_join_time_stamp[6] == processing_time_stamp, wr_packet_join_time_stamp[5] == processing_time_stamp, wr_packet_join_time_stamp[4] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[3] == processing_time_stamp, wr_packet_join_time_stamp[2] == processing_time_stamp, wr_packet_join_time_stamp[1] == processing_time_stamp, wr_packet_join_time_stamp[0] == processing_time_stamp};
/* ?????????????????????? */
wire [4:0] processing_join_request;

/* Port->SRAM ???????????? */
reg concatenate_enables [15:0];
reg [15:0] concatenate_heads [15:0];
reg [15:0] concatenate_tails [15:0];

wire [15:0] concatenate_select = {concatenate_enables[15] == 1, concatenate_enables[14] == 1, concatenate_enables[13] == 1, concatenate_enables[12] == 1, 
                                  concatenate_enables[11] == 1, concatenate_enables[10] == 1, concatenate_enables[9] == 1, concatenate_enables[8] == 1, 
                                  concatenate_enables[7] == 1, concatenate_enables[6] == 1, concatenate_enables[5] == 1, concatenate_enables[4] == 1, 
                                  concatenate_enables[3] == 1, concatenate_enables[2] == 1, concatenate_enables[1] == 1, concatenate_enables[0] == 1}; 
wire [3:0] concatenate_port;
decoder_16_4 decoder_concatenate(
    .select(concatenate_select),
    .idx(concatenate_port)
);

wire [15:0] concatenate_head = concatenate_heads[concatenate_port];
wire [15:0] concatenate_tail = concatenate_tails[concatenate_port];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    wire ready_to_xfer;
    wire xfer_data_vld;
    wire [15:0] xfer_data;
    wire end_of_packet;
    assign wr_xfer_data_vld[port] = xfer_data_vld;
    assign wr_xfer_data[port] = xfer_data;
    assign wr_end_of_packet[port] = end_of_packet;

    wire [4:0] matching_best_sram;

    wire match_suc;
    wire match_enable;
    wire [3:0] new_dest_port;
    wire [8:0] new_length;

    /* ??????????????????SRAM????????????SRAM??????????????????? */
    reg [4:0] next_matching_sram;
    reg [4:0] matching_sram;

    /* ??????????????????????????????????????? */
    reg [10:0] free_space;
    reg [8:0] packet_amount;
    reg accessibility;

    reg [15:0] queue_head [7:0];
    reg [15:0] queue_tail [7:0];
    wire [7:0] queue_empty = {queue_head[7] == queue_tail[7], queue_head[6] == queue_tail[6], queue_head[5] == queue_tail[5], queue_head[4] == queue_tail[4], 
                              queue_head[3] == queue_tail[3], queue_head[2] == queue_tail[2], queue_head[1] == queue_tail[1], queue_head[0] == queue_tail[0]};

    /* ??????? */
                              
    /* ??????????????? */
    reg join_enable;
    /* ????????????????????? */
    reg [2:0] join_prior;
    /* ????????????????SRAM???? */
    reg [4:0] join_request;
    /* ???????????????????????????????????Port->SRAM??concatenate_enables */
    reg [3:0] concatenate_tick;
     
    /* ???? */
 
    wire [3:0] rd_prior;
    reg [2:0] pst_rd_prior; /* ????????????????(rd_sop??rd_prior???????) */

    reg [5:0] rd_sram;
    reg [5:0] pst_rd_sram; /* ??????????????????SRAM(?????rd_sram????????????????????????????????8???SRAM?????????) */
    assign rd_srams[port] = rd_sram;

    reg rd_not_over; /* ?????????????????????rd_vld */
    wire rd_xfer_data_vld = rd_not_over ? rd_xfer_data_vlds[pst_rd_sram] : 0;
    wire [15:0] rd_xfer_data = rd_xfer_datas[pst_rd_sram];
    
    reg [6:0] rd_page_amount; /* ???????????? */
    reg [2:0] rd_batch_end; /* ??????????????????? */

    reg [2:0] rd_batch;
    wire rd_end_of_packet = rd_page_amount == 0 && rd_batch == rd_batch_end; /* ??????????????????? */

    wire update_matched_sram;
    assign matched_sram[port] = update_matched_sram ? matching_best_sram : 6'd32; /* ????????SRAM???????????????????????????????????????????????? */

    reg [10:0] rd_page; /* ??????????????? */
    assign rd_pages[port] = rd_page;

    reg [10:0] rd_length;

    reg pst_ready;
 
    port_wr_frontend port_wr_frontend(
        .clk(clk),
        .rst_n(rst_n),

        .wr_sop(wr_sop[port]),
        .wr_vld(wr_vld[port]),
        .wr_data(wr_data[port]),
        .wr_eop(wr_eop[port]),
        .pause(pause[port]), 

        .ready_to_xfer(ready_to_xfer),
        .xfer_data_vld(xfer_data_vld),
        .xfer_data(xfer_data),
        .end_of_packet(end_of_packet),
        
        .match_suc(match_suc),
        .match_enable(match_enable),
        .new_dest_port(new_dest_port),
        .new_length(new_length)
    );

    always @(posedge clk) begin
        matching_sram <= next_matching_sram;
        free_space <= free_spaces[next_matching_sram];
        packet_amount <= packet_amounts[wr_data[port][3:0]][next_matching_sram];
        accessibility <= accessibilities[next_matching_sram];
    end
    
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
    end

    /* ???????????????????????????????????wr_page?????????????????????????np_dout????????????????????? */
    reg [1:0] regain_wr_page_tick;

    always @(posedge clk) begin
        if(!rst_n) begin
            regain_wr_page_tick <= 2'd0;
        end else if(end_of_packet) begin
            regain_wr_page_tick <= 2'd3;
            $display("wr_sra m = %d",wr_sram[port]);
        end else if(regain_wr_page_tick != 0) begin
            regain_wr_page_tick <= regain_wr_page_tick - 1;
            $display("regain_wr_page_tick = %d %d",regain_wr_page_tick,wr_sram[port]);
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            wr_sram[port] <= 6'd32;
        end else if(ready_to_xfer) begin /* ???????PORT->SRAM?????????????????????????????wr_sram??????????? */
            wr_sram[port] <= matching_best_sram;
            $display("matching_best_sram = %d",matching_best_sram);
        end else if(regain_wr_page_tick == 1) begin /* ???????????????????????????????? */
            wr_sram[port] <= 6'd32;
        end
        //if(wr_sram[port] != 32) begin
            //$display("wr_sram = %d",wr_sram[port]);
        //end
        if(ready_to_xfer) begin
            $display("12sw");
        end
    end
   
    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),

        .match_threshold(match_threshold),

        .new_length(new_length),
        .match_enable(match_enable),
        .match_suc(match_suc),

        .matching_sram(matching_sram),
        .matching_best_sram(matching_best_sram),
        .update_matched_sram(update_matched_sram),

        .accessible(accessibility),
        .free_space(free_space),
        .packet_amount(packet_amount) 
    );

    always @(posedge clk) begin
        join_enable <= wr_packet_dest_port[processing_join_request] == port ? 1 : 0;
        //$display("wr_packet_dest_port[processing_join_request] = %d %d",wr_packet_dest_port[processing_join_request],port);
        //$display("que ue = %d %d %d",queue_head[2],queue_tail[2],port);
    end

    always @(posedge clk) begin
        /* ?????????????????????????????????????????? */
        if(wr_packet_dest_port[processing_join_request] == port) begin
            join_prior <= wr_packet_prior[processing_join_request];
            join_request <= processing_join_request;
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            queue_tail[0] <= 16'd0; queue_tail[1] <= 16'd0; queue_tail[2] <= 16'd0; queue_tail[3] <= 16'd0;
            queue_tail[4] <= 16'd0; queue_tail[5] <= 16'd0; queue_tail[6] <= 16'd0; queue_tail[7] <= 16'd0;
        end else if(join_enable && queue_empty[join_prior]) begin
            queue_tail[join_prior] <= wr_packet_tail_addr[join_request];
        end else if(join_enable)begin /* ???????????????F?????????? */
            queue_tail[join_prior] <= wr_packet_tail_addr[join_request];
            $display("wr_packet_tail_addr[join_request] = %d %d",wr_packet_tail_addr[join_request],join_prior);
            concatenate_heads[port] <= queue_tail[join_prior];
            concatenate_tails[port] <= wr_packet_head_addr[join_request];
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            queue_head[0] <= 16'd0; queue_head[1] <= 16'd0; queue_head[2] <= 16'd0; queue_head[3] <= 16'd0;
            queue_head[4] <= 16'd0; queue_head[5] <= 16'd0; queue_head[6] <= 16'd0; queue_head[7] <= 16'd0;
        end else if(join_enable && queue_empty[join_prior]) begin /* ?????????? */
            queue_head[join_prior] <= wr_packet_head_addr[join_request];
            $display("queue_head[join_prior] = %d %d",wr_packet_head_addr[join_request],join_prior);
        end else if(~rd_end_of_packet) begin /* ??????????????????????? */
        end else if({pst_rd_sram, rd_page} != queue_tail[pst_rd_prior]) begin /* ?????????????? */
            queue_head[pst_rd_prior] <= rd_next_pages[pst_rd_sram];
        end else begin /* ?????????????? */
            queue_head[pst_rd_prior] <= queue_tail[pst_rd_prior];
        end
    end
    
    always @(posedge clk) begin
        concatenate_enables[port] <= join_enable == 1 && ~queue_empty[join_prior];
    end

    reg able_read;

    always @(posedge clk) begin
        if(!rst_n) begin
            able_read <= 0;
        end else if(rd_sop[port]) begin
            able_read <= 1;
        end else if(rd_vld[port]) begin
            able_read <= 0;
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            rd_sram <= 6'd32;
        end else if(ready[port]) begin
            rd_sram <= queue_head[rd_prior][15:11];
        end else if(rd_sop[port]) begin
            pst_rd_prior <= rd_prior;
            //rd_sram <= queue_head[rd_prior][15:11];
            pst_rd_sram <= rd_sram;
            $display("rd_prior = %d",rd_prior);
            $display("queue_head[rd_prior] = %d",queue_head[rd_prior]);
        end else if(!(able_read || rd_vld[port])) begin
            pst_rd_sram <= 6'd32;
        end else if(rd_page_amount == 0) begin
            rd_sram <= 6'd32;
        end
    end
//?????ready?????????????rd_sram???rd_sop

    always @(posedge clk) begin
        if(!rst_n) begin
            rd_sop[port] <= 1'b0;
        end else if(pst_ready == 1'b1 && rd_ports[rd_sram] == port) begin
            rd_sop[port] <= 1'b1;
        end else begin
            rd_sop[port] <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            pst_ready <= 1'b0;
        end else if(ready[port]) begin
            pst_ready <= 1'b1;
        end else if(pst_ready == 1'b1 && rd_ports[rd_sram] == port) begin
            pst_ready <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if(rd_sop[port]) begin /* ???????????????? */
            rd_page <= queue_head[rd_prior][10:0];
        end else if(rd_batch == 3'd5 && rd_page_amount != 0) begin /* ??????????????????????????????(PORT rd_batch?5???SRAM rd_batch?7) */
            rd_page <= rd_next_pages[pst_rd_sram];
            $display("pst_rd_sram = %d %d",pst_rd_sram,rd_next_pages[pst_rd_sram]);
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            rd_not_over <= 1;
        end if(rd_end_of_packet) begin
            rd_not_over <= 0;
        end else if(rd_sop[port]) begin
            rd_not_over <= 1;
        end
    end

    always @(posedge clk) begin
        if(rd_sop[port]) begin
            rd_page_amount <= 7'd64;
            rd_batch_end <= 0;
        end else if(rd_page_amount == 7'd64 && rd_xfer_data_vld) begin
            rd_page_amount <= rd_xfer_data[15:10];
            rd_batch_end <= rd_xfer_data[9:7];
            rd_length <= rd_xfer_data[15:7];
            $display("rd_xfer_data %d %d",rd_xfer_data[15:10],rd_xfer_data[9:7]);
        end else if(rd_batch == 3'd7) begin
            rd_page_amount <= rd_page_amount - 1;
        end
    end

    always @(posedge clk) begin
        if(~rst_n || rd_sop[port]) begin
            rd_batch <= 3'd0;
        end else if(rd_xfer_data_vld) begin
            rd_batch <= rd_batch + 1;
            $display("rd_b atch = %d %d %d",rd_batch + 1,rd_batch_end,rd_page_amount);

        end
    end

    port_rd_dispatch port_rd_dispatch(
        .clk(clk),
        .rst_n(rst_n),

        .wrr_en(wrr_enable[port]),

        .queue_empty(queue_empty),
        .update(rd_sop[port]),
        .rd_prior(rd_prior)
    );
    
/*
    always @(posedge clk) begin
        rd_sop[port] <= ready[port] && queue_empty != 8'hFF;
        if(ready[port]) begin
            $display("queue_empty = %d",queue_empty);
            $display("que ue = %d %d %d",queue_head[2],queue_tail[2],port);
        end
        //$display("rd_prior = %d",rd_prior);
    end
*/



    port_rd_frontend port_rd_frontend(
        .clk(clk),
        .rst_n(rst_n),
    
        .rd_eop(rd_eop[port]),
        .rd_vld(rd_vld[port]),
        .rd_data(rd_data[port]),
        .ready(ready[port]),
        .rd_length(rd_length),
    
        .xfer_data_vld(rd_xfer_data_vld),
        .xfer_data(rd_xfer_data),
        .end_of_packet(rd_end_of_packet)
    );

    /* ?????? */

    integer sram;
    always @(posedge clk) begin
        if(~rst_n) begin
            for(sram = 0; sram < 32; sram = sram + 1)
                packet_amounts[port][sram] <= 0;
        end else if(join_enable) begin /* ????+1 */
            packet_amounts[port][join_request] <= packet_amounts[port][join_request] + 1;
            $display("packet_amounts[port][join_request] = %d %d %d",packet_amounts[port][join_request],port,join_request);
        end else if(rd_end_of_packet) begin /* ??????-1 */
            packet_amounts[port][pst_rd_sram] <= packet_amounts[port][pst_rd_sram] - 1;
            $display("we3");
        end
    end

    //TODO ??????
    wire [15:0] debug_head = queue_head[4];
    wire [15:0] debug_tail = queue_tail[4];
    wire [15:0] debug_amount = packet_amounts[port][3];

end endgenerate

decoder_32_5 decoder_32_5(
    .select(processing_join_select),
    .idx(processing_join_request)
);

always @(posedge clk) begin
    if(processing_join_select == 0) begin /* ???????????????????????????????????????????? */
        processing_join_mask <= 32'hFFFFFFFF;
    end else begin /* ????????????????????????????????0??????????? */
        processing_join_mask[processing_join_request] <= 0;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        ts_tail_ptr <= 0;
    end else if(wr_packet_join_request != 0) begin /* ???????????????????????????????????? */
        ts_fifo[ts_tail_ptr] <= time_stamp;
        ts_tail_ptr <= ts_tail_ptr + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        ts_head_ptr <= 0;
    end else if(processing_join_select == 0 && ts_head_ptr != ts_tail_ptr) begin /* ?????????????????????????????????????????????????????????????????? */
        ts_head_ptr <= ts_head_ptr + 1;
    end
end

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    /* ??????????? */
    wire [15:0] select_matched = {matched_sram[15] == sram, matched_sram[14] == sram, matched_sram[13] == sram, matched_sram[12] == sram, 
                                  matched_sram[11] == sram, matched_sram[10] == sram, matched_sram[9] == sram, matched_sram[8] == sram, 
                                  matched_sram[7] == sram, matched_sram[6] == sram, matched_sram[5] == sram, matched_sram[4] == sram, 
                                  matched_sram[3] == sram, matched_sram[2] == sram, matched_sram[1] == sram, matched_sram[0] == sram};
    /* ?????????? */
    wire [15:0] select_wr = {wr_sram[15] == sram, wr_sram[14] == sram, wr_sram[13] == sram, wr_sram[12] == sram, 
                             wr_sram[11] == sram, wr_sram[10] == sram, wr_sram[9] == sram, wr_sram[8] == sram, 
                             wr_sram[7] == sram, wr_sram[6] == sram, wr_sram[5] == sram, wr_sram[4] == sram, 
                             wr_sram[3] == sram, wr_sram[2] == sram, wr_sram[1] == sram, wr_sram[0] == sram};
    
    /* ????????SRAM???????? */
    wire [3:0] wr_port;
    decoder_16_4 decoder_wr_select(
        .select(select_wr),
        .idx(wr_port)
    );



    /* ??SRAM??????????????????????????????????????????????????????????SRAM?????? */
    assign accessibilities[sram] = select_wr == 0 && select_matched == 0;

    /* ??????? */
    /* ?????????? */
    wire [15:0] select_rd = {rd_srams[15] == sram, rd_srams[14] == sram, rd_srams[13] == sram, rd_srams[12] == sram, 
                             rd_srams[11] == sram, rd_srams[10] == sram, rd_srams[9] == sram, rd_srams[8] == sram, 
                             rd_srams[7] == sram, rd_srams[6] == sram, rd_srams[5] == sram, rd_srams[4] == sram, 
                             rd_srams[3] == sram, rd_srams[2] == sram, rd_srams[1] == sram, rd_srams[0] == sram};

    /* ????????SRAM???????? */
    wire [3:0] rd_port;
    decoder_16_4 decoder_rd_select(
        .select(select_rd),
        .idx(rd_port)
    );

    /* ????????? */ 
    reg [2:0] rd_batch;
    /* ???????????? */ 
    reg [10:0] rd_page;
    /* ?????????? */ 
    reg rd_page_down;

    reg can_read;

    always @(posedge clk) begin
        if(!rst_n) begin
            can_read <= 0;
        end else if(rd_sop[rd_port]) begin
            can_read <= 1;
        end else if(rd_vld[rd_port]) begin
            can_read <= 0;
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            rd_ports[sram] <= 5'd16;
        end else if(rd_batch != 3'd7) begin
        end else if(select_rd != 0) begin /* ????????????? */
            rd_ports[sram] <= rd_port;
            $display("select_rd = %d",select_rd);
        end else begin /* ????????????? */
            rd_ports[sram] <= 5'd16;
        end
        if(select_wr) begin
            $display("wr_port = %d %d",wr_port,wr_xfer_data_vld[wr_port]);
            $display("wr_end_of_packet[wr_port] = %d",wr_end_of_packet[wr_port]);
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            rd_batch <= 3'd7;
            rd_page_down <= 0;
        end else if(rd_batch != 3'd7) begin /* ???????? */
            rd_batch <= rd_batch + 1;
            rd_page_down <= 0;
        end else if(select_rd != 0 && (can_read || rd_vld[rd_port])) begin /* ????????????? */
            rd_page_down <= 1;
            rd_batch <= 3'd0;
            rd_page <= rd_pages[rd_port];
            $display("rd_pages = %d",rd_pages[rd_port]);
        end else begin /* ????????????? */
            rd_batch <= 3'd7;
            rd_page_down <= 0;
        end
    end

    sram_interface sram_interface(
        .clk(clk),
        .rst_n(rst_n), 

        .SRAM_IDX(sram[4:0]),
        .time_stamp(time_stamp),

        .wr_xfer_data_vld(wr_xfer_data_vld[wr_port]),
        .wr_xfer_data(wr_xfer_data[wr_port]),
        .wr_end_of_packet(wr_end_of_packet[wr_port]),

        .wr_packet_dest_port(wr_packet_dest_port[sram]),
        .wr_packet_prior(wr_packet_prior[sram]),
        .wr_packet_head_addr(wr_packet_head_addr[sram]),
        .wr_packet_tail_addr(wr_packet_tail_addr[sram]),
        .wr_packet_join_request(wr_packet_join_request[sram]),
        .wr_packet_join_time_stamp(wr_packet_join_time_stamp[sram]),

        .concatenate_enable(concatenate_head[15:11] == sram),
        .concatenate_head(concatenate_head[10:0]), 
        .concatenate_tail(concatenate_tail),

        .rd_page_down(rd_page_down),
        .rd_page(rd_page),
        
        .rd_xfer_data_vld(rd_xfer_data_vlds[sram]),
        .rd_xfer_data(rd_xfer_datas[sram]),
        .rd_next_page(rd_next_pages[sram]),
        .rd_ecc_code(rd_ecc_codes[sram]),

        .free_space(free_spaces[sram])

        // ,.wr_en(wr_en[sram]),
        // .wr_addr(wr_addr[sram]),
        // .din(din[sram]),
        // .rd_en(rd_en[sram]), 
        // .rd_addr(rd_addr[sram]),
        // .dout(dout[sram])
    );
end endgenerate 
endmodule