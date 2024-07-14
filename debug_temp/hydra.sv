`include "port_wr_sram_matcher.sv"
`include "port_wr_frontend.sv"
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
    input [15:0] pause,

    output reg full,
    output reg almost_full,

    input [15:0] ready,
    output reg [15:0] rd_sop,
    output reg [15:0] rd_eop,
    output reg [15:0] rd_vld,
    output reg [15:0] [15:0] rd_data,

    //????IO??
    input [15:0] wrr_enable,
    input [4:0] match_threshold,
    input [1:0] match_mode,
    //????????????????
    input [3:0] viscosity
);

/* ???? */
reg [4:0] time_stamp;
always @(posedge clk) begin
    if(~rst_n) begin
        time_stamp <= 0;
    end else begin
        time_stamp <= time_stamp + 1;
    end
end

/* ????????????SRAM??????*/
reg [5:0] wr_sram [15:0]; /* ??????? */
reg [5:0] matched_sram [15:0]; /* ??????? */

/* ?????SRAM???????????? */
wire wr_xfer_data_vld [15:0];
wire [15:0] wr_xfer_data [15:0];
wire wr_end_of_packet [15:0];

/* SRAM->Port ???????????? */
wire [3:0] wr_packet_dest_port [31:0];
wire [2:0] wr_packet_prior [31:0];
wire [15:0] wr_packet_head_addr [31:0];
wire [15:0] wr_packet_tail_addr [31:0];
wire [31:0] wr_packet_join_request; //TODO ??????????????????????????????????????????????????wire???????????
wire [5:0] wr_packet_join_time_stamp [31:0];

/* ??????? */ 
reg [4:0] ts_fifo [31:0];
reg [4:0] ts_head_ptr;
reg [4:0] ts_tail_ptr;

//TODO ????12??????????????????????????????????????
//??????????????????

/* ????????????? */
wire [5:0] processing_time_stamp = ts_head_ptr == ts_tail_ptr ? 6'd33 : ts_fifo[ts_head_ptr];
/* ???????????????????? */
reg [31:0] processing_join_mask;
/* ????????????????????? */
wire [31:0] processing_join_select = processing_join_mask & {wr_packet_join_time_stamp[31] == processing_time_stamp, wr_packet_join_time_stamp[30] == processing_time_stamp, wr_packet_join_time_stamp[29] == processing_time_stamp, wr_packet_join_time_stamp[28] == processing_time_stamp, wr_packet_join_time_stamp[27] == processing_time_stamp, wr_packet_join_time_stamp[26] == processing_time_stamp, wr_packet_join_time_stamp[25] == processing_time_stamp, wr_packet_join_time_stamp[24] == processing_time_stamp, wr_packet_join_time_stamp[23] == processing_time_stamp, wr_packet_join_time_stamp[22] == processing_time_stamp, wr_packet_join_time_stamp[21] == processing_time_stamp, wr_packet_join_time_stamp[20] == processing_time_stamp, wr_packet_join_time_stamp[19] == processing_time_stamp, wr_packet_join_time_stamp[18] == processing_time_stamp, wr_packet_join_time_stamp[17] == processing_time_stamp, wr_packet_join_time_stamp[16] == processing_time_stamp, wr_packet_join_time_stamp[15] == processing_time_stamp, wr_packet_join_time_stamp[14] == processing_time_stamp, wr_packet_join_time_stamp[13] == processing_time_stamp, wr_packet_join_time_stamp[12] == processing_time_stamp, wr_packet_join_time_stamp[11] == processing_time_stamp, wr_packet_join_time_stamp[10] == processing_time_stamp, wr_packet_join_time_stamp[9] == processing_time_stamp, wr_packet_join_time_stamp[8] == processing_time_stamp, wr_packet_join_time_stamp[7] == processing_time_stamp, wr_packet_join_time_stamp[6] == processing_time_stamp, wr_packet_join_time_stamp[5] == processing_time_stamp, wr_packet_join_time_stamp[4] == processing_time_stamp, wr_packet_join_time_stamp[3] == processing_time_stamp, wr_packet_join_time_stamp[2] == processing_time_stamp, wr_packet_join_time_stamp[1] == processing_time_stamp, wr_packet_join_time_stamp[0] == processing_time_stamp};
/* ?????????????????????? */
wire [4:0] processing_join_request;

/* Port->SRAM ???????????? */
wire [3:0] processing_concatenate_port = time_stamp[3:0];
reg concatenate_enable [15:0];
reg [15:0] concatenate_previous [15:0];
reg [15:0] concatenate_subsequent [15:0];

/*
 * SRAM
 */ 

reg [8:0] packet_amounts [31:0][15:0];
reg [10:0] free_spaces [31:0];
reg accessibilities [31:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    wire ready_to_xfer;
    wire xfer_data_vld;
    wire [15:0] xfer_data;
    wire end_of_packet;
    assign wr_xfer_data_vld[port] = xfer_data_vld;
    assign wr_xfer_data[port] = xfer_data;
    assign wr_end_of_packet[port] = end_of_packet;

    wire match_suc;
    wire match_enable;
    wire [3:0] new_dest_port;
    wire [8:0] new_length;

    /* ??????????????????SRAM????????????SRAM??????????????????? */
    reg [4:0] next_matching_sram;
    reg [4:0] matching_sram;
    /* SRAM?????? */
    reg [10:0] free_space;
    reg [8:0] packet_amount;
    reg accessibility;

    /* ??????????0???????? */
    reg [3:0] viscous_tick;
    wire viscous = viscous_tick != 0;

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
        if(!rst_n) begin
            viscous_tick <= 4'd0;
        end else if(end_of_packet) begin //?????????????????????
            viscous_tick <= viscosity;
        end else if(viscous_tick > 0) begin
            viscous_tick <= viscous_tick - 1;
        end
        //$display("xfer = %d",xfer_data_vld);
    end

    always @(posedge clk) begin
        matching_sram <= next_matching_sram;
        free_space <= free_spaces[next_matching_sram];
        //TODO ??packet_amounts????????????????????????????????????????????????????
        packet_amount <= packet_amounts[next_matching_sram][wr_data[port][3:0]];
        accessibility <= accessibilities[next_matching_sram];
        //$display()
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

    wire [4:0] matching_best_sram;

    always @(posedge clk) begin
        if(!rst_n) begin
            wr_sram[port] <= 6'd32;
        end else if(ready_to_xfer) begin /* ???????PORT->SRAM?????????????????????????????wr_sram??????????? */
            wr_sram[port] <= matching_best_sram;
            $display("matching_best_sram = %d",matching_best_sram);
            $display("port = %d",port);
        end else if(viscous_tick == 4'd1 || viscosity == 0) begin /* ???????????????????????????????? */
            wr_sram[port] <= 6'd32;
        end
        //$display("wr_sram[0] = %d",wr_sram[0]);
    end

    wire update_matched_sram;

    always @(posedge clk) begin
        if(!rst_n) begin
            matched_sram[port] <= 6'd32;
        end else if(update_matched_sram) begin
            matched_sram[port] <= matching_best_sram; /* ????????SRAM???????????????????????????????????????????????? */
        end else begin
            matched_sram[port] <= 6'd32;
        end
    end
    
    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),
    
        .match_mode(match_mode),
        .match_threshold(match_threshold),

        .new_dest_port(new_dest_port),
        .new_length(new_length),
        .match_enable(match_enable),
        .match_suc(match_suc),

        .viscous(viscous),
        .matching_sram(matching_sram),
        .matching_best_sram(matching_best_sram),
        .update_matched_sram(update_matched_sram),

        .accessible(accessibility),
        .free_space(free_space),
        .packet_amount(packet_amount) 
    );

    reg [15:0] queue_head [7:0];
    reg [15:0] queue_tail [7:0];
    wire [7:0] queue_empty = {queue_head[7] == queue_tail[7], queue_head[6] == queue_tail[6], queue_head[5] == queue_tail[5], queue_head[4] == queue_tail[4], queue_head[3] == queue_tail[3], queue_head[2] == queue_tail[2], queue_head[1] == queue_tail[1], queue_head[0] == queue_tail[0]};

    wire [15:0] debug_head = queue_head[4];
    wire [15:0] debug_tail = queue_tail[4];

    /* ??????????????? */
    reg join_enable;
    /* ????????????????????? */
    reg [2:0] join_prior;
    /* ????????????????SRAM???? */
    reg [2:0] join_request;
    /* ???????????????????????????????????Port->SRAM??concatenate_enable */
    reg [3:0] concatenate_tick;

    always @(posedge clk) begin
        /* ??????????????????????????? */
        if(wr_packet_dest_port[processing_join_request] == port) begin
            join_enable <= 1;
            join_prior <= wr_packet_prior[processing_join_request];
            join_request <= processing_join_request;
            $display("processing_join_request = %d",processing_join_request);
            $display("prior = %d",wr_packet_prior[processing_join_request]);
        end else begin
            join_enable <= 0;
        end
    end

    integer prior;
    always @(posedge clk) begin
        if(~rst_n) begin
            for(prior = 0; prior < 8; prior = prior + 1) begin
                queue_head[prior] <= 16'd0;
                queue_tail[prior] <= 16'd0;
            end
        end if(join_enable == 0) begin
        end else if(queue_empty[join_prior]) begin /* ?????????????? ?->? + ??->?? */
            queue_head[join_prior] <= wr_packet_head_addr[join_request];
            queue_tail[join_prior] <= wr_packet_tail_addr[join_request];
        end else begin /* ??????????????? ???????????? + ??->?? */
            queue_tail[join_prior] <= wr_packet_tail_addr[join_request];
            concatenate_previous[port] <= queue_tail[join_prior];
            concatenate_subsequent[port] <= wr_packet_head_addr[join_request];
        end
    end
    
    always @(posedge clk) begin
        if(join_enable == 1 && ~queue_empty[join_prior]) begin /* ??????????????? ???????????? + ??->?? */
            concatenate_enable[port] <= 1'b1;
        end else if(concatenate_tick == 0) begin
            concatenate_enable[port] <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if(join_enable == 1 && ~queue_empty[join_prior]) begin
            concatenate_tick <= 4'd15;
        end else if(concatenate_tick != 0) begin
            concatenate_tick <= concatenate_tick - 1;
        end
    end

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

    /* ?????????? */
    wire [15:0] select_wr = {wr_sram[15] == sram, wr_sram[14] == sram, wr_sram[13] == sram, wr_sram[12] == sram, wr_sram[11] == sram, wr_sram[10] == sram, wr_sram[9] == sram, wr_sram[8] == sram, wr_sram[7] == sram, wr_sram[6] == sram, wr_sram[5] == sram, wr_sram[4] == sram, wr_sram[3] == sram, wr_sram[2] == sram, wr_sram[1] == sram, wr_sram[0] == sram};
    /* ??????????? */
    wire [15:0] select_matched = {matched_sram[15] == sram, matched_sram[14] == sram, matched_sram[13] == sram, matched_sram[12] == sram, matched_sram[11] == sram, matched_sram[10] == sram, matched_sram[9] == sram, matched_sram[8] == sram, matched_sram[7] == sram, matched_sram[6] == sram, matched_sram[5] == sram, matched_sram[4] == sram, matched_sram[3] == sram, matched_sram[2] == sram, matched_sram[1] == sram, matched_sram[0] == sram};
    always @(posedge clk) begin
        /* ??SRAM??????????????????????????????????????????????????????????SRAM?????? */
        accessibilities[sram] <= select_wr == 0 && select_matched == 0;
        $display("select_wr = %d",select_wr);
        //$display("wr_sram = %b",wr_sram[0]);
    end
    
    /* ????????SRAM?????????????????????16-4????????? */
    wire [3:0] wr_port;
    decoder_16_4 decoder_16_4(
        .select(select_wr),
        .idx(wr_port)
    );

    /* ??????????? */
    reg concatenate_en; 
    reg [15:0] concatenate_head;
    reg [15:0] concatenate_tail;

    always @(posedge clk) begin
        if(concatenate_enable[processing_concatenate_port] /* ???????????????????????????????????????SRAM */
            && concatenate_previous[processing_concatenate_port][15:11] == sram) begin
            
            //TODO ?????????????????????????????????????????????????????head??tail???wire????SRAM
            concatenate_head <= concatenate_previous[processing_concatenate_port];
            concatenate_tail <= concatenate_subsequent[processing_concatenate_port];
            concatenate_en <= 1;
        end else begin
            concatenate_en <= 0;
        end
        $display("wr_port = %d",wr_port);
    end

    integer port;
    always @(posedge clk) begin
        if(~rst_n) begin
            for(port = 0; port < 16; port = port + 1) begin
                packet_amounts[sram][port] <= 32 - sram; /* DEBUG ??????????????????????? 9'd0 */
            end
            free_spaces[sram] <= 100 + sram; /* DEBUG ??????????????????????? 11'd2047 */
        end else if(wr_end_of_packet[wr_port]) begin
            packet_amounts[sram][wr_port] <= packet_amounts[sram][wr_port] + 1;
            free_spaces[sram] <= free_spaces[sram] - 1; //TODO FIXME ????????????????????????sram_interface??????????????
        end else if(0) begin
            // packet_amounts[sram][rd_port] <= packet_amounts[sram][rd_port] - 1;
        end
    end

    sram_interface sram_interface(
        .clk(clk),
        .rst_n(rst_n), 

        .SRAM_IDX(sram[4:0]),
        .time_stamp(time_stamp),
        .match_mode(match_mode),

        .wr_xfer_data_vld(wr_xfer_data_vld[wr_port]),
        .wr_xfer_data(wr_xfer_data[wr_port]),
        .wr_end_of_packet(wr_end_of_packet[wr_port]), 

        .wr_packet_dest_port(wr_packet_dest_port[sram]),
        .wr_packet_prior(wr_packet_prior[sram]),
        .wr_packet_head_addr(wr_packet_head_addr[sram]),
        .wr_packet_tail_addr(wr_packet_tail_addr[sram]),
        .wr_packet_join_request(wr_packet_join_request[sram]),
        .wr_packet_join_time_stamp(wr_packet_join_time_stamp[sram]),

        .concatenate_enable(concatenate_en),
        .concatenate_head(concatenate_head), 
        .concatenate_tail(concatenate_tail)
    );
end endgenerate 
endmodule