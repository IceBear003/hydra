`include "sram.sv"

module sram_interface
(
    input clk,
    input rst_n,

    input [4:0] time_stamp,
    input [4:0] SRAM_IDX,

    /* ???? */

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
    input [10:0] concatenate_head,
    input [15:0] concatenate_tail,

    /* ???? */

    input rd_page_down,
    input [10:0] rd_page,

    output reg rd_xfer_data_vld,
    output [15:0] rd_xfer_data,
    output [15:0] rd_next_page,
    output [7:0] rd_ecc_code,

    /* ??? */

    output reg [10:0] free_space
    
    /* SRAM??????????? */
    // ,output wr_en,
    // output [13:0] wr_addr,
    // output [15:0] din,
    
    // output rd_en,
    // output [13:0] rd_addr,
    // input [15:0] dout
);

/******************************************************************************
 *                                ????????                                 *
 ******************************************************************************/

/* ECC???????? */
(* ram_style = "block" *) reg [7:0] ecc_codes [2047:0];
reg [10:0] ec_wr_addr;
wire [7:0] ec_din;
wire [10:0] ec_rd_addr;
reg [7:0] ec_dout;
always @(posedge clk) begin ecc_codes[ec_wr_addr] <= ec_din; end
always @(posedge clk) begin ec_dout <= ecc_codes[ec_rd_addr]; end

/* ECC?????? */
reg [15:0] ecc_encoder_buffer [7:0];

/* ????????????????????? (??page_down???????1????????) */
assign ec_rd_addr = rd_page;
assign rd_ecc_code = ec_dout;

/* ????? */
(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
reg [10:0] jt_wr_addr;
reg [15:0] jt_din;
wire [10:0] jt_rd_addr;
reg [15:0] jt_dout;
always @(posedge clk) begin jump_table[jt_wr_addr] <= jt_din; end
always @(posedge clk) begin 
    jt_dout <= jump_table[jt_rd_addr]; 
    if(jt_rd_addr == 5 && SRAM_IDX == 10) begin
        $display("jt_dout = %d %d",jt_dout,jt_din);
    end
    if(jt_wr_addr == 4 && SRAM_IDX == 29) begin
        $display("jt_d in = %d",jt_din);
    end
end

/* ???????????????????????? (??page_down???????1????????) */
assign jt_rd_addr = rd_page;
assign rd_next_page = jt_dout;

/* ???????? FIFO????RAM */
(* ram_style = "block" *) reg [10:0] null_pages [2047:0];
reg [10:0] np_wr_addr;
reg [10:0] np_din;
wire [10:0] np_rd_addr;
reg [10:0] np_dout;
always @(posedge clk) begin null_pages[np_wr_addr] <= np_din; end
always @(posedge clk) begin np_dout <= null_pages[np_rd_addr]; end

/*
 * np_head_ptr - ??????????????
 * np_tail_ptr - ???????????????
 * np_perfusion - ????????????????
 */
reg [10:0] np_head_ptr;
reg [10:0] np_tail_ptr;
reg [11:0] np_perfusion;

/*
 * ????????????
 * |- 0 - ???????????
 * |- 1 - ???????????????????
 * |- 2 - ????????????????????
 */
reg [1:0] wr_state;

/* ?????????? */
reg [10:0] wr_page;
/* ???????????????????????????????????wr_page??????????????????????????np_dout????????????????????? */
reg [1:0] regain_wr_page_tick;

reg [3:0] rd_batch; /* ??????????? */
wire [13:0] sram_rd_addr = {rd_page, rd_page_down ? 3'd0 : rd_batch[2:0]}; /* ???????????????0????????????rd_batch */
always @(posedge clk) begin
    rd_xfer_data_vld <= rd_batch != 4'd8 || rd_page_down;
    if(rd_batch != 4'd8) begin
        $display("rd_batch = %d",rd_batch);
        $display("rd_page = %d",rd_page);
        $display("rd_page_down = %d",rd_page_down);
        $display("rd_xfer_data_vld = %d %d",rd_xfer_data_vld,SRAM_IDX);
    end
end

/* ???????????????? */
reg [2:0] wr_batch;

reg [5:0] packet_length;

wire [13:0] sram_wr_addr = {wr_page, wr_batch};

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

ecc_encoder ecc_encoder( 
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

/* ???????? */
always @(posedge clk) begin
    if(concatenate_enable) begin /* ??????????????????????????? */
        jt_wr_addr <= concatenate_head;
        jt_din <= concatenate_tail;
        $display("jt_wr_addr = %d",concatenate_head);
        $display("jt _din = %d %d",concatenate_tail,SRAM_IDX);
    end else if(wr_xfer_data_vld && wr_page != wr_packet_tail_addr[10:0]) begin /* ??????????????????????????????? wr_page -> next_page(np_dout) */
        jt_wr_addr <= wr_page;
        jt_din <= {SRAM_IDX, np_dout};
        $display("jt_wr_addr = %d",wr_page);
        $display("jt_din = %d",{SRAM_IDX, np_dout});
    end
end

always @(posedge clk) begin
    if(!rst_n) begin 
        np_head_ptr <= 0;
    end if(wr_batch == 0 && wr_xfer_data_vld) begin /* ??????????????????????? */
        np_head_ptr <= np_head_ptr + 1;
        if(SRAM_IDX == 6) begin
            $display("np_head_ptr = %d",np_head_ptr);
        end
    end
end

assign np_rd_addr = (wr_state == 2'd0 && wr_xfer_data_vld) 
                    ? np_head_ptr + wr_xfer_data[15:10] /* ??????????????????????????????? */
                    : np_head_ptr; /* ??????????????????? */

always @(posedge clk) begin
    if(!rst_n) begin
        np_perfusion <= 0;  /* ?????0???? */
        np_tail_ptr <= 0;
    end else if(rd_page_down) begin /* ?????????? */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= rd_page;
    end else if(np_perfusion != 12'd2048) begin /* ?????2047???? */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= np_perfusion;
        if(SRAM_IDX == 6) begin
            $display("np_din = %d %d",np_perfusion,np_tail_ptr);
        end
        np_perfusion <= np_perfusion + 1;
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
    end else if((wr_batch == 3'd7 && wr_xfer_data_vld) || regain_wr_page_tick == 2'd1) begin /* ????wr_page?????? */
        wr_page <= np_dout;
        if(SRAM_IDX == 6) begin
            $display("np_dout = %d %d",np_dout,np_rd_addr,null_pages[np_rd_addr]);
        end
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        wr_batch <= 0;
    end else if(wr_end_of_packet) begin
        wr_batch <= 0;
        $display("Sram = %d",SRAM_IDX);
    end else if(wr_xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
        $display("wr_batch = %d %d",wr_batch,SRAM_IDX);
    end
    //$display("wr_xfer_data_vld = %d %d",wr_xfer_data_vld,SRAM_IDX);
end

/* 
 * ???????????????????????????????
 * |- wr_packet_dest_port - ???????????
 * |- wr_packet_prior - ??????????
 * |- wr_packet_head_addr - ?????????
 * |- wr_packet_tail_addr - ??????????
 */
always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_packet_dest_port <= wr_xfer_data[3:0];
        wr_packet_prior <= wr_xfer_data[6:4];
        wr_packet_head_addr <= {SRAM_IDX, wr_page};
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

/* ???????????? */
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

always @(posedge clk) begin
    if(~rst_n) begin
        rd_batch <= 4'd8;
    end if(rd_page_down) begin
        rd_batch <= 1; /* ?????????????????????1 */
    end else if(rd_batch != 4'd8) begin
        rd_batch <= rd_batch + 1;
    end
end

/******************************************************************************
 *                                  ??????                                   *
 ******************************************************************************/

always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        packet_length <= wr_xfer_data[15:10] + 1;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        free_space <= 11'd2047;
    end else if(wr_packet_join_request && rd_page_down) begin
        free_space <= free_space - packet_length + 1;
        $display("free_space = %d %d",free_space - packet_length + 1,SRAM_IDX);
    end else if(wr_packet_join_request) begin
        free_space <= free_space - packet_length;
        $display("free_space = %d %d",free_space - packet_length,SRAM_IDX);
    end else if(rd_page_down) begin
        free_space <= free_space + 1;
    end
end

// /* SRAM??????????????
sram sram(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_xfer_data_vld),
    .wr_addr(sram_wr_addr),
    .din(wr_xfer_data),
    .rd_en(rd_page_down || rd_batch != 4'd8),   //?????????????????1?????SRAM?????
    .rd_addr(sram_rd_addr),
    .dout(rd_xfer_data)
); 
// */

/* SRAM??????????? */
// assign wr_en = wr_xfer_data_vld;
// assign wr_addr = sram_wr_addr;
// assign din = wr_xfer_data;
// assign rd_en = 1'b1;
// assign rd_addr = sram_rd_addr;
// assign dout = rd_xfer_data;

endmodule