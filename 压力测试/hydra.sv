`include "port_wr_frontend.v"
`include "port_wr_sram_matcher.v"
`include "port_rd_frontend.v"
`include "port_rd_dispatch.v"
`include "sram_interface.v"
`include "ecc_decoder.v"
`include "encoder_16_4.v"
`include "encoder_32_5.v"
module hydra
(
    input clk,
    input rst_n,

    /* 写入IO口 */
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0][15:0] wr_data,
    output [15:0] pause,
    output reg full,
    output reg almost_full,

    /* 读出IO口 */
    input [15:0] ready,
    output [15:0] rd_sop,
    output [15:0] rd_eop,
    output [15:0] rd_vld,
    output [15:0][15:0] rd_data,

    /*
     * 可配置参数
     * |- wrr_en - 端口是否启用WRR调度
     * |- match_mode - SRAM分配模式
     *               |- 0 - 静态分配模式
     *               |- 1 - 半动态分配模式
     *               |- 2 - 全动态分配模式
     * |- match_threshold - 匹配阈值
     *                    |- 静态分配模式(<=0)
     *                    |- 半动态分配模式(<=16)
     *                    |- 全动态分配模式(<=30)
     */
    input [15:0] wrr_en,
    input [4:0] match_threshold,
    input [1:0] match_mode
);

/* 时间戳 */
reg [4:0] time_stamp;
always @(posedge clk) time_stamp <= ~rst_n ? 0 : time_stamp + 1;

/* 时间序列 5×32 FIFO */ 
reg [4:0] ts_fifo [31:0];
reg [4:0] ts_head_ptr;
reg [4:0] ts_tail_ptr;

/* 
 * 统计信息 
 * |- port_packet_amounts - 每个端口在对应SRAM中有多少数据包
 * |- free_spaces - SRAM剩余空间
 * |- accessibilities - SRAM占用状态
 */
wire [8:0] port_packet_amounts [15:0][31:0];
wire [10:0] free_spaces [31:0];
wire [31:0] accessibilities;

/* 
 * Crossbar选通矩阵
 * |- wr_srams - 写入选通矩阵
 * |- match_srams - 匹配选通矩阵
 * |- rd_srams - 读出选通矩阵
 */
wire [5:0] wr_srams [15:0];
wire [5:0] match_srams [15:0];
wire [5:0] rd_srams [15:0];

/* 
 * 写入Crossbar通道 端口->SRAM
 * |- wr_xfer_data_vlds - 写入传输数据有效信号
 * |- wr_xfer_datas - 写入传输数据
 * |- wr_xfer_end_of_packets - 写入传输终止
 */
wire wr_xfer_data_vlds [16:0];
wire [15:0] wr_xfer_datas [16:0];
wire wr_xfer_end_of_packets [16:0];
assign wr_xfer_data_vlds[16] = 0;
assign wr_xfer_datas[16] = 0;
assign wr_xfer_end_of_packets[16] = 0;

/* 
 * 读出Crossbar通道 端口->SRAM
 * |- rd_xfer_pages - 读出页地址
 *
 * 读出Crossbar通道 SRAM->端口
 * |- rd_xfer_ports - 读出反馈端口编号
 * |- rd_xfer_datas - 读出传输数据
 * |- rd_xfer_ecc_codes - 读出页校验码
 * |- rd_xfer_next_pages - 读出页下页地址
 */
wire [10:0] rd_xfer_pages [15:0];
wire [4:0] rd_xfer_ports [31:0];
wire [15:0] rd_xfer_datas [31:0];
wire [7:0] rd_xfer_ecc_codes [31:0];
wire [15:0] rd_xfer_next_pages [31:0];

/* 
 * 入队请求Crossbar通道 SRAM->端口
 * |- join_select - 入队请求选通信号
 * |- join_time_stamps - 入队请求时间戳
 * |- join_dest_ports - 入队请求目标端口
 * |- join_priors - 入队请求优先级
 * |- join_heads - 入队请求首页地址
 * |- join_tails - 入队请求尾页地址
 */
wire [31:0] join_select;
wire [5:0] join_time_stamps [31:0];
wire [4:0] join_dest_ports [32:0];
wire [2:0] join_priors [31:0];
wire [10:0] join_heads [31:0];
wire [10:0] join_tails [31:0];
assign join_dest_ports[32] = 5'd16;

/* 
 * 保序机制
 * |- processing_time_stamp - 正在处理的时间戳，未处理时为33
 * |- processing_join_mask - 当前正在处理的时间戳对应的所有被挂起的入队请求选通掩码
 * |- processing_join_select - 当前可受理入队请求的选通信号
 * |- processing_join - 当前正在处理的入队请求的发起SRAM，未处理时为32
 * |- processing_join_one_hot_masks - 独热选通掩码，用于在时间戳对应的入队请求只剩下一个时，驱动轮换序列中下一个时间戳
 */
wire [5:0] processing_time_stamp = ts_head_ptr == ts_tail_ptr ? 6'd33 : ts_fifo[ts_head_ptr];
reg [32:0] processing_join_mask;
wire [31:0] processing_join_select = processing_join_mask & {join_time_stamps[31] == processing_time_stamp, join_time_stamps[30] == processing_time_stamp, join_time_stamps[29] == processing_time_stamp, join_time_stamps[28] == processing_time_stamp, join_time_stamps[27] == processing_time_stamp, join_time_stamps[26] == processing_time_stamp, join_time_stamps[25] == processing_time_stamp, join_time_stamps[24] == processing_time_stamp, join_time_stamps[23] == processing_time_stamp, join_time_stamps[22] == processing_time_stamp, join_time_stamps[21] == processing_time_stamp, join_time_stamps[20] == processing_time_stamp, join_time_stamps[19] == processing_time_stamp, join_time_stamps[18] == processing_time_stamp, join_time_stamps[17] == processing_time_stamp, join_time_stamps[16] == processing_time_stamp, join_time_stamps[15] == processing_time_stamp, join_time_stamps[14] == processing_time_stamp, join_time_stamps[13] == processing_time_stamp, join_time_stamps[12] == processing_time_stamp, join_time_stamps[11] == processing_time_stamp, join_time_stamps[10] == processing_time_stamp, join_time_stamps[9] == processing_time_stamp, join_time_stamps[8] == processing_time_stamp, join_time_stamps[7] == processing_time_stamp, join_time_stamps[6] == processing_time_stamp, join_time_stamps[5] == processing_time_stamp, join_time_stamps[4] == processing_time_stamp, join_time_stamps[3] == processing_time_stamp, join_time_stamps[2] == processing_time_stamp, join_time_stamps[1] == processing_time_stamp, join_time_stamps[0] == processing_time_stamp};
wire [5:0] processing_join;
wire [31:0] processing_join_one_hot_masks [32:0];
for(genvar sram = 0; sram < 33; sram = sram + 1) assign processing_join_one_hot_masks[sram] = 32'b1 << sram;

/* 
 * 当前正在处理的入队请求
 * |- join_sra - SRAM编号
 * |- join_prior - 优先级
 * |- join_head - 首页地址
 */
reg [4:0] join_sram;
reg [2:0] join_prior;
reg [15:0] join_head;

/* 由入队选通信号得到正在受理的入队请求的发起SRAM */
encoder_32_5 encoder_32_5( 
    .select(processing_join_select),
    .idx(processing_join)
);

/* 
 * 跳转表拼接请求Crossbar通道 Port->SRAM
 * |- concatenate_enables - 拼接请求使能信号
 * |- concatenate_heads - 拼接请求首页
 * |- concatenate_tails - 拼接请求尾页
 * |- concatenate_select - 拼接请求选通信号
 * |- concatenate_port - 正在处理的拼接请求的发起端口
 * |- concatenate_head - 正在处理的拼接请求的头部
 * |- concatenate_tail - 正在处理的拼接请求的尾部
 */
wire concatenate_enables [15:0];
wire [15:0] concatenate_heads [16:0];
wire [15:0] concatenate_tails [16:0];
wire [15:0] concatenate_select = {concatenate_enables[15] == 1, concatenate_enables[14] == 1, concatenate_enables[13] == 1, concatenate_enables[12] == 1, concatenate_enables[11] == 1, concatenate_enables[10] == 1, concatenate_enables[9] == 1, concatenate_enables[8] == 1, concatenate_enables[7] == 1, concatenate_enables[6] == 1, concatenate_enables[5] == 1, concatenate_enables[4] == 1, concatenate_enables[3] == 1, concatenate_enables[2] == 1, concatenate_enables[1] == 1, concatenate_enables[0] == 1}; 
wire [4:0] concatenate_port;
wire [15:0] concatenate_head = concatenate_heads[concatenate_port];
wire [15:0] concatenate_tail = concatenate_tails[concatenate_port];
assign concatenate_heads[16] = 0;
assign concatenate_tails[16] = 0;

/* 由拼接请求选通信号得到正在处理的拼接请求的发起端口 */
encoder_16_4 encoder_concatenate(
    .select(concatenate_select),
    .idx(concatenate_port)
);

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    /* 
     * 优先级队列管理 
     * |- queue_head - 队列头部
     * |- queue_tail - 队列尾部
     * |- queue_amounts - 队列中数据包数量
     * |- queue_empty - 队列是否为空
     */
    reg [15:0] queue_head [7:0];
    reg [15:0] queue_tail [7:0];
    reg [13:0] queue_amounts [7:0];
    wire [7:0] queue_empty = {queue_head[7] == queue_tail[7], queue_head[6] == queue_tail[6], queue_head[5] == queue_tail[5], queue_head[4] == queue_tail[4], queue_head[3] == queue_tail[3], queue_head[2] == queue_tail[2], queue_head[1] == queue_tail[1], queue_head[0] == queue_tail[0]};

    /* 
     * 匹配控制信号
     * |- match_suc - 匹配成功信号
     * |- match_enable - 匹配使能信号
     * |- match_dest_port - 匹配目的端口
     * |- match_length - 匹配长度
     */
    wire match_suc;
    wire match_enable;
    wire [3:0] match_dest_port;
    wire [8:0] match_length;

    /* 
     * 匹配参数
     * |- next_match_sram - 下周期尝试匹配的SRAM
     * |- match_sram - 当前周期尝试匹配的SRAM
     * |- accessibility - 当前匹配的SRAM是否被占用
     * |- free_space - 当前匹配的SRAM的剩余空间
     * |- packet_amount - 当前匹配的SRAM中对应端口数据包的数量
     */
    reg [4:0] next_match_sram;
    reg [4:0] match_sram;
    reg accessibility;
    reg [10:0] free_space;
    reg [8:0] packet_amount;

    /*
     * 写入传输控制
     * |- wr_srams - 当前正写入的SRAM
     * |- match_srams - 当前匹配到的最优SRAM
     * |- wr_xfer_ready - 写入传输数据准备信号
     * |- wr_xfer_data_vld - 写入传输数据有效信号
     * |- wr_xfer_data - 写入传输信号数据
     * |- wr_xfer_end_of_packet - 写入传输数据终止信号
     */
    reg [5:0] wr_sram;
    wire [5:0] match_best_sram;
    wire wr_xfer_ready;
    wire wr_xfer_data_vld;
    wire [15:0] wr_xfer_data;
    wire wr_xfer_end_of_packet;
    assign wr_srams[port] = wr_sram;
    assign match_srams[port] = match_best_sram;
    assign wr_xfer_data_vlds[port] = wr_xfer_data_vld;
    assign wr_xfer_datas[port] = wr_xfer_data;
    assign wr_xfer_end_of_packets[port] = wr_xfer_end_of_packet;

    /* join_enable - 入队请求受理信号，驱动下一周期入队过程 */
    reg join_enable;

    /* 
     * 拼接请求
     * |- concatenate_enable - 拼接请求发起信号
     * |- concatenate_head - 拼接请求头地址
     * |- concatenate_tail - 拼接请求尾地址
     */
    reg concatenate_enable;
    reg [15:0] concatenate_head;
    reg [15:0] concatenate_tail;
    assign concatenate_enables[port] = concatenate_enable;
    assign concatenate_heads[port] = concatenate_head;
    assign concatenate_tails[port] = concatenate_tail;

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
    
    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),

        .match_threshold(match_threshold),

        .new_length(match_length[8:3]), 
        .match_enable(match_enable),
        .match_suc(match_suc),
        .xfer_ready(xfer_ready),

        .match_sram(match_sram),
        .match_best_sram(match_best_sram),
        .accessible(accessibility),
        .free_space(free_space),
        .packet_amount(packet_amount) 
    );
    
    /*
     * 生成下周期尝试匹配的SRAM，并提前抓取匹配参数
     * PORT_IDX与时间戳的参与保证同一周期每个端口总尝试匹配不同的SRAM，避免Crossbar写入仲裁
     */
    always @(posedge clk) begin
        case(match_mode)
            /* 静态分配模式，在端口绑定的2块SRAM之间来回搜索 */
            0: next_match_sram <= {port[3:0], time_stamp[0]};
            /* 半动态分配模式，在端口绑定的1块SRAM和16块共享的SRAM中轮流搜索 */
            1: next_match_sram <= time_stamp[0] ? time_stamp + {port[3:0], 1'b0} : {port[3:0], 1'b0};
            /* 全动态分配模式，在32块共享的SRAM中轮流搜索 */
            default: next_match_sram <= time_stamp + {port[3:0], 1'b0};
        endcase
        match_sram <= next_match_sram;
        accessibility <= accessibilities[next_match_sram] || wr_sram == next_match_sram; /* 粘滞匹配 */
        free_space <= free_spaces[next_match_sram];
        packet_amount <= port_packet_amounts[match_dest_port][next_match_sram];
    end

    /* 更新正在写入的SRAM编号 */
    always @(posedge clk) begin
        if(wr_xfer_ready) begin                                 /* 新数据包即将传输，将匹配到的SRAM标记为写占用 */
            wr_sram <= match_best_sram;
        end else if(~rst_n || wr_xfer_end_of_packet) begin      /* 新数据包传输完毕，解除写入占用 */
            wr_sram <= 6'd32;
        end
    end

    /* 更新入队请求受理使能信号 */
    always @(posedge clk) begin
        join_enable <= join_dest_ports[processing_join] == port;
    end
    
    /* 有新数据包入队时发起拼接请求 */
    always @(posedge clk) begin
        concatenate_enable <= join_enable;
        if(join_enable) begin
            if(~queue_empty[join_prior]) begin                          /* 队列非空时 */
                concatenate_head <= queue_tail[join_prior];             /* 拼接头为原队尾 */
                concatenate_tail <= join_head;                          /* 拼接尾为新数据包头*/
            end else begin                                              /* 队列为空时 */
                concatenate_head <= {join_sram, join_tails[join_sram]}; /* 拼接头为新数据包尾 */
                concatenate_tail <= {join_sram, join_tails[join_sram]}; /* 拼接尾为新数据包尾*/
            end
        end
    end
 
    /* 
     * 读出控制
     * |- rd_prior - 下一次读出的队列编号 
     * |- pst_rd_prior - 正在读出的队列编号
     * |- rd_sram - 正在传输的数据包对应的SRAM编号(在传输完毕时重置) 
     * |- pst_rd_sram - 正在输出的数据包对应的SRAM编号(在输出完毕时重置)
     * |- rd_page - 正在传输的页地址
     * |- rd_batch_end - 数据包最后一页有多少半字
     */
    wire [3:0] rd_prior;
    reg [2:0] pst_rd_prior;
    reg [5:0] rd_sram;
    reg [4:0] pst_rd_sram;
    reg [10:0] rd_page;
    reg [2:0] rd_batch_end;
    assign rd_srams[port] = rd_sram;
    assign rd_xfer_pages[port] = rd_page;

    /*
     * 读出传输控制
     * |- rd_xfer_ready - 读出传输发起信号
     * |- rd_xfer_page_amount - 传输还剩下多少页
     * |- rd_xfer_batch - 传输切片编号
     * |- rd_xfer_eopacket - 数据包传输终止信号
     * |- rd_xfer_eopage - 数据页传输终止信号
     */
    wire rd_xfer_ready = ready[port] && rd_prior != 4'd8;
    reg [6:0] rd_xfer_page_amount;
    reg [3:0] rd_xfer_batch;
    wire rd_xfer_eopacket = rd_xfer_page_amount == 0 && rd_xfer_batch == rd_batch_end;
    wire rd_xfer_eopage = rd_xfer_batch == 3'd7 || rd_xfer_eopacket;
    
    /*
     * 读出传输原始数据
     * |- rd_xfer_data - 传输数据
     * |- rd_xfer_ecc_code - 传输页的ECC校验码
     * |- rd_xfer_next_page - 传输页的下页地址
     */
    wire [15:0] rd_xfer_data = rd_xfer_page_amount == 0 && rd_xfer_batch > rd_batch_end ? 0 : rd_xfer_datas[pst_rd_sram];
    reg [7:0] rd_xfer_ecc_code;
    reg [15:0] rd_xfer_next_page;

    /*
     * 读出输出控制
     * |- rd_out_page_amount - 输出还剩下多少页
     * |- rd_out_batch - 输出切片编号
     * |- rd_out_data - 输出数据
     * |- rd_out_eop - 输出终止信号
     */
    reg [6:0] rd_out_page_amount;
    wire [3:0] rd_out_batch;
    wire [15:0] rd_out_data;
    wire rd_out_eop = rd_out_page_amount == 0 && rd_out_batch == rd_batch_end;

    always @(posedge clk) begin
        if(~rst_n) begin
            pst_rd_prior <= 0;
            rd_sram <= 6'd32;
        end if(rd_xfer_ready) begin                                                                     /* 准备时传输时更新读取SRAM，发起读取请求 */
            pst_rd_prior <= rd_prior;
            rd_sram <= queue_head[rd_prior][15:11];
        end else if(rd_xfer_page_amount == 0 && rd_xfer_batch == 0) begin                               /* 最后一页传输一开始即重置读取SRAM，以防SRAM侧多读 */
            rd_sram <= 6'd32;
        end
    end

    always @(posedge clk) begin
        if(rd_xfer_ready) begin
            rd_page <= queue_head[rd_prior][10:0];
        end else if(rd_xfer_page_amount == 0) begin
        end else if(rd_xfer_batch == 4'd5) begin
            rd_page <= rd_xfer_next_page;
        end
    end

    /* 传输切片计数器 */
    always @(posedge clk) begin
        if(~rst_n) begin
            rd_xfer_batch <= 4'd8;
            pst_rd_sram <= 0;
        end else if(rd_xfer_ports[rd_sram] == port && ~rd_xfer_eopacket) begin                          /* SRAM正在处理本端口的读出请求，计数器重置 */
            rd_xfer_batch <= 4'd0;
            pst_rd_sram <= rd_sram;
        end else if(rd_xfer_batch != 4'd8) begin                                                        /* 自增直到8 */
            rd_xfer_batch <= rd_xfer_batch + 1;
        end
    end

    /* 获取当前页的下页地址和ECC校验码 */
    always @(posedge clk) begin
        if(rd_xfer_batch == 4'd0) begin
            rd_xfer_next_page <= rd_xfer_next_pages[pst_rd_sram];
            rd_xfer_ecc_code <= rd_xfer_ecc_codes[pst_rd_sram];
        end
    end

    /* 更新传输页数量和切片编号 */
    always @(posedge clk) begin
        if(~rst_n || rd_xfer_ready) begin                                                               /* 刚开始时为默认值 */
            rd_xfer_page_amount <= 7'd127;
            rd_batch_end <= 3'd7;
        end else if(rd_xfer_page_amount[6] && rd_out_batch == 4'd0) begin                               /* 第一半字纠错结束，获取准确的包长度 */
            rd_xfer_page_amount <= rd_out_data[15:10] - 1;                                              /* 减去1是考虑已经传输了一页 */
            rd_batch_end <= rd_out_data[9:7];
        end else if(rd_xfer_page_amount != 0 && rd_xfer_batch == 4'd7) begin                            /* 每传输一页，剩余页数量-1 */
            rd_xfer_page_amount <= rd_xfer_page_amount - 1;
        end
    end

    /* 更新输出页数量 */
    always @(posedge clk) begin
        if(~rst_n || rd_xfer_ready) begin
            rd_out_page_amount <= 7'd64;
        end else if(rd_out_page_amount == 7'd64 && rd_out_batch == 4'd0) begin                          /* 第一半字纠错结束，获取准确的包长度 */
            rd_out_page_amount <= rd_out_data[15:10];
        end else if(rd_out_page_amount != 0 && rd_out_batch == 4'd7) begin                              /* 每输出一页，剩余页数量-1 */
            rd_out_page_amount <= rd_out_page_amount - 1;
        end
    end

    port_rd_dispatch port_rd_dispatch(
        .clk(clk),
        .rst_n(rst_n),

        .wrr_en(wrr_en[port]),

        .queue_empty(queue_empty),
        .prior_update(rd_xfer_eopacket),
        .prior_next(rd_prior)
    );

    ecc_decoder port_ecc_decoder(
        .clk(clk),
        .rst_n(rst_n),

        .in_batch(rd_xfer_batch),
        .in_data(rd_xfer_data),
        .ecc_code(rd_xfer_ecc_code),

        .end_of_packet(rd_out_eop),
        .out_batch(rd_out_batch),
        .out_data(rd_out_data)
    );

    port_rd_frontend port_rd_frontend(
        .clk(clk),
    
        .rd_sop(rd_sop[port]),
        .rd_eop(rd_eop[port]), 
        .rd_vld(rd_vld[port]),
        .rd_data(rd_data[port]),

        .out_ready(rd_xfer_ready),
        .out_data_vld(rd_out_batch != 4'd8),
        .out_data(rd_out_data),
        .end_of_packet(rd_out_eop)
    );

    /* 优先级队列队尾维护 */
    always @(posedge clk) begin
        if(~rst_n) begin
            queue_tail[0] <= 16'd0; queue_tail[1] <= 16'd0; queue_tail[2] <= 16'd0; queue_tail[3] <= 16'd0;
            queue_tail[4] <= 16'd0; queue_tail[5] <= 16'd0; queue_tail[6] <= 16'd0; queue_tail[7] <= 16'd0;
        end if(join_enable) begin
            queue_tail[join_prior] <= {join_sram, join_tails[join_sram]};           /* join_tails无需缓存，因为尾部预测本身需要2个周期 */
        end
    end

    /* 优先级队列队头维护 */
    always @(posedge clk) begin
        if(~rst_n) begin
            queue_head[0] <= 16'd0; queue_head[1] <= 16'd0; queue_head[2] <= 16'd0; queue_head[3] <= 16'd0;
            queue_head[4] <= 16'd0; queue_head[5] <= 16'd0; queue_head[6] <= 16'd0; queue_head[7] <= 16'd0;
        end else if(join_enable && queue_empty[join_prior]) begin                   /* 新数据包加入空队列时，队头更新到数据包首 */
            queue_head[join_prior] <= join_head; 
        end else if(~rd_xfer_eopacket) begin                                        /* 数据包读取传输完毕，更新队列头指针 */
        end else if(rd_xfer_next_page != queue_tail[pst_rd_prior]) begin            /* 队列有数据包剩余，队首接到下一页的地址 */
            queue_head[pst_rd_prior] <= rd_xfer_next_pages[pst_rd_sram];
        end else begin                                                              /* 队列无数据包剩余，赋值队首使之队尾相同 */
            queue_head[pst_rd_prior] <= queue_tail[pst_rd_prior];
        end
    end

    /* packet_amounts - 端口在各个SRAM中数据包存量 */
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

    /* 更新端口在各个SRAM中数据包存量的统计信息 */
    integer sram;
    always @(posedge clk) begin
        if(~rst_n) begin
            for(sram = 0; sram < 32; sram = sram + 1)
                packet_amounts[sram] <= 0;
        end else if(join_enable && rd_xfer_eopacket) begin          /* 边读边写不变 */
        end else if(join_enable) begin                              /* 有数据包入队时+1 */
            packet_amounts[join_sram] <= packet_amounts[join_sram] + 1;
        end else if(rd_xfer_eopacket) begin                         /* 读取数据包完毕-1 */
            packet_amounts[rd_sram] <= packet_amounts[rd_sram] - 1;
        end
    end
end endgenerate

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs
    /* 
     * 由Crossbar选通矩阵得到的选通信号
     * |- wr_select - 写选通信号
     * |- match_select - 匹配选通信号
     * |- rd_select - 读取选通信号
     */
    wire [15:0] wr_select = {wr_srams[15] == sram, wr_srams[14] == sram, wr_srams[13] == sram, wr_srams[12] == sram, wr_srams[11] == sram, wr_srams[10] == sram, wr_srams[9] == sram, wr_srams[8] == sram, wr_srams[7] == sram, wr_srams[6] == sram, wr_srams[5] == sram, wr_srams[4] == sram, wr_srams[3] == sram, wr_srams[2] == sram, wr_srams[1] == sram, wr_srams[0] == sram};
    wire [15:0] match_select = {match_srams[15] == sram, match_srams[14] == sram, match_srams[13] == sram, match_srams[12] == sram, match_srams[11] == sram, match_srams[10] == sram, match_srams[9] == sram, match_srams[8] == sram, match_srams[7] == sram, match_srams[6] == sram, match_srams[5] == sram, match_srams[4] == sram, match_srams[3] == sram, match_srams[2] == sram, match_srams[1] == sram, match_srams[0] == sram};
    wire [15:0] rd_select = {rd_srams[15] == sram, rd_srams[14] == sram, rd_srams[13] == sram, rd_srams[12] == sram, rd_srams[11] == sram, rd_srams[10] == sram, rd_srams[9] == sram, rd_srams[8] == sram, rd_srams[7] == sram, rd_srams[6] == sram, rd_srams[5] == sram, rd_srams[4] == sram, rd_srams[3] == sram, rd_srams[2] == sram, rd_srams[1] == sram, rd_srams[0] == sram};
    
    /* 当SRAM既没有正被任一端口写入数据，也没有被任一端口当作较优的匹配结果，则认为该SRAM可被匹配 */
    assign accessibilities[sram] = wr_select == 0 && match_select == 0;

    /* 安抚读取掩码 */
    reg [15:0] comfort_mask;

    /* wr_port - 当前正向本SRAM写入的端口 */
    wire [4:0] wr_port;
    encoder_16_4 encoder_wr_select(
        .select(wr_select),
        .idx(wr_port)
    );
    /* rd_port - 即将读取本SRAM的端口 */
    wire [4:0] rd_port;
    wire [15:0] rd_select_masked = comfort_mask & rd_select;
    encoder_16_4 encoder_rd_select(
        .select(rd_select_masked),
        .idx(rd_port)
    );

    /* 
     * 读取机制
     * |- pst_rd_port - 正在被受理的读取请求的端口
     * |- rd_batch - 读取切片计数器
     * |- rd_page - 读取页地址
     * |- rd_page_down - 翻页信号
     */
    reg [5:0] pst_rd_port;
    reg [2:0] rd_batch;
    reg [10:0] rd_page;
    reg rd_page_down;
    assign rd_xfer_ports[sram] = pst_rd_port;

    /* 读取切片计数器与使能信号 */
    always @(posedge clk) begin
        if(~rst_n) begin
            rd_batch <= 3'd7;
            rd_page_down <= 0;
            pst_rd_port <= 5'd16;
            rd_page <= 11'd0;
        end else if(rd_batch != 3'd7) begin                         /* 正在读取一页 */
            rd_batch <= rd_batch + 1;
            rd_page_down <= 0;
            pst_rd_port <= 5'd16;
        end else if(rd_select_masked != 0) begin                    /* 有新的页读取请求 */
            rd_batch <= 3'd0;
            rd_page_down <= 1;
            pst_rd_port <= rd_port;
            rd_page <= rd_xfer_pages[rd_port];
        end else begin                                              /* 无新的页读取请求 */
            rd_batch <= 3'd7;
            rd_page_down <= 0;
            pst_rd_port <= 5'd16;
        end
    end

    /* 更新安抚掩码 */
    always @(posedge clk) begin
        if(~rst_n || rd_select_masked == 0) begin                   /* 重置安抚掩码 */
            comfort_mask <= 16'hFFFF;
        end else if(rd_batch == 7 && rd_select_masked != 0) begin   /* 拉低对应位的安抚掩码 */
            comfort_mask[rd_port] <= 0;
        end
    end

    sram_interface sram_interface(
        .clk(clk), 
        .rst_n(rst_n), 

        .time_stamp(time_stamp),
        .sram_idx(sram[4:0]),

        .wr_xfer_data_vld(wr_xfer_data_vlds[wr_port]),
        .wr_xfer_data(wr_xfer_datas[wr_port]),
        .wr_end_of_packet(wr_xfer_end_of_packets[wr_port]),

        .join_enable(join_select[sram]),
        .join_time_stamp(join_time_stamps[sram]),
        .join_dest_port(join_dest_ports[sram]),
        .join_prior(join_priors[sram]),
        .join_head(join_heads[sram]),
        .join_tail(join_tails[sram]),

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

/* 缓存正在受理的入队请求信息 */
always @(posedge clk) begin
    join_sram <= processing_join;
    join_prior <= join_priors[processing_join];
    join_head <= {processing_join, join_heads[processing_join]};
end

/* 时间序列更新 */
always @(posedge clk) begin
    if(!rst_n) begin
        ts_tail_ptr <= 0;
    end else if(join_select != 0) begin
        ts_fifo[ts_tail_ptr] <= time_stamp;
        ts_tail_ptr <= ts_tail_ptr + 1;
    end
end

/* 更新时间戳对应的所有被挂起的入队请求选通掩码 */
always @(posedge clk) begin
    if(!rst_n) begin
        processing_join_mask <= 33'h1FFFFFFFF;
        ts_head_ptr <= 0;
    end else if(processing_join_select == processing_join_one_hot_masks[processing_join] && ts_head_ptr != ts_tail_ptr) begin
        processing_join_mask <= 33'h1FFFFFFFF;              /* 正在处理的时间戳对应的入队请求仅剩一个，轮换到下一个时间戳 */
        ts_head_ptr <= ts_head_ptr + 1;
    end else begin
        processing_join_mask[processing_join] <= 0;         /* 正常处理完一个入队请求，拉低掩码对应位置，防止重复入队 */
    end
end

always @(posedge clk) begin
    full <= accessibilities == 0;                           /* 无SRAM可用时拉高full */
    almost_full <= (~accessibilities &                      /* 可用的SRAM剩余空间都少于50%时拉高almost_full */
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

endmodule