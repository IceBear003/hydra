module sram_interface
(
    input clk,
    input rst_n,

    input [1:0] match_mode,
    input [4:0] time_stamp,
    input [4:0] SRAM_IDX,

    /*
     * ????
     */
    input wr_xfer_data_vld,
    input [15:0] wr_xfer_data,
    input wr_end_of_packet,

    output reg [3:0] wr_packet_dest_port,
    output reg [2:0] wr_packet_prior,
    output reg [15:0] wr_packet_head_addr,
    output reg [15:0] wr_packet_tail_addr,
    output reg wr_packet_join_request,
    output reg [5:0] wr_packet_join_time_stamp,

    input concatenate_enable,
    input [15:0] concatenate_head,
    input [15:0] concatenate_tail,

    /*
     * ????
     */
    input [10:0] rd_page,

    output reg rd_xfer_data_vld,
    output reg [15:0] rd_xfer_data,
    output reg [15:0] rd_next_page
);

/******************************************************************************
 *                                ????????                                 *
 ******************************************************************************/

/* ECC???????? */
(* ram_style = "block" *) reg [7:0] ecc_codes [2047:0];
reg [10:0] ec_wr_addr;
wire [7:0] ec_din;
reg [10:0] ec_rd_addr;
reg [7:0] ec_dout;
always @(posedge clk) begin ecc_codes[ec_wr_addr] <= ec_din; end
always @(posedge clk) begin ec_dout <= ecc_codes[ec_rd_addr]; end

/*
 * np_head_ptr - ??????????????
 * np_tail_ptr - ???????????????
 * np_perfusion_process - ????????????????
 */
reg [10:0] np_head_ptr;
reg [10:0] np_tail_ptr;
reg [10:0] np_perfusion_process;

/* ECC?????? */
reg [15:0] ecc_encoder_buffer [7:0];

/* ???????????????? */
reg [2:0] wr_batch;

/* ?????????? */
reg [10:0] wr_page;
/* ???????????????????????????????????wr_page?????????????????????????np_dout????????????????????? */
reg [1:0] regain_wr_page_tick;

/*
 * ???????????
 * |- 0 - ???????????
 * |- 1 - ??????????????????
 * |- 2 - ???????????????????
 */
reg [1:0] wr_state;

always @(posedge clk) begin
    if(wr_xfer_data_vld) begin
        if(wr_batch == 0) begin
            /* ??????????????????????????ECC???? */
            ecc_encoder_buffer[1] <= 16'h0000;
            ecc_encoder_buffer[2] <= 16'h0000;
            ecc_encoder_buffer[3] <= 16'h0000;
            ecc_encoder_buffer[4] <= 16'h0000;
            ecc_encoder_buffer[5] <= 16'h0000;
            ecc_encoder_buffer[6] <= 16'h0000;
            ecc_encoder_buffer[7] <= 16'h0000;
        end
        ecc_encoder_buffer[wr_batch] <= wr_xfer_data;
    end
end

always @(posedge clk) begin
    if(wr_batch == 3'd7 && wr_xfer_data_vld || wr_end_of_packet) begin
        /* ???????????????ECC???????? */
        ec_wr_addr <= wr_page;
    end
end

sram_ecc_encoder sram_ecc_encoder( 
    .data_0(ecc_encoder_buffer[0]),
    .data_1(ecc_encoder_buffer[1]),
    .data_2(ecc_encoder_buffer[2]),
    .data_3(ecc_encoder_buffer[3]),
    .data_4(ecc_encoder_buffer[4]),
    .data_5(ecc_encoder_buffer[5]),
    .data_6(ecc_encoder_buffer[6]),
    .data_7(ecc_encoder_buffer[7]),
    .code(ec_din)
);

/* ????? */
(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
reg [10:0] jt_wr_addr;
reg [15:0] jt_din;
reg [10:0] jt_rd_addr;
reg [15:0] jt_dout;
always @(posedge clk) begin jump_table[jt_wr_addr] <= jt_din; end
always @(posedge clk) begin jt_dout <= jump_table[jt_rd_addr]; end

/* ???????? FIFO????RAM */
(* ram_style = "block" *) reg [10:0] null_pages [2047:0];
reg [10:0] np_wr_addr;
reg [10:0] np_din;
wire [10:0] np_rd_addr;
reg [10:0] np_dout;
always @(posedge clk) begin null_pages[np_wr_addr] <= np_din; end
always @(posedge clk) begin np_dout <= null_pages[np_rd_addr]; end

/* ???????? */
always @(posedge clk) begin
    if(concatenate_enable) begin /* ??????????????????????????? */
        jt_wr_addr <= concatenate_head;
        jt_din <= concatenate_tail;
        $display("jt_ wr_addr = %d %d",concatenate_head,SRAM_IDX);
        $display("jt _din = %d",concatenate_tail);
    end else if (wr_xfer_data_vld && wr_page != wr_packet_tail_addr) begin
        jt_wr_addr <= wr_page;
        jt_din <= {SRAM_IDX,np_dout};
        if(wr_page) begin
            $display("jt_wr_addr = %d %d",wr_page,SRAM_IDX);
            $display("jt_din = %d",np_dout);
        end
    end
end

always @(posedge clk) begin
    if(!rst_n) begin 
        np_head_ptr <= 0;
    end if(wr_batch == 0 && wr_xfer_data_vld) begin /* ????????????????? */
        np_head_ptr <= np_head_ptr + 1;
    end
end

assign np_rd_addr = (wr_state == 2'd0 && wr_xfer_data_vld) 
                    ? np_head_ptr + wr_xfer_data[15:10] - (wr_xfer_data[9:7] == 0) /* ????????????????????????? */
                    : np_head_ptr;

always @(posedge clk) begin
    if(!rst_n) begin
        np_perfusion_process <= 0;  /* ?????1??? */
        np_tail_ptr <= 0;
    end else if(0 /* ???????????? */) begin
        np_tail_ptr <= np_tail_ptr + 1;
    end else if(np_perfusion_process != 12'd2048) begin /* ?????2047???? */
        np_tail_ptr <= np_tail_ptr + 1;
        np_perfusion_process <= np_perfusion_process + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= np_perfusion_process;
    end
end

/******************************************************************************
 *                                  ??????                                   *
 ******************************************************************************/

always @(posedge clk) begin
    if(!rst_n) begin
        wr_state <= 2'd0;
    end else if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_state <= 2'd1;
    end else if(wr_state == 2'd1 && wr_batch == 3'd7 && wr_xfer_data_vld) begin
        wr_state <= 2'd2;
    end else if(wr_state == 2'd2 && wr_end_of_packet) begin
        wr_state <= 2'd0;
        $display("1wd");
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        regain_wr_page_tick <= 2'd0;
    end else if(wr_end_of_packet) begin
        regain_wr_page_tick <= 2'd3;
    end else if(regain_wr_page_tick != 0) begin
        regain_wr_page_tick <= regain_wr_page_tick - 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        wr_page <= 0;
    end else if((wr_batch == 3'd7 && wr_xfer_data_vld) || regain_wr_page_tick == 2'd1) begin /* ????wr_page????? */
        wr_page <= np_dout;
        $display("np_rd_addr = %d",np_rd_addr);
        $display("np_head_ptr = %d %d",np_head_ptr,SRAM_IDX);
        $display("wr_xfer_data_vld = %d",wr_xfer_data_vld);
    end 
    //$display("wr_xfer_data_vld = %d %d",wr_xfer_data_vld,SRAM_IDX);
    //$display("wr_end_of_packet = %d %d",wr_end_of_packet,SRAM_IDX);
end

always @(posedge clk) begin
    if(!rst_n) begin
        wr_batch <= 0;
    end else if(wr_xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
    end else if(wr_end_of_packet) begin
        wr_batch <= 0;
    end
end

/* 
 * ???????????????????????????????
 * |- wr_packet_dest_port - ??????????
 * |- wr_packet_prior - ??????????
 * |- wr_packet_head_addr - ?????????
 * |- wr_packet_tail_addr - ??????????
 */
always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_packet_dest_port <= wr_xfer_data[3:0];
        wr_packet_prior <= wr_xfer_data[6:4];
        wr_packet_head_addr <= {SRAM_IDX, wr_page};
        $display("wr_ packet_head_addr = %d %d",SRAM_IDX,wr_page);
    end
    if(wr_state == 2'd1 && wr_batch == 3'd1) begin
        wr_packet_tail_addr <= {SRAM_IDX, np_dout};
    end
end

/* ????????????????????????? */
always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_packet_join_request <= 1;
    end else begin
        wr_packet_join_request <= 0;
    end
end

/* ??????????? */
always @(posedge clk) begin
    if(~rst_n) begin 
        wr_packet_join_time_stamp <= 6'd32;
    end if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_packet_join_time_stamp <= {1'b0, time_stamp + 5'd1}; /* +1 ?????????????????????????????????? */
    end else if(time_stamp + 5'd1 == wr_packet_join_time_stamp) begin
        wr_packet_join_time_stamp <= 6'd32; /* 32?????????????????????? */
    end
end

/******************************************************************************
 *                                  ????????                                   *
 ******************************************************************************/

/******************************************************************************
 *                                  SRAM????                                   *
 ******************************************************************************/

wire [13:0] sram_wr_addr = {wr_page, wr_batch};

sram sram(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_xfer_data_vld),
    .wr_addr(sram_wr_addr),
    .din(wr_xfer_data)
);
endmodule