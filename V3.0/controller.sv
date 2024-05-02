module controller(
    input clk,
    input rst_n,

    //16 Ports
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] [15:0] wr_data,
    output reg [15:0] full = 0,
    output reg [15:0] almost_full = 0
);

reg [4:0] cnt = 0;

integer i, j;

reg [15:0][4:0] distribution;//端口对应的SRAM
reg [31:0][3:0] bind_dest_port;//SRAM对应的端口

always @(negedge rst_n) begin
    for(i = 0; i < 16; i = i + 1) begin
        distribution[i] <= i;
    end
end

reg [15:0] search_tag = 0;
reg [15:0][10:0] max_amount = 0;//临时最大值
reg [31:0]locking = 0;//SRAM lock
reg [31:0][2:0]batch = 0;// Data page
reg [31:0][8:0]left = 0;//持久化的数据长度
reg [31:0][3:0]dest_port_;//持久化的dest port
reg [31:0][2:0]prior_;
reg [15:0][10:0]page;// port page writein

always @(posedge clk) begin
    for(i = 0; i < 16; i = i + 1) begin
        if(port_writting[i]) begin
            if(port_new_packet[i]) begin
                if(bind_dest_port[distribution[i]] != port_dest_port[i] ||
                    free_space[distribution[i]] < port_length[i]) begin
                    search_tag[i] <= 1;//更换写入的SRAM
                end
            end
            //                 dest_port      length
            //判断已经被绑定的ditribution的sram是否空间充足
                //若充足，则不做搜索操作
                //若不充足，则查看预分配（dest port）是否可用
                    //若可用则直接用                      force_mode
                    //若不可用就等待，将xfer_stop拉高，进入强制搜索模式
        end

        if(port_data_vld[i]) begin//端口正在输出data
            if(left[i] == 0) begin//输出data的第一个tick和输入data的最后一个tick应该都需要，有点混乱
                left[i] <= port_length[i];
                dest_port_[i] <= port_dest_port[i];
                prior_[i] <= port_prior[i];
                if(batch[i] != 7) begin//batch[i]会不会等于7
                    //ECC
                    ecc_wr_en[distribution[i]] <= 0;
                    ecc_wr_addr[distribution[i]] <= page[i];
                    ecc_din[distribution[i]] <= ecc_encoder_code[i];

                end
            end else begin 
                left[i] <= left[i] - 1;
            end
            if(batch[i] == 7) begin//在数据末的时候？在数据初的时候,应当需要预先一个tick（在搜索结束的时候）处理page
                page[i] <= null_ptr[distribution[i]];
                wr_op[distribution[i]] <= 1;//SRAM正在写入
                wr_port[distribution[i]] <= dest_port_[i];//写入的端口

                //有可能是空的，初始化queue head\tail
                jump_table[queue_tail[{dest_port_[i],port_prior}]] <= null_ptr[distribution[i]];//tail填充下一个
                queue_tail[{dest_port_[i],port_prior}] <= null_ptr[distribution[i]];
                
                //ECC
                ecc_wr_en[distribution[i]] <= 1;
                ecc_wr_addr[distribution[i]] <= page[i];
                ecc_din[distribution[i]] <= ecc_encoder_code[i];
                

            end else begin
                wr_op[distribution[i]] <= 0;
            end
            batch[i] <= batch[i] + 1;
            sram_wr_en[distribution[i]] <= 1;
            sram_wr_addr[distribution[i]] <= {page[i], batch[i]};
            sram_din[distribution[i]] <= port_data[i];
            ecc_encoder_data[i] <= (port_data[i] << (batch[i] << 4)) + ecc_encoder_data[i];
        end
        
        if(search_tag[i]) begin//搜索SRAM。search_tag没有置0以及这个search如何结束（可以添加一个计数器）
            if(locking[(cnt+i)%32] != 1) begin
                if(port_amount[(cnt+i)%32][port_dest_port[i]] > max_amount[i]) begin//一个SRAM中有多少个dest_port的数据
                    locking[(cnt+i)%32] <= 1; 
                    locking[distribution[i]] <= 0;
                    distribution[i] <= (cnt+i)%32;
                    //max amount要还原
                    max_amount[i] <= port_amount[(cnt+i)%32][port_dest_port[i]];
                    bind_dest_port[(cnt+i)%32] <= port_dest_port[i];
                end
            end
        end

        //如果正在进入数据(加数据有效信号)
            //已经分配好SRAM，
            //直接取nullptr
            //开始调用sram写
            //累计8个
            //触发ECC，写ECC
        //无论何时，则开始分配流程，
            //如果不是强制搜索模式
                //即当端口自己作为dest port，择优
                //看SRAM是否正在被写、是否被别的端口预分配占用、是否有己方的大量数据
                //如果sram数据量过少并且可用的SRAM数量过少，则不预分配，拉高almost_full
            //如果是强制搜索模式
                //看SRAM是否正在被写、是否有己方的数据
                //如果得不到结果，拉高full、把xfer_ptr往后移直到write_ptr
                //如果可用的SRAM，就正常写
    end
    cnt <= cnt + 1;
end

wire [15:0] [2:0] port_prior;
wire [15:0] [3:0] port_dest_port;
wire [15:0] port_data_vld;
wire [15:0] [15:0] port_data;
wire [15:0] [8:0] port_length;
wire [15:0] port_writting;
wire [15:0] port_new_packet;
wire [15:0] port_unlock;

reg [127:0][15:0] queue_head;
reg [127:0][15:0] queue_tail;
reg [15:0][7:0] queue_empty;

always @(negedge rst_n) begin
    queue_head = 'b0;
    queue_tail = 'b0;
    queue_empty = {128{1'b1}};
end

port port [15:0]
(
    .clk(clk),

    .wr_sop(wr_sop),
    .wr_eop(wr_eop),
    .wr_vld(wr_vld),
    .wr_data(wr_data),

    .prior(port_prior),
    .dest_port(port_dest_port),
    .data_vld(port_data_vld),
    .data(port_data),
    .length(port_length),
    .writting(port_writting),
    .new_packet(port_new_packet)
    // .unlock(port_unlock)
);

reg [15:0][127:0] ecc_encoder_data;
wire [15:0][7:0] ecc_encoder_code;

ecc_encoder ecc_encoder [15:0]
(
    .data(ecc_encoder_data),
    .code(ecc_encoder_code)
);

reg [15:0][127:0] rd_buffer;
wire [15:0][7:0] ecc_decoder_code;
wire [15:0][127:0] cr_rd_buffer;

ecc_decoder ecc_decoder [15:0]
(
    .data(rd_buffer),
    .code(ecc_decoder_code),
    .cr_data(cr_rd_buffer)
);

reg [31:0] sram_wr_en;
reg [31:0][13:0] sram_wr_addr;
reg [31:0][15:0] sram_din;

reg [31:0] sram_rd_en;
reg [31:0][13:0] sram_rd_addr;
wire [31:0][15:0] sram_dout;

sram sram [31:0]
(
    .clk(clk),
    .rst_n(rst_n),
    
    .wr_en(sram_wr_en),
    .wr_addr(sram_wr_addr),
    .din(sram_din),
    
    .rd_en(sram_rd_en),
    .rd_addr(sram_rd_addr),
    .dout(sram_dout)
);

reg [31:0] ecc_wr_en;
reg [31:0][10:0] ecc_wr_addr;
reg [31:0][7:0] ecc_din;

reg [31:0]ecc_rd_en;
reg [31:0][10:0] ecc_rd_addr;
wire [31:0][7:0] ecc_dout;

reg [31:0]wr_op;
reg [31:0][3:0] wr_port;
reg [31:0]rd_op;
reg [31:0][3:0] rd_port;
reg [31:0][10:0] rd_addr;

wire [31:0][15:0][10:0] port_amount;

wire [31:0][10:0] null_ptr;
wire [31:0][10:0] free_space;

reg [65535:0][15:0] jump_table;

sram_state sram_state [31:0] 
(
    .clk(clk),
    .rst_n(rst_n),

    .ecc_wr_en(ecc_wr_en),
    .ecc_wr_addr(ecc_wr_addr),
    .ecc_din(ecc_din),
    .ecc_rd_en(ecc_rd_en),
    .ecc_rd_addr(ecc_rd_addr),
    .ecc_dout(ecc_dout),

    .wr_op(wr_op),
    .wr_port(wr_port),
    .rd_addr(rd_addr),
    .rd_op(rd_op),
    .rd_port(rd_port),

    .port_amount(port_amount),

    .null_ptr(null_ptr),
    .free_space(free_space)
);

endmodule