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

    output reg [4:0] join_request_dest_port,
    output reg [2:0] join_request_prior,
    output reg [15:0] join_request_head,
    output reg [15:0] join_request_tail,
    output reg join_request_enable,
    output reg [5:0] join_request_time_stamp,

    input concatenate_enable,
    input [10:0] concatenate_head,
    input [15:0] concatenate_tail,

    /* ???? */

    input rd_page_down,
    input [10:0] rd_page,

    output reg rd_xfer_data_vld,
    output [15:0] rd_xfer_data,
    output reg [15:0] rd_next_page,
    output reg [7:0] rd_ecc_code,

    /* ??? */

    output reg [10:0] free_space
    
    /* SRAM??????????? */
    // ,(*DONT_TOUCH="YES"*) output wr_en,
    // (*DONT_TOUCH="YES"*) output [13:0] wr_addr,
    // (*DONT_TOUCH="YES"*) output [15:0] din,
    
    // (*DONT_TOUCH="YES"*) output rd_en,
    // (*DONT_TOUCH="YES"*) output [13:0] rd_addr,
    // (*DONT_TOUCH="YES"*) input [15:0] dout
);

/******************************************************************************
 *                                ????????                                 *
 ******************************************************************************/

/* ???????????????? */
reg [2:0] wr_batch;

/*
 * ????????????
 * |- 0 - ???????????
 * |- 1 - ???????????????????
 * |- 2 - ????????????????????
 */
reg [1:0] wr_state;

/* ?????????? */
reg [10:0] wr_page;
/* 
 * ECC??????
 * RAM??(2048*8) ??? 0.5*36Kbit BRAM
 */
(* ram_style = "block" *) reg [7:0] ecc_codes [2047:0];
/* ECC??????? */
reg ec_wr_en;
reg [10:0] ec_wr_addr;
wire [7:0] ec_din;
always @(posedge clk) begin 
    if(ec_wr_en) begin
        ecc_codes[ec_wr_addr] <= ec_din; 
        //$display("ecc_addr = %d %d %d",ec_wr_addr,ec_din,SRAM_IDX);
    end
end
always @(posedge clk) begin
    if(wr_batch == 3'd7 && wr_xfer_data_vld || wr_end_of_packet) begin
        ec_wr_en <= 1;
        /* ???????????????ECC???????? */
        ec_wr_addr <= wr_page;
    end else begin
        ec_wr_en <= 0;
    end
end
/* ECC???????? */
reg [15:0] ecc_encoder_buffer [7:0];
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
        //$display("ecc_data = %d %d %d %d",wr_xfer_data,wr_batch,ec_din,SRAM_IDX);
    end
end
/* ECC?????? */
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
/* ECC??????? */
wire [10:0] ec_rd_addr;
reg [7:0] ec_dout;
always @(posedge clk) begin 
    ec_dout <= ecc_codes[ec_rd_addr]; 
end
/* ????????????????? */
assign ec_rd_addr = rd_page;

always @(posedge clk) begin
    rd_ecc_code <= ec_dout;
end

/*
 * ??FIFO??????????????
 * |- np_head_ptr - ??????????????
 * |- np_tail_ptr - ???????????????
 * |- np_perfusion - ????????????????
 */
reg [10:0] np_head_ptr;
reg [10:0] np_tail_ptr;
reg [11:0] np_perfusion;
reg [10:0] np_dout;
/* 
 * ?????
 * RAM??(2048*16) ??? 1*36Kbit BRAM
 */
(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
 /* ????????? */
reg [10:0] jt_wr_addr;
reg [15:0] jt_din;
always @(posedge clk) begin jump_table[jt_wr_addr] <= jt_din; end
/* ????????(???????/???????) */
always @(posedge clk) begin
    if(concatenate_enable) begin                                                    /* ???????????????????? */
        jt_wr_addr <= concatenate_head;
        jt_din <= concatenate_tail;
        $display("jt_con = %d %d %d",concatenate_head,concatenate_tail,SRAM_IDX);
    end else if(wr_xfer_data_vld && wr_page != join_request_tail[10:0]) begin       /* ??????????????????? */
        jt_wr_addr <= wr_page;
        jt_din <= {SRAM_IDX, np_dout};
        $display("jt_in = %d %d %d",wr_page,np_dout,SRAM_IDX);
    end
end
/* ????????? */
wire [10:0] jt_rd_addr;
reg [15:0] jt_dout;
always @(posedge clk) begin jt_dout <= jump_table[jt_rd_addr]; end
/* ????????????????????? */
assign jt_rd_addr = rd_page;
always @(posedge clk) begin
    rd_next_page <= jt_dout;
end

/* 
 * ????????
 * RAM??(2048*11) ??? 1*36Kbit BRAM
 */
(* ram_style = "block" *) reg [10:0] null_pages [2047:0];

/* ???????????? */
reg [10:0] np_wr_addr;
reg [10:0] np_din;
always @(posedge clk) begin null_pages[np_wr_addr] <= np_din; end

/* ???????????? */
wire [10:0] np_rd_addr;

always @(posedge clk) begin np_dout <= null_pages[np_rd_addr]; end

assign np_rd_addr = (wr_state == 2'd0 && wr_xfer_data_vld) 
                    ? np_head_ptr + wr_xfer_data[15:10] /* ??????????????????????????????? */
                    : np_head_ptr;                      /* ??????????????????? */
reg [10:0] new_page;
always @(posedge clk) begin
    new_page <= np_dout;
end                    

always @(posedge clk) begin
    if(!rst_n) begin 
        np_head_ptr <= 0;
    end if(wr_batch == 0 && wr_xfer_data_vld) begin     /* ??????????????????????? */
        np_head_ptr <= np_head_ptr + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        np_perfusion <= 0;                              /* ?????0???? */
        np_tail_ptr <= 0;
    end else if(rd_page_down) begin                     /* ?????????? */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= rd_page;
    end else if(np_perfusion != 12'd2048) begin         /* ?????2047???? */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= np_perfusion;
        np_perfusion <= np_perfusion + 1;
        //$display("np = %d %d %d %d %d",np_tail_ptr,np_wr_addr,np_din,np_perfusion,SRAM_IDX);
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
    if((wr_batch == 3'd7 && wr_xfer_data_vld) || wr_state == 2'd0) begin /* ????wr_page?????? */
        wr_page <= new_page;
        //if(wr_xfer_data_vld)
        //    $display("wr_page = %d %d",wr_page,SRAM_IDX);
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        wr_batch <= 0;
    end else if(wr_end_of_packet) begin
        wr_batch <= 0;
    end else if(wr_xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
    end
end

/* ????????????????????????????? */
always @(posedge clk) begin
    join_request_enable <= wr_state == 2'd0 && wr_xfer_data_vld;    /* ??????????? */
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin                  /* ????????????????? */
        join_request_dest_port <= wr_xfer_data[3:0];
        join_request_prior <= wr_xfer_data[6:4];
        join_request_head <= {SRAM_IDX, wr_page};
    end
    if(wr_state == 2'd1 && wr_batch == 3'd2) begin                  /* ?????????????????????????????????? */
        join_request_tail <= {SRAM_IDX, new_page};
        //$display("request_tail = %d %d",new_page,SRAM_IDX);
    end
end

/* ???????????? */
always @(posedge clk) begin
    if(~rst_n) begin 
        join_request_time_stamp <= 6'd32;
    end if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        join_request_time_stamp <= {1'b0, time_stamp + 5'd1};       /* ????????????????????????????? */
    end else if(time_stamp + 5'd1 == join_request_time_stamp) begin
        join_request_time_stamp <= 6'd32;                           /* 31???????????????? */
    end
end

/******************************************************************************
 *                                  ????????                                   *
 ******************************************************************************/

reg [3:0] rd_batch; /* ??????????? */
wire [13:0] sram_rd_addr = {rd_page, rd_page_down ? 3'd0 : rd_batch[2:0]}; /* ???????????????0????????????rd_addr_batch */
always @(posedge clk) begin
    rd_xfer_data_vld <= rd_batch != 4'd8 || rd_page_down;
end

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

reg [5:0] packet_length;
always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        packet_length <= wr_xfer_data[15:10] + 1;
    end
end 

always @(posedge clk) begin
    if(~rst_n) begin
        //if(SRAM_IDX == 10)
            free_space <= 11'd2047;
        //else
        //    free_space <= 11'd1;
    end else if(join_request_enable && rd_page_down) begin
        free_space <= free_space - packet_length + 1;
    end else if(join_request_enable) begin
        free_space <= free_space - packet_length;
    end else if(rd_page_down) begin
        free_space <= free_space + 1;
    end
end

wire [13:0] sram_wr_addr = {wr_page, wr_batch};

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
endmodule