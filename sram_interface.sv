`include "sram.sv"
`include "ecc_encoder.sv"

module sram_interface
(
    input clk,
    input rst_n,

    input [4:0] time_stamp,
    input [4:0] SRAM_IDX,

    /* 写入 */

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

    /* 读出 */

    input rd_page_down,
    input [10:0] rd_page,

    output [15:0] rd_xfer_data,
    output reg [15:0] rd_next_page,
    output reg [7:0] rd_ecc_code,

    /* 统计 */

    output reg [10:0] free_space
    
    /* SRAM引出，综合用 */
    // ,(*DONT_TOUCH="YES"*) output wr_en,
    // (*DONT_TOUCH="YES"*) output [13:0] wr_addr,
    // (*DONT_TOUCH="YES"*) output [15:0] din,
    
    // (*DONT_TOUCH="YES"*) output rd_en,
    // (*DONT_TOUCH="YES"*) output [13:0] rd_addr,
    // (*DONT_TOUCH="YES"*) input [15:0] dout
);

/******************************************************************************
 *                                重要存储结构                                 *
 ******************************************************************************/

/* 
 * ECC编码存储
 * RAM结构(2048*8) 占用 0.5*36Kbit BRAM
 */
(* ram_style = "block" *) reg [7:0] ecc_codes [2047:0];
/* ECC存储写入 */
reg ec_wr_en;
reg [10:0] ec_wr_addr;
wire [7:0] ec_din;
always @(posedge clk) begin 
    if(ec_wr_en) begin
        ecc_codes[ec_wr_addr] <= ec_din; 
    end
end
always @(posedge clk) begin
    if(wr_batch == 3'd7 && wr_xfer_data_vld || wr_end_of_packet) begin
        ec_wr_en <= 1;
        /* 页末时准备将结果写入ECC编码存储器 */
        ec_wr_addr <= wr_page;
    end else begin
        ec_wr_en <= 0;
    end
end
/* ECC编码缓冲区 */
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
/* ECC编码器 */
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
/* ECC存储读出 */
wire [10:0] ec_rd_addr;
reg [7:0] ec_dout;
always @(posedge clk) begin 
    ec_dout <= ecc_codes[ec_rd_addr]; 
end
/* 读出数据页的校验码 */
assign ec_rd_addr = rd_page;

always @(posedge clk) begin
    rd_ecc_code <= ec_dout;
end

/* 
 * 跳转表
 * RAM结构(2048*16) 占用 1*36Kbit BRAM
 */
(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
 /* 跳转表写入 */
reg [10:0] jt_wr_addr;
reg [15:0] jt_din;
always @(posedge clk) begin jump_table[jt_wr_addr] <= jt_din; end
/* 跳转表拼接(数据包间/数据包内) */
always @(posedge clk) begin
    if(concatenate_enable) begin                                                    /* 不同数据包间跳转表的拼接 */
        jt_wr_addr <= concatenate_head;
        jt_din <= concatenate_tail;
    end else if(wr_xfer_data_vld && wr_page != join_request_tail[10:0]) begin       /* 数据包内相邻两页的拼接 */
        jt_wr_addr <= wr_page;
        jt_din <= {SRAM_IDX, np_dout};
    end
end
/* 跳转表读出 */
wire [10:0] jt_rd_addr;
reg [15:0] jt_dout;
always @(posedge clk) begin jt_dout <= jump_table[jt_rd_addr]; end
/* 生成当前读取的页链接下一页 */
assign jt_rd_addr = rd_page;
always @(posedge clk) begin
    rd_next_page <= jt_dout;
end

/* 
 * 空闲队列
 * RAM结构(2048*11) 占用 1*36Kbit BRAM
 */
(* ram_style = "block" *) reg [10:0] null_pages [2047:0];

/* 空闲队列写入 */
reg [10:0] np_wr_addr;
reg [10:0] np_din;
always @(posedge clk) begin null_pages[np_wr_addr] <= np_din; end

/* 空闲队列读出 */
wire [10:0] np_rd_addr;
reg [10:0] np_dout;
always @(posedge clk) begin np_dout <= null_pages[np_rd_addr]; end

assign np_rd_addr = (wr_state == 2'd0 && wr_xfer_data_vld) 
                    ? np_head_ptr + wr_xfer_data[15:10] /* 在数据包刚开始传输时预测数据包尾页地址 */
                    : np_head_ptr;                      /* 其他时间查询顶部空页地址 */
reg [10:0] new_page;
always @(np_dout) begin
    new_page = np_dout;
end                    

/*
 * 以FIFO形式维护空闲队列
 * |- np_head_ptr - 空闲队列的头指针
 * |- np_tail_ptr - 空闲队列的尾指针
 * |- np_perfusion - 空闲队列的灌注进度
 */
reg [10:0] np_head_ptr;
reg [10:0] np_tail_ptr;
reg [11:0] np_perfusion;

always @(posedge clk) begin
    if(!rst_n) begin 
        np_head_ptr <= 0;
    end if(wr_batch == 0 && wr_xfer_data_vld) begin     /* 在一页刚开始的时候弹出顶页 */
        np_head_ptr <= np_head_ptr + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        np_perfusion <= 0;                              /* 灌注从0开始 */
        np_tail_ptr <= 0;
    end else if(rd_page_down) begin                     /* 回收读出的页 */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= rd_page;
    end else if(np_perfusion != 12'd2048) begin         /* 灌注到2047结束 */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= np_perfusion;
        np_perfusion <= np_perfusion + 1;
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

/* 正在写入的页 */
reg [10:0] wr_page;
always @(posedge clk) begin
    if((wr_batch == 3'd7 && wr_xfer_data_vld) || wr_state == 2'd0) begin /* 更新wr_page到新页 */
        wr_page <= new_page;
    end
end

/* 数据包写入切片下标 */
reg [2:0] wr_batch;

always @(posedge clk) begin
    if(!rst_n) begin
        wr_batch <= 0;
    end else if(wr_end_of_packet) begin
        wr_batch <= 0;
    end else if(wr_xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
    end
end

/* 在数据包刚写入时发起并生成入队请求 */
always @(posedge clk) begin
    join_request_enable <= wr_state == 2'd0 && wr_xfer_data_vld;    /* 发起入队请求 */
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin                  /* 生成入队请求基本信息 */
        join_request_dest_port <= wr_xfer_data[3:0];
        join_request_prior <= wr_xfer_data[6:4];
        join_request_head <= {SRAM_IDX, wr_page};
    end
    if(wr_state == 2'd1 && wr_batch == 3'd2) begin                  /* 尾部预测完成后追加入队请求的数据包尾页地址 */
        join_request_tail <= {SRAM_IDX, new_page};
    end
end

/* 入队请求时间戳 */
always @(posedge clk) begin
    if(~rst_n) begin 
        join_request_time_stamp <= 6'd32;
    end if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        join_request_time_stamp <= {1'b0, time_stamp + 5'd1};       /* 与主模块中时间序列新插入的时间戳同步 */
    end else if(time_stamp + 5'd1 == join_request_time_stamp) begin
        join_request_time_stamp <= 6'd32;                           /* 31周期后销毁入队请求 */
    end
end

/******************************************************************************
 *                                  读出处理                                   *
 ******************************************************************************/

reg [3:0] rd_batch; /* 读出切片下标 */
wire [13:0] sram_rd_addr = {rd_page, rd_page_down ? 3'd0 : rd_batch[2:0]}; /* 翻页时，切片下标应为0，其他时刻则为rd_addr_batch */

always @(posedge clk) begin
    if(~rst_n) begin
        rd_batch <= 4'd8;
    end if(rd_page_down) begin
        rd_batch <= 1; /* 翻页时，下一刻切片下标应为1 */
    end else if(rd_batch != 4'd8) begin
        rd_batch <= rd_batch + 1;
    end
end

/******************************************************************************
 *                                  统计信息                                   *
 ******************************************************************************/

reg [5:0] packet_length;
always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        packet_length <= wr_xfer_data[15:10] + 1;
    end
end 

always @(posedge clk) begin
    if(~rst_n) begin
        free_space <= 11'd2047;
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
    .rd_en(rd_page_down || rd_batch != 4'd8),   //仅在需要读取的时候为1，节省SRAM功耗
    .rd_addr(sram_rd_addr),
    .dout(rd_xfer_data)
); 

// assign wr_en = wr_xfer_data_vld;
// assign wr_addr = sram_wr_addr;
// assign din = wr_xfer_data;
// assign rd_en = rd_page_down || rd_batch != 4'd8;
// assign rd_addr = sram_rd_addr;
// assign rd_xfer_data = dout;
endmodule