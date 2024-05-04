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

reg [15:0][4:0] distribution;//ç«¯å£å¯¹åº”çš„SRAM
reg [31:0][3:0] bind_dest_port;//SRAMå¯¹åº”çš„ç«¯å?

reg [15:0] search_tag = 0;
reg [15:0][10:0] max_amount = 0;//ä¸´æ—¶æœ?å¤§å??
reg [31:0]locking = 0;//SRAM lock
reg [15:0][2:0]batch = 0;// Data page
reg [15:0][8:0]left = 0;//æŒä¹…åŒ–çš„æ•°æ®é•¿åº¦
reg [15:0][3:0]dest_port_ = 0;//æŒä¹…åŒ–çš„dest port
reg [15:0][2:0]prior_;
reg [15:0][10:0]page = 0;// port page writein
reg [15:0]end_;

always @(negedge rst_n) begin
    for(i = 0; i < 16; i = i + 1) begin
        distribution[i] <= i;
        locking[i] <= 1;
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

reg [31:0] ecc_wr_en;
reg [31:0][10:0] ecc_wr_addr;
reg [31:0][7:0] ecc_din;

reg [31:0]ecc_rd_en;
reg [31:0][10:0] ecc_rd_addr;
wire [31:0][7:0] ecc_dout;

reg [31:0]wr_op;
reg [31:0][3:0] wr_port;
reg [31:0]rd_op = 0;
reg [31:0][3:0] rd_port;
reg [31:0][10:0] rd_addr;

reg [31:0][3:0] request_port;
wire [31:0][10:0] page_amount;

wire [31:0][10:0] null_ptr;
wire [31:0][10:0] free_space;

reg [65535:0][15:0] jump_table;

reg [127:0][15:0] queue_head;
reg [127:0][15:0] queue_tail;
reg [15:0][7:0] queue_empty;

reg [15:0][127:0] ecc_encoder_data;
wire [15:0][7:0] ecc_encoder_code;

reg [15:0][127:0] rd_buffer;
wire [15:0][7:0] ecc_decoder_code;
wire [15:0][127:0] cr_rd_buffer;

reg [31:0] sram_wr_en;
reg [31:0][13:0] sram_wr_addr;
reg [31:0][15:0] sram_din;

reg [31:0] sram_rd_en;
reg [31:0][13:0] sram_rd_addr;
wire [31:0][15:0] sram_dout;
wire [15:0] xfer_en;
reg [15:0] xfer_s = 0;
reg [15:0] xfer_stop = 0;
reg [15:0] xfer_stop_out = 0;

always @(posedge clk) begin
    if(rst_n == 1) begin
    for(i = 0; i < 16; i = i + 1) begin
        if(port_writting[i]) begin
            if(port_new_packet[i]) begin
                if(dest_port_[i] != port_dest_port[i] ||
                    free_space[distribution[i]] < port_length[i]) begin
                    search_tag[i] <= 1;//æ›´æ¢å†™å…¥çš„SRAM
                    request_port[(cnt+i)%32 + 1] <= port_dest_port[i];
                    $display("port_dest_port[i] = %d, i = %d",port_dest_port[i],i);
                    $display("free _space[distribution[i]] = %d",free_space[distribution[i]]);
                    if(free_space[distribution[i]] < port_length[i])
                        xfer_stop[i] <= 1;
                end
            end
        end
        if(xfer_stop_out[i] == 1)
            xfer_stop[i] <= 0;
        $display("cnt = %d",cnt);
        //$display("port_new_packet[i] = %d", port_new_packet[i]);
        //$display("port_writting[i] = %d", port_writting[i]);
        //$display("dest_port_[i] = %d", dest_port_[i]);
        //$display("port_dest_port[i] = %d",port_dest_port[i]);
        //$display("left[i] = %d", left[i]);
        //$display("port_data_vld[i] = %d",port_data_vld[i]);
        //$display("port_length[i] = %d",port_length[i]);
        if(left[i] == 0) begin
            end_[i] <= 0;
        end
        if(xfer_en[i] == 1 && port_data_vld[i] == 0) begin
            page[i] <= null_ptr[distribution[i]];
            search_tag[i] <= 0;
            wr_op[distribution[i]] <= 1;
            wr_port[distribution[i]] <= dest_port_[i];
            $display("       distribution[i] = %d, i = %d",distribution[i],i);
        end
        if(port_data_vld[i]) begin//ç«¯å£æ­£åœ¨è¾“å‡ºdata
            if(left[i] == 0) begin//è¾“å‡ºdataçš„ç¬¬ä¸?ä¸ªtickå’Œè¾“å…¥dataçš„æœ€åŽä¸€ä¸ªtickåº”è¯¥éƒ½éœ€è¦ï¼Œæœ‰ç‚¹æ··ä¹±
                left[i] <= port_length[i];
                dest_port_[i] <= port_dest_port[i];
                prior_[i] <= port_prior[i];
                wr_op[distribution[i]] <= 1;
                wr_port[distribution[i]] <= dest_port_[i];
                //request_port[distribution[i]] <= port_dest_port[i];
                $display("       distribution[i] = %d",distribution[i]);
                //search_tag[i] <= 0;
            end else begin 
                if(left[i] == 1) begin
                    end_[i] <= 1;
                end
                left[i] <= left[i] - 1;
            end
            if(batch[i] == 7 && !end_[i]) begin//åœ¨æ•°æ®æœ«çš„æ—¶å€™ï¼Ÿåœ¨æ•°æ®åˆçš„æ—¶å€?,åº”å½“éœ?è¦é¢„å…ˆä¸€ä¸ªtickï¼ˆåœ¨æœç´¢ç»“æŸçš„æ—¶å€™ï¼‰å¤„ç†page
                page[i] <= null_ptr[distribution[i]];
                $display("distribution[i] = %d",distribution[i]);
                $display("     null_ptr[distribution[i]] = %d",null_ptr[distribution[i]]);
                wr_op[distribution[i]] <= 1;//SRAMæ­£åœ¨å†™å…¥
                wr_port[distribution[i]] <= dest_port_[i];//å†™å…¥çš„ç«¯å?

                //FIXME æœ‰å¯èƒ½æ˜¯ç©ºçš„ï¼Œåˆå§‹åŒ–queue head\tail
                jump_table[queue_tail[{dest_port_[i],port_prior}]] <= null_ptr[distribution[i]];//tailå¡«å……ä¸‹ä¸€ä¸?
                queue_tail[{dest_port_[i],port_prior}] <= null_ptr[distribution[i]];
                
                ecc_wr_en[distribution[i]] <= 1;
                ecc_wr_addr[distribution[i]] <= page[i];
                ecc_din[distribution[i]] <= ecc_encoder_code[i];
            end else begin
                if(end_[i] == 1) begin
                    ecc_wr_en[distribution[i]] <= 0;
                    ecc_wr_addr[distribution[i]] <= page[i];
                    ecc_din[distribution[i]] <= ecc_encoder_code[i];

                    jump_table[queue_tail[{dest_port_[i],port_prior}]] <= null_ptr[distribution[i]];
                    queue_tail[{dest_port_[i],port_prior}] <= null_ptr[distribution[i]];

                    //wr_op[distribution[i]] <= 1;//SRAMæ­£åœ¨å†™å…¥
                    //wr_port[distribution[i]] <= dest_port_[i];
                end
                else wr_op[distribution[i]] <= 0;
            end
            batch[i] <= batch[i] + 1;
            sram_wr_en[distribution[i]] <= 1;
            sram_wr_addr[distribution[i]] <= {page[i], batch[i]};
            $display("batch[i] = %d",batch[i]);
            $display("page[i] = %d",page[i]);
            $display("sram_wr_addr[distribution[i]] = %d",sram_wr_addr[distribution[i]]);
            $display("free_space[distribution[i]] = %d",free_space[distribution[i]]);
            sram_din[distribution[i]] <= port_data[i];
            ecc_encoder_data[i] <= (port_data[i] << (batch[i] << 4)) + ecc_encoder_data[i];
        end
        else wr_op[distribution[i]] <= 0;
        
        if(search_tag[i] && xfer_en[i] == 0) begin
            if(locking[(cnt+i)%32] != 1) begin
                if(page_amount[(cnt+i)%32] >= max_amount[i]) begin//ä¸?ä¸ªSRAMä¸­æœ‰å¤šå°‘ä¸ªdest_portçš„æ•°æ?
                    locking[(cnt+i)%32] <= 1; 
                    locking[distribution[i]] <= 0;
                    distribution[i] <= (cnt+i)%32;
                    //max amountè¦è¿˜åŽ?
                    max_amount[i] <= page_amount[(cnt+i)%32];
                    $display("distribution[i] = %d, i = %d",distribution[i],i,page_amount[(cnt+i)%32],max_amount[i]);
                    bind_dest_port[(cnt+i)%32] <= port_dest_port[i];
                end
                request_port[(cnt+i)%32 + 1] <= port_dest_port[i];
            end
        end
    end
    cnt <= cnt + 1;
    end
end

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
    .new_packet(port_new_packet),
    .xfer_en(xfer_en),
    .xfer_stop(xfer_stop),
    .xfer_stop_out(xfer_stop_out)
    // .unlock(port_unlock)
);

ecc_encoder ecc_encoder [15:0]
(
    .data(ecc_encoder_data),
    .code(ecc_encoder_code)
);

ecc_decoder ecc_decoder [15:0]
(
    .data(rd_buffer),
    .code(ecc_decoder_code),
    .cr_data(cr_rd_buffer)
);

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