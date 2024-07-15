`include "port_wr_sram_matcher.sv"
`include "port_wr_frontend.sv"
`include "sram_interface.sv"
`include "decoder_8_3.sv"
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
    input [15:0] pause,

    output reg full,
    output reg almost_full,

    input [15:0] ready,
    output reg [15:0] rd_sop,
    output reg [15:0] rd_eop,
    output reg [15:0] rd_vld,
    output reg [15:0] [15:0] rd_data,

    //配置IO口
    input [15:0] wrr_enable,
    input [4:0] match_threshold,
    input [1:0] match_mode,
    //也许可以加个动态粘性？
    input [3:0] viscosity
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

/* WRR掩码集 */
reg [7:0] wrr_mask_set [7:0];
always @(posedge clk) begin
    if(~rst_n) begin
        wrr_mask_set[7] <= 8'hFF;
        wrr_mask_set[6] <= 8'h7F;
        wrr_mask_set[5] <= 8'h3F;
        wrr_mask_set[4] <= 8'h1F;
        wrr_mask_set[3] <= 8'h0F;
        wrr_mask_set[2] <= 8'h07;
        wrr_mask_set[1] <= 8'h03;
        wrr_mask_set[0] <= 8'h01;
    end
end

/* 端口正在交互的SRAM的下标*/
reg [5:0] wr_sram [15:0]; /* 写入占用 */
wire [5:0] matched_sram [15:0]; /* 较优匹配 */
reg [5:0] rd_sram [15:0]; /* 读出占用 */

/* 写入时端口与SRAM传输信息的通道 */
wire wr_xfer_data_vld [15:0];
wire [15:0] wr_xfer_data [15:0];
wire wr_end_of_packet [15:0];

/* 读出时SRAM与端口传输信息的通道 */
wire [4:0] rd_port [31:0];
wire rd_xfer_data_vld [31:0];
wire [15:0] rd_xfer_data [31:0];
wire rd_end_of_packet [31:0];
wire [7:0] rd_ecc_code [31:0];  /* 校验码，用于纠错 */
wire [15:0] rd_next_page [31:0]; /* 下一页地址，用于更新queue_head */

/* 端口在对应SRAM的数据包存量 */
reg [8:0] packet_amounts [15:0][31:0];

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

    /* 粘滞倒计时，为0时则不再粘滞 */
    reg [3:0] viscous_tick;
    wire viscous = viscous_tick != 0;

    always @(posedge clk) begin
        if(!rst_n) begin
            viscous_tick <= 4'd0;
        end else if(end_of_packet) begin //数据包写完后启动粘滞倒计时
            viscous_tick <= viscosity;
        end else if(viscous_tick > 0) begin
            viscous_tick <= viscous_tick - 1;
        end
    end

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
        packet_amount <= packet_amounts[wr_data[port][3:0]][next_matching_sram];
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

    wire [4:0] matching_best_sram;

    always @(posedge clk) begin
        if(!rst_n) begin
            wr_sram[port] <= 6'd32;
        end else if(ready_to_xfer) begin /* 即将开始PORT->SRAM的数据传输时，将最优匹配结果持久化到wr_sram，启用写占用 */
            wr_sram[port] <= matching_best_sram;
        end else if(viscous_tick == 4'd1 || (viscosity == 0 && end_of_packet)) begin /* 直到数据包传输完毕后粘滞结束，写占用取消 */
            wr_sram[port] <= 6'd32;
        end
    end

    wire update_matched_sram;
    assign matched_sram[port] = update_matched_sram ? matching_best_sram : 6'd32; /* 同步优匹配SRAM，将会一直执行该操作直到匹配结束（匹配占用取消，转变为写占用） */
    
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
    //TODO FIXME 可能存在垃圾跳转信息，使得empty错误
    //应当维护每个队列的数据包量，根据量是否为0判断队列是否为空
    wire [7:0] queue_empty = {queue_head[7] == queue_tail[7], queue_head[6] == queue_tail[6], queue_head[5] == queue_tail[5], queue_head[4] == queue_tail[4], queue_head[3] == queue_tail[3], queue_head[2] == queue_tail[2], queue_head[1] == queue_tail[1], queue_head[0] == queue_tail[0]};

    wire [15:0] debug_head = queue_head[4];
    wire [15:0] debug_tail = queue_tail[4];

    /* 是否即将处理入队请求 */
    reg join_enable;
    /* 即将处理入队请求的优先级 */
    reg [2:0] join_prior;
    /* 即将处理入队请求的SRAM下标 */
    reg [4:0] join_request;
    /* 跳转表拼接倒计时，归零时一定拼接完毕，可重置Port->SRAM的concatenate_enable */
    reg [3:0] concatenate_tick;

    always @(posedge clk) begin
        /* 当前处理的入队请求的目的端口是该端口 */
        if(wr_packet_dest_port[processing_join_request] == port) begin
            join_enable <= 1;
            join_prior <= wr_packet_prior[processing_join_request];
            join_request <= processing_join_request;
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
        end else if(queue_empty[join_prior]) begin /* 队列为空时入队只需 头->头 + 尾->尾 */
            queue_head[join_prior] <= wr_packet_head_addr[join_request];
            queue_tail[join_prior] <= wr_packet_tail_addr[join_request];
        end else begin /* 队列不为空时入队需 发起跳转表拼接 + 尾->尾 */
            queue_tail[join_prior] <= wr_packet_tail_addr[join_request];
            concatenate_previous[port] <= queue_tail[join_prior];
            concatenate_subsequent[port] <= wr_packet_head_addr[join_request];
        end
    end
    
    always @(posedge clk) begin
        if(join_enable == 1 && ~queue_empty[join_prior]) begin /* 队列不为空时入队需 发起跳转表拼接 + 尾->尾 */
            concatenate_enable[port] <= 1;
        end else if(concatenate_enable[port]) begin
            concatenate_enable[port] <= 0;
        end
    end

    
    wire [7:0] select_mask;
    // always @(posedge clk) begin
    //     if(~rst_n) begin
    //         select_mask_next <= 8'd0;
    //     end else if() begin
    //         select_mask_next <= 8'd1;
    //     end else begin
    //         select_mask_next <= 8'd0;
    //     end
    // end

    wire [7:0] queue_read_select = queue_empty || select_mask;
    wire [2:0] read_queue;
    decoder_8_3 decoder_8_3(
        .select(queue_read_select),
        .idx(read_queue)    //TODO FIX 'dx
    );


end endgenerate

/* SRAM->Port 数据包入队请求 */
wire [3:0] wr_packet_dest_port [31:0];
wire [2:0] wr_packet_prior [31:0];
wire [15:0] wr_packet_head_addr [31:0];
wire [15:0] wr_packet_tail_addr [31:0];
wire [31:0] wr_packet_join_request; //TODO 这里把下标提前了，不知道行不行，不行的话就后置，然后新建一个wire把它们并起来
wire [5:0] wr_packet_join_time_stamp [31:0];

/* 时间序列 */ 
reg [4:0] ts_fifo [31:0];
reg [4:0] ts_head_ptr;
reg [4:0] ts_tail_ptr;

//TODO 时序超过12个门，需要拆一个周期出来，具体综合的时候再调整
//这边刚好空余出一个周期来

/* 正在处理的时间戳 */
wire [5:0] processing_time_stamp = ts_head_ptr == ts_tail_ptr ? 6'd33 : ts_fifo[ts_head_ptr];
/* 时间戳对应的入队请求掩码 */
reg [31:0] processing_join_mask;
/* 时间戳对应的入队请求选通信号 */
wire [31:0] processing_join_select = processing_join_mask & {wr_packet_join_time_stamp[31] == processing_time_stamp, wr_packet_join_time_stamp[30] == processing_time_stamp, wr_packet_join_time_stamp[29] == processing_time_stamp, wr_packet_join_time_stamp[28] == processing_time_stamp, wr_packet_join_time_stamp[27] == processing_time_stamp, wr_packet_join_time_stamp[26] == processing_time_stamp, wr_packet_join_time_stamp[25] == processing_time_stamp, wr_packet_join_time_stamp[24] == processing_time_stamp, wr_packet_join_time_stamp[23] == processing_time_stamp, wr_packet_join_time_stamp[22] == processing_time_stamp, wr_packet_join_time_stamp[21] == processing_time_stamp, wr_packet_join_time_stamp[20] == processing_time_stamp, wr_packet_join_time_stamp[19] == processing_time_stamp, wr_packet_join_time_stamp[18] == processing_time_stamp, wr_packet_join_time_stamp[17] == processing_time_stamp, wr_packet_join_time_stamp[16] == processing_time_stamp, wr_packet_join_time_stamp[15] == processing_time_stamp, wr_packet_join_time_stamp[14] == processing_time_stamp, wr_packet_join_time_stamp[13] == processing_time_stamp, wr_packet_join_time_stamp[12] == processing_time_stamp, wr_packet_join_time_stamp[11] == processing_time_stamp, wr_packet_join_time_stamp[10] == processing_time_stamp, wr_packet_join_time_stamp[9] == processing_time_stamp, wr_packet_join_time_stamp[8] == processing_time_stamp, wr_packet_join_time_stamp[7] == processing_time_stamp, wr_packet_join_time_stamp[6] == processing_time_stamp, wr_packet_join_time_stamp[5] == processing_time_stamp, wr_packet_join_time_stamp[4] == processing_time_stamp, wr_packet_join_time_stamp[3] == processing_time_stamp, wr_packet_join_time_stamp[2] == processing_time_stamp, wr_packet_join_time_stamp[1] == processing_time_stamp, wr_packet_join_time_stamp[0] == processing_time_stamp};
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
reg concatenate_enable [15:0];
reg [15:0] concatenate_previous [15:0];
reg [15:0] concatenate_subsequent [15:0];
wire [15:0] concatenate_select = {concatenate_enable[15] == 1, concatenate_enable[14] == 1, concatenate_enable[13] == 1, concatenate_enable[12] == 1, concatenate_enable[11] == 1, concatenate_enable[10] == 1, concatenate_enable[9] == 1, concatenate_enable[8] == 1, concatenate_enable[7] == 1, concatenate_enable[6] == 1, concatenate_enable[5] == 1, concatenate_enable[4] == 1, concatenate_enable[3] == 1, concatenate_enable[2] == 1, concatenate_enable[1] == 1, concatenate_enable[0] == 1}; 

/*
 * SRAM
 */ 

reg [10:0] free_spaces [31:0];
reg accessibilities [31:0];

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    /* 写占用选通信号 */
    wire [15:0] select_wr = {wr_sram[15] == sram, wr_sram[14] == sram, wr_sram[13] == sram, wr_sram[12] == sram, wr_sram[11] == sram, wr_sram[10] == sram, wr_sram[9] == sram, wr_sram[8] == sram, wr_sram[7] == sram, wr_sram[6] == sram, wr_sram[5] == sram, wr_sram[4] == sram, wr_sram[3] == sram, wr_sram[2] == sram, wr_sram[1] == sram, wr_sram[0] == sram};
    /* 匹配占用选通信号 */
    wire [15:0] select_matched = {matched_sram[15] == sram, matched_sram[14] == sram, matched_sram[13] == sram, matched_sram[12] == sram, matched_sram[11] == sram, matched_sram[10] == sram, matched_sram[9] == sram, matched_sram[8] == sram, matched_sram[7] == sram, matched_sram[6] == sram, matched_sram[5] == sram, matched_sram[4] == sram, matched_sram[3] == sram, matched_sram[2] == sram, matched_sram[1] == sram, matched_sram[0] == sram};
    always @(posedge clk) begin
        /* 当SRAM既没有正被任一端口写入数据，也没有被任一端口当作较优的匹配结果，则认为该SRAM可被匹配 */
        accessibilities[sram] <= select_wr == 0 && select_matched == 0;
    end
    
    /* 当前正向该SRAM写入的端口号，由写选通信号经过16-4解码器得到 */
    wire [3:0] wr_port;
    decoder_16_4 decoder_16_4(
        .select(select_wr),
        .idx(wr_port)
    );

    /* 跳转表拼接处理 */
    reg concatenate_en; 
    reg [15:0] concatenate_head;
    reg [15:0] concatenate_tail;
    reg [15:0] pst_concatenate_head;
    reg [15:0] pst_concatenate_tail;

    wire [3:0] concatenate_port;
    decoder_16_4 decoder_concatenate(
        .select(concatenate_select),
        .idx(concatenate_port)
    );

    always @(posedge clk) begin
        concatenate_head <= concatenate_previous[concatenate_port];
        concatenate_tail <= concatenate_subsequent[concatenate_port];
    end

    always @(posedge clk) begin
        if(concatenate_head[15:11] == sram) begin
            concatenate_en <= 1;
            pst_concatenate_head <= concatenate_head;
            pst_concatenate_tail <= concatenate_tail;
        end else begin
            concatenate_en <= 0;
        end
    end

    integer port;
    always @(posedge clk) begin
        if(~rst_n) begin
            free_spaces[sram] <= 100 + sram; /* DEBUG 此为调试用数据吗，实际应该是 11'd2047 */
        end else if(wr_end_of_packet[wr_port]) begin
            free_spaces[sram] <= free_spaces[sram] - 1; //TODO FIXME 需要知道包的长度，这个好说，从sram_interface拉个信号出来即可
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
        .concatenate_head(pst_concatenate_head), 
        .concatenate_tail(pst_concatenate_tail)
    );
end endgenerate 
endmodule