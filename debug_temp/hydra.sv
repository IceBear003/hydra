`include "port_wr_frontend.sv"
`include "port_wr_sram_matcher.sv"
`include "port_rd_frontend.sv"
`include "port_rd_dispatch.sv"
`include "sram_interface.sv"

module hydra
(
    /* ??????????? */
    input clk,
    input rst_n,
    /* ????IO?? */
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] [15:0] wr_data,
    output [15:0] pause,
    output reg full,
    output reg almost_full,
    /* ????IO?? */
    input [15:0] ready,
    output [15:0] rd_sop,
    output [15:0] rd_eop,
    output [15:0] rd_vld,
    output [15:0] [15:0] rd_data,
    /*
     * ??????????
     * |- wrr_enable - ??????????WRR????
     * |- match_mode - SRAM??????
     *      |- 0 - ????????????
     *      |- 1 - ??????????
     *      |- 2/3 - ???????????
     * |- match_threshold - ???????????????????????????????????????????????
     *      |- ???????????? ?????0
     *      |- ?????????? ?????16
     *      |- ??????????? ?????30
     */
    input [15:0] wrr_enable,
    input [4:0] match_threshold,
    input [1:0] match_mode
);

/* ????? */
reg [4:0] time_stamp;
always @(posedge clk) time_stamp <= ~rst_n ? 0 : time_stamp + 1;

/* Crossbar???????? ???->SRAM */
wire [5:0] wr_srams [15:0];                             /* ???????? */
wire [5:0] match_srams [15:0];                          /* ??????? */
wire [5:0] rd_srams [15:0];                             /* ???????? */
wire [5:0] pre_rd_srams [15:0];                         /* ?????????? */
/* ????Crossbar??? ???->SRAM */
wire wr_xfer_data_vlds [16:0];                          /* ???????????? */
wire [15:0] wr_xfer_datas [15:0];                       /* ???????? */
wire wr_xfer_end_of_packets [16:0];                     /* ??????? */
assign wr_xfer_data_vlds[16] = 0;
assign wr_xfer_end_of_packets[16] = 0;
/* ????Crossbar??? ???->SRAM */
wire [10:0] rd_xfer_pages [15:0];                       /* ????????? */
/* ????Crossbar??? SRAM->??? */
wire [4:0] rd_xfer_ports [31:0];                        /* ???????? */
wire [15:0] rd_xfer_datas [31:0];                       /* ???????? */
wire [7:0] rd_xfer_ecc_codes [31:0];                    /* ??????????? */
wire [15:0] rd_xfer_next_pages [31:0];                  /* ???????????? */

/* ?????? */
wire [8:0] port_packet_amounts [15:0][31:0];            /* ??????????SRAM?????????????? */
wire [10:0] free_spaces [31:0];                         /* SRAM????? */
wire [31:0] accessibilities;                            /* SRAM??????? */

always @(posedge clk) begin
    full <= accessibilities == 0;                       /* ??SRAM?????????full */
    almost_full <= (~accessibilities &                  /* ?????SRAM?????????50%?????almost_full */
        {free_spaces[0][10], free_spaces[1][10], free_spaces[2][10], free_spaces[3][10], 
        free_spaces[4][10], free_spaces[5][10], free_spaces[6][10], free_spaces[7][10], 
        free_spaces[8][10], free_spaces[9][10], free_spaces[10][10], free_spaces[11][10], 
        free_spaces[12][10], free_spaces[13][10], free_spaces[14][10], free_spaces[15][10], 
        free_spaces[16][10], free_spaces[17][10], free_spaces[18][10], free_spaces[19][10], 
        free_spaces[20][10], free_spaces[21][10], free_spaces[22][10], free_spaces[23][10], 
        free_spaces[24][10], free_spaces[25][10], free_spaces[26][10], free_spaces[27][10], 
        free_spaces[28][10], free_spaces[29][10], free_spaces[30][10], free_spaces[31][10]} == 0
    );
end

/* ???????Crossbar??? SRAM->??? */
wire [31:0] join_request_select;            /* ??????????????? */
wire [5:0] join_request_time_stamps [31:0]; /* ???????????? */
wire [4:0] join_request_dest_ports [32:0];  assign join_request_dest_ports[32] = 5'd16;
wire [2:0] join_request_priors [31:0];
wire [15:0] join_request_heads [31:0];
wire [15:0] join_request_tails [31:0];

reg [4:0] join_request_sram;                /* ?????????????????SRAM??? */
reg [2:0] join_request_prior;               /* ??????????????????????? */
reg [15:0] join_request_head;               /* ??????????????????????? */
wire [5:0] processing_join_request;  
always @(posedge clk) begin
    join_request_sram <= processing_join_request;
    join_request_prior <= join_request_priors[processing_join_request];
    join_request_head <= join_request_heads[processing_join_request];
end

/* ??????? */ 
reg [4:0] ts_fifo [31:0];
reg [4:0] ts_head_ptr;
reg [4:0] ts_tail_ptr;

wire [5:0] processing_time_stamp = ts_head_ptr == ts_tail_ptr ? 6'd33 : ts_fifo[ts_head_ptr];   /* ???????????????????????33 */
reg [32:0] processing_join_mask;                                                                /* ????????????????????????????????????????????????? */
wire [31:0] processing_join_select =                                                            /* ???????????????????????? */
    processing_join_mask & {join_request_time_stamps[31] == processing_time_stamp, join_request_time_stamps[30] == processing_time_stamp, join_request_time_stamps[29] == processing_time_stamp, join_request_time_stamps[28] == processing_time_stamp, join_request_time_stamps[27] == processing_time_stamp, join_request_time_stamps[26] == processing_time_stamp, join_request_time_stamps[25] == processing_time_stamp, join_request_time_stamps[24] == processing_time_stamp, join_request_time_stamps[23] == processing_time_stamp, join_request_time_stamps[22] == processing_time_stamp, join_request_time_stamps[21] == processing_time_stamp, join_request_time_stamps[20] == processing_time_stamp, join_request_time_stamps[19] == processing_time_stamp, join_request_time_stamps[18] == processing_time_stamp, join_request_time_stamps[17] == processing_time_stamp, join_request_time_stamps[16] == processing_time_stamp, join_request_time_stamps[15] == processing_time_stamp, join_request_time_stamps[14] == processing_time_stamp, join_request_time_stamps[13] == processing_time_stamp, join_request_time_stamps[12] == processing_time_stamp, join_request_time_stamps[11] == processing_time_stamp, join_request_time_stamps[10] == processing_time_stamp, join_request_time_stamps[9] == processing_time_stamp, join_request_time_stamps[8] == processing_time_stamp, join_request_time_stamps[7] == processing_time_stamp, join_request_time_stamps[6] == processing_time_stamp, join_request_time_stamps[5] == processing_time_stamp, join_request_time_stamps[4] == processing_time_stamp, join_request_time_stamps[3] == processing_time_stamp, join_request_time_stamps[2] == processing_time_stamp, join_request_time_stamps[1] == processing_time_stamp, join_request_time_stamps[0] == processing_time_stamp};
                                                           /* ???????????????????????SRAM??????????32 */
encoder_32_5 encoder_32_5( 
    .select(processing_join_select),
    .idx(processing_join_request)
);
wire [31:0] processing_join_one_hot_masks [32:0];   /* ??????????????????????????????????????????????????????????????????? */
for(genvar sram = 0; sram < 33; sram = sram + 1) begin
    assign processing_join_one_hot_masks[sram] = 32'b1 << sram;
end

always @(posedge clk) begin
    if(!rst_n) begin
        ts_tail_ptr <= 0;
    end else if(join_request_select != 0) begin
        ts_fifo[ts_tail_ptr] <= time_stamp;
        ts_tail_ptr <= ts_tail_ptr + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        processing_join_mask <= 33'h1FFFFFFFF;
        ts_head_ptr <= 0;
    end else if(processing_join_select == processing_join_one_hot_masks[processing_join_request] && ts_head_ptr != ts_tail_ptr) begin
        processing_join_mask <= 33'h1FFFFFFFF;              /* ??????????????????????????????????????????????? */
        ts_head_ptr <= ts_head_ptr + 1;
    end else begin
        processing_join_mask[processing_join_request] <= 0; /* ????????????????????????????????????????????? */
    end
end

/* ????????????Crossbar??? Port->SRAM */
wire concatenate_enables [15:0];
wire [15:0] concatenate_heads [16:0]; assign concatenate_heads[16] = 0;
wire [15:0] concatenate_tails [16:0]; assign concatenate_tails[16] = 0;
wire [15:0] concatenate_select = {concatenate_enables[15] == 1, concatenate_enables[14] == 1, concatenate_enables[13] == 1, concatenate_enables[12] == 1, 
                                  concatenate_enables[11] == 1, concatenate_enables[10] == 1, concatenate_enables[9] == 1, concatenate_enables[8] == 1, 
                                  concatenate_enables[7] == 1, concatenate_enables[6] == 1, concatenate_enables[5] == 1, concatenate_enables[4] == 1, 
                                  concatenate_enables[3] == 1, concatenate_enables[2] == 1, concatenate_enables[1] == 1, concatenate_enables[0] == 1}; 
wire [4:0] concatenate_port;    /* ?????????????????????? */
encoder_16_4 encoder_concatenate(
    .select(concatenate_select),
    .idx(concatenate_port)
);
wire [15:0] concatenate_head = concatenate_heads[concatenate_port]; /* ???????????????????? */
wire [15:0] concatenate_tail = concatenate_tails[concatenate_port]; /* ????????????????????? */
reg [15:0][11:0] cnt_in = 0;
reg [15:0][11:0] cnt_out = 0;

integer i;

reg [19:0] cnt_vld = 0;

always @(posedge clk) begin
    for(i = 0; i < 16; i = i + 1) begin
        $display("cnt_in = %d %d",cnt_in[i],i);
        $display("cnt_out = %d %d",cnt_out[i],i);
        if(rd_vld[i])
            cnt_vld = cnt_vld + 1;
    end
    //$display("cnt_vld = %d",cnt_vld);
    for(i = 0; i < 16; i = i + 1) begin
        //if(wr_sop[i]) cnt_in[i] = cnt_in[i] + 1;
        if(rd_eop[i]) cnt_out[i] = cnt_out[i] + 1;
    end
end

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    wire wr_xfer_ready;
    wire wr_xfer_data_vld;
    wire [15:0] wr_xfer_data;
    wire wr_xfer_end_of_packet;
    assign wr_xfer_data_vlds[port] = wr_xfer_data_vld;
    assign wr_xfer_datas[port] = wr_xfer_data;
    assign wr_xfer_end_of_packets[port] = wr_xfer_end_of_packet;

    wire match_suc;
    wire match_enable;
    wire [3:0] match_dest_port;
    wire [8:0] match_length;

    port_wr_frontend port_wr_frontend(
        .clk(clk),
        .rst_n(rst_n),

        .wr_sop(wr_sop[port]),
        .wr_vld(wr_vld[port]),
        .wr_data(wr_data[port]),
        .wr_eop(wr_eop[port]),
        .pause(pause[port]), 

        .xfer_ready(wr_xfer_ready),
        .xfer_data_vld(wr_xfer_data_vld),
        .xfer_data(wr_xfer_data),
        .end_of_packet(wr_xfer_end_of_packet),
         
        .match_suc(match_suc),
        .match_enable(match_enable),
        .match_dest_port(match_dest_port),
        .match_length(match_length)
    );

    /* ?????? */
    reg [4:0] next_match_sram;  /* ?????????????SRAM */
    reg [4:0] match_sram;       /* ??????????????SRAM */
    reg [10:0] free_space;      /* ???????SRAM???????? */
    reg [8:0] packet_amount;    /* ???????SRAM??????????????????? */
    reg accessibility;          /* ???????SRAM?????? */
    
    reg [5:0] wr_sram;                              /* ??????????SRAM */
    wire [5:0] match_best_sram;                     /* ????????????SRAM */
    assign wr_srams[port] = wr_sram;
    assign match_srams[port] = match_best_sram;

    always @(posedge clk) begin
        if(wr_eop[port]) begin
            cnt_in[match_dest_port] = cnt_in[match_dest_port] + 1;
        end
    end
    /*
     * ?????????????????SRAM???????????????
     * PORT_IDX????????????????????????????????????SRAM??????Crossbar???????
     */
    always @(posedge clk) begin
        case(match_mode)
            /* ???????????????????2??SRAM??????????? */
            0: next_match_sram <= {port[3:0], time_stamp[0]};
            /* ?????????????????1??SRAM??16??s????SRAM?????????? */
            1: next_match_sram <= time_stamp[0] ? time_stamp + {port[3:0], 1'b0} : {port[3:0], 1'b0};
            /* ??????????????32??s????SRAM?????????? */
            default: next_match_sram <= time_stamp + {port[3:0], 1'b0};
        endcase
        match_sram <= next_match_sram;
        free_space <= free_spaces[next_match_sram];
        packet_amount <= port_packet_amounts[match_dest_port][next_match_sram];
        accessibility <= accessibilities[next_match_sram] || wr_sram == next_match_sram; /* ?????????SRAM???????????? */
    end

    always @(posedge clk) begin
        if(~rst_n || wr_xfer_end_of_packet) begin   /* ????????????????????????? */
            wr_sram <= 6'd32;
        end else if(wr_xfer_ready) begin            /* ??????????????????????SRAM????????? */
            wr_sram <= match_best_sram;
            $display("match_best_sram = %d %d",match_best_sram,port);
        end
    end
   
    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),

        .match_threshold(match_threshold),

        .new_length(match_length[8:3]), 
        .match_enable(match_enable),
        .match_suc(match_suc),

        .match_sram(match_sram),
        .match_best_sram(match_best_sram),
        .accessible(accessibility),
        .free_space(free_space),
        .packet_amount(packet_amount) 
    );

    /* ????????? */
    reg [15:0] queue_head [7:0];        /* ??????? */
    reg [15:0] queue_tail [7:0];        /* ???????? */
    reg [13:0] queue_amounts [7:0];     /* ??????????????? */
    wire [7:0] queue_empty = {          /* ?????????? */
        queue_head[7] == queue_tail[7], 
        queue_head[6] == queue_tail[6], 
        queue_head[5] == queue_tail[5], 
        queue_head[4] == queue_tail[4], 
        queue_head[3] == queue_tail[3], 
        queue_head[2] == queue_tail[2], 
        queue_head[1] == queue_tail[1], 
        queue_head[0] == queue_tail[0]
    };

    /* ??????? */
    reg join_request_enable;            /* ?????????????????????????????????? */
    always @(posedge clk) begin
        join_request_enable <= join_request_dest_ports[processing_join_request] == port;
    end

    reg concatenate_enable;             /* ???????????? */
    reg [15:0] concatenate_head;        /* ???????????? */
    reg [15:0] concatenate_tail;        /* ????????????? */
    assign concatenate_enables[port] = concatenate_enable;
    assign concatenate_heads[port] = concatenate_head;
    assign concatenate_tails[port] = concatenate_tail;
    
    /* ?????????????????????????????? */
    always @(posedge clk) begin
        if(join_request_enable) begin
            concatenate_enable <= 1;
            if(~queue_empty[join_request_prior]) begin                      /* ????????? */
                concatenate_head <= queue_tail[join_request_prior];         /* ?????????? */
                concatenate_tail <= join_request_head;                      /* ???????????????*/
                $display("concate = %d %d %d",queue_tail[join_request_prior],join_request_head,port);
            end else begin                                                  /* ????????? */
                concatenate_head <= join_request_tails[join_request_sram];  /* ?????????????? */
                concatenate_tail <= join_request_tails[join_request_sram];  /* ???????????????*/
            end
            $display("con cate = %d %d %d",queue_tail[join_request_prior],join_request_head,port);
        end else begin
            concatenate_enable <= 0;
        end
    end

    /* ??????? */
    always @(posedge clk) begin
        if(~rst_n) begin
            queue_tail[0] <= 16'd0; queue_tail[1] <= 16'd0; queue_tail[2] <= 16'd0; queue_tail[3] <= 16'd0;
            queue_tail[4] <= 16'd0; queue_tail[5] <= 16'd0; queue_tail[6] <= 16'd0; queue_tail[7] <= 16'd0;
        end if(join_request_enable) begin
            queue_tail[join_request_prior] <= join_request_tails[join_request_sram];/* join_request_tails????U???????????????????2?????? */
        end
    end

    /* ???? */
    wire [3:0] rd_prior;
    reg [2:0] pst_rd_prior;     /* ????????????????(rd_sop??rd_prior???????) */

    reg [5:0] rd_sram;
    assign rd_srams[port] = rd_sram;
    reg [4:0] pst_rd_sram;
    
    reg [10:0] rd_page;
    assign rd_xfer_pages[port] = rd_page;

    reg [6:0] rd_ecc_in_page_amount;   /* ????????????? */
    reg [6:0] rd_ecc_out_page_amount;   /* ????????????? */
    reg [2:0] rd_batch_end;     /* ??????????????????? */

    reg [3:0] ecc_in_batch;
    wire [3:0] ecc_out_batch;

    reg rd_over;
    
    wire rd_xfer_ready = ready[port] && rd_prior != 4'd8;
    wire rd_end_of_packet = rd_ecc_in_page_amount == 0 && ecc_in_batch == rd_batch_end && ~rd_over;
    wire rd_end_of_page = ecc_in_batch == 3'd7 || rd_end_of_packet;

    wire [15:0] rd_xfer_data = rd_ecc_in_page_amount == 0 && ecc_in_batch > rd_batch_end ? 0 : rd_xfer_datas[pst_rd_sram];
    reg [7:0] rd_xfer_ecc_code;
    reg [15:0] rd_xfer_next_page;
    wire [15:0] rd_out_data;

    wire out_end_of_packet = rd_ecc_out_page_amount == 0 && ecc_out_batch == rd_batch_end;

    //reg rd_end_of_pat;
    //always @(posedge clk) rd_end_of_pat <= rd_end_of_packet;
    /* ?????? */
    always @(posedge clk) begin
        if(~rst_n) begin
            queue_head[0] <= 16'd0; queue_head[1] <= 16'd0; queue_head[2] <= 16'd0; queue_head[3] <= 16'd0;
            queue_head[4] <= 16'd0; queue_head[5] <= 16'd0; queue_head[6] <= 16'd0; queue_head[7] <= 16'd0;
        end else if(join_request_enable && queue_empty[join_request_prior]) begin   /* ?????????????????????????????????????????????????? */
            queue_head[join_request_prior] <= join_request_head; 
        end else if(~rd_end_of_packet) begin                                        /* ??????????????????????? */
        end else if(rd_xfer_next_page != queue_tail[pst_rd_prior]) begin            /* ?????????????? */
            queue_head[pst_rd_prior] <= rd_xfer_next_pages[pst_rd_sram];
            if(port == 1)
                $display("queue_head = %d %d %d %d",pst_rd_prior,rd_xfer_next_page,rd_end_of_packet,port);
        end else begin                                                              /* ?????????????? */
            queue_head[pst_rd_prior] <= queue_tail[pst_rd_prior];
        end
    end

    always @(posedge clk) begin
        if(~rst_n || rd_xfer_ready) begin
            rd_over <= 0; 
        end else if(rd_end_of_packet) begin
            rd_over <= 1; 
        end
    end
   
    always @(posedge clk) begin
        if(~rst_n) begin
            rd_sram <= 6'd32;
        end if(rd_xfer_ready) begin
            pst_rd_prior <= rd_prior;
            rd_sram <= queue_head[rd_prior][15:11];
            //pst_rd_sram  <= queue_head[rd_prior][15:11];
            $display("rd_sram = %d %d",queue_head[rd_prior][15:11],port);
        end else if(rd_ecc_in_page_amount == 0 && ecc_in_batch == rd_batch_end) begin
            rd_sram <= 6'd32;
        end
    end

    always @(posedge clk) begin
        if(~rst_n || rd_eop[port]) begin
            pst_rd_sram <= 6'd32;
        end else if(rd_xfer_ready) begin
            pst_rd_sram  <= queue_head[rd_prior][15:11];
            //$display("rd_sram = %d %d",queue_head[rd_prior][15:11],port);
        end
    end

    always @(posedge clk) begin
        if(rd_xfer_ready) begin
            rd_page <= queue_head[rd_prior][10:0];
            if(port == 1)
                $display("rd_p age = %d %d %d",queue_head[rd_prior][10:0],port,rd_prior);
        end else if(ecc_in_batch == 4'd5) begin
            rd_page <= rd_xfer_next_page;
            $display("rd_page = %d %d %d",rd_page,rd_xfer_next_page,port);
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            ecc_in_batch <= 4'd8;
        end else if(rd_xfer_ports[rd_sram] == port && ~rd_end_of_packet) begin
            ecc_in_batch <= 4'd0;
        end else if(ecc_in_batch != 4'd8) begin
            ecc_in_batch <= ecc_in_batch + 1;
        end
        if(port == 1)
            $display("ecc_in_batch = %d %d %d",ecc_in_batch,rd_sram,rd_xfer_ports[rd_sram]);
    end

    always @(posedge clk) begin
        if(~rst_n || rd_xfer_ready) begin
            rd_ecc_in_page_amount <= 7'd64;
            rd_batch_end <= 3'd7;
        end else if(rd_ecc_in_page_amount == 7'd64 && ecc_out_batch == 4'd0) begin
            rd_ecc_in_page_amount <= rd_out_data[15:10] - 1;
            rd_batch_end <= rd_out_data[9:7];
            $display("rd_batch_end = %d %d %d",rd_out_data[9:7],port,rd_out_data[15:10] - 1);
        end else if(~rd_ecc_in_page_amount[6] && rd_ecc_in_page_amount != 0 && ecc_in_batch == 4'd7) begin
            rd_ecc_in_page_amount <= rd_ecc_in_page_amount - 1;
            if(port == 1)
                $display("rd_ecc_in_page_amount = %d %d",rd_ecc_in_page_amount,port);
        end
        if(port == 1 && !rd_ecc_in_page_amount)
            $display("rd_ecc_out_page_amount = %d",rd_ecc_out_page_amount);
    end

    always @(posedge clk) begin
        if(~rst_n || rd_xfer_ready) begin
            rd_ecc_out_page_amount <= 7'd64;
        end else if(rd_ecc_out_page_amount == 7'd64 && ecc_out_batch == 4'd0) begin
            rd_ecc_out_page_amount <= rd_out_data[15:10];
        end else if(~rd_ecc_out_page_amount[6] && rd_ecc_out_page_amount != 0 && ecc_out_batch == 4'd7) begin
            rd_ecc_out_page_amount <= rd_ecc_out_page_amount - 1;

        end
    end

    always @(posedge clk) begin
        if(ecc_in_batch == 4'd0) begin
            rd_xfer_next_page <= rd_xfer_next_pages[pst_rd_sram];
        end
    end

    always @(posedge clk) begin
        if(ecc_in_batch == 4'd6) begin
            rd_xfer_ecc_code <= rd_xfer_ecc_codes[pst_rd_sram];
        end
    end

    port_rd_dispatch port_rd_dispatch(
        .clk(clk),
        .rst_n(rst_n),

        .wrr_en(wrr_enable[port]),

        .queue_empty(queue_empty),
        .update(rd_end_of_packet),
        .rd_prior(rd_prior)
    );

    ecc_decoder port_ecc_decoder(
        .clk(clk),
        .rst_n(rst_n),

        .in_batch(ecc_in_batch),
        .data(rd_xfer_data),
        .code(rd_xfer_ecc_code),

        .out_end_of_packet(out_end_of_packet),
        .out_batch(ecc_out_batch),
        .out_data(rd_out_data)
    );

    port_rd_frontend port_rd_frontend(
        .clk(clk),
    
        .rd_sop(rd_sop[port]),
        .rd_eop(rd_eop[port]), 
        .rd_vld(rd_vld[port]),
        .rd_data(rd_data[port]),

        .xfer_ready(rd_xfer_ready),
        .xfer_data_vld(ecc_out_batch != 4'd8),
        .xfer_data(rd_out_data),
        .end_of_packet(out_end_of_packet)
    );

    /* ?????? */
    reg [8:0] packet_amounts [31:0];

    assign port_packet_amounts[port][0] = packet_amounts[0];
    assign port_packet_amounts[port][1] = packet_amounts[1];
    assign port_packet_amounts[port][2] = packet_amounts[2];
    assign port_packet_amounts[port][3] = packet_amounts[3];
    assign port_packet_amounts[port][4] = packet_amounts[4];
    assign port_packet_amounts[port][5] = packet_amounts[5];
    assign port_packet_amounts[port][6] = packet_amounts[6];
    assign port_packet_amounts[port][7] = packet_amounts[7];
    assign port_packet_amounts[port][8] = packet_amounts[8];
    assign port_packet_amounts[port][9] = packet_amounts[9];
    assign port_packet_amounts[port][10] = packet_amounts[10];
    assign port_packet_amounts[port][11] = packet_amounts[11];
    assign port_packet_amounts[port][12] = packet_amounts[12];
    assign port_packet_amounts[port][13] = packet_amounts[13];
    assign port_packet_amounts[port][14] = packet_amounts[14];
    assign port_packet_amounts[port][15] = packet_amounts[15];
    assign port_packet_amounts[port][16] = packet_amounts[16];
    assign port_packet_amounts[port][17] = packet_amounts[17];
    assign port_packet_amounts[port][18] = packet_amounts[18];
    assign port_packet_amounts[port][19] = packet_amounts[19];
    assign port_packet_amounts[port][20] = packet_amounts[20];
    assign port_packet_amounts[port][21] = packet_amounts[21];
    assign port_packet_amounts[port][22] = packet_amounts[22];
    assign port_packet_amounts[port][23] = packet_amounts[23];
    assign port_packet_amounts[port][24] = packet_amounts[24];
    assign port_packet_amounts[port][25] = packet_amounts[25];
    assign port_packet_amounts[port][26] = packet_amounts[26];
    assign port_packet_amounts[port][27] = packet_amounts[27];
    assign port_packet_amounts[port][28] = packet_amounts[28];
    assign port_packet_amounts[port][29] = packet_amounts[29];
    assign port_packet_amounts[port][30] = packet_amounts[30];
    assign port_packet_amounts[port][31] = packet_amounts[31];

    integer sram;
    always @(posedge clk) begin
        if(~rst_n) begin
            for(sram = 0; sram < 32; sram = sram + 1)
                packet_amounts[sram] <= 0;
        end else if(join_request_enable) begin /* ?????+1 */
            packet_amounts[join_request_sram] <= packet_amounts[join_request_sram] + 1;
        end else if(rd_end_of_packet) begin /* ??????-1 */
            packet_amounts[rd_sram] <= packet_amounts[rd_sram] - 1;
        end
    end

    //TODO ??????
    wire [15:0] debug_head = queue_head[4];
    wire [15:0] debug_tail = queue_tail[4];
    wire [15:0] debug_amount = packet_amounts[1];
end endgenerate

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    wire [15:0] match_select =          /* ?????????????? */
       {match_srams[15] == sram, match_srams[14] == sram, match_srams[13] == sram, match_srams[12] == sram, 
        match_srams[11] == sram, match_srams[10] == sram, match_srams[9] == sram, match_srams[8] == sram, 
        match_srams[7] == sram, match_srams[6] == sram, match_srams[5] == sram, match_srams[4] == sram, 
        match_srams[3] == sram, match_srams[2] == sram, match_srams[1] == sram, match_srams[0] == sram};
    wire [15:0] wr_select =             /* ??????????????? */
        {wr_srams[15] == sram, wr_srams[14] == sram, wr_srams[13] == sram, wr_srams[12] == sram, 
        wr_srams[11] == sram, wr_srams[10] == sram, wr_srams[9] == sram, wr_srams[8] == sram, 
        wr_srams[7] == sram, wr_srams[6] == sram, wr_srams[5] == sram, wr_srams[4] == sram, 
        wr_srams[3] == sram, wr_srams[2] == sram, wr_srams[1] == sram, wr_srams[0] == sram};

    wire [4:0] wr_port;                 /* ????????SRAM???????? */
    encoder_16_4 encoder_wr_select(
        .select(wr_select),
        .idx(wr_port)
    );
    /* ??SRAM????????????????????????????????????????????????????????????SRAM?????? */
    assign accessibilities[sram] = wr_select == 0 && match_select == 0;

    reg [15:0] comfort_mask;                /* ??????????? */
    wire [15:0] rd_select = comfort_mask &  /* ???????????? */
                            {rd_srams[15] == sram, rd_srams[14] == sram, rd_srams[13] == sram, rd_srams[12] == sram, 
                             rd_srams[11] == sram, rd_srams[10] == sram, rd_srams[9] == sram, rd_srams[8] == sram, 
                             rd_srams[7] == sram, rd_srams[6] == sram, rd_srams[5] == sram, rd_srams[4] == sram, 
                             rd_srams[3] == sram, rd_srams[2] == sram, rd_srams[1] == sram, rd_srams[0] == sram};

    wire [4:0] rd_port_idx;                  /* ??????????SRAM???????? */
    encoder_16_4 encoder_rd_select(
        .select(rd_select),
        .idx(rd_port_idx)
    );

    reg [2:0] rd_batch;                      /* ????????? */ 
    reg [5:0] rd_port;                       /* ?????????????????? */ 
    assign rd_xfer_ports[sram] = rd_port;
    reg [10:0] rd_page;                      /* ???????????? */ 
    reg rd_page_down;                        /* ???????????? */ 

    always @(posedge clk) begin
        if(~rst_n) begin
            rd_batch <= 3'd7;
            rd_page_down <= 0;
            rd_port <= 5'd16;
        end else if(rd_batch != 3'd7) begin  /* ?????????? */
            rd_batch <= rd_batch + 1;
            rd_page_down <= 0;
            rd_port <= 5'd16;
        end else if(rd_select != 0) begin    /* ????????????? */
            rd_batch <= 3'd0;
            rd_page_down <= 1;
            rd_port <= rd_port_idx;
            rd_page <= rd_xfer_pages[rd_port_idx];
            $display("rd_port = %d %d %d",rd_port_idx,rd_xfer_pages[rd_port_idx],sram);
        end else begin                       /* ????????????? */
            rd_batch <= 3'd7;
            rd_page_down <= 0;
            rd_port <= 5'd16;
        end
    end

    always @(posedge clk) begin
        if(~rst_n || rd_select == 0) begin                  /* ??????????? */
            comfort_mask <= 16'hFFFF;
        end else if(rd_batch == 7 && rd_select != 0) begin  /* ????????????????? */
            comfort_mask[rd_port_idx] <= 0;
        end
    end

    sram_interface sram_interface(
        .clk(clk), 
        .rst_n(rst_n), 

        .SRAM_IDX(sram[4:0]),
        .time_stamp(time_stamp),

        .wr_xfer_data_vld(wr_xfer_data_vlds[wr_port]),
        .wr_xfer_data(wr_xfer_datas[wr_port]),
        .wr_end_of_packet(wr_xfer_end_of_packets[wr_port]),

        .join_request_enable(join_request_select[sram]),
        .join_request_time_stamp(join_request_time_stamps[sram]),
        .join_request_dest_port(join_request_dest_ports[sram]),
        .join_request_prior(join_request_priors[sram]),
        .join_request_head(join_request_heads[sram]),
        .join_request_tail(join_request_tails[sram]),

        .concatenate_enable(concatenate_head[15:11] == sram && concatenate_select != 0),
        .concatenate_head(concatenate_head[10:0]), 
        .concatenate_tail(concatenate_tail),

        .rd_page_down(rd_page_down),
        .rd_page(rd_page),
        
        .rd_xfer_data(rd_xfer_datas[sram]),
        .rd_next_page(rd_xfer_next_pages[sram]),
        .rd_ecc_code(rd_xfer_ecc_codes[sram]),

        .free_space(free_spaces[sram])
    );
end endgenerate 
endmodule