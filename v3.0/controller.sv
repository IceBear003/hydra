`include "./v3.0/sram_state.sv"
`include "./v3.0/sram.sv"
`include "./v3.0/ecc_encoder.sv"
`include "./v3.0/ecc_decoder.sv"
`include "./v3.0/port.sv"

module controller(
    input clk,
    input rst_n,

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
reg [15:0][2:0]batch = 0;// Data page
reg [15:0][8:0]left = 0;//持久化的数据长度
reg [15:0][3:0]dest_port_;//持久化的dest port
reg [15:0][2:0]prior_;
reg [15:0][10:0]page;// port page writein
reg [15:0]end_;

always @(posedge clk) begin
    for(i = 0; i < 16; i = i + 1) begin
        if(port_writting[i]) begin
            if(port_new_packet[i]) begin
                if(dest_port_[i] != port_dest_port[i] ||
                    free_space[distribution[i]] < port_length[i]) begin
                    search_tag[i] <= 1;//更换写入的SRAM
                    request_port[(cnt+i)%32 + 1] <= port_dest_port[i];
                end
            end
        end

        if(left[i] == 0) begin
            end_[i] <= 0;
        end

        if(port_data_vld[i]) begin//端口正在输出data
            if(left[i] == 0) begin//输出data的第一个tick和输入data的最后一个tick应该都需要，有点混乱
                left[i] <= port_length[i];
                dest_port_[i] <= port_dest_port[i];
                prior_[i] <= port_prior[i];
                search_tag[i] <= 0;
            end else begin 
                if(left[i] == 1) begin
                    end_[i] <= 1;
                end
                left[i] <= left[i] - 1;
            end
            if(batch[i] == 7 && !end_[i]) begin//在数据末的时候？在数据初的时候,应当需要预先一个tick（在搜索结束的时候）处理page
                page[i] <= null_ptr[distribution[i]];
                wr_op[distribution[i]] <= 1;//SRAM正在写入
                wr_port[distribution[i]] <= dest_port_[i];//写入的端口

                //FIXME 有可能是空的，初始化queue head\tail
                jump_table[queue_tail[{dest_port_[i],port_prior}]] <= null_ptr[distribution[i]];//tail填充下一个
                queue_tail[{dest_port_[i],port_prior}] <= null_ptr[distribution[i]];
                
                ecc_wr_en[distribution[i]] <= 1;
                ecc_wr_addr[distribution[i]] <= page[i];
                ecc_din[distribution[i]] <= ecc_encoder_code[i];
            end else begin
                if(end_[i] == 1) begin
                    ecc_wr_en[distribution[i]] <= 0;
                    ecc_wr_addr[distribution[i]] <= page[i];
                    ecc_din[distribution[i]] <= ecc_encoder_code[i];
                end
                wr_op[distribution[i]] <= 0;
            end
            batch[i] <= batch[i] + 1;
            sram_wr_en[distribution[i]] <= 1;
            sram_wr_addr[distribution[i]] <= {page[i], batch[i]};
            sram_din[distribution[i]] <= port_data[i];
            ecc_encoder_data[i] <= (port_data[i] << (batch[i] << 4)) + ecc_encoder_data[i];
        end
        
        if(search_tag[i]) begin
            if((~locking) == 0) begin
                full[i] <= 0;
            end

            if(locking[(cnt+i)%32] != 1) begin
                if(page_amount[(cnt+i)%32] > max_amount[i]) begin//一个SRAM中有多少个dest_port的数据
                    locking[(cnt+i)%32] <= 1; 
                    locking[distribution[i]] <= 0;
                    distribution[i] <= (cnt+i)%32;
                    //max amount要还原
                    max_amount[i] <= page_amount[(cnt+i)%32];
                    bind_dest_port[(cnt+i)%32] <= port_dest_port[i];
                end
                request_port[(cnt+i)%32 + 1] <= port_dest_port[i];
            end
        end
    end
    cnt <= cnt + 1;
end

integer k,m,n,p;
reg [15:0][7:0] queue_waiting;
reg [15:0] sending;
reg [15:0][2:0] sending_priority;
reg [31:0][15:0] sram_request;
reg [31:0][3:0] processing_request; 
reg [31:0] processing; 

reg [15:0] sending_ctrl;
reg [15:0][8:0] sending_left;
reg [15:0][2:0] sending_batch = 0;

reg [15:0][3:0] rd_batch = 0;

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(rd_batch[p] > 0) begin
            rd_batch[p] <= rd_batch[p] - 1;
            rd_vld[p] <= 1;
            rd_data[p] <= cr_rd_buffer[p] >> (16 * (7 - rd_batch[p]));
            ecc_decoder_enable[processing_request[m]] <= 0;
        end else begin
            rd_vld <= 0;
            rd_eop[p] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(n = 0; n < 16; n = n + 1) begin
        queue_waiting[n] = {
            queue_head[n<<3 + 0] != 16'h0000,
            queue_head[n<<3 + 1] != 16'h0000,
            queue_head[n<<3 + 2] != 16'h0000,
            queue_head[n<<3 + 3] != 16'h0000,
            queue_head[n<<3 + 4] != 16'h0000,
            queue_head[n<<3 + 5] != 16'h0000,
            queue_head[n<<3 + 6] != 16'h0000,
            queue_head[n<<3 + 7] != 16'h0000
        };
    end
end

always @(posedge clk) begin
    for(m = 0; m <32; m = m + 1) begin
        if(sram_request[m] != 0 && processing[m] != 1) begin
            case(sram_request[m]) 
                16'h0001: begin processing_request[m] <= 4'h0; sending_ctrl[m]<= 4'h0; end
                16'h0002: begin processing_request[m] <= 4'h1; sending_ctrl[m]<= 4'h1; end
                16'h0004: begin processing_request[m] <= 4'h2; sending_ctrl[m]<= 4'h2; end
                16'h0008: begin processing_request[m] <= 4'h3; sending_ctrl[m]<= 4'h3; end
                16'h0010: begin processing_request[m] <= 4'h4; sending_ctrl[m]<= 4'h4; end
                16'h0020: begin processing_request[m] <= 4'h5; sending_ctrl[m]<= 4'h5; end
                16'h0040: begin processing_request[m] <= 4'h6; sending_ctrl[m]<= 4'h6; end
                16'h0080: begin processing_request[m] <= 4'h7; sending_ctrl[m]<= 4'h7; end
                16'h0100: begin processing_request[m] <= 4'h8; sending_ctrl[m]<= 4'h8; end
                16'h0200: begin processing_request[m] <= 4'h9; sending_ctrl[m]<= 4'h9; end
                16'h0400: begin processing_request[m] <= 4'hA; sending_ctrl[m]<= 4'hA; end
                16'h0800: begin processing_request[m] <= 4'hB; sending_ctrl[m]<= 4'hB; end
                16'h1000: begin processing_request[m] <= 4'hC; sending_ctrl[m]<= 4'hC; end
                16'h2000: begin processing_request[m] <= 4'hD; sending_ctrl[m]<= 4'hD; end
                16'h4000: begin processing_request[m] <= 4'hE; sending_ctrl[m]<= 4'hE; end
                16'h8000: begin processing_request[m] <= 4'hF; sending_ctrl[m]<= 4'hF; end
            endcase
            processing[m] <= 1;

            sram_rd_en[m] <= 1;
            sram_rd_addr[m] <= {queue_head[10:0],3'd0};
        end
        if(processing[m] == 1) begin
            if(sending_ctrl[m] == 1) begin
                sending_ctrl[m] <= 0;
                sending_left[m] <= sram_dout[m] - 1;
                sending_batch[processing_request[m]] <= 1;
                sram_rd_addr[m] <= {queue_head[10:0],3'd1};
            end else begin
                if(sending_left[m] > 0) begin
                    sending_left[m] <= sending_left[m] - 1;
                    sending_batch[m] <= sending_batch[m] + 1;
                    sram_rd_addr[m] <= {queue_head[10:0],sending_batch[m]};
                    rd_buffer[processing_request[m]] <= rd_buffer[processing_request[m]] << 16 + sram_dout[m];

                    if(sending_batch[m] == 0) begin
                        ecc_rd_en[processing_request[m]] <= 1;
                        ecc_rd_addr[processing_request[m]] <= queue_head[10:0];
                    end
                    if(sending_batch[m] == 1) begin
                        ecc_decoder_code[processing_request[m]] <= ecc_dout[processing_request[m]];
                    end
                    if(sending_batch[m] == 7) begin
                        ecc_decoder_enable[processing_request[m]] <= 1;
                        rd_batch[processing_request[m]] <= 4'd8;
                        queue_head <= jump_table[queue_head]; //注意，可能是结尾，应改动
                    end
                end else begin 
                    sram_rd_en[m] <= 0;
                    rd_buffer[processing_request[m]] <= rd_buffer[processing_request[m]] << (16 * (7 - sending_batch[processing_request[m]]));
                    ecc_decoder_enable[processing_request[m]] <= 1;
                    rd_batch[processing_request[m]] <= sending_batch[processing_request[m]] + 1;
                    queue_head <= jump_table[queue_head]; //注意，可能是结尾，应改动
                end
            end
        end
    end
end

always @(posedge clk) begin
    for(k = 0; k < 16; k = k + 1) begin
        if(ready[k]) begin
            if(queue_waiting[k] != 0) begin
                case(k)
                    8'b1XXXXXXX: sending_priority[k] <= 3'd0;
                    8'b01XXXXXX: sending_priority[k] <= 3'd1;
                    8'b001XXXXX: sending_priority[k] <= 3'd2;
                    8'b0001XXXX: sending_priority[k] <= 3'd3;
                    8'b00001XXX: sending_priority[k] <= 3'd4;
                    8'b000001XX: sending_priority[k] <= 3'd5;
                    8'b0000001X: sending_priority[k] <= 3'd6;
                    8'b00000001: sending_priority[k] <= 3'd7;
                endcase
                sending[k] <= 1;
            end
        end

        if(sending[k]) begin
            sram_request[queue_head[sending_priority[k]]] <= sram_request[queue_head[sending_priority[k]]] | {16'b1 << k};
            rd_sop[k] <= 1;
        end
    end
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
reg [15:0][7:0] ecc_decoder_code;
reg [15:0] ecc_decoder_enable;
wire [15:0][127:0] cr_rd_buffer;

ecc_decoder ecc_decoder [15:0]
(
    .data(rd_buffer),
    .code(ecc_decoder_code),
    .enable(ecc_decoder_enable),
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

reg [31:0][3:0] request_port;
wire [31:0][10:0] page_amount;

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

    .request_port(request_port),
    .page_amount(page_amount),

    .null_ptr(null_ptr),
    .free_space(free_space)
);

endmodule