`include "port_wr_frontend.sv"
`include "port_wr_sram_matcher.sv"
`include "port_rd_frontend.sv"
`include "port_rd_dispatch.sv"
`include "sram_interface.sv"
`include "decoder_16_4.sv"
`include "decoder_32_5.sv"

module hydra
(
    input clk,
    input rst_n,

    //基本IO口
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] [15:0] wr_data,
    output [15:0] pause,

    output reg full,
    output reg almost_full,

    input [15:0] ready,
    output reg [15:0] rd_sop,
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
    
    /* SRAM引出，综合用 */
    // ,output [31:0] wr_en,
    // output [31:0] [13:0] wr_addr,
    // output [31:0] [15:0] din,
    
    // output [31:0] rd_en,
    // output [31:0] [13:0] rd_addr,
    // input [31:0] [15:0] dout
);

/* 时间戳 */
reg [4:0] time_stamp;
always @(posedge clk) begin
    if(~rst_n) begin
        time_stamp <= 0;
    end else begin
        time_stamp <= time_stamp + 1;
    end
end

always @(posedge clk) begin
    full <= accessibilities == 0;
    almost_full <= (~accessibilities & {free_spaces[0][10], free_spaces[1][10], free_spaces[2][10], free_spaces[3][10],
                                        free_spaces[4][10], free_spaces[5][10], free_spaces[6][10], free_spaces[7][10], 
                                        free_spaces[8][10], free_spaces[9][10], free_spaces[10][10], free_spaces[11][10], 
                                        free_spaces[12][10], free_spaces[13][10], free_spaces[14][10], free_spaces[15][10], 
                                        free_spaces[16][10], free_spaces[17][10], free_spaces[18][10], free_spaces[19][10], 
                                        free_spaces[20][10], free_spaces[21][10], free_spaces[22][10], free_spaces[23][10], 
                                        free_spaces[24][10], free_spaces[25][10], free_spaces[26][10], free_spaces[27][10], 
                                        free_spaces[28][10], free_spaces[29][10], free_spaces[30][10], free_spaces[31][10]} == 0);
end

/* 端口正在交互的SRAM的下标*/
wire [5:0] wr_srams [15:0]; /* 写入占用 */
wire [5:0] matched_sram [15:0]; /* 较优匹配 */
wire [5:0] rd_srams [15:0]; /* 读出占用 */

/* 写入时端口与SRAM传输信息的通道 */
wire wr_xfer_data_vld [15:0];
wire [15:0] wr_xfer_data [15:0];
wire wr_end_of_packet [15:0];

/* 读出时端口与SRAM传输信息的通道 */
wire [10:0] rd_pages [15:0];

wire [4:0] rd_ports [31:0];
wire rd_xfer_data_vlds [31:0];
wire [15:0] rd_xfer_datas [31:0];
(*DONT_TOUCH="YES"*) wire [7:0] rd_ecc_codes [31:0];  /* 校验码，用于纠错 */
wire [15:0] rd_next_pages [31:0]; /* 下一页地址，用于更新queue_head */

/* 端口在对应SRAM的数据包存量 */
wire [8:0] packet_amounts_all [15:0][31:0];

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

    /* 提前生成下周期要匹配的SRAM，便于提前获取SRAM状态，减少组合逻辑复杂度 */
    reg [4:0] next_matching_sram;
    reg [4:0] matching_sram;

    /* 提前抓取下周期匹配所需的信号，避免匹配组合逻辑堆积 */
    reg [10:0] free_space;
    reg [8:0] packet_amount;
    reg accessibility;

    always @(posedge clk) begin
        matching_sram <= next_matching_sram;
        free_space <= free_spaces[next_matching_sram];
        packet_amount <= packet_amounts_all[wr_data[port][3:0]][next_matching_sram];
        accessibility <= accessibilities[next_matching_sram];
    end
    
    /*
     * 生成下周期尝试匹配的SRAM编号
     * PORT_IDX与时间戳的参与保证同一周期每个端口总尝试匹配不同的SRAM，避免进一步的仲裁
     */
    always @(posedge clk) begin
        case(match_mode)
            /* 静态分配模式，在端口绑定的2块SRAM之间来回搜索 */
            0: next_matching_sram <= {port[3:0], time_stamp[0]};
            /* 半动态分配模式，在端口绑定的1块SRAM和16块共享的SRAM中轮流搜索 */
            1: next_matching_sram <= time_stamp[0] ? time_stamp + {port[3:0], 1'b0} : {port[3:0], 1'b0};
            /* 全动态分配模式，在32块共享的SRAM中轮流搜索 */
            default: next_matching_sram <= time_stamp + {port[3:0], 1'b0};
        endcase
    end

    /* 在数据包传输完毕之后的第二个周期重新获取新的wr_page，以规避最后一页数据量过少导致的np_dout还未刷新到新的空闲页的问题 */
    reg [1:0] regain_wr_page_tick;

    always @(posedge clk) begin
        if(!rst_n) begin
            regain_wr_page_tick <= 2'd0;
        end else if(end_of_packet) begin
            regain_wr_page_tick <= 2'd3;
        end else if(regain_wr_page_tick != 0) begin
            regain_wr_page_tick <= regain_wr_page_tick - 1;
        end
    end

    reg [5:0] wr_sram;
    assign wr_srams[port] = wr_sram;
    wire [4:0] matching_best_sram;

    always @(posedge clk) begin
        if(!rst_n) begin
            wr_sram <= 6'd32;
        end else if(ready_to_xfer) begin /* 即将开始PORT->SRAM的数据传输时，将最优匹配结果持久化到wr_srams，启用写占用 */
            wr_sram <= matching_best_sram;
        end else if(regain_wr_page_tick == 1) begin /* 直到数据包传输完毕后，写占用取消 */
            wr_sram <= 6'd32;
        end
    end

    wire update_matched_sram;
    assign matched_sram[port] = update_matched_sram ? matching_best_sram : 6'd32; /* 同步优匹配SRAM，将会一直执行该操作直到匹配结束（匹配占用取消，转变为写占用） */
    
    port_wr_sram_matcher port_wr_sram_matcher(
        .clk(clk),
        .rst_n(rst_n),

        .match_threshold(match_threshold),

        .new_length(new_length),
        .match_enable(match_enable),
        .match_suc(match_suc),

        .matching_sram(matching_sram),
        .matching_best_sram(matching_best_sram),
        .update_matched_sram(update_matched_sram),

        .accessible(accessibility),
        .free_space(free_space),
        .packet_amount(packet_amount) 
    );

    reg [15:0] queue_head [7:0];
    reg [15:0] queue_tail [7:0];
    wire [7:0] queue_empty = {queue_head[7] == queue_tail[7], queue_head[6] == queue_tail[6], queue_head[5] == queue_tail[5], queue_head[4] == queue_tail[4], 
                              queue_head[3] == queue_tail[3], queue_head[2] == queue_tail[2], queue_head[1] == queue_tail[1], queue_head[0] == queue_tail[0]};

    /* 入队请求 */
                              
    /* 是否即将处理入队请求 */
    reg join_enable;
    /* 即将处理入队请求的优先级 */
    reg [2:0] join_prior;
    /* 即将处理入队请求的SRAM下标 */
    reg [4:0] join_request;
    /* 跳转表拼接倒计时，归零时一定拼接完毕，可重置Port->SRAM的concatenate_enables */
    reg [3:0] concatenate_tick;
    
    always @(posedge clk) begin
        join_enable <= wr_packet_dest_port[processing_join_request] == port;
    end

    always @(posedge clk) begin
        /* 若当前处理的入队请求的目的端口是该端口，则对其进行处理 */
        if(wr_packet_dest_port[processing_join_request] == port) begin
            join_prior <= wr_packet_prior[processing_join_request];
            join_request <= processing_join_request;
        end
    end

    reg concatenate_enable;
    reg [15:0] concatenate_head;
    reg [15:0] concatenate_tail;

    assign concatenate_enables[port] = concatenate_enable;
    assign concatenate_heads[port] = concatenate_head;
    assign concatenate_tails[port] = concatenate_tail;
    
    always @(posedge clk) begin
        concatenate_enable <= join_enable == 1 && ~queue_empty[join_prior];
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            queue_tail[0] <= 16'd0; queue_tail[1] <= 16'd0; queue_tail[2] <= 16'd0; queue_tail[3] <= 16'd0;
            queue_tail[4] <= 16'd0; queue_tail[5] <= 16'd0; queue_tail[6] <= 16'd0; queue_tail[7] <= 16'd0;
        end if(~join_enable) begin
        end else if(queue_empty[join_prior]) begin
            queue_tail[join_prior] <= wr_packet_tail_addr[join_request];
        end else begin /* 队列不为空入队，需发起跳转表拼接 */
            queue_tail[join_prior] <= wr_packet_tail_addr[join_request];
            concatenate_head <= queue_tail[join_prior];
            concatenate_tail <= wr_packet_head_addr[join_request];
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            queue_head[0] <= 16'd0; queue_head[1] <= 16'd0; queue_head[2] <= 16'd0; queue_head[3] <= 16'd0;
            queue_head[4] <= 16'd0; queue_head[5] <= 16'd0; queue_head[6] <= 16'd0; queue_head[7] <= 16'd0;
        end else if(join_enable && queue_empty[join_prior]) begin /* 队列为空入队 */
            queue_head[join_prior] <= wr_packet_head_addr[join_request];
        end else if(~rd_end_of_packet) begin /* 数据包读取完毕，更新队列头指针 */
        end else if({pst_rd_sram, rd_page} != queue_tail[pst_rd_prior]) begin /* 队列有数据包剩余 */
            queue_head[pst_rd_prior] <= rd_next_pages[pst_rd_sram];
        end else begin /* 队列无数据包剩余 */
            queue_head[pst_rd_prior] <= queue_tail[pst_rd_prior];
        end
    end
 
    /* 读出 */
 
    wire [3:0] rd_prior;
    reg [2:0] pst_rd_prior; /* 持久化本次读取的队列(rd_sop后rd_prior将会更新) */

    reg [5:0] rd_sram;
    reg [5:0] pst_rd_sram; /* 持久化本次读取数据包的SRAM(最后一页rd_sram将会提前重置，以避免在数据包大小整除8时，SRAM多翻页的问题) */
    assign rd_srams[port] = rd_sram;

    always @(posedge clk) begin
        if(~rst_n) begin
            rd_sram <= 6'd32;
        end else if(rd_sop[port]) begin
            pst_rd_prior <= rd_prior;
            rd_sram <= queue_head[rd_prior][15:11];
        end else if(rd_page_amount == 0) begin
            rd_sram <= 6'd32;
        end
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            pst_rd_sram <= 6'd32;
        end else if(rd_sop[port]) begin
            pst_rd_sram <= queue_head[rd_prior][15:11];
        end else if(rd_end_of_packet) begin
            pst_rd_sram <= 6'd32;
        end
    end

    reg [10:0] rd_page; /* 当前正在读取的页地址 */
    assign rd_pages[port] = rd_page;

    always @(posedge clk) begin
        if(rd_sop[port]) begin /* 数据包开始读取时为队头 */
            rd_page <= queue_head[rd_prior][10:0];
        end else if(rd_batch == 3'd5 && rd_page_amount != 0) begin /* 数据包读取中途，一页的结束时切换到下页(PORT rd_batch为5对应SRAM rd_batch为7) */
            rd_page <= rd_next_pages[pst_rd_sram];
        end
    end

    reg rd_not_over; /* 数据包是否读取完毕，用于约束rd_vld */
    always @(posedge clk) begin
        if(~rst_n) begin
            rd_not_over <= 0;
        end if(rd_end_of_packet) begin
            rd_not_over <= 0;
        end else if(rd_sop[port]) begin
            rd_not_over <= 1;
        end
    end

    reg [6:0] rd_page_amount; /* 数据包有多少页 */
    reg [2:0] rd_batch_end; /* 数据包最后一页有多少半字 */
    always @(posedge clk) begin
        if(~rst_n || rd_sop[port]) begin
            rd_page_amount <= 7'd64;
            rd_batch_end <= 0;
        end else if(rd_page_amount == 7'd64 && rd_xfer_data_vld) begin
            rd_page_amount <= rd_xfer_data[15:10];
            rd_batch_end <= rd_xfer_data[9:7];
        end else if(rd_batch == 3'd7) begin
            rd_page_amount <= rd_page_amount - 1;
        end
    end

    reg [2:0] rd_batch;
    always @(posedge clk) begin
        if(~rst_n || rd_sop[port]) begin
            rd_batch <= 3'd0;
        end else if(rd_xfer_data_vld) begin
            rd_batch <= rd_batch + 1;
        end
    end

    wire rd_xfer_data_vld = rd_not_over ? rd_xfer_data_vlds[pst_rd_sram] && rd_ports[pst_rd_sram] == port : 0;
    wire [15:0] rd_xfer_data = rd_xfer_datas[pst_rd_sram];
    
    wire rd_end_of_packet = rd_page_amount == 0 && rd_batch == rd_batch_end; /* 是否为数据包的最后一半字 */

    port_rd_dispatch port_rd_dispatch(
        .clk(clk),
        .rst_n(rst_n),

        .wrr_en(wrr_enable[port]),

        .queue_empty(queue_empty),
        .update(rd_sop[port]),
        .rd_prior(rd_prior)
    );
    

    always @(posedge clk) begin
        rd_sop[port] <= ready[port] && queue_empty != 8'hFF;
    end

    port_rd_frontend port_rd_frontend(
        .clk(clk),
    
        .rd_eop(rd_eop[port]),
        .rd_vld(rd_vld[port]),
        .rd_data(rd_data[port]),
    
        .xfer_data_vld(rd_xfer_data_vld),
        .xfer_data(rd_xfer_data),
        .end_of_packet(rd_end_of_packet)
    );

    /* 统计信息 */
    reg [8:0] packet_amounts [31:0];
    assign packet_amounts_all[port][0] = packet_amounts[0];
    assign packet_amounts_all[port][1] = packet_amounts[1];
    assign packet_amounts_all[port][2] = packet_amounts[2];
    assign packet_amounts_all[port][3] = packet_amounts[3];
    assign packet_amounts_all[port][4] = packet_amounts[4];
    assign packet_amounts_all[port][5] = packet_amounts[5];
    assign packet_amounts_all[port][6] = packet_amounts[6];
    assign packet_amounts_all[port][7] = packet_amounts[7];
    assign packet_amounts_all[port][8] = packet_amounts[8];
    assign packet_amounts_all[port][9] = packet_amounts[9];
    assign packet_amounts_all[port][10] = packet_amounts[10];
    assign packet_amounts_all[port][11] = packet_amounts[11];
    assign packet_amounts_all[port][12] = packet_amounts[12];
    assign packet_amounts_all[port][13] = packet_amounts[13];
    assign packet_amounts_all[port][14] = packet_amounts[14];
    assign packet_amounts_all[port][15] = packet_amounts[15];
    assign packet_amounts_all[port][16] = packet_amounts[16];
    assign packet_amounts_all[port][17] = packet_amounts[17];
    assign packet_amounts_all[port][18] = packet_amounts[18];
    assign packet_amounts_all[port][19] = packet_amounts[19];
    assign packet_amounts_all[port][20] = packet_amounts[20];
    assign packet_amounts_all[port][21] = packet_amounts[21];
    assign packet_amounts_all[port][22] = packet_amounts[22];
    assign packet_amounts_all[port][23] = packet_amounts[23];
    assign packet_amounts_all[port][24] = packet_amounts[24];
    assign packet_amounts_all[port][25] = packet_amounts[25];
    assign packet_amounts_all[port][26] = packet_amounts[26];
    assign packet_amounts_all[port][27] = packet_amounts[27];
    assign packet_amounts_all[port][28] = packet_amounts[28];
    assign packet_amounts_all[port][29] = packet_amounts[29];
    assign packet_amounts_all[port][30] = packet_amounts[30];
    assign packet_amounts_all[port][31] = packet_amounts[31];

    integer sram;
    always @(posedge clk) begin
        if(~rst_n) begin
            for(sram = 0; sram < 32; sram = sram + 1)
                packet_amounts[sram] <= 0;
        end else if(join_enable) begin /* 入队时+1 */
            packet_amounts[join_request] <= packet_amounts[join_request] + 1;
        end else if(rd_end_of_packet) begin /* 读取完毕-1 */
            packet_amounts[pst_rd_sram] <= packet_amounts[pst_rd_sram] - 1;
        end
    end

    //TODO 调试用
    wire [15:0] debug_head = queue_head[4];
    wire [15:0] debug_tail = queue_tail[4];
    wire [15:0] debug_amount = packet_amounts[3];

end endgenerate

/* SRAM->Port 数据包入队请求 */
wire [3:0] wr_packet_dest_port [31:0];
wire [2:0] wr_packet_prior [31:0];
wire [15:0] wr_packet_head_addr [31:0];
wire [15:0] wr_packet_tail_addr [31:0];
wire [31:0] wr_packet_join_request;
wire [5:0] wr_packet_join_time_stamp [31:0];

/* 时间序列 */ 
reg [4:0] ts_fifo [31:0];
reg [4:0] ts_head_ptr;
reg [4:0] ts_tail_ptr;

/* 正在处理的时间戳 */
wire [5:0] processing_time_stamp = ts_head_ptr == ts_tail_ptr ? 6'd33 : ts_fifo[ts_head_ptr];
/* 时间戳对应的入队请求掩码 */
reg [31:0] processing_join_mask;
/* 时间戳对应的入队请求选通信号 */
wire [31:0] processing_join_select = processing_join_mask & 
                                    {wr_packet_join_time_stamp[31] == processing_time_stamp, wr_packet_join_time_stamp[30] == processing_time_stamp, wr_packet_join_time_stamp[29] == processing_time_stamp, wr_packet_join_time_stamp[28] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[27] == processing_time_stamp, wr_packet_join_time_stamp[26] == processing_time_stamp, wr_packet_join_time_stamp[25] == processing_time_stamp, wr_packet_join_time_stamp[24] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[23] == processing_time_stamp, wr_packet_join_time_stamp[22] == processing_time_stamp, wr_packet_join_time_stamp[21] == processing_time_stamp, wr_packet_join_time_stamp[20] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[19] == processing_time_stamp, wr_packet_join_time_stamp[18] == processing_time_stamp, wr_packet_join_time_stamp[17] == processing_time_stamp, wr_packet_join_time_stamp[16] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[15] == processing_time_stamp, wr_packet_join_time_stamp[14] == processing_time_stamp, wr_packet_join_time_stamp[13] == processing_time_stamp, wr_packet_join_time_stamp[12] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[11] == processing_time_stamp, wr_packet_join_time_stamp[10] == processing_time_stamp, wr_packet_join_time_stamp[9] == processing_time_stamp, wr_packet_join_time_stamp[8] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[7] == processing_time_stamp, wr_packet_join_time_stamp[6] == processing_time_stamp, wr_packet_join_time_stamp[5] == processing_time_stamp, wr_packet_join_time_stamp[4] == processing_time_stamp, 
                                     wr_packet_join_time_stamp[3] == processing_time_stamp, wr_packet_join_time_stamp[2] == processing_time_stamp, wr_packet_join_time_stamp[1] == processing_time_stamp, wr_packet_join_time_stamp[0] == processing_time_stamp};
/* 本周期正在处理的入队请求 */
wire [4:0] processing_join_request;
decoder_32_5 decoder_32_5(
    .select(processing_join_select),
    .idx(processing_join_request)
);

always @(posedge clk) begin
    if(processing_join_select == 0) begin /* 当前正在处理的时间戳的入队请求已经处理完毕，掩码重置 */
        processing_join_mask <= 32'hFFFFFFFF;
    end else begin /* 将掩码中正在处理的入队请求对应位置置0，防止重复入队 */
        processing_join_mask[processing_join_request] <= 0;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        ts_tail_ptr <= 0;
    end else if(wr_packet_join_request != 0) begin /* 如果当前时间戳有入队请求，则将时间戳推入时间序列 */
        ts_fifo[ts_tail_ptr] <= time_stamp;
        ts_tail_ptr <= ts_tail_ptr + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        ts_head_ptr <= 0;
    end else if(processing_join_select == 0 && ts_head_ptr != ts_tail_ptr) begin /* 如果当前正在处理的时间戳的入队请求已经处理完毕，则轮换到时间序列中的下一个时间戳 */
        ts_head_ptr <= ts_head_ptr + 1;
    end
end

/* Port->SRAM 跳转表拼接请求 */
wire concatenate_enables [15:0];
wire [15:0] concatenate_heads [15:0];
wire [15:0] concatenate_tails [15:0];

wire [15:0] concatenate_select = {concatenate_enables[15] == 1, concatenate_enables[14] == 1, concatenate_enables[13] == 1, concatenate_enables[12] == 1, 
                                  concatenate_enables[11] == 1, concatenate_enables[10] == 1, concatenate_enables[9] == 1, concatenate_enables[8] == 1, 
                                  concatenate_enables[7] == 1, concatenate_enables[6] == 1, concatenate_enables[5] == 1, concatenate_enables[4] == 1, 
                                  concatenate_enables[3] == 1, concatenate_enables[2] == 1, concatenate_enables[1] == 1, concatenate_enables[0] == 1}; 
wire [3:0] concatenate_port;
decoder_16_4 decoder_concatenate(
    .select(concatenate_select),
    .idx(concatenate_port)
);

wire [15:0] concatenate_head = concatenate_heads[concatenate_port];
wire [15:0] concatenate_tail = concatenate_tails[concatenate_port];

/* SRAM状态 */ 
wire [10:0] free_spaces [31:0];
wire [31:0] accessibilities;

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    /* 匹配占用选通信号 */
    wire [15:0] select_matched = {matched_sram[15] == sram, matched_sram[14] == sram, matched_sram[13] == sram, matched_sram[12] == sram, 
                                  matched_sram[11] == sram, matched_sram[10] == sram, matched_sram[9] == sram, matched_sram[8] == sram, 
                                  matched_sram[7] == sram, matched_sram[6] == sram, matched_sram[5] == sram, matched_sram[4] == sram, 
                                  matched_sram[3] == sram, matched_sram[2] == sram, matched_sram[1] == sram, matched_sram[0] == sram};
    /* 写占用选通信号 */
    wire [15:0] select_wr = {wr_srams[15] == sram, wr_srams[14] == sram, wr_srams[13] == sram, wr_srams[12] == sram, 
                             wr_srams[11] == sram, wr_srams[10] == sram, wr_srams[9] == sram, wr_srams[8] == sram, 
                             wr_srams[7] == sram, wr_srams[6] == sram, wr_srams[5] == sram, wr_srams[4] == sram, 
                             wr_srams[3] == sram, wr_srams[2] == sram, wr_srams[1] == sram, wr_srams[0] == sram};
    
    /* 当前正向该SRAM写入的端口号 */
    wire [3:0] wr_port;
    decoder_16_4 decoder_wr_select(
        .select(select_wr),
        .idx(wr_port)
    );

    /* 当SRAM既没有正被任一端口写入数据，也没有被任一端口当作较优的匹配结果，则认为该SRAM可被匹配 */
    assign accessibilities[sram] = select_wr == 0 && select_matched == 0;

    /* 读出模块 */
    /* 写占用选通信号 */
    wire [15:0] select_rd = {rd_srams[15] == sram, rd_srams[14] == sram, rd_srams[13] == sram, rd_srams[12] == sram, 
                             rd_srams[11] == sram, rd_srams[10] == sram, rd_srams[9] == sram, rd_srams[8] == sram, 
                             rd_srams[7] == sram, rd_srams[6] == sram, rd_srams[5] == sram, rd_srams[4] == sram, 
                             rd_srams[3] == sram, rd_srams[2] == sram, rd_srams[1] == sram, rd_srams[0] == sram};

    /* 当前正在读出SRAM数据的端口号 */
    wire [3:0] rd_port_idx;
    decoder_16_4 decoder_rd_select(
        .select(select_rd),
        .idx(rd_port_idx)
    );

    /* 切片计数器 */ 
    reg [2:0] rd_batch;
    /* 正在读取的数据包的端口 */ 
    reg [10:0] rd_port;
    assign rd_ports[sram] = rd_port;
    /* 正在读取的页地址 */ 
    reg [10:0] rd_page;
    /* 是否即将读下一页 */ 
    reg rd_page_down;

    always @(posedge clk) begin
        if(~rst_n) begin
            rd_batch <= 3'd7;
            rd_page_down <= 0;
            rd_port <= 5'd16;
        end else if(rd_batch != 3'd7) begin /* 正在读取一页 */
            rd_batch <= rd_batch + 1;
            rd_page_down <= 0;
        end else if(select_rd != 0) begin /* 有新的页读取请求 */
            rd_batch <= 3'd0;
            rd_page_down <= 1;
            rd_port <= rd_port_idx;
            rd_page <= rd_pages[rd_port_idx];
        end else begin /* 无新的页读取请求 */
            rd_batch <= 3'd7;
            rd_page_down <= 0;
        end
    end

    reg rd_new_packet;
    always @(posedge clk) begin
        if(~rst_n) begin
            rd_new_packet <= 0;
        end else if(rd_batch == 3'd7 && select_rd != 0 && rd_port != rd_port_idx) begin
            rd_new_packet <= 1;
        end else begin
            rd_new_packet <= 0;
        end
    end

    wire rd_xfer_data_vld;
    assign rd_xfer_data_vlds[sram] = rd_xfer_data_vld && ~rd_new_packet;

    sram_interface sram_interface(
        .clk(clk),
        .rst_n(rst_n), 

        .SRAM_IDX(sram[4:0]),
        .time_stamp(time_stamp),

        .wr_xfer_data_vld(wr_xfer_data_vld[wr_port]),
        .wr_xfer_data(wr_xfer_data[wr_port]),
        .wr_end_of_packet(wr_end_of_packet[wr_port]),

        .wr_packet_dest_port(wr_packet_dest_port[sram]),
        .wr_packet_prior(wr_packet_prior[sram]),
        .wr_packet_head_addr(wr_packet_head_addr[sram]),
        .wr_packet_tail_addr(wr_packet_tail_addr[sram]),
        .wr_packet_join_request(wr_packet_join_request[sram]),
        .wr_packet_join_time_stamp(wr_packet_join_time_stamp[sram]),

        .concatenate_enable(concatenate_head[15:11] == sram),
        .concatenate_head(concatenate_head[10:0]), 
        .concatenate_tail(concatenate_tail),

        .rd_page_down(rd_page_down),
        .rd_page(rd_page),
        
        .rd_xfer_data_vld(rd_xfer_data_vld),
        .rd_xfer_data(rd_xfer_datas[sram]),
        .rd_next_page(rd_next_pages[sram]),
        .rd_ecc_code(rd_ecc_codes[sram]),

        .free_space(free_spaces[sram])

        // ,.wr_en(wr_en[sram]),
        // .wr_addr(wr_addr[sram]),
        // .din(din[sram]),
        // .rd_en(rd_en[sram]), 
        // .rd_addr(rd_addr[sram]),
        // .dout(dout[sram])
    );
end endgenerate 
endmodule