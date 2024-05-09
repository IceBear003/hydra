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

    input [15:0] wrr_en,

    input [15:0] ready,
    output reg [15:0] rd_sop = 0,
    output reg [15:0] rd_eop = 0,
    output reg [15:0] rd_vld = 0,
    output reg [15:0] [15:0] rd_data
);

integer wr_p1;

reg [15:0] new_packet = 0;
reg [15:0] searching = 0;

reg [4:0] cnt = 0;
reg [15:0][4:0] searching_sram_index = 0;

reg [15:0][6:0] last_queue = 0;
reg [15:0][4:0] last_distribution = 0;
reg [15:0][3:0] cur_dest_port = 0;
reg [15:0][2:0] cur_prior = 0;
reg [15:0][8:0] cur_length = 0;

reg [31:0] locking = 0;
reg [15:0][10:0] max_amount = 0;
reg [15:0][4:0] searching_distribution = 0;
reg [15:0][4:0] distribution = 0;
reg [15:0][10:0] wr_page = 0;

reg [15:0][15:0] packet_en = 0;
reg [15:0][15:0] packet_head_addr = 0;
reg [15:0][15:0] packet_tail_addr = 0;

reg [15:0][2:0] batch = 0;

wire [15:0] begin_of_packet;

reg [31:0][11:0] delta_free_space = 0;
reg [31:0][11:0] delta_page_amount = 0;

reg [31:0] sram_rd_en = 0;
reg [31:0][13:0] sram_rd_addr = 0;
wire [31:0][15:0] sram_dout;

reg [31:0] ecc_wr_en = 0;
reg [31:0][10:0] ecc_wr_addr = 0;
reg [31:0][7:0] ecc_din = 0;

reg [31:0]ecc_rd_en = 0;
reg [31:0][10:0] ecc_rd_addr = 0;
wire [31:0][7:0] ecc_dout;

reg [31:0] jt_wr_en = 0;
reg [31:0][10:0] jt_wr_addr = 0;
reg [31:0][15:0] jt_din = 0;

reg [31:0]jt_rd_en = 0;
reg [31:0][10:0] jt_rd_addr = 0;
wire [31:0][15:0] jt_dout;

reg [31:0]wr_op = 0;
reg [31:0]wr_or = 0;
reg [31:0][3:0] wr_port = 0;
reg [31:0]rd_op = 0;
reg [31:0][3:0] rd_port = 0;
reg [31:0][10:0] rd_addr = 0;

reg [31:0][3:0] request_port = 0;
wire [31:0][10:0] page_amount;

wire [31:0][10:0] null_ptr;
wire [31:0][10:0] free_space;

reg [31:0] accessible;
reg [15:0] search_get;

always @(posedge clk) begin
    cnt <= cnt + 1;
end

integer i;

always @(posedge clk) begin
    for(i = 0; i < 31; i = i + 1) begin
        accessible[i] <= (~locking[i] | (free_space[i] >= 32));
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        full[wr_p1] <= (accessible == 0);
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        searching_sram_index[wr_p1] <= (cnt + wr_p1) % 32;
        request_port[(cnt + wr_p1) % 32] <= port_dest_port[wr_p1];
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(port_new_packet[wr_p1] == 1) begin
            searching[wr_p1] <= 1;
        end
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(start_of_packet[wr_p1] == 1) begin
            cur_dest_port[wr_p1] <= port_dest_port[wr_p1];
            cur_prior[wr_p1] <= port_prior[wr_p1];
            cur_length[wr_p1] <= port_length[wr_p1];
            distribution[wr_p1] <= searching_distribution[wr_p1];
            searching[wr_p1] <= 0;
            search_get[wr_p1] <= 0;
            packet_en[wr_p1] <= 0;
            packet_head_addr[wr_p1] <= {searching_distribution[wr_p1],null_ptr[searching_distribution[wr_p1]]};
            $display("searching_distribution[wr_p1] = %d, %d",searching_distribution[wr_p1],wr_p1);
        end
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(!rst_n) begin
            search_get[wr_p1] <= 1;
        end
        else if(begin_of_packet[wr_p1] == 1) begin
            searching[wr_p1] <= 0;
            //$display("searching_distribution[wr_p1] = %d, %d",searching_distribution[wr_p1],wr_p1);
        end
    end
end

always @(posedge clk) begin
    if(!rst_n)
        for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
            searching_distribution[wr_p1] <= wr_p1;
            locking[wr_p1] <= 1;
        end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        //$display("locking[searching_sram_index[wr_p1]] = %d, %d",locking[searching_sram_index[wr_p1]],wr_p1);
        //$display("searching_sram_index[wr_p1] = %d",searching_sram_index[wr_p1]);
        if((port_new_packet[wr_p1] == 1 || searching[wr_p1] == 1) 
        && (!locking[searching_sram_index[wr_p1]] || 
        (searching_sram_index[wr_p1] == distribution[wr_p1] && cur_length[wr_p1] > 0))) begin
            $display("page_amount[searching_sram_index[wr_p1]] = %d",page_amount[searching_sram_index[wr_p1]]);
            $display("searching_sram_index[wr_p1] = %d,%d",searching_sram_index[wr_p1],wr_p1);
            $display("free_space[searching_sram_index[wr_p1]] = %d",free_space[searching_sram_index[wr_p1]]);
            if(page_amount[searching_sram_index[wr_p1]] >= max_amount[wr_p1] 
            && free_space[searching_sram_index[wr_p1]] >= ((port_length[wr_p1] - 1) >> 3) + 1) begin
                //EXCHANGE
                max_amount[wr_p1] <= page_amount[searching_sram_index[cur_dest_port[wr_p1]]];
                searching_distribution[wr_p1] <= searching_sram_index[wr_p1];
                //LOCK UNLOCK
                if(!(searching_distribution[wr_p1] == distribution[wr_p1] && cur_length[wr_p1] > 0))
                    locking[searching_distribution[wr_p1]] <= 0;
                locking[searching_sram_index[wr_p1]] <= 1;
                //PAGE LOAD
                if(cur_length[wr_p1] == 0)
                    wr_page[wr_p1] <= null_ptr[searching_sram_index[wr_p1]];
                $display("distribution[wr_p1] = %d, %d",distribution[wr_p1],wr_p1);
                $display("searching_sram_index[wr_p1] = %d,%d",searching_sram_index[wr_p1],wr_p1);
                $display("page_amount[searching_sram_index[wr_p1]] = %d",page_amount[searching_sram_index[wr_p1]]);
                $display("free_space[searching_sram_index[wr_p1]] = %d",free_space[searching_sram_index[wr_p1]]);
                $display("port_length[wr_p1] = %d",port_length[wr_p1]);
                search_get[wr_p1] <= 1;
            end
        end
    end
end

reg [15:0] if_end;
reg [15:0] if_end_1;

always @(posedge clk) begin
    if_end_1 <= if_end;
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(cur_length[wr_p1] == 1) begin
            if_end[wr_p1] <= 1;
        end else begin
            if_end[wr_p1] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(batch[wr_p1] == 7 || start_of_packet[wr_p1]) begin
            
            if(start_of_packet[wr_p1]) begin
                wr_op[searching_distribution[wr_p1]] <= 1;
                wr_or[searching_distribution[wr_p1]] <= 1;
                delta_free_space[searching_distribution[wr_p1]] <= ((port_length[wr_p1] - 1) >> 3) + 1;
                delta_page_amount[searching_distribution[wr_p1]] <= ((port_length[wr_p1] - 1) >> 3) + 1;
                wr_page[wr_p1] <= null_ptr[searching_distribution[wr_p1]];
                wr_port[searching_distribution[wr_p1]] <= port_dest_port[wr_p1];
            end else begin
                //wr_op[distribution[wr_p1]] <= (cur_length[wr_p1] > 1);
                wr_or[distribution[wr_p1]] <= (cur_length[wr_p1] > 1);
                wr_page[wr_p1] <= null_ptr[distribution[wr_p1]];
                //wr_port[distribution[wr_p1]] <= cur_dest_port[wr_p1];
            end
            //$display("start_of_packet[wr_p1] = %d",start_of_packet[wr_p1]);
            if(cur_length[wr_p1] > 0) begin
                jt_wr_en[distribution[wr_p1]] <= 1;
                jt_wr_addr[distribution[wr_p1]] <= wr_page[wr_p1];
                jt_din[distribution[wr_p1]] <= null_ptr[distribution[wr_p1]];
            end
            //$display("cur_length[wr_p1] = %d",cur_length[wr_p1]);
            if(cur_length[wr_p1] <= 7) begin
                packet_tail_addr[wr_p1] <= {distribution[wr_p1],null_ptr[distribution[wr_p1]]};
                $display("n ull_ptr[distribution[wr_p1]] = %d",null_ptr[distribution[wr_p1]]);
            end
        end else if(cur_length[wr_p1] > 0 || if_end[wr_p1] == 1) begin
            wr_op[distribution[wr_p1]] <= 0;
            wr_or[distribution[wr_p1]] <= 0;
            jt_wr_en[distribution[wr_p1]] <= 0;
        end
    end
end

reg [15:0][4:0] cnt_tem;

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(port_data_vld[wr_p1] == 1) begin
            batch[wr_p1] <= batch[wr_p1] + 1;
            sram_wr_en[distribution[wr_p1]] <= 1;
            sram_wr_addr[distribution[wr_p1]] <= {wr_page[wr_p1], batch[wr_p1]};
            sram_din[distribution[wr_p1]] <= port_data[wr_p1];
            cur_length[wr_p1] <= cur_length[wr_p1] - 1;
            $display("port_data[wr_p1] = %d",port_data[wr_p1]);
            $display("distribution[wr_p1] = %d, %d",distribution[wr_p1],wr_p1);
            $display("wr_page[wr_p1] = %d",wr_page[wr_p1]);
            $display("batch[wr_p1] = %d",batch[wr_p1]);
            $display("locking[distribution[wr_p1]] = %d",locking[distribution[wr_p1]]);
            $display("sram_wr_en[distribution[wr_p1]] = %d",sram_wr_en[distribution[wr_p1]]);
            
        end else if(cur_length[wr_p1] == 1) begin
            $display("cur_length[wr_p1] = %d",cur_length[wr_p1]);
            cur_length[wr_p1] <= 0;
        end else if(if_end[wr_p1] == 1)begin
            sram_wr_en[distribution[wr_p1]] <= 0;   
            last_queue[wr_p1] <= {cur_dest_port[wr_p1], cur_prior[wr_p1]};
            last_distribution[wr_p1] <= distribution[wr_p1];
            sram_wr_en[distribution[wr_p1]] <= 0;
            packet_en[wr_p1] <= 1;
            if(searching_distribution[wr_p1] != distribution[wr_p1])
                locking[distribution[wr_p1]] <= 0;
            $display("d i stribution[wr_p1] = %d, %d",distribution[wr_p1],wr_p1);
            batch[wr_p1] <= 0;
            cnt_tem[wr_p1] <= cnt + (1 - (cnt & 1));
            //search_get[wr_p1] <= 0;
        end else if(cnt_tem[wr_p1] == cnt && !if_end_1[wr_p1]) begin
            packet_en[wr_p1] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(port_data_vld[wr_p1] == 1) begin
            case(batch[wr_p1]) 
                3'b000 : ecc_encoder_data_0[wr_p1] <= port_data[wr_p1];
                3'b001 : ecc_encoder_data_1[wr_p1] <= port_data[wr_p1];
                3'b010 : ecc_encoder_data_2[wr_p1] <= port_data[wr_p1];
                3'b011 : ecc_encoder_data_3[wr_p1] <= port_data[wr_p1];
                3'b100 : ecc_encoder_data_4[wr_p1] <= port_data[wr_p1];
                3'b101 : ecc_encoder_data_5[wr_p1] <= port_data[wr_p1];
                3'b110 : ecc_encoder_data_6[wr_p1] <= port_data[wr_p1];
                3'b111 : ecc_encoder_data_7[wr_p1] <= port_data[wr_p1];
            endcase
        end else
            ecc_encoder_data_0[wr_p1] <= 0;
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(port_data_vld[wr_p1] == 1) begin
            if(batch[wr_p1] == 0) begin
                ecc_encoder_data_1[wr_p1] <= 0;
                ecc_encoder_data_2[wr_p1] <= 0;
                ecc_encoder_data_3[wr_p1] <= 0;
                ecc_encoder_data_4[wr_p1] <= 0;
                ecc_encoder_data_5[wr_p1] <= 0;
                ecc_encoder_data_6[wr_p1] <= 0;
                ecc_encoder_data_7[wr_p1] <= 0;
            end
        end
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(port_data_vld[wr_p1] == 1 && (batch[wr_p1] == 7 || cur_length[wr_p1] == 1)) begin
            ecc_encoder_enable[wr_p1] <= 1;
        end else begin
            ecc_encoder_enable[wr_p1] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(ecc_encoder_enable[wr_p1] == 1) begin
            ecc_wr_en[distribution[wr_p1]] <= 1;
            ecc_wr_addr[distribution[wr_p1]] <= wr_page[wr_p1];
            ecc_din[distribution[wr_p1]] <= ecc_encoder_code[wr_p1];
        end else begin
            ecc_wr_en[distribution[wr_p1]] <= 0;
        end
    end
end

always @(posedge clk) begin
    if(packet_en[cnt >> 1] && !(if_end_1[cnt >> 1] && cnt % 2 != 0)) begin
        if(cnt % 2 == 0) begin
            jt_wr_en[queue_tail_sram[last_queue[cnt >> 1]]] <= 1;
            jt_wr_addr[queue_tail_sram[last_queue[cnt >> 1]]] <= queue_tail_page[last_queue[cnt >> 1]];
            jt_din[queue_tail_sram[last_queue[cnt >> 1]]] <= packet_head_addr[cnt >> 1];

            $display("queue_tail_sram[last_queue[cnt >> 1]] = %d",queue_tail_sram[last_queue[cnt >> 1]]);
            $display("last_queue[cnt >> 1] = %d",last_queue[cnt >> 1]);
        end else begin
            jt_wr_en[queue_tail_sram[last_queue[cnt >> 1]]] <= 0;
            queue_tail_sram[last_queue[cnt >> 1]] <= packet_tail_addr[cnt >> 1][15:11];
            queue_tail_page[last_queue[cnt >> 1]] <= packet_tail_addr[cnt >> 1][10:0];
            $display("packet_tail_addr[%d] = %d",cnt >> 1,packet_tail_addr[cnt >> 1]);
        end
    end
end
reg [4:0] queue_head_sram [127:0];
reg [10:0] queue_head_page [127:0];
reg [4:0] queue_tail_sram [127:0];
reg [10:0] queue_tail_page [127:0];
reg [7:0] queue_not_empty [15:0];

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(queue_tail_page[p] == queue_head_page[p] && queue_tail_sram[p] == queue_tail_sram[p]) begin
            queue_not_empty[p] <= 0;
        end else begin
            queue_not_empty[p] <= 1;
        end
    end
end

wire [15:0] [3:0] port_dest_port;
wire [15:0] [2:0] port_prior;
wire [15:0] [8:0] port_length;
wire [15:0] port_data_vld;
wire [15:0] [15:0] port_data;
wire [15:0] start_of_packet;
wire [15:0] port_new_packet;

port port [15:0]
(
    .clk(clk),

    .wr_sop(wr_sop),
    .wr_eop(wr_eop),
    .wr_vld(wr_vld),
    .wr_data(wr_data),

    .dest_port(port_dest_port),
    .prior(port_prior),
    .length(port_length),
    .data_vld(port_data_vld),
    .data(port_data),
    .start_of_packet(start_of_packet),
    .new_packet(port_new_packet)
);

reg [15:0] ecc_encoder_enable;
reg [15:0][15:0] ecc_encoder_data_0;
reg [15:0][15:0] ecc_encoder_data_1;
reg [15:0][15:0] ecc_encoder_data_2;
reg [15:0][15:0] ecc_encoder_data_3;
reg [15:0][15:0] ecc_encoder_data_4;
reg [15:0][15:0] ecc_encoder_data_5;
reg [15:0][15:0] ecc_encoder_data_6;
reg [15:0][15:0] ecc_encoder_data_7;
wire [15:0][7:0] ecc_encoder_code;

ecc_encoder ecc_encoder [15:0]
(
    .clk(clk),
    .enable(ecc_encoder_enable),
    .data_0(ecc_encoder_data_0),
    .data_1(ecc_encoder_data_1),
    .data_2(ecc_encoder_data_2),
    .data_3(ecc_encoder_data_3),
    .data_4(ecc_encoder_data_4),
    .data_5(ecc_encoder_data_5),
    .data_6(ecc_encoder_data_6),
    .data_7(ecc_encoder_data_7),
    .code(ecc_encoder_code)
);

reg [15:0] ecc_decoder_enable;
reg [15:0][15:0] ecc_decoder_data_0;
reg [15:0][15:0] ecc_decoder_data_1;
reg [15:0][15:0] ecc_decoder_data_2;
reg [15:0][15:0] ecc_decoder_data_3;
reg [15:0][15:0] ecc_decoder_data_4;
reg [15:0][15:0] ecc_decoder_data_5;
reg [15:0][15:0] ecc_decoder_data_6;
reg [15:0][15:0] ecc_decoder_data_7;
reg [15:0][7:0] ecc_decoder_code;
wire [15:0][15:0] ecc_decoder_cr_data_0;
wire [15:0][15:0] ecc_decoder_cr_data_1;
wire [15:0][15:0] ecc_decoder_cr_data_2;
wire [15:0][15:0] ecc_decoder_cr_data_3;
wire [15:0][15:0] ecc_decoder_cr_data_4;
wire [15:0][15:0] ecc_decoder_cr_data_5;
wire [15:0][15:0] ecc_decoder_cr_data_6;
wire [15:0][15:0] ecc_decoder_cr_data_7;

ecc_decoder ecc_decoder [15:0]
(
    .enable(ecc_decoder_enable),
    .data_0(ecc_encoder_data_0),
    .data_1(ecc_encoder_data_1),
    .data_2(ecc_encoder_data_2),
    .data_3(ecc_encoder_data_3),
    .data_4(ecc_encoder_data_4),
    .data_5(ecc_encoder_data_5),
    .data_6(ecc_encoder_data_6),
    .data_7(ecc_encoder_data_7),
    .code(ecc_decoder_code),
    .cr_data_0(ecc_decoder_cr_data_0),
    .cr_data_1(ecc_decoder_cr_data_1),
    .cr_data_2(ecc_decoder_cr_data_2),
    .cr_data_3(ecc_decoder_cr_data_3),
    .cr_data_4(ecc_decoder_cr_data_4),
    .cr_data_5(ecc_decoder_cr_data_5),
    .cr_data_6(ecc_decoder_cr_data_6),
    .cr_data_7(ecc_decoder_cr_data_7)
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

reg [31:0] jt_wr_en;
reg [31:0][10:0] jt_wr_addr;
reg [31:0][15:0] jt_din;

reg [31:0]jt_rd_en;
reg [31:0][10:0] jt_rd_addr;
wire [31:0][15:0] jt_dout;

reg [31:0]wr_op;
reg [31:0][3:0] wr_port;
reg [31:0]rd_op;
reg [31:0][3:0] rd_port;
reg [31:0][10:0] rd_addr;

reg [31:0][3:0] request_port;
wire [31:0][10:0] page_amount;

wire [31:0][10:0] null_ptr;
wire [31:0][10:0] free_space;

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

    .jt_wr_en(jt_wr_en),
    .jt_wr_addr(jt_wr_addr),
    .jt_din(jt_din),
    .jt_rd_en(jt_rd_en),
    .jt_rd_addr(jt_rd_addr),
    .jt_dout(jt_dout),

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