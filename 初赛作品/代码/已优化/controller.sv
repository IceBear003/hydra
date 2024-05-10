`include "./初赛作品/代码/已优化/port_frontend.sv"
`include "./初赛作品/代码/已优化/ecc_encoder.sv"
`include "./初赛作品/代码/已优化/ecc_decoder.sv"
`include "./初赛作品/代码/已优化/sram.sv"
`include "./初赛作品/代码/已优化/sram_state.sv"

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
    output reg [15:0] [15:0] rd_data
);


reg [4:0] queue_head_sram [127:0];
reg [10:0] queue_head_page [127:0];
reg [4:0] queue_tail_sram [127:0];
reg [10:0] queue_tail_page [127:0];
reg [7:0] queue_not_empty [15:0];

reg [4:0] cnt_32 = 0;
always @(posedge clk) begin
    cnt_32 <= cnt_32 + 1;
end
reg [3:0] cnt_16 = 0;
always @(posedge clk) begin
    cnt_16 <= cnt_16 + 1;
end

//port_frontend IOs
wire [3:0] port_dest_port [15:0];
wire [2:0] port_prior [15:0];
wire [8:0] port_length [15:0];
reg search_get [15:0];
wire port_data_vld [15:0];
wire [15:0] port_data [15:0];
wire port_new_packet_into_buf [15:0];
//ecc_encoder IOs
reg ecc_encoder_enable [15:0];
reg [15:0] ecc_encoder_data_0 [15:0];
reg [15:0] ecc_encoder_data_1 [15:0];
reg [15:0] ecc_encoder_data_2 [15:0];
reg [15:0] ecc_encoder_data_3 [15:0];
reg [15:0] ecc_encoder_data_4 [15:0];
reg [15:0] ecc_encoder_data_5 [15:0];
reg [15:0] ecc_encoder_data_6 [15:0];
reg [15:0] ecc_encoder_data_7 [15:0];
wire [7:0] ecc_encoder_code [15:0];
//ecc_decoder IOs
reg  ecc_decoder_enable [15:0];
reg [15:0] ecc_decoder_data_0 [15:0];
reg [15:0] ecc_decoder_data_1 [15:0];
reg [15:0] ecc_decoder_data_2 [15:0];
reg [15:0] ecc_decoder_data_3 [15:0];
reg [15:0] ecc_decoder_data_4 [15:0];
reg [15:0] ecc_decoder_data_5 [15:0];
reg [15:0] ecc_decoder_data_6 [15:0];
reg [15:0] ecc_decoder_data_7 [15:0];
reg [7:0] ecc_decoder_code [15:0];
wire [15:0] ecc_decoder_cr_data_0 [15:0];
wire [15:0] ecc_decoder_cr_data_1 [15:0];
wire [15:0] ecc_decoder_cr_data_2 [15:0];
wire [15:0] ecc_decoder_cr_data_3 [15:0];
wire [15:0] ecc_decoder_cr_data_4 [15:0];
wire [15:0] ecc_decoder_cr_data_5 [15:0];
wire [15:0] ecc_decoder_cr_data_6 [15:0];
wire [15:0] ecc_decoder_cr_data_7 [15:0];

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
//上个被写入SRAM的数据包
reg [6:0] last_dest_queue [15:0];   //目的队列(3+4)
reg [10:0] last_page [15:0];        //被写入的页地址

//数据包是否已经结束/是否需要插入队列末端，指导队列头尾地址更新
reg packet_over [15:0];
reg packet_merge[15:0];
//数据包是否还未结束，防止已经与端口脱离关系的SRAM正常工作受干扰
reg packet_not_over [15:0];
//数据包的头尾地址(5+11)
reg [15:0] packet_head_addr [15:0];
reg [15:0] packet_tail_addr [15:0];
//数据包已经被处理的半字数
reg [8:0] packet_length [15:0];
//数据包处理批次下标
reg [2:0] packet_batch [15:0];

//正在写入的页地址
reg [10:0] wr_page [15:0];

//ECC结果是否到被存储的时机
//实际上是ecc_encoder_enable打一拍
reg ecc_result [15:0];
//ECC结果存储的SRAM的编号
//对于一个数据包末尾页的校验，其存储时间在数据包处理完毕之后
//这时distribution可能已经被更新，所以需要额外存储ECC校验码目的SRAM
reg [4:0] ecc_sram [15:0];


genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports
    always @(posedge clk) begin
        full[port] <= (locking | much_space) == 0;
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
        if(port_new_packet_into_buf[port] == 1) begin
            searching[port] <= 1;
        end else if(search_cnt[port] == 31) begin
            searching[port] <= 0;
        end
    end
    //搜索计数器，等于31时正在进行第32次搜索，等于32之后一周期被清零
    //可以将其等于32的时刻认为是搜索全部完成的时候
    always @(posedge clk) begin
        if(searching[port] == 1) begin
            search_cnt[port] <= search_cnt[port] + 1;
        end else begin
            search_cnt[port] <= 0;
        end
    end
    //主搜索逻辑
    //这里有个无伤大雅的小问题 FIXME
    always @(posedge clk) begin
        if(new_packet_into_buf[port]) begin     //新包来了，重置寄存器
            max_amount[port] <= 0;
            search_get[port] <= 0;
        end else if (searching[port] == 1) begin    //搜索中
        end else if (locking[searching_sram_index[port]] == 1) begin    //不搜索锁定的  
        end else if (free_space[searching_sram_index[port]] < port_length[port]) begin      //不搜索空间不够的
        end else if (max_amount[port] >= page_amount[searching_sram_index[port]]) begin     //不偏好己方端口数据量少的
        end else begin
            max_amount[port] <= page_amount[searching_sram_index[port]];
            searching_distribution[port] <= searching_sram_index[port];
            locking[searching_sram_index[port]] <= 1;
            locking[searching_distribution[port]] <= 1;
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

    /*
        处理数据包
    */
    //处理数据包批次，在搜索完成的时候重置为0
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_batch[port] <= 0;
        end else if(port_data_vld[port] || packet_over[port]) begin
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
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_not_over[port] <= 1;
        end else if(packet_length[port] == cur_length[port]) begin  //最后一周期的有效数据
            packet_not_over[port] <= 0;
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_over[port] <= 0;
        end else if(packet_length[port] == cur_length[port]) begin  //最后一周期的有效数据
            packet_over[port] <= 1;
        end
    end

    /*
        写跳转表
    */
    //当batch=0且有效数据的时候，更新上页对应的的跳转表指向这一页的地址
    //不能在数据包最开始的batch=0触发，所以search_cnt != 32
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0 && search_cnt != 32) begin
            jt_wr_en[cur_distribution[port]] <= 1;
        end else if(packet_not_over[port]) begin
            jt_wr_en[cur_distribution[port]] <= 0;
        end
    end
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0 && search_cnt != 32) begin
            jt_wr_addr[cur_distribution[port]] <= wr_last_page[port];
        end
    end
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0 && search_cnt != 32) begin
            jt_wr_din[cur_distribution[port]] <= wr_page[port];
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

    //提前一周期生成下一页的地址
    //即使下一页没东西了也没副作用，因为该页没有被弹出空闲队列
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7) begin
            wr_page[port] <= null_ptr[cur_distribution[port]];
        end else if(search_cnt[port] == 32) begin   //数据包头也需要提前生成
            wr_page[port] <= null_ptr[cur_distribution[port]];
        end
    end
    //生成下一页地址的时候，持久化上一页的地址，方便写跳转表
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7) begin
            wr_last_page[port] <= wr_page[port];
        end
    end
    //当真正开始使用页的时候，把它弹出空闲队列
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0) begin
            //这边有问题
            wr_op[cur_distribution[port]] <= 1;
        end else if(packet_not_over[port]) begin
            wr_op[cur_distribution[port]] <= 0;
        end
    end
    //持久化上个数据包的目的队列(3+4)，这是为了在数据包处理完毕后，将其头尾插入
    //队列末端时需要知道是哪个队列，防止这时候cur_dest_port/prior可能已经更新
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_length[port] == cur_length[port]) begin
            last_dest_queue[port] <= {cur_distribution[port], cur_sram_index[port]};
        end
    end
    //轮询把整个数据包插入队尾，这样不同端口就不会冲突
    always @(posedge clk) begin
        if(port == cnt_16 && packet_over[port] && packet_merge[port]) begin
            //把原来的尾巴的跳转表指向头
            jt_wr_en[queue_tail_sram[last_dest_queue[port]]] <= 1;
            jt_wr_addr[queue_tail_page[last_dest_queue[port]]] <= wr_last_page[port];
            jt_din[queue_tail_page[last_dest_queue[port]]] <= packet_head_addr[port];
            //把尾巴设置为新的尾地址
            queue_tail_sram[last_dest_queue[port]] <= packet_tail_addr[port][15:11];
            queue_tail_page[last_dest_queue[port]] <= packet_tail_addr[port][10:0];
        end 
    end
    //是否已经插入优先级队列末端，1-需要插入，0-已经插入
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_length[port] == cur_length[port]) begin
            packet_merge[port] <= 1;
        end else if(port == cnt_16 && packet_over[port]) begin
            packet_merge[port] <= 0;
        end 
    end

    /*
        写入SRAM
    */
    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_wr_addr[port] <= {wr_page[port], packet_batch[port]};
        end 
    end
    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_wr_en[cur_distribution[port]] <= 1;
        end else if(packet_not_over[port]) begin    //数据包结束了就不归这个端口关了，就不能任由其设置为0了
            sram_wr_en[cur_distribution[port]] <= 0;
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
            ecc_result <= 1;
        end else if(packet_batch[port] == 1) begin
            ecc_result <= 0;
        end
    end
    //获取到结果就可以写了，即batch=1的时候
    always @(posedge clk) begin
        if(packet_batch[port] == 1 && ecc_result == 1) begin
            ecc_wr_en[ecc_sram[port]] <= 1;
        end else begin
            ecc_wr_en[ecc_sram[port]] <= 0;
        end
    end
    always @(posedge clk) begin
        if(packet_batch[port] == 1 && ecc_result == 1) begin
            ecc_wr_din[ecc_sram[port]] <= ecc_encoder_code[port];
        end
    end
    always @(posedge clk) begin
        if(packet_batch[port] == 1 && ecc_result == 1) begin
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

//sram IOs
reg sram_wr_en [31:0];
reg [13:0] sram_wr_addr [31:0];
reg [15:0] sram_din [31:0];

reg sram_rd_en [31:0];
reg [13:0] sram_rd_addr [31:0];
wire [15:0] sram_dout [31:0];
//sram_state IOs
reg  ecc_wr_en [31:0];
reg [10:0] ecc_wr_addr [31:0];
reg [7:0] ecc_din [31:0];

reg ecc_rd_en [31:0];
reg [10:0] ecc_rd_addr [31:0];
wire [7:0] ecc_dout [31:0];

reg jt_wr_en [31:0];
reg [10:0] jt_wr_addr [31:0];
reg [15:0] jt_din [31:0];

reg jt_rd_en [31:0];
reg [10:0] jt_rd_addr [31:0];
wire [15:0] jt_dout [31:0];

reg wr_op [31:0];
reg [3:0] wr_port [31:0];
reg rd_op [31:0];
reg [3:0] rd_port [31:0];
reg [10:0] rd_addr [31:0];

reg [3:0] request_port [31:0];
wire [10:0] page_amount [31:0];

wire [10:0] null_ptr [31:0];
wire [10:0] free_space [31:0];

reg [31:0] much_space;
reg [31:0] locking;

genvar sram;
generate for(sram = 0; sram < 16; sram = sram + 1) begin : SRAMs
    
    always @(posedge clk) begin
        much_space[sram] <= free_space[sram] >= 512;
    end

    sram sram
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

        .wr_op(wr_op[sram]),
        .wr_port(wr_port[sram]),
        .rd_addr(rd_addr[sram]),
        .rd_op(rd_op[sram]),
        .rd_port(rd_port[sram]),

        .request_port(request_port[sram]),
        .page_amount(page_amount[sram]),

        .null_ptr(null_ptr[sram]),
        .free_space(free_space[sram])
    );
end endgenerate
endmodule