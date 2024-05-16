`include "./初赛作品/代码/已优化/port_frontend.sv"
`include "./初赛作品/代码/已优化/ecc_encoder.sv"
`include "./初赛作品/代码/已优化/ecc_decoder.sv"
`include "./初赛作品/代码/已优化/dual_port_sram.sv"
`include "./初赛作品/代码/已优化/sram_state.sv"

// `include "port_frontend.sv"
// `include "ecc_encoder.sv"
// `include "ecc_decoder.sv"
// `include "dual_port_sram.sv"
// `include "sram_state.sv"

module controller(
    input clk,
    input rst_n,

    //Config
    input [15:0] wrr_en,

    //16 Ports
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] [15:0] wr_data,
    output reg [15:0] full = 0,
    output reg [15:0] almost_full = 0,

    input [15:0] ready,
    output reg [15:0] rd_sop = 0,
    output reg [15:0] rd_eop = 0,
    output reg [15:0] rd_vld = 0,
    output reg [15:0] [15:0] rd_data,

    //port_frontend IOs
    input [3:0] port_dest_port [15:0],
    input [2:0] port_prior [15:0],
    input [8:0] port_length [15:0],
    output reg search_get [15:0],
    input port_data_vld [15:0],
    input [15:0] port_data [15:0],
    input port_new_packet_into_buf [15:0],
    //ecc_encoder IOs
    output reg ecc_encoder_enable [15:0],
    output reg [15:0] ecc_encoder_data_0 [15:0],
    output reg [15:0] ecc_encoder_data_1 [15:0],
    output reg [15:0] ecc_encoder_data_2 [15:0],
    output reg [15:0] ecc_encoder_data_3 [15:0],
    output reg [15:0] ecc_encoder_data_4 [15:0],
    output reg [15:0] ecc_encoder_data_5 [15:0],
    output reg [15:0] ecc_encoder_data_6 [15:0],
    output reg [15:0] ecc_encoder_data_7 [15:0],
    input [7:0] ecc_encoder_code [15:0],
    //ecc_decoder IOs
    output reg  ecc_decoder_enable [15:0],
    output reg [15:0] ecc_decoder_data_0 [15:0],
    output reg [15:0] ecc_decoder_data_1 [15:0],
    output reg [15:0] ecc_decoder_data_2 [15:0],
    output reg [15:0] ecc_decoder_data_3 [15:0],
    output reg [15:0] ecc_decoder_data_4 [15:0],
    output reg [15:0] ecc_decoder_data_5 [15:0],
    output reg [15:0] ecc_decoder_data_6 [15:0],
    output reg [15:0] ecc_decoder_data_7 [15:0],
    output reg [7:0] ecc_decoder_code [15:0],
    input [15:0] ecc_decoder_cr_data_0 [15:0],
    input [15:0] ecc_decoder_cr_data_1 [15:0],
    input [15:0] ecc_decoder_cr_data_2 [15:0],
    input [15:0] ecc_decoder_cr_data_3 [15:0],
    input [15:0] ecc_decoder_cr_data_4 [15:0],
    input [15:0] ecc_decoder_cr_data_5 [15:0],
    input [15:0] ecc_decoder_cr_data_6 [15:0],
    input [15:0] ecc_decoder_cr_data_7 [15:0],
    
    //sram IOs
    output reg sram_wr_en [31:0],
    output reg [13:0] sram_wr_addr [31:0],
    output reg [15:0] sram_din [31:0],

    output reg sram_rd_en [31:0],
    output reg [13:0] sram_rd_addr [31:0],
    input [15:0] sram_dout [31:0],
    //sram_state IOs
    output reg  ecc_wr_en [31:0],
    output reg [10:0] ecc_wr_addr [31:0],
    output reg [7:0] ecc_din [31:0],

    output reg ecc_rd_en [31:0],
    output reg [10:0] ecc_rd_addr [31:0],
    input [7:0] ecc_dout [31:0],

    output reg jt_wr_en [31:0],
    output reg [10:0] jt_wr_addr [31:0],
    output reg [15:0] jt_din [31:0],

    output reg jt_rd_en [31:0],
    output reg [10:0] jt_rd_addr [31:0],
    input [15:0] jt_dout [31:0],

    output reg wr_or [31:0],
    output reg wr_op [31:0],
    
    output reg [11:0] delta_free_space [31:0],
    output reg [11:0] delta_page_amount [31:0],

    output reg [3:0] wr_port [31:0],
    output reg rd_op [31:0],
    output reg [3:0] rd_port [31:0],
    output reg [10:0] rd_addr [31:0],

    output reg [3:0] request_port [31:0],
    input [10:0] page_amount [31:0],

    input [10:0] null_ptr [31:0],
    input [10:0] free_space [31:0]
);

reg [4:0] cnt_32 = 0;
always @(posedge clk) begin
    cnt_32 <= cnt_32 + 1;
end
reg [3:0] cnt_16 = 0;
always @(posedge clk) begin
    cnt_16 <= cnt_16 + 1;
end

//搜索相关寄存器
reg [4:0] searching_sram_index [15:0];
reg [4:0] searching_distribution [15:0];
reg [10:0] max_amount [15:0];
reg [5:0] search_cnt [15:0];
reg searching [15:0];

//持久化寄存器
//当前正被写入SRAM的数据包
reg [3:0] cur_dest_port [15:0];
reg [2:0] cur_prior [15:0];
reg [8:0] cur_length [15:0];
reg [4:0] cur_distribution [15:0];
reg [4:0] last_distribution [15:0];
//上个被写入SRAM的数据包
reg [2:0] last_dest_queue [15:0];   //目的队列(3+4)
reg [10:0] last_page [15:0];        //被写入的页地址

//数据包是否已经结束，需要插入队列末端，指导队列头尾地址更新
reg packet_merge[15:0];
//数据包善后信号，从第一个包发送到最后一个包被写入sram
reg packet_signal_reset[15:0];
//上个数据包的头尾地址(5+11)
reg [15:0] last_packet_head_addr [15:0];
reg [15:0] last_packet_tail_addr [15:0];
//数据包的头尾地址(5+11)
reg [15:0] packet_head_addr [15:0];
reg [15:0] packet_tail_addr [15:0];
//数据包已经被处理的半字数
reg [8:0] packet_length [15:0];
//数据包处理批次下标
reg [2:0] packet_batch [15:0];

//上次写入的页地址
reg [10:0] wr_last_page [15:0];
//正在写入的页地址
reg [10:0] wr_page [15:0];

//ECC结果是否到被存储的时机
//实际上是ecc_encoder_enable打一拍
reg ecc_result [15:0];
//ECC结果存储的SRAM的编号
//对于一个数据包末尾页的校验，其存储时间在数据包处理完毕之后
//这时distribution可能已经被更新，所以需要额外存储ECC校验码目的SRAM
reg [4:0] ecc_sram [15:0];


//读取
//端口正在请求哪个SRAM的数据
reg [4:0] reading_sram [15:0];
//SRAM正在处理哪个端口的请求
reg [3:0] processing_request [31:0];
//端口请求的页地址
reg [10:0] reading_page [15:0];
//端口请求的半字数
reg [2:0] reading_batch [15:0];
//数据准备完毕，端口可进一步处理
reg handshake [31:0];

reg [3:0] sram_distribution [31:0];
reg sram_occupy [31:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    //端口正在读取哪个队列的数据包
    //从0到7优先度递减
    reg [2:0] reading_priority;
    //端口正在读取的数据包的剩余长度(半字)
    reg [8:0] reading_packet_length;
    //输出计数器-页终止位
    reg [3:0] output_batch; //建议初始为8+
    //输出计数器-页终止位
    reg [2:0] end_batch;
    //当前数据包是否已经读取长度
    reg packet_length_got;

    //当SRAM读取完当前页的所有半字
    //并发来握手信号时，就使能ECC
    always @(posedge clk) begin
        if(handshake[reading_sram[port]] == 1 && processing_request[reading_sram[port]] == port) begin
            ecc_decoder_enable[port] <= 1;
        end else begin
            ecc_decoder_enable[port] <= 0;
        end
    end

    //当ECC正在运行的时候，输出计数器重置
    //在下一个周期开始累加直到当前页的最后一个半字
    //batch 0到1的时候，发送第一个半字（在一周期后生效）
    always @(posedge clk) begin
        if(ecc_decoder_enable[port] == 1) begin
            output_batch <= 0;
        end else if(output_batch <= end_batch) begin
            output_batch <= output_batch + 1;
        end
    end

    //根据batch发送半字
    always @(posedge clk) begin
        if(output_batch <= end_batch) begin
            case(output_batch) 
                3'd0: rd_data[port] <= ecc_decoder_cr_data_0[port];
                3'd1: rd_data[port] <= ecc_decoder_cr_data_1[port];
                3'd2: rd_data[port] <= ecc_decoder_cr_data_2[port];
                3'd3: rd_data[port] <= ecc_decoder_cr_data_3[port];
                3'd4: rd_data[port] <= ecc_decoder_cr_data_4[port];
                3'd5: rd_data[port] <= ecc_decoder_cr_data_5[port];
                3'd6: rd_data[port] <= ecc_decoder_cr_data_6[port];
                3'd7: rd_data[port] <= ecc_decoder_cr_data_7[port];
            endcase
        end
    end

    //rd vld使能，当output batch累计到页尾之后，则为0，表示不发送数据
    always @(posedge clk) begin
        rd_vld[port] <= output_batch <= end_batch;
    end

    //读取数据包的第一个半字的高9位
    //得到数据包的长度，当然应该减去控制半字本身所占的一半字

    //每当发送一个数据减1，直到0为止
    always @(posedge clk) begin
        if(rd_vld[port] == 1 && packet_length_got == 0) begin
            reading_packet_length <= rd_data[port][15:7] - 1;
        end else if(output_batch <= end_batch) begin
            reading_packet_length <= reading_packet_length - 1;
        end
    end

    //当前页发完了，即将要发下一页了
    //持久化下一页的计数器长度
    always @(posedge clk) begin
        if(packet_length_got == 1 && output_batch == end_batch) begin
            end_batch <= reading_batch[port];
            reading_batch[port] <= reading_packet_length > 15 ? 7 : reading_packet_length - 7;
        end else if(packet_length_got == 0) begin
            end_batch <= 7;
            reading_batch[port] <= 7;
        end
    end

    //维护packet length got在获取到长度之前一直为0
    always @(posedge clk) begin
        if(rd_sop[port] == 1) begin
            packet_length_got <= 0;
        end else if(rd_vld[port] == 1 && packet_length_got == 0) begin 
            packet_length_got <= 1;
        end
    end

    //如果是数据包开头，或者一页开始输出的时候，则为下一页的读取做准备
    //jt 的 rd en和rd addr在SRAM模块实现
    //跳转表应当判空 这里还没确定
    always @(posedge clk) begin
        if(rd_sop[port] == 1 ||
            (handshake[reading_sram[port]] == 1 && processing_request[reading_sram[port]] == port)) begin
            reading_sram[port] <= queue_head_sram[reading_priority];
            reading_page[port] <= queue_head_page[reading_priority];
            {queue_head_sram[reading_priority], queue_head_page[reading_priority]} <= jt_dout[reading_sram[port]];
        end
    end

    //当包长为0的时候，说明再发最后一个，下一个周期就可以拉高rd eop了
    //并且使得WRR轮换
    always @(posedge clk) begin
        if(rd_vld[port] == 1 && reading_packet_length == 0) begin
            rd_eop[port] <= 1;
            next_packet <= 1;
        end else begin
            rd_eop[port] <= 0;
            next_packet <= 0;
        end
    end

    reg next_packet;
    reg [7:0] wrr_mask;
    reg [2:0] wrr_start;
    reg [2:0] wrr_end;

    reg [7:0] queue_waiting;
    
    //WRR位掩码刷新，当next_packet为高时刷新
    always @(posedge clk) begin
        if(next_packet == 0) begin
        end else if(wrr_start < wrr_end) begin
            wrr_mask[wrr_start] <= 0;
            wrr_start <= wrr_start + 1;
        end else if(wrr_end > 1) begin
            wrr_start <= 0;
            wrr_end <= wrr_end - 1;
            wrr_mask <= 8'hFF >> (7 - wrr_end);
        end else begin
            wrr_start <= 0;
            wrr_end <= 7;
            wrr_mask <= 8'hFF;
        end
    end

    //等待读取的队列（被掩码处理过）在next_packet为高时刷新
    //注意，这里用的是上次next_packet已经刷新好的wrr_mask而不是这次新刷新的
    always @(posedge clk) begin
        if(next_packet == 1 && wrr_en == 1 && (wrr_mask & queue_not_empty != 0)) begin
            queue_waiting <= wrr_mask & queue_not_empty;
        end else begin
            queue_waiting <= queue_not_empty;
        end
    end

    reg waiting_ready;
    //根据独热码判定最优先位置
    always @(posedge clk) begin
        if(wr_eop[port] == 1) begin
            waiting_ready <= 1;
        end else if(ready[port] == 1) begin
            waiting_ready <= 0;
        end
    end

    //根据独热码判定最优先位置
    always @(posedge clk) begin
        if(ready[port] == 1 && waiting_ready == 1) begin
            case(queue_waiting & ~(queue_waiting - 1)) 
                8'h01: reading_priority[port] <= 0;
                8'h02: reading_priority[port] <= 1;
                8'h04: reading_priority[port] <= 2;
                8'h08: reading_priority[port] <= 3;
                8'h10: reading_priority[port] <= 4;
                8'h20: reading_priority[port] <= 5;
                8'h40: reading_priority[port] <= 6;
                8'h80: reading_priority[port] <= 7;
                default: begin end
            endcase
        end
    end

    //ready时拉高sop
    always @(posedge clk) begin
        if(rd_sop[port] == 1) begin
            rd_sop[port] <= 0;
        end else if(ready[port]) begin
            rd_sop[port] <= 1;
        end
    end

    //初始化当前包的状态信息
    always @(posedge clk) begin
        if(rd_sop[port] == 1) begin
            reading_packet_length[port] <= 0;
        end
    end
    
    reg [4:0] queue_head_sram [7:0];
    reg [10:0] queue_head_page [7:0];
    reg [4:0] queue_tail_sram [7:0];
    reg [10:0] queue_tail_page [7:0];
    reg [7:0] queue_not_empty;

    always @(posedge clk) begin
        full[port] <= (locking_c | much_space_c) == 0;
    end

    /* 
        搜索
    */

    //刷新每个端口下一周期搜索的SRAM编号
    always @(posedge clk) begin
        searching_sram_index[port] <= (cnt_32 + port) % 32;
    end
    //询问下一周期搜索的SRAM中有多少(属于正在缓冲区匹配SRAM的数据包的)目的端口的半字
    always @(posedge clk) begin
        request_port[(cnt_32 + port) % 32] <= port_dest_port[port];
    end
    //有新的数据包进入缓冲区，应当启动搜索，32周期后结束搜索
    always @(posedge clk) begin
        if(!rst_n) begin
            searching[port] <= 0;
        end else if(port_new_packet_into_buf[port] == 1) begin
            searching[port] <= 1;
        end else if(search_cnt[port] == 31) begin
            searching[port] <= 0;
        end
    end
    //搜索计数器，等于31时正在进行第32次搜索，等于32之后一周期被清零
    //可以将其等于32的时刻认为是搜索全部完成的时候
    always @(posedge clk) begin
        if(!rst_n) begin
            search_cnt[port] <= 0;
        end else if(searching[port] == 1) begin
            search_cnt[port] <= search_cnt[port] + 1;
        end else if(searching[port] == 0) begin
            search_cnt[port] <= 0;
        end
    end
    //主搜索逻辑
    //这里有个无伤大雅的小问题 FIXME
    always @(posedge clk) begin
        if (!(searching[port] == 1 || port_new_packet_into_buf[port] == 1)) begin     //新包来了，重置寄存器
            max_amount[port] <= 0;
            search_get[port] <= 0;
        end else if (locking[searching_sram_index[port]] == 1) begin    //不搜索锁定的  
        end else if (free_space[searching_sram_index[port]] < port_length[port]) begin      //不搜索空间不够的
        end else if (max_amount[port] > page_amount[searching_sram_index[port]]) begin     //不偏好己方端口数据量少的
        end else begin
            max_amount[port] <= page_amount[searching_sram_index[port]];
            searching_distribution[port] <= searching_sram_index[port];
            locking[searching_sram_index[port]] <= 1;
            locking[searching_distribution[port]] <= 0;
            search_get[port] <= 1;
        end
    end

    /*
        持久化
    */
    //如果搜索结束，则意味着要开始写入数据包了
    //持久化数据包的目的端口
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_dest_port[port] <= port_dest_port[port];
        end
    end
    //持久化数据包的目的队列
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_prior[port] <= port_prior[port];
        end
    end
    //持久化数据包的长度
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_length[port] <= port_length[port];
        end
    end
    //持久化搜索结果的SRAM
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_distribution[port] <= searching_distribution[port];
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            wr_op[searching_distribution[port]] <= 1;
            delta_free_space[searching_distribution[port]] <= ((port_length[port] - 1) >> 3) + 1;
            delta_page_amount[searching_distribution[port]] <= ((port_length[port] - 1) >> 3) + 1;
        end else if(wr_op[cur_distribution[port]] == 1) begin
            wr_op[cur_distribution[port]] <= 0;
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            sram_distribution[searching_distribution[port]] <= port;
            sram_occupy[searching_distribution[port]] <= 1;
        end else if(port_data_vld[port] && packet_length[port] == cur_length[port] && packet_length[port]) begin
            sram_occupy[cur_distribution[port]] <= 0;
        end
    end

    /*
        处理数据包
    */
    //处理数据包批次，在搜索完成的时候重置为0
    always @(posedge clk) begin
        if(!rst_n) begin
            packet_batch[port] <= 0;
        end else if(search_cnt[port] == 32 || packet_length[port] == cur_length[port] + 1) begin
            packet_batch[port] <= 0;
        end else if(port_data_vld[port]) begin
            //数据包结束之后时刻自增
            //即使数据包处理完毕后仍可以当作打拍器使用
            packet_batch[port] <= packet_batch[port] + 1;
        end
    end
    //当前已经处理的长度自增，在搜索完毕的时候重置为1，这里为什么不设置为0
    //是因为如果设置为0，那么数据包最后一个半字处理的时候与cur_length差了1，比较大小的时候要引入一个+1的组合逻辑
    //怎么优化怎么来了
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_length[port] <= 1;
        end else if(port_data_vld[port]) begin      //有有效数据的周期自增
            packet_length[port] <= packet_length[port] + 1;
        end else if(packet_length[port] == cur_length[port] + 1) begin
            packet_length[port] <= 0;
        end
    end
    //从第一个有效数据发来到最后一个数据被写入SRAM
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_signal_reset[port] <= 1;
        end else if(!port_data_vld[port]) begin
            packet_signal_reset[port] <= 0;
        end
    end

    /*
        写跳转表
    */
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7 && packet_length[port] != cur_length[port]) begin
            jt_wr_en[cur_distribution[port]] <= 1;
        end else if(port == cnt_32 >> 1 && packet_merge[port] &&
            jt_wr_en[queue_tail_sram[last_dest_queue[port]]] != 1) begin
            jt_wr_en[queue_tail_sram[last_dest_queue[port]]] <= 1;  //这个1虽然无法重置但是无伤大雅
            last_distribution[port] <= queue_tail_sram[last_dest_queue[port]];
        end else if(jt_wr_en[last_distribution[port]] == 1 && !packet_merge[port] 
                    && ((sram_occupy[last_distribution[port]] && 
                    packet_batch[sram_distribution[last_distribution[port]]] != 7) 
                    || !sram_occupy[last_distribution[port]])) begin
            jt_wr_en[last_distribution[port]] <= 0;
        end else if(packet_batch[port] != 7 || packet_length[port] == cur_length[port] + 1) begin
            jt_wr_en[cur_distribution[port]] <= 0;
        end
    end
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7 && packet_length[port] != cur_length[port]) begin
            jt_wr_addr[cur_distribution[port]] <= wr_page[port];
        end else if(port == cnt_32 >> 1 && packet_merge[port] &&
                    jt_wr_en[queue_tail_sram[last_dest_queue[port]]] != 1) begin
            jt_wr_addr[queue_tail_sram[last_dest_queue[port]]] <= wr_last_page[port];
        end
    end
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7 && packet_length[port] != cur_length[port]) begin
            jt_din[cur_distribution[port]] <= null_ptr[cur_distribution[port]];
        end else if(port == cnt_32 >> 1 && packet_merge[port] &&
                    jt_wr_en[queue_tail_sram[last_dest_queue[port]]] != 1) begin
            jt_din[queue_tail_sram[last_dest_queue[port]]] <= last_packet_head_addr[port];
        end
    end
    
    
    //数据包头尾地址的记载
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_head_addr[port] <= {searching_distribution[port], null_ptr[searching_distribution[port]]};
        end
    end
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0) begin
            packet_tail_addr[port] <= {cur_distribution[port], wr_page[port]};
        end
    end

    always @(posedge clk) begin
        if(port_data_vld[port] && packet_length[port] == cur_length[port]) begin
            last_packet_head_addr[port] <= packet_head_addr[port];
        end
    end

    always @(posedge clk) begin
        if(port_data_vld[port] && packet_length[port] == cur_length[port]) begin
            last_packet_tail_addr[port] <= packet_tail_addr[port];
        end
    end

    //提前一周期生成下一页的地址
    //即使下一页没东西了也没副作用，因为该页没有被弹出空闲队列
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7) begin
            wr_page[port] <= null_ptr[cur_distribution[port]];
        end else if(search_cnt[port] == 32) begin   //数据包头也需要提前生成
            wr_page[port] <= null_ptr[searching_distribution[port]];
        end
    end
    //生成下一页地址的时候，持久化上一页的地址，方便写跳转表
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_length[port] == cur_length[port]) begin
            wr_last_page[port] <= wr_page[port];
        end
    end
    //当真正开始使用页的时候，把它弹出空闲队列
    always @(posedge clk) begin
        if(port_data_vld[port] && (packet_batch[port] == 7 
            && packet_length[port] != cur_length[port])) begin
            wr_or[cur_distribution[port]] <= 1;
        end else if(search_cnt[port] == 32) begin
            wr_or[searching_distribution[port]] <= 1;
        end else if(packet_signal_reset[port] == 1) begin
            wr_or[cur_distribution[port]] <= 0;
        end
    end
    //持久化上个数据包的目的队列(3+4)，这是为了在数据包处理完毕后，将其头尾插入
    //队列末端时需要知道是哪个队列，防止这时候cur_dest_port/prior可能已经更新
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_length[port] == cur_length[port]) begin
            last_dest_queue[port] <= cur_prior[port];
        end
    end
    //轮询把整个数据包插入队尾，这样不同端口就不会冲突
    always @(posedge clk) begin
        if(port == cnt_32 >> 1 && packet_merge[port] && jt_wr_en[queue_tail_sram[last_dest_queue[port]]] != 1) begin
            if(queue_not_empty[last_dest_queue[port]]) begin
                queue_not_empty[last_dest_queue[port]] <= 0;
                queue_head_sram[last_dest_queue[port]] <= last_packet_head_addr[port][15:11];
                queue_head_page[last_dest_queue[port]] <= last_packet_head_addr[port][10:0];
            end
            queue_tail_sram[last_dest_queue[port]] <= last_packet_tail_addr[port][15:11];
            queue_tail_page[last_dest_queue[port]] <= last_packet_tail_addr[port][10:0];
        end 
    end
    //是否已经插入优先级队列末端，1-需要插入，0-已经插入
    always @(posedge clk) begin
        if(packet_length[port] == cur_length[port]) begin
            packet_merge[port] <= 1;
        end else if(port == cnt_32 >> 1 && packet_merge[port]) begin
            packet_merge[port] <= 0;
        end 
    end

    /*
        写入SRAM
    */
    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_wr_addr[cur_distribution[port]] <= {wr_page[port], packet_batch[port]};
        end 
    end
    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_wr_en[cur_distribution[port]] <= 1;
        end
    end
    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_din[cur_distribution[port]] <= port_data[port];
        end
    end

    /*
        ECC校验
    */
    //一页写完了或者数据包结束了的时候使能ECC
    always @(posedge clk) begin
        if((port_data_vld[port] && packet_batch[port] == 7) || packet_length[port] == cur_length[port]) begin
            ecc_encoder_enable[port] <= 1;
        end else begin
            ecc_encoder_enable[port] <= 0;
        end
    end
    //使能ECC的时候记录一下这个ECC的结果应当存放到哪个SRAM（即当前数据包的SRAM）
    always @(posedge clk) begin
        if((port_data_vld[port] && packet_batch[port] == 7) || packet_length[port] == cur_length[port]) begin
            ecc_sram[port] <= cur_distribution[port];
        end else begin
            ecc_sram[port] <= cur_distribution[port];
        end
    end
    //打一拍，等待ecc结果准备好（batch=0的时候ecc在更新结果，=1的时候即可获取，见后三个always）
    //引入ecc_result也是防止在开头一页batch=1的时候误触发ECC加码/存储操作
    always @(posedge clk) begin
        if(ecc_encoder_enable[port] == 1) begin
            ecc_result[port] <= 1;
        end else if(packet_batch[port] == 1) begin
            ecc_result[port] <= 0;
        end
    end
    //获取到结果就可以写了，即batch=1的时候
    always @(posedge clk) begin
        if(packet_batch[port] == 1 && ecc_result[port] == 1) begin
            ecc_wr_en[ecc_sram[port]] <= 1;
        end else begin
            ecc_wr_en[ecc_sram[port]] <= 0;
        end
    end
    always @(posedge clk) begin
        if(packet_batch[port] == 1 && ecc_result[port] == 1) begin
            ecc_din[ecc_sram[port]] <= ecc_encoder_code[port];
        end
    end
    always @(posedge clk) begin
        if(packet_batch[port] == 1 && ecc_result[port] == 1) begin
            ecc_wr_addr[ecc_sram[port]] <= wr_last_page[port];
        end
    end
    //不同批次的数据写入ECC缓冲区
    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            case(packet_batch[port])
                3'd0: ecc_decoder_data_0[port] <= port_data[port];
                3'd1: ecc_decoder_data_1[port] <= port_data[port];
                3'd2: ecc_decoder_data_2[port] <= port_data[port];
                3'd3: ecc_decoder_data_3[port] <= port_data[port];
                3'd4: ecc_decoder_data_4[port] <= port_data[port];
                3'd5: ecc_decoder_data_5[port] <= port_data[port];
                3'd6: ecc_decoder_data_6[port] <= port_data[port];
                3'd7: ecc_decoder_data_7[port] <= port_data[port];
            endcase
        end
    end
    //在新一批数据开始写入时清空ECC缓冲区
    always @(posedge clk) begin
        if(port_data_vld[port] == 1 && packet_batch[port] == 0) begin
            ecc_encoder_data_1[port] <= 0;
            ecc_encoder_data_2[port] <= 0;
            ecc_encoder_data_3[port] <= 0;
            ecc_encoder_data_4[port] <= 0;
            ecc_encoder_data_5[port] <= 0;
            ecc_encoder_data_6[port] <= 0;
            ecc_encoder_data_7[port] <= 0;
        end
    end
    
    port_frontend port_frontend
    (
        .clk(clk),
        .wr_sop(wr_sop[port]),
        .wr_eop(wr_eop[port]),
        .wr_vld(wr_vld[port]),
        .wr_data(wr_data[port]),
        .dest_port(port_dest_port[port]),
        .prior(port_prior[port]),
        .length(port_length[port]),
        .data_vld(port_data_vld[port]),
        .data(port_data[port]),
        .search_get(search_get[port]),
        .new_packet_into_buf(port_new_packet_into_buf[port])
    );

    ecc_encoder ecc_encoder
    (
        .clk(clk),
        .enable(ecc_encoder_enable[port]),
        .data_0(ecc_encoder_data_0[port]),
        .data_1(ecc_encoder_data_1[port]),
        .data_2(ecc_encoder_data_2[port]),
        .data_3(ecc_encoder_data_3[port]),
        .data_4(ecc_encoder_data_4[port]),
        .data_5(ecc_encoder_data_5[port]),
        .data_6(ecc_encoder_data_6[port]),
        .data_7(ecc_encoder_data_7[port]),
        .code(ecc_encoder_code[port])
    );

    ecc_decoder ecc_decoder
    (
        .clk(clk),
        .enable(ecc_decoder_enable[port]),
        .data_0(ecc_encoder_data_0[port]),
        .data_1(ecc_encoder_data_1[port]),
        .data_2(ecc_encoder_data_2[port]),
        .data_3(ecc_encoder_data_3[port]),
        .data_4(ecc_encoder_data_4[port]),
        .data_5(ecc_encoder_data_5[port]),
        .data_6(ecc_encoder_data_6[port]),
        .data_7(ecc_encoder_data_7[port]),
        .code(ecc_decoder_code[port]),
        .cr_data_0(ecc_decoder_cr_data_0[port]),
        .cr_data_1(ecc_decoder_cr_data_1[port]),
        .cr_data_2(ecc_decoder_cr_data_2[port]),
        .cr_data_3(ecc_decoder_cr_data_3[port]),
        .cr_data_4(ecc_decoder_cr_data_4[port]),
        .cr_data_5(ecc_decoder_cr_data_5[port]),
        .cr_data_6(ecc_decoder_cr_data_6[port]),
        .cr_data_7(ecc_decoder_cr_data_7[port])
    );
end endgenerate

reg much_space [31:0];
reg locking [31:0];
wire [31:0] much_space_c;
wire [31:0] locking_c;

assign much_space_c = {much_space[31], much_space[30], much_space[29], much_space[28], much_space[27], much_space[26], much_space[25], much_space[24], much_space[23], much_space[22], much_space[21], much_space[20], much_space[19], much_space[18], much_space[17], much_space[16], much_space[15], much_space[14], much_space[13], much_space[12], much_space[11], much_space[10], much_space[9], much_space[8], much_space[7], much_space[6], much_space[5], much_space[4], much_space[3], much_space[2], much_space[1], much_space[0]};
assign locking_c = {locking[31], locking[30], locking[29], locking[28], locking[27], locking[26], locking[25], locking[24], locking[23], locking[22], locking[21], locking[20], locking[19], locking[18], locking[17], locking[16], locking[15], locking[14], locking[13], locking[12], locking[11], locking[10], locking[9], locking[8], locking[7], locking[6], locking[5], locking[4], locking[3], locking[2], locking[1], locking[0]};

genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    //正在请求读取当前SRAM的端口
    wire [15:0] requesting_ports;
    //被掩码处理过的正在请求读取当前SRAM的端口
    reg [15:0] requesting_ports_masked;

    //掩码维护
    //用于实现多个端口同时读取时的轮询输出页操作
    reg next_request;
    reg [15:0] mask;
    reg [3:0] mask_start;

    always @(posedge clk) begin
        if(!rst_n) begin
            mask_start <= 0;
        end else if(next_request) begin
            mask_start <= mask_start + 1;
        end
    end

    always @(posedge clk) begin
        if(next_request) begin
            mask <= 16'hFFFF >> mask_start;
        end
    end

    //这样就不会爆multi driven
    assign requesting_ports = {
        reading_sram[0] == sram,
        reading_sram[1] == sram,
        reading_sram[2] == sram,
        reading_sram[3] == sram,
        reading_sram[4] == sram,
        reading_sram[5] == sram,
        reading_sram[6] == sram,
        reading_sram[7] == sram,
        reading_sram[8] == sram,
        reading_sram[9] == sram,
        reading_sram[10] == sram,
        reading_sram[11] == sram,
        reading_sram[12] == sram,
        reading_sram[13] == sram,
        reading_sram[14] == sram,
        reading_sram[15] == sram
    };

    always @(posedge clk) begin
        if(requesting_ports & mask != 0) begin
            requesting_ports_masked <= requesting_ports & mask;
        end else begin
            requesting_ports_masked <= requesting_ports;
        end
    end

    //是否正在处理请求
    reg processing_enable;
    //处理请求到第几个半字
    reg [3:0] processing_batch; //初值应该为9
    //正在处理哪个端口的请求
    reg [3:0] processing_port;
    //当前是否是一页的开头
    reg start_of_page;

    //只要有请求当然就在处理
    always @(posedge clk) begin
        processing_enable <= requesting_ports_masked != 0;
    end

    //当一页开始的时候，batch设置为0
    //读取的时候batch累加，直到reading_batch+1 (最高可达9)
    //batch等于0的时候，sram读取0位置的半字，等于1的时候，输出读取0位置的半字到ECC缓冲区
    always @(posedge clk) begin
        if(processing_enable == 1 && start_of_page == 1) begin
            processing_batch <= 0;
            start_of_page <= 0;
        end else if(processing_batch <= reading_batch[processing_port] + 1) begin
            processing_batch <= processing_batch + 1;
        end else begin
            start_of_page <= 1;
        end
    end

    //当一页真正开始前，搜索当前是在读取哪个端口
    always @(posedge clk) begin
        if(processing_enable == 1 && start_of_page == 1) begin
            case(requesting_ports_masked & ~(requesting_ports_masked - 1))
                16'h0001: processing_port <= 4'h0;
                16'h0002: processing_port <= 4'h1;
                16'h0004: processing_port <= 4'h2;
                16'h0008: processing_port <= 4'h3;
                16'h0010: processing_port <= 4'h4;
                16'h0020: processing_port <= 4'h5;
                16'h0040: processing_port <= 4'h6;
                16'h0080: processing_port <= 4'h7;
                16'h0100: processing_port <= 4'h8;
                16'h0200: processing_port <= 4'h9;
                16'h0400: processing_port <= 4'hA;
                16'h0800: processing_port <= 4'hB;
                16'h1000: processing_port <= 4'hC;
                16'h2000: processing_port <= 4'hD;
                16'h4000: processing_port <= 4'hE;
                16'h8000: processing_port <= 4'hF;
                default: begin end
            endcase
        end
    end

    //一页刚开始读取的时候，查询跳转表，方便端口中jt dout的调用
    always @(posedge clk) begin
        if(processing_enable == 1 && processing_batch == 0) begin
            jt_rd_en[sram] <= 1;
            jt_rd_addr[sram] <= reading_page[processing_port];
        end
    end

    //一页刚开始的时候读取ECC校验码
    //在第一半字读取完毕的时候将ECC校验码写到端口的ECC校验器里
    always @(posedge clk) begin
        if(processing_enable == 0) begin
        end else if(processing_batch == 0) begin
            ecc_rd_en[sram] <= 1;
            ecc_rd_addr[sram] <= reading_page[processing_port];
        end else if(processing_batch == 1) begin
            ecc_decoder_code[processing_port] <= ecc_dout[sram];
        end
    end

    //读取数据
    always @(posedge clk) begin
        if(processing_enable == 1 && processing_batch <= reading_batch[processing_port]) begin
            sram_rd_en[sram] <= 1;
            sram_rd_addr[sram] <= {reading_page[processing_port],processing_batch};
        end
    end

    //页完全读取结束，发送握手信号触发端口中ECC使能的实现以及后续的输出操作
    always @(posedge clk) begin
        if(processing_batch == reading_batch[processing_port] + 1) begin
            handshake[sram] <= 1;
        end else begin
            handshake[sram] <= 0;
        end
    end

    //ECC缓冲区的装填（batch=1~8）与清空（batch=0）
    always @(posedge clk) begin
        if(processing_enable == 1) begin
            case(processing_batch)
                4'h1: ecc_decoder_data_0[processing_port] <= sram_dout[sram];
                4'h2: ecc_decoder_data_1[processing_port] <= sram_dout[sram];
                4'h3: ecc_decoder_data_2[processing_port] <= sram_dout[sram];
                4'h4: ecc_decoder_data_3[processing_port] <= sram_dout[sram];
                4'h5: ecc_decoder_data_4[processing_port] <= sram_dout[sram];
                4'h6: ecc_decoder_data_5[processing_port] <= sram_dout[sram];
                4'h7: ecc_decoder_data_6[processing_port] <= sram_dout[sram];
                4'h8: ecc_decoder_data_7[processing_port] <= sram_dout[sram];
                4'h0: begin
                    ecc_decoder_data_0[processing_port] <= 0;
                    ecc_decoder_data_1[processing_port] <= 0;
                    ecc_decoder_data_2[processing_port] <= 0;
                    ecc_decoder_data_3[processing_port] <= 0;
                    ecc_decoder_data_4[processing_port] <= 0;
                    ecc_decoder_data_5[processing_port] <= 0;
                    ecc_decoder_data_6[processing_port] <= 0;
                    ecc_decoder_data_7[processing_port] <= 0;
                end
            endcase
        end
    end
    
    always @(posedge clk) begin
        much_space[sram] <= free_space[sram] >= 512;
    end

    always @(posedge clk) begin
        if(!rst_n)
            rd_op[sram] <= 0;
    end

    dual_port_sram dual_port_sram
    (
        .clk(clk),
        .wr_en(sram_wr_en[sram]),
        .wr_addr(sram_wr_addr[sram]),
        .din(sram_din[sram]),
        .rd_en(sram_rd_en[sram]),
        .rd_addr(sram_rd_addr[sram]),
        .dout(sram_dout[sram])
    );

    sram_state sram_state
    (
        .clk(clk),
        .ecc_wr_en(ecc_wr_en[sram]),
        .ecc_wr_addr(ecc_wr_addr[sram]),
        .ecc_din(ecc_din[sram]),
        .ecc_rd_en(ecc_rd_en[sram]),
        .ecc_rd_addr(ecc_rd_addr[sram]),
        .ecc_dout(ecc_dout[sram]),
        .jt_wr_en(jt_wr_en[sram]),
        .jt_wr_addr(jt_wr_addr[sram]),
        .jt_din(jt_din[sram]),
        .jt_rd_en(jt_rd_en[sram]),
        .jt_rd_addr(jt_rd_addr[sram]),
        .jt_dout(jt_dout[sram]),
        
        .wr_or(wr_or[sram]),
        .wr_op(wr_op[sram]),
        .wr_port(wr_port[sram]),
        .rd_addr(rd_addr[sram]),
        .rd_op(rd_op[sram]),
        .rd_port(rd_port[sram]),
        .delta_free_space(delta_free_space[sram]),
        .delta_page_amount(delta_page_amount[sram]),

        .request_port(request_port[sram]),
        .page_amount(page_amount[sram]),
        .null_ptr(null_ptr[sram]),
        .free_space(free_space[sram])
    );
end endgenerate
endmodule