`include "port_wr_frontend.sv"
`include "port_wr_sram_matcher.sv"
`include "port_rd_frontend.sv"
`include "port_rd_dispatch.sv"
`include "sram_interface.sv"
`include "ecc_decoder.sv"
`include "encoder_16_4.sv"
`include "encoder_32_5.sv"

module hydra
(
    /* 时钟与复位信号 */
    input clk,
    input rst_n,
    /* 读出IO口 */
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] [15:0] wr_data,
    output [15:0] pause,
    output reg full,
    output reg almost_full,
    /* 读出IO口 */
    input [15:0] ready,
    output [15:0] rd_sop,
    output [15:0] rd_eop,
    output [15:0] rd_vld,
    output [15:0] [15:0] rd_data,
    /*
     * 可配置参数
     * |- wrr_enable - 端口是否启用WRR调度
     * |- match_mode - SRAM分配模式
     *      |- 0 - 静态分配模式
     *      |- 1 - 半动态分配模式
     *      |- 2/3 - 全动态分配模式
     * |- match_threshold - 匹配阈值，当匹配时长超过该值后，一旦有任何可用的即完成匹配
     *      |- 静态分配模式 最大为0
     *      |- 半动态分配模式 最大为16
     *      |- 全动态分配模式 最大为30
     */
    input [15:0] wrr_enable,
    input [4:0] match_threshold,
    input [1:0] match_mode
);

/* 时间戳 */
reg [4:0] time_stamp;
always @(posedge clk) time_stamp <= ~rst_n ? 0 : time_stamp + 1;

/* Crossbar选通信号 端口->SRAM */
wire [5:0] wr_srams [15:0];                             /* 写入选通 */
wire [5:0] match_srams [15:0];                          /* 匹配选通 */
wire [5:0] rd_srams [15:0];                             /* 读出选通 */
wire [5:0] pre_rd_srams [15:0];                         /* 预读取选通 */
/* 写入Crossbar通道 端口->SRAM */
wire wr_xfer_data_vlds [16:0];                          /* 写入数据有效 */
wire [15:0] wr_xfer_datas [15:0];                       /* 写入数据 */
wire wr_xfer_end_of_packets [16:0];                     /* 写入终止 */
assign wr_xfer_data_vlds[16] = 0;
assign wr_xfer_end_of_packets[16] = 0;
/* 读出Crossbar通道 端口->SRAM */
wire [10:0] rd_xfer_pages [15:0];                       /* 读出页地址 */
/* 读出Crossbar通道 SRAM->端口 */
wire [4:0] rd_xfer_ports [31:0];                        /* 读出反馈 */
wire rd_xfer_data_vlds [31:0];                          /* 读出数据有效(TODO可优化) */ 
wire [15:0] rd_xfer_datas [31:0];                       /* 读出数据 */
wire [7:0] rd_xfer_ecc_codes [31:0];                    /* 读出页校验码 */
wire [15:0] rd_xfer_next_pages [31:0];                  /* 读出页下页地址 */

/* 统计信息 */
wire [8:0] port_packet_amounts [15:0][31:0];            /* 每个端口在对应SRAM中有多少数据包 */
wire [10:0] free_spaces [31:0];                         /* SRAM剩余空间 */
wire [31:0] accessibilities;                            /* SRAM占用状态 */

always @(posedge clk) begin
    full <= accessibilities == 0;                       /* 无SRAM可用时拉高full */
    almost_full <= (~accessibilities &                  /* 可用的SRAM剩余空间都少于50%时拉高almost_full */
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

/* 入队请求Crossbar通道 SRAM->端口 */
wire [31:0] join_request_select;            /* 入队请求选通信号 */
wire [5:0] join_request_time_stamps [31:0]; /* 入队请求时间戳 */
wire [4:0] join_request_dest_ports [32:0];  assign join_request_dest_ports[32] = 5'd16;
wire [2:0] join_request_priors [31:0];
wire [15:0] join_request_heads [31:0];
wire [15:0] join_request_tails [31:0];

reg [4:0] join_request_sram;                /* 当前处理的入队请求的SRAM编号 */
reg [2:0] join_request_prior;               /* 当前处理的入队请求的优先级 */
reg [15:0] join_request_head;               /* 当前处理的入队请求的首页地址 */
always @(posedge clk) begin
    join_request_sram <= processing_join_request;
    join_request_prior <= join_request_priors[processing_join_request];
    join_request_head <= join_request_heads[processing_join_request];
end

/* 时间序列 */ 
reg [4:0] ts_fifo [31:0];
reg [4:0] ts_head_ptr;
reg [4:0] ts_tail_ptr;

wire [5:0] processing_time_stamp = ts_head_ptr == ts_tail_ptr ? 6'd33 : ts_fifo[ts_head_ptr];   /* 正在处理的时间戳，未处理时为33 */
reg [32:0] processing_join_mask;                                                                /* 当前正在处理的时间戳对应的所有被挂起的入队请求选通掩码 */
wire [31:0] processing_join_select =                                                            /* 时间戳对应的入队请求选通信号 */
    processing_join_mask & {join_request_time_stamps[31] == processing_time_stamp, join_request_time_stamps[30] == processing_time_stamp, join_request_time_stamps[29] == processing_time_stamp, join_request_time_stamps[28] == processing_time_stamp, join_request_time_stamps[27] == processing_time_stamp, join_request_time_stamps[26] == processing_time_stamp, join_request_time_stamps[25] == processing_time_stamp, join_request_time_stamps[24] == processing_time_stamp, join_request_time_stamps[23] == processing_time_stamp, join_request_time_stamps[22] == processing_time_stamp, join_request_time_stamps[21] == processing_time_stamp, join_request_time_stamps[20] == processing_time_stamp, join_request_time_stamps[19] == processing_time_stamp, join_request_time_stamps[18] == processing_time_stamp, join_request_time_stamps[17] == processing_time_stamp, join_request_time_stamps[16] == processing_time_stamp, join_request_time_stamps[15] == processing_time_stamp, join_request_time_stamps[14] == processing_time_stamp, join_request_time_stamps[13] == processing_time_stamp, join_request_time_stamps[12] == processing_time_stamp, join_request_time_stamps[11] == processing_time_stamp, join_request_time_stamps[10] == processing_time_stamp, join_request_time_stamps[9] == processing_time_stamp, join_request_time_stamps[8] == processing_time_stamp, join_request_time_stamps[7] == processing_time_stamp, join_request_time_stamps[6] == processing_time_stamp, join_request_time_stamps[5] == processing_time_stamp, join_request_time_stamps[4] == processing_time_stamp, join_request_time_stamps[3] == processing_time_stamp, join_request_time_stamps[2] == processing_time_stamp, join_request_time_stamps[1] == processing_time_stamp, join_request_time_stamps[0] == processing_time_stamp};
wire [5:0] processing_join_request;                                                             /* 本周期正在处理的入队请求的SRAM，未处理时为32 */
encoder_32_5 encoder_32_5( 
    .select(processing_join_select),
    .idx(processing_join_request)
);
wire [31:0] processing_join_one_hot_masks [32:0];   /* 独热选通掩码，用于在时间戳对应的入队请求只剩下一个时，驱动轮换序列中下一个时间戳 */
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
        processing_join_mask <= 33'h1FFFFFFFF;              /* 正在处理的时间戳对应的入队请求仅剩一个，轮换到下一个时间戳 */
        ts_head_ptr <= ts_head_ptr + 1;
    end else begin
        processing_join_mask[processing_join_request] <= 0; /* 正常处理完一个入队请求，拉低掩码对应位置，防止重复入队 */
    end
end

/* 跳转表拼接请求Crossbar通道 Port->SRAM */
wire concatenate_enables [15:0];
wire [15:0] concatenate_heads [16:0];
wire [15:0] concatenate_tails [16:0];
wire [15:0] concatenate_select = {concatenate_enables[15] == 1, concatenate_enables[14] == 1, concatenate_enables[13] == 1, concatenate_enables[12] == 1, 
                                  concatenate_enables[11] == 1, concatenate_enables[10] == 1, concatenate_enables[9] == 1, concatenate_enables[8] == 1, 
                                  concatenate_enables[7] == 1, concatenate_enables[6] == 1, concatenate_enables[5] == 1, concatenate_enables[4] == 1, 
                                  concatenate_enables[3] == 1, concatenate_enables[2] == 1, concatenate_enables[1] == 1, concatenate_enables[0] == 1}; 
wire [4:0] concatenate_port;    /* 正在处理的拼接请求对应的端口 */
encoder_16_4 encoder_concatenate(
    .select(concatenate_select),
    .idx(concatenate_port)
);
wire [15:0] concatenate_head = concatenate_heads[concatenate_port]; /* 正在处理的拼接请求的头部 */
wire [15:0] concatenate_tail = concatenate_tails[concatenate_port]; /* 正在处理的拼接请求的尾部 */

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

    /* 匹配参数 */
    reg [4:0] next_match_sram;  /* 下周期尝试匹配的SRAM */
    reg [4:0] match_sram;       /* 当前周期尝试匹配的SRAM */
    reg [10:0] free_space;      /* 当前匹配的SRAM的剩余空间 */
    reg [8:0] packet_amount;    /* 当前匹配的SRAM中对应端口数据包的数量 */
    reg accessibility;          /* 当前匹配的SRAM是否被占用 */
    
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
        free_space <= free_spaces[next_match_sram];
        packet_amount <= port_packet_amounts[wr_data[port][3:0]][next_match_sram];
        accessibility <= accessibilities[next_match_sram] || wr_sram == match_sram; /* 正在写入的SRAM可被粘滞匹配选中 */
    end

    reg [5:0] wr_sram;                              /* 当前正写入的SRAM */
    wire [5:0] match_best_sram;                     /* 当前匹配到的最优SRAM */
    assign wr_srams[port] = wr_sram;
    assign match_srams[port] = match_best_sram;

    always @(posedge clk) begin
        if(~rst_n || wr_xfer_end_of_packet) begin   /* 新数据包传输完毕，解除写入占用 */
            wr_sram <= 6'd32;
        end else if(wr_xfer_ready) begin            /* 新数据包即将传输，将匹配到的SRAM标记为写占用 */
            wr_sram <= match_best_sram;
        end
    end
    
    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),

        .match_threshold(match_threshold),

        .new_length(match_length), 
        .match_enable(match_enable),
        .match_suc(match_suc),

        .match_sram(match_sram),
        .match_best_sram(match_best_sram),
        .accessible(accessibility),
        .free_space(free_space),
        .packet_amount(packet_amount) 
    );

    /* 优先级队列 */
    reg [15:0] queue_head [7:0];        /* 队列头部 */
    reg [15:0] queue_tail [7:0];        /* 队列尾部 */
    reg [13:0] queue_amounts [7:0];     /* 队列中数据包数量 */
    wire [7:0] queue_empty = {          /* 队列是否为空 */
        queue_head[7] == queue_tail[7], 
        queue_head[6] == queue_tail[6], 
        queue_head[5] == queue_tail[5], 
        queue_head[4] == queue_tail[4], 
        queue_head[3] == queue_tail[3], 
        queue_head[2] == queue_tail[2], 
        queue_head[1] == queue_tail[1], 
        queue_head[0] == queue_tail[0]
    };

    /* 入队请求 */
    reg join_request_enable;            /* 是否为本端口的入队请求，驱动下一周期入队过程 */
    always @(posedge clk) begin
        join_request_enable <= join_request_dest_ports[processing_join_request] == port;
    end

    reg concatenate_enable;             /* 拼接请求发起信号 */
    reg [15:0] concatenate_head;        /* 拼接请求头地址 */
    reg [15:0] concatenate_tail;        /* 拼接请求尾地址 */
    assign concatenate_enables[port] = concatenate_enable;
    assign concatenate_heads[port] = concatenate_head;
    assign concatenate_tails[port] = concatenate_tail;
    
    /* 有新数据包加入非空队列时发起拼接请求 */
    always @(posedge clk) begin
        if(join_request_enable) begin
            concatenate_enable <= 1;
            if(~queue_empty[join_request_prior]) begin                      /* 队列非空时 */
                concatenate_head <= queue_tail[join_request_prior];         /* 拼接头为原队尾 */
                concatenate_tail <= join_request_head;                      /* 拼接尾为新数据包头*/
            end else begin                                                  /* 队列为空时 */
                concatenate_head <= join_request_tails[join_request_sram];  /* 拼接头为新数据包尾 */
                concatenate_tail <= join_request_tails[join_request_sram];  /* 拼接尾为新数据包尾*/
            end
        end else begin
            concatenate_enable <= 0;
        end
    end

    /* 队尾维护 */
    always @(posedge clk) begin
        if(~rst_n) begin
            queue_tail[0] <= 16'd0; queue_tail[1] <= 16'd0; queue_tail[2] <= 16'd0; queue_tail[3] <= 16'd0;
            queue_tail[4] <= 16'd0; queue_tail[5] <= 16'd0; queue_tail[6] <= 16'd0; queue_tail[7] <= 16'd0;
        end if(join_request_enable) begin
            queue_tail[join_request_prior] <= join_request_tails[join_request_sram];/* join_request_tails无需缓存，因为尾部预测本身需要2个周期 */
        end
    end

    /* 队头维护 */
    always @(posedge clk) begin
        if(~rst_n) begin
            queue_head[0] <= 16'd0; queue_head[1] <= 16'd0; queue_head[2] <= 16'd0; queue_head[3] <= 16'd0;
            queue_head[4] <= 16'd0; queue_head[5] <= 16'd0; queue_head[6] <= 16'd0; queue_head[7] <= 16'd0;
        end else if(join_request_enable && queue_empty[join_request_prior]) begin   /* 新数据包加入空队列时，无需发起拼接，但需要更新队头到数据包首 */
            queue_head[join_request_prior] <= join_request_head; 
        end else if(~rd_end_of_packet) begin                                        /* 数据包读取完毕，更新队列头指针 */
        end else if(rd_xfer_next_page != queue_tail[pst_rd_prior]) begin            /* 队列有数据包剩余 */
            queue_head[pst_rd_prior] <= rd_xfer_next_page;
        end else begin                                                              /* 队列无数据包剩余 */
            queue_head[pst_rd_prior] <= queue_tail[pst_rd_prior];
        end
    end
 
    /* 读出 */
    wire [3:0] rd_prior;
    reg [2:0] pst_rd_prior;     /* 持久化本次读取的队列(rd_sop后rd_prior将会更新) */

    reg [5:0] rd_sram;
    assign rd_srams[port] = rd_sram;
    reg [4:0] pst_rd_sram;
    
    reg [10:0] rd_page;
    assign rd_xfer_pages[port] = rd_page;

    reg [6:0] rd_ecc_in_page_amount;   /* 数据包有多少页 */
    reg [6:0] rd_ecc_out_page_amount;   /* 数据包有多少页 */
    reg [2:0] rd_batch_end;     /* 数据包最后一页有多少半字 */

    reg [3:0] ecc_in_batch;
    wire [3:0] ecc_out_batch;

    wire rd_xfer_ready = ready[port] && rd_prior != 4'd8;
    wire rd_end_of_packet = rd_ecc_in_page_amount == 0 && ecc_in_batch == rd_batch_end;
    wire rd_end_of_page = ecc_in_batch == 3'd7 || rd_end_of_packet;

    always @(posedge clk) begin
        if(~rst_n) begin
            rd_sram <= 6'd32;
        end if(rd_xfer_ready) begin
            pst_rd_prior <= rd_prior;
            rd_sram <= queue_head[rd_prior][15:11];
            pst_rd_sram  <= queue_head[rd_prior][15:11];
            rd_page <= queue_head[rd_prior][10:0];
        end else if(rd_ecc_in_page_amount == 0) begin
            rd_sram <= 6'd32;
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            ecc_in_batch <= 4'd8;
        end else if(rd_xfer_ports[rd_sram] == port) begin
            ecc_in_batch <= 4'd0;
        end else if(ecc_in_batch != 4'd8) begin
            ecc_in_batch <= ecc_in_batch + 1;
        end
    end

    always @(posedge clk) begin
        if(~rst_n || rd_xfer_ready) begin
            rd_ecc_in_page_amount <= 7'd64;
            rd_batch_end <= 3'd7;
        end else if(rd_ecc_in_page_amount == 7'd64 && ecc_out_batch == 4'd0) begin
            rd_ecc_in_page_amount <= rd_out_data[15:10] - 1;
            rd_batch_end <= rd_out_data[9:7];
        end else if(~rd_ecc_in_page_amount[6] && rd_ecc_in_page_amount != 0 && ecc_in_batch == 4'd7) begin
            rd_ecc_in_page_amount <= rd_ecc_in_page_amount - 1;
        end
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

    wire rd_xfer_data_vld = rd_xfer_data_vlds[pst_rd_sram];
    wire [15:0] rd_xfer_data = rd_ecc_in_page_amount == 0 && ecc_in_batch > rd_batch_end ? 0 : rd_xfer_datas[pst_rd_sram];
    reg [7:0] rd_xfer_ecc_code;
    reg [15:0] rd_xfer_next_page;
    wire [15:0] rd_out_data;

    always @(posedge clk) begin
        if(ecc_in_batch == 4'd1) begin
            rd_xfer_next_page <= rd_xfer_next_pages[pst_rd_sram];
        end
        if(ecc_in_batch == 4'd7) begin
            rd_xfer_ecc_code <= rd_xfer_ecc_codes[pst_rd_sram];
        end
    end

    always @(posedge clk) begin
        if(ecc_in_batch == 4'd5) begin
            rd_page <= rd_xfer_next_page;
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
    
    wire out_end_of_packet = rd_ecc_out_page_amount == 0 && ecc_out_batch == rd_batch_end;

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

    /* 统计信息 */
    reg [8:0] packet_amounts [31:0];
    integer sram;
    for(sram = 0; sram < 32; sram = sram + 1)
        assign port_packet_amounts[port][sram] = packet_amounts[sram];

    always @(posedge clk) begin
        if(~rst_n) begin
            for(sram = 0; sram < 32; sram = sram + 1)
                packet_amounts[sram] <= 0;
        end else if(join_request_enable) begin /* 入队时+1 */
            packet_amounts[join_request_sram] <= packet_amounts[join_request_sram] + 1;
        end else if(rd_end_of_packet) begin /* 读取完毕-1 */
            packet_amounts[rd_sram] <= packet_amounts[rd_sram] - 1;
        end
    end

    //TODO 调试用
    wire [15:0] debug_head = queue_head[4];
    wire [15:0] debug_tail = queue_tail[4];
    wire [15:0] debug_amount = packet_amounts[1];
end endgenerate

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    wire [15:0] match_select =          /* 匹配占用选通信号 */
       {match_srams[15] == sram, match_srams[14] == sram, match_srams[13] == sram, match_srams[12] == sram, 
        match_srams[11] == sram, match_srams[10] == sram, match_srams[9] == sram, match_srams[8] == sram, 
        match_srams[7] == sram, match_srams[6] == sram, match_srams[5] == sram, match_srams[4] == sram, 
        match_srams[3] == sram, match_srams[2] == sram, match_srams[1] == sram, match_srams[0] == sram};
    wire [15:0] wr_select =             /* 写占用选通信号 */
        {wr_srams[15] == sram, wr_srams[14] == sram, wr_srams[13] == sram, wr_srams[12] == sram, 
        wr_srams[11] == sram, wr_srams[10] == sram, wr_srams[9] == sram, wr_srams[8] == sram, 
        wr_srams[7] == sram, wr_srams[6] == sram, wr_srams[5] == sram, wr_srams[4] == sram, 
        wr_srams[3] == sram, wr_srams[2] == sram, wr_srams[1] == sram, wr_srams[0] == sram};

    wire [4:0] wr_port;                 /* 当前正向该SRAM写入的端口 */
    encoder_16_4 encoder_wr_select(
        .select(wr_select),
        .idx(wr_port)
    );
    /* 当SRAM既没有正被任一端口写入数据，也没有被任一端口当作较优的匹配结果，则认为该SRAM可被匹配 */
    assign accessibilities[sram] = wr_select == 0 && match_select == 0;

    reg [15:0] comfort_mask;                /* 安抚读取掩码 */
    wire [15:0] rd_select = comfort_mask &  /* 读出选通信号 */
                            {rd_srams[15] == sram, rd_srams[14] == sram, rd_srams[13] == sram, rd_srams[12] == sram, 
                             rd_srams[11] == sram, rd_srams[10] == sram, rd_srams[9] == sram, rd_srams[8] == sram, 
                             rd_srams[7] == sram, rd_srams[6] == sram, rd_srams[5] == sram, rd_srams[4] == sram, 
                             rd_srams[3] == sram, rd_srams[2] == sram, rd_srams[1] == sram, rd_srams[0] == sram};

    wire [4:0] rd_port_idx;                  /* 当前准备读出SRAM数据的端口号 */
    encoder_16_4 encoder_rd_select(
        .select(rd_select),
        .idx(rd_port_idx)
    );

    reg [2:0] rd_batch;                      /* 切片计数器 */ 
    reg [5:0] rd_port;                       /* 正在读取的数据包的端口 */ 
    assign rd_xfer_ports[sram] = rd_port;
    reg [10:0] rd_page;                      /* 正在读取的页地址 */ 
    reg rd_page_down;                        /* 是否即将读下一页 */ 

    always @(posedge clk) begin
        if(~rst_n) begin
            rd_batch <= 3'd7;
            rd_page_down <= 0;
            rd_port <= 5'd16;
        end else if(rd_batch != 3'd7) begin  /* 正在读取一页 */
            rd_batch <= rd_batch + 1;
            rd_page_down <= 0;
            rd_port <= 5'd16;
        end else if(rd_select != 0) begin    /* 有新的页读取请求 */
            rd_batch <= 3'd0;
            rd_page_down <= 1;
            rd_port <= rd_port_idx;
            rd_page <= rd_xfer_pages[rd_port_idx];
        end else begin                       /* 无新的页读取请求 */
            rd_batch <= 3'd7;
            rd_page_down <= 0;
            rd_port <= 5'd16;
        end
    end

    always @(posedge clk) begin
        if(~rst_n || rd_select == 0) begin                  /* 重置安抚掩码 */
            comfort_mask <= 16'hFFFF;
        end else if(rd_batch == 7 && rd_select != 0) begin  /* 拉低对应位的安抚掩码 */
            // comfort_mask[rd_port_idx] <= 0;
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

        .concatenate_enable(concatenate_head[15:11] == sram),
        .concatenate_head(concatenate_head[10:0]), 
        .concatenate_tail(concatenate_tail),

        .rd_page_down(rd_page_down),
        .rd_page(rd_page),
        
        .rd_xfer_data_vld(rd_xfer_data_vlds[sram]),
        .rd_xfer_data(rd_xfer_datas[sram]),
        .rd_next_page(rd_xfer_next_pages[sram]),
        .rd_ecc_code(rd_xfer_ecc_codes[sram]),

        .free_space(free_spaces[sram])
    );
end endgenerate 
endmodule