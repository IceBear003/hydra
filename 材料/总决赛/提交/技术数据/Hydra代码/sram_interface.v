`include "sram.v"
`include "ecc_encoder.v"
module sram_interface
(
    input clk,
    input rst_n,

    /* time_stamp - 时间戳 */
    input [4:0] time_stamp,
    /* sram_idx - SRAM编号 */
    input [4:0] sram_idx,

    /* 
     * 写入传输数据IO 
     * |- wr_xfer_data_vld - 写入传输数据有效信号
     * |- wr_xfer_data - 写入传输数据
     * |- wr_end_of_packet - 写入传输结束信号
     */
    input wr_xfer_data_vld,
    input [15:0] wr_xfer_data,
    input wr_end_of_packet,

    /* 
     * 入队请求 
     * |- join_enable - 入队请求发起信号
     * |- join_time_stamp - 入队请求时间戳
     * |- join_dest_port - 入队请求目的端口
     * |- join_prior - 入队请求优先级
     * |- join_head - 入队请求首页地址
     * |- join_tail - 入队请求尾页地址
     */
    output reg join_enable,
    output reg [5:0] join_time_stamp,
    output reg [4:0] join_dest_port,
    output reg [2:0] join_prior,
    output reg [10:0] join_head,
    output reg [10:0] join_tail,

    /*
     * 拼接请求 
     * |- concatenate_enable - 拼接请求使能信号
     * |- concatenate_head - 拼接请求首页地址
     * |- concatenate_tail - 拼接请求尾页地址
     */
    input concatenate_enable,
    input [10:0] concatenate_head,
    input [15:0] concatenate_tail,

    /* 
     * 读出传输数据IO
     * |- rd_page_down - 翻页信号
     * |- rd_page - 读出页地址
     * |- rd_xfer_data - 读出传输数据
     * |- rd_next_page - 读出页的下一页地址
     * |- rd_ecc_code - 读出页的(136,128)ECC校验码
     */
    input rd_page_down,
    input [10:0] rd_page,
    output [15:0] rd_xfer_data,
    output [15:0] rd_next_page,
    output [7:0] rd_ecc_code,

    /* free_space - 剩余空间（单位:页） */
    output reg [10:0] free_space
    
    /* SRAM读写IO
    ,
    (*DONT_TOUCH="YES"*) output wr_en,
    (*DONT_TOUCH="YES"*) output [13:0] wr_addr,
    (*DONT_TOUCH="YES"*) output [15:0] din,
    (*DONT_TOUCH="YES"*) output rd_en,
    (*DONT_TOUCH="YES"*) output [13:0] rd_addr,
    (*DONT_TOUCH="YES"*) input [15:0] dout
    */
);

/* ECC编码存储 8×2048 RAM */
(* ram_style = "block" *) reg [7:0] ecc_codes [2047:0];
reg ec_wr_en;
reg [10:0] ec_wr_addr;
wire [7:0] ec_din;
wire [10:0] ec_rd_addr;
reg [7:0] ec_dout;
always @(posedge clk) if(ec_wr_en) ecc_codes[ec_wr_addr] <= ec_din;
always @(posedge clk) ec_dout <= ecc_codes[ec_rd_addr];
/* ECC编码缓冲区 */
reg [15:0] ecc_encoder_buffer [7:0];

/* 跳转表 16×2048 RAM */
(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
reg [10:0] jt_wr_addr;
reg [15:0] jt_din;
wire [10:0] jt_rd_addr;
reg [15:0] jt_dout;
always @(posedge clk) jump_table[jt_wr_addr] <= jt_din;
always @(posedge clk) jt_dout <= jump_table[jt_rd_addr];

/* 空闲队列 11×2048 RAM */
(* ram_style = "block" *) reg [10:0] null_pages [2047:0];
reg [10:0] np_wr_addr;
reg [10:0] np_din;
always @(posedge clk) null_pages[np_wr_addr] <= np_din;
wire [10:0] np_rd_addr;
reg [10:0] np_dout;
always @(posedge clk) np_dout <= null_pages[np_rd_addr];

/*
 * 空闲队列的维护与初始化
 * |- np_head_ptr - 空闲队列的头指针
 * |- np_tail_ptr - 空闲队列的尾指针
 * |- np_perfusion - 空闲队列的灌注进度
 */
reg [10:0] np_head_ptr;
reg [10:0] np_tail_ptr;
reg [11:0] np_perfusion;

/*
 * 写入机制
 * |- wr_page - 写入页地址
 * |- wr_batch - 写入半字切片编号
 * |- wr_state - 数据包写入自动机
 *             |- 0 - 无数据包写入
 *             |- 1 - 正在写入数据包的第一页
 *             |- 2 - 正在写入数据包的后续页
 */
reg [10:0] wr_page;
reg [2:0] wr_batch;
reg [1:0] wr_state;

/*
 * 读出机制
 * |- rd_batch - 读出切片编号
 */
reg [3:0] rd_batch; 

/* 生成ECC校验码并写入存储器 */
always @(posedge clk) begin
    if(wr_xfer_data_vld) begin
        if(wr_batch == 0) begin                                             /* 页初时清理缓冲，以免脏数据影响ECC计算 */
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
    if(wr_batch == 3'd7 && wr_xfer_data_vld || wr_end_of_packet) begin      /* 页末时准备将结果写入ECC编码存储器 */
        ec_wr_en <= 1;
        ec_wr_addr <= wr_page;
    end else begin
        ec_wr_en <= 0;
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

/* 从存储器中读出ECC校验码 */
assign ec_rd_addr = rd_page;
assign rd_ecc_code = ec_dout;

/* 拼接请求发起/数据包不同页写入 时跳转表的更新 */
always @(posedge clk) begin
    if(concatenate_enable) begin                                        /* 不同数据包间跳转表的拼接 */
        jt_wr_addr <= concatenate_head;
        jt_din <= concatenate_tail;
    // end else if(wr_end_of_packet) begin                              /* 数据包尾页指向自身 */
    end else if(~wr_xfer_data_vld) begin
    end else if(wr_page != join_tail) begin                             /* 数据包内相邻两页的拼接 */
        jt_wr_addr <= wr_page;
        jt_din <= {sram_idx, np_dout};
    end 
end

/* 从跳转表中读取当前页的下一页地址 */
assign jt_rd_addr = rd_page;
assign rd_next_page = jt_dout;

/* 尾部预测 & 顶部空页地址查询 */
assign np_rd_addr = (wr_state == 2'd0 && wr_xfer_data_vld) 
                    ? np_head_ptr + wr_xfer_data[15:10]                 /* 在数据包刚开始传输时预测数据包尾页地址 */
                    : np_head_ptr;                                      /* 其他时间查询顶部空页地址 */

/* 从空闲队列中取出空闲页 */
always @(posedge clk) begin
    if(!rst_n) begin 
        np_head_ptr <= 0;
    end if(wr_batch == 0 && wr_xfer_data_vld) begin                     /* 在一页刚开始的时候弹出顶页 */
        np_head_ptr <= np_head_ptr + 1;
    end
end

/* 初始化空闲队列 & 回收被读取的页 */
always @(posedge clk) begin
    if(!rst_n) begin
        np_perfusion <= 0;                                              /* 灌注从0开始 */
        np_tail_ptr <= 0;
    end else if(rd_page_down) begin                                     /* 回收读出的页 */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= rd_page;
    end else if(np_perfusion != 12'd2048) begin                         /* 灌注到2047结束 */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= np_perfusion;
        np_perfusion <= np_perfusion + 1;
    end
end

/* 数据包写入自动机状态转移 */
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

/* 更新下次写入的页地址 */
always @(posedge clk) begin
    if((wr_batch == 3'd7 && wr_xfer_data_vld) || wr_state == 2'd0) begin
        wr_page <= np_dout;
    end
end

/* 写入切片计数器 */
always @(posedge clk) begin
    if(!rst_n || wr_end_of_packet) begin
        wr_batch <= 0;
    end else if(wr_xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
    end
end

/* 刚写入时生成并发起入队请求 */
always @(posedge clk) begin
    join_enable <= wr_state == 2'd0 && wr_xfer_data_vld;                /* 发起入队请求 */
    if(~rst_n) begin
        join_time_stamp <= 6'd34;
        join_dest_port <= 0;
        join_prior <= 0;
        join_head <= 0;
    end else if(wr_state == 2'd0 && wr_xfer_data_vld) begin             /* 生成入队请求基本信息 */
        join_time_stamp <= {1'b0, time_stamp + 5'd1};                   /* 与主模块中时间序列新插入的时间戳同步 */
        join_dest_port <= wr_xfer_data[3:0];
        join_prior <= wr_xfer_data[6:4];
        join_head <= wr_page;
    end else if(time_stamp[3:0] == join_time_stamp[3:0] && ~(wr_state == 2'd1 && wr_batch == 3'd1)) begin
        join_time_stamp <= 6'd34;                                       /* 16周期后销毁入队请求 */
    end
    if(wr_state == 2'd1 && wr_batch == 3'd1) begin                      /* 尾部预测完成后追加入队请求的数据包尾页地址 */
        join_tail <= np_dout;
    end
end

/* 读出切片计数器 */
always @(posedge clk) begin
    if(~rst_n) begin
        rd_batch <= 4'd8;
    end if(rd_page_down) begin
        rd_batch <= 1;                                                  /* 翻页时，下一刻切片编号应为1 */
    end else if(rd_batch != 4'd8) begin
        rd_batch <= rd_batch + 1;
    end
end

/* 写入数据包长度持久化 */
reg [6:0] packet_length;                                                /* 7位是防止最大包长的数据包溢出，导致free_space不正常减少 */
always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        packet_length <= wr_xfer_data[15:10] + 1;
    end
end 

/* 剩余空间更新 */
always @(posedge clk) begin
    if(~rst_n) begin
        free_space <= 11'd2047;
    end 
    else if(join_enable && rd_page_down) begin
        free_space <= free_space - packet_length + 1;
    end else if(join_enable) begin
        free_space <= free_space - packet_length;
    end else if(rd_page_down) begin
        free_space <= free_space + 1;
    end
end

sram sram(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_xfer_data_vld),
    .wr_addr({wr_page, wr_batch}),
    .din(wr_xfer_data),
    .rd_en(rd_page_down || rd_batch != 4'd8),
    .rd_addr({rd_page, rd_page_down ? 3'd0 : rd_batch[2:0]}),   /* 翻页时，切片编号应为0，其他时刻则为rd_addr_batch */
    .dout(rd_xfer_data)
); 

// assign wr_en = wr_xfer_data_vld;
// assign wr_addr = {wr_page, wr_batch};
// assign din = wr_xfer_data;
// assign rd_en = rd_page_down || rd_batch != 4'd8;
// assign rd_addr = {rd_page, rd_page_down ? 3'd0 : rd_batch[2:0]};
// assign rd_xfer_data = dout;

endmodule