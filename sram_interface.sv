`include "sram.sv"
`include "sram_ecc_encoder.sv"
`include "sram_ecc_decoder.sv"
`include "sram_rd_round.sv"

module sram_interface
(
    input clk,
    input rst_n,

    input [1:0] match_mode,
    input [4:0] time_stamp,
    input [4:0] SRAM_IDX,

    /*
     * 写入数据
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
    input [15:0] concatenate_tail
);

/******************************************************************************
 *                                重要存储结构                                 *
 ******************************************************************************/

/* ECC编码存储器 */
(* ram_style = "block" *) reg [7:0] ecc_codes [2047:0];
reg [10:0] ec_wr_addr;
wire [7:0] ec_din;
reg [10:0] ec_rd_addr;
reg [7:0] ec_dout;
always @(posedge clk) begin ecc_codes[ec_wr_addr] <= ec_din; end
always @(posedge clk) begin ec_dout <= ecc_codes[ec_rd_addr]; end

/* ECC加码器 */
reg [15:0] ecc_encoder_buffer [7:0];

always @(posedge clk) begin
    if(wr_xfer_data_vld) begin
        if(wr_batch == 0) begin
            /* 页初时清理缓冲，以免脏数据影响ECC计算 */
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
    if(wr_end_of_page) begin
        /* 页末时准备将结果写入ECC编码存储器 */
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

/* 跳转表 */
(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
reg [10:0] jt_wr_addr;
reg [15:0] jt_din;
reg [10:0] jt_rd_addr;
reg [15:0] jt_dout;
always @(posedge clk) begin jump_table[jt_wr_addr] <= jt_din; end
always @(posedge clk) begin jt_dout <= jump_table[jt_rd_addr]; end

/* 跳转表拼接 */
always @(posedge clk) begin
    if(concatenate_enable) begin /* 优先进行不同数据包间跳转表的拼接 */
        jt_wr_addr <= concatenate_head;
        jt_din <= concatenate_tail;
    end else begin
        jt_wr_addr <= wr_page;
        jt_din <= np_dout;
    end
end

/* 空闲队列 FIFO结构的RAM */
(* ram_style = "block" *) reg [10:0] null_pages [2047:0];
reg [10:0] np_wr_addr;
reg [10:0] np_din;
wire [10:0] np_rd_addr;
reg [10:0] np_dout;
always @(posedge clk) begin null_pages[np_wr_addr] <= np_din; end
always @(posedge clk) begin np_dout <= null_pages[np_rd_addr]; end

/*
 * np_head_ptr - 空闲队列的头指针
 * np_tail_ptr - 空闲队列的尾指针
 * np_perfusion_process - 空闲队列的灌注进度
 */
reg [10:0] np_head_ptr;
reg [10:0] np_tail_ptr;
reg [10:0] np_perfusion_process;

always @(posedge clk) begin
    if(!rst_n) begin 
        np_head_ptr <= 0;
    end if(wr_batch == 0 && wr_xfer_data_vld) begin /* 在一页刚开始的时候弹出顶页 */
        np_head_ptr <= np_head_ptr + 1;
    end
end

assign np_rd_addr = (wr_state == 2'd0 && wr_xfer_data_vld) 
                    ? np_head_ptr + wr_xfer_data[15:10] - (wr_xfer_data[9:7] == 0) /* 在数据包刚开始传输时查询尾页地址 */
                    : np_head_ptr;

always @(posedge clk) begin
    if(!rst_n) begin
        np_perfusion_process <= 0;  /* 灌注从1开始 */
        np_tail_ptr <= 0;
    end else if(0 /* 读出页，未完成 */) begin
        np_tail_ptr <= np_tail_ptr + 1;
    end else if(np_perfusion_process != 12'd2048) begin /* 灌注到2047结束 */
        np_tail_ptr <= np_tail_ptr + 1;
        np_perfusion_process <= np_perfusion_process + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= np_perfusion_process;
    end
end

/******************************************************************************
 *                                  写入处理                                   *
 ******************************************************************************/

/*
 * 数据包写入状态
 * |- 0 - 无数据包写入
 * |- 1 - 正在写入数据包的第一页
 * |- 2 - 正在写入数据包的后续页
 */
reg [1:0] wr_state;

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

/* 当前是否为页末 */
wire wr_end_of_page = wr_batch == 3'd7 && wr_xfer_data_vld || wr_end_of_packet;
/* 正在写入的页 */
reg [10:0] wr_page;

always @(posedge clk) begin
    if(!rst_n) begin
        wr_page <= 0;
    end else if(wr_end_of_page) begin /* 在上页末时更新wr_page到新页 */ //TODO FIX: 最后一页长度小于3时会出错
        wr_page <= np_dout;
    end
end

/* 数据包写入切片下标 */
reg [2:0] wr_batch;

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
 * 在数据包刚写入时生成入队请求基本信息
 * |- wr_packet_dest_port - 数据包目的端口
 * |- wr_packet_prior - 数据包优先级
 * |- wr_packet_head_addr - 数据包头地址
 * |- wr_packet_tail_addr - 数据包尾地址
 */
always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_packet_dest_port <= wr_xfer_data[3:0];
        wr_packet_prior <= wr_xfer_data[6:4];
        wr_packet_head_addr <= {SRAM_IDX, wr_page};
    end
    if(wr_state == 2'd1 && wr_batch == 3'd2) begin
        wr_packet_tail_addr <= {SRAM_IDX, np_dout};
    end
end

/* 在数据包刚写入时发起入队请求 */
always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_packet_join_request <= 1;
    end else begin
        wr_packet_join_request <= 0;
    end
end

/* 入队请求时间戳 */
always @(posedge clk) begin
    if(~rst_n) begin 
        wr_packet_join_time_stamp <= 6'd32;
    end if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_packet_join_time_stamp <= time_stamp + 5'd1; /* +1 是为了与主模块中时间序列新插入的时间戳同步 */
    end else if(time_stamp + 5'd1 == wr_packet_join_time_stamp) begin
        wr_packet_join_time_stamp <= 6'd32; /* 32周期后自动还原，防止重复入队 */
    end
end

/******************************************************************************
 *                                  读出处理                                   *
 ******************************************************************************/

/******************************************************************************
 *                                  SRAM本体                                   *
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