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

reg [127:0][4:0] queue_head_sram = 0;
reg [127:0][10:0] queue_head_page = 0;
reg [127:0][4:0] queue_tail_sram = 0;
reg [127:0][10:0] queue_tail_page = 0;
reg [15:0][7:0] queue_empty = 0;

wire [15:0] [3:0] port_dest_port;
wire [15:0] [2:0] port_prior;
wire [15:0] [8:0] port_length;
wire [15:0] port_data_vld;
wire [15:0] [15:0] port_data;
wire [15:0] start_of_packet;
wire [15:0] port_new_packet;
wire [15:0] begin_of_packet;

reg [15:0] ecc_encoder_enable = 0;
reg [15:0][15:0] ecc_encoder_data_0 = 0;
reg [15:0][15:0] ecc_encoder_data_1 = 0;
reg [15:0][15:0] ecc_encoder_data_2 = 0;
reg [15:0][15:0] ecc_encoder_data_3 = 0;
reg [15:0][15:0] ecc_encoder_data_4 = 0;
reg [15:0][15:0] ecc_encoder_data_5 = 0;
reg [15:0][15:0] ecc_encoder_data_6 = 0;
reg [15:0][15:0] ecc_encoder_data_7 = 0;
wire [15:0][7:0] ecc_encoder_code;

reg [15:0][127:0] rd_buffer = 0;
reg [15:0][7:0] ecc_decoder_code = 0;
reg [15:0] ecc_decoder_enable = 0;
wire [15:0][127:0] cr_rd_buffer;

reg [31:0] sram_wr_en = 0;
reg [31:0][13:0] sram_wr_addr = 0;
reg [31:0][15:0] sram_din = 0;
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

reg [31:0] accessible = 0;
reg [15:0] search_get = 0;

integer p,s;

reg [15:0]wrr_next = 0 ;
reg [7:0][15:0] wrr_mask = 0 ;
reg [2:0][15:0] mask_e = 0 ;
reg [2:0][15:0] mask_s = 0 ;

//updated every clk
reg [7:0][15:0] port_queue_waiting = 0 ;
reg [2:0][15:0] port_priority_reading = 0 ;

//turn on right after "ready"
reg [15:0]ready_delay = 0 ;

reg [15:0]handshake_reset = 0 ;
reg [2:0][15:0] handshake = 0 ;
reg [2:0][15:0] rd_batch = 0 ;

reg [31:0]sram_read_request_next = 0 ;
reg [3:0][31:0] sram_read_request_mask_e = 0 ;
reg [15:0][31:0] sram_read_request_mask = 0 ;
reg [15:0][31:0] sram_read_request_masked = 0 ;

reg [3:0][31:0] sram_reading_request = 0 ;
reg [31:0]sram_reading = 0;

reg [8:0][15:0] port_reading_packet_length = 0 ;
reg [8:0][15:0] sram_reading_packet_length = 0 ;

reg [7:0][15:0] queue_not_empty = 0;

reg [15:0]end_of_packet = 0;

reg [10:0][31:0] sram_rd_page = 0;
reg [2:0][31:0] sram_rd_batch = 0;
reg [31:0]sram_got_data = 0;

reg [15:0][31:0] sram_read_request = 0;
//Use to disable request after finishing read packet
reg [4:0][15:0] port_reading_sram = 0;

reg [15:0][15:0] ecc_decoder_data_0;
reg [15:0][15:0] ecc_decoder_data_1;
reg [15:0][15:0] ecc_decoder_data_2;
reg [15:0][15:0] ecc_decoder_data_3;
reg [15:0][15:0] ecc_decoder_data_4;
reg [15:0][15:0] ecc_decoder_data_5;
reg [15:0][15:0] ecc_decoder_data_6;
reg [15:0][15:0] ecc_decoder_data_7;
wire [15:0][15:0] ecc_decoder_cr_data_0;
wire [15:0][15:0] ecc_decoder_cr_data_1;
wire [15:0][15:0] ecc_decoder_cr_data_2;
wire [15:0][15:0] ecc_decoder_cr_data_3;
wire [15:0][15:0] ecc_decoder_cr_data_4;
wire [15:0][15:0] ecc_decoder_cr_data_5;
wire [15:0][15:0] ecc_decoder_cr_data_6;
wire [15:0][15:0] ecc_decoder_cr_data_7;

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(start_of_packet[wr_p1] == 1) begin
            search_get[wr_p1] <= 0;
            packet_en[wr_p1] <= 0;
            packet_head_addr[wr_p1] <= {searching_distribution[wr_p1],null_ptr[searching_distribution[wr_p1]]};
            $display("searching_distribution[wr_p1] = %d, %d",searching_distribution[wr_p1],wr_p1);
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
                max_amount[wr_p1] <= page_amount[searching_sram_index[wr_p1]];
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
                max_amount[wr_p1] <= 0;
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
//update queue_not_empty
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

//Read Mechanism

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(wrr_next[p]) begin
            if(mask_s[p] + mask_e[p] == 7 && mask_e[p] != 7) begin
                mask_e[p] <= mask_e[p] + 1;
                mask_s[p] <= 0;
            end else if(mask_e[p] == 7) begin
                mask_e[p] <= 0;
                mask_s[p] <= 0;
            end else begin 
                mask_s[p] <= mask_s[p] + 1;
            end
        end
    end
end

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(wrr_next[p]) begin
            if(mask_s[p] + mask_e[p] == 7 && mask_e[p] != 7) begin
                wrr_mask[p] <= 8'hFF << mask_e[p];
            end else if(mask_e[p] == 7) begin
                wrr_mask[p] <= 8'hFF;
            end else begin 
                wrr_mask[p][mask_s[p]] <= 0;
            end
        end
    end
end

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(wrr_en == 1 && queue_not_empty[p] & wrr_mask[p] != 0) begin
            port_queue_waiting[p] <= queue_not_empty[p] & wrr_mask[p];
        end else begin
            port_queue_waiting[p] <= queue_not_empty[p];
        end
    end
end

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(ready[p] == 1) begin
            casex(port_queue_waiting[p])
                8'bxxxxxxx1: port_priority_reading[p] <= 3'd0;
                8'bxxxxxx10: port_priority_reading[p] <= 3'd1;
                8'bxxxxx100: port_priority_reading[p] <= 3'd2;
                8'bxxxx1000: port_priority_reading[p] <= 3'd3;
                8'bxxx10000: port_priority_reading[p] <= 3'd4;
                8'bxx100000: port_priority_reading[p] <= 3'd5;
                8'bx1000000: port_priority_reading[p] <= 3'd6;
                8'b10000000: port_priority_reading[p] <= 3'd7;
                default: begin end
            endcase
        end
    end
end

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        rd_sop[p] <= ready[p] == 1 && port_queue_waiting[p] != 0;
    end
end

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(rd_sop[p] == 1) begin
            sram_read_request[queue_head_sram[{p,port_priority_reading[p]}]][p] <= 1;
            port_reading_sram[p] <= queue_head_sram[{p,port_priority_reading[p]}];
        end
        if(end_of_packet[p] == 1) begin
            sram_read_request[port_reading_sram[p]][p] <= 0;
        end
    end
end

//reset batch at page beginning
always @(negedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(handshake_reset[p] == 1) begin
            rd_batch[p] <= 0;
        end else if(handshake[p] != rd_batch[p]) begin
            rd_batch[p] <= rd_batch[p] + 1;
        end
    end
end

always @(negedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(handshake[p] != rd_batch[p] + 1) begin
            rd_vld[p] <= 1;
        end else begin
            rd_vld[p] <= 0;
        end
    end
end

always @(negedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(handshake[p] != rd_batch[p] + 1) begin
            case(rd_batch[p])
                3'd0: rd_data[p] <= ecc_decoder_cr_data_0[p];
                3'd1: rd_data[p] <= ecc_decoder_cr_data_1[p];
                3'd2: rd_data[p] <= ecc_decoder_cr_data_2[p];
                3'd3: rd_data[p] <= ecc_decoder_cr_data_3[p];
                3'd4: rd_data[p] <= ecc_decoder_cr_data_4[p];
                3'd5: rd_data[p] <= ecc_decoder_cr_data_5[p];
                3'd6: rd_data[p] <= ecc_decoder_cr_data_6[p];
                3'd7: rd_data[p] <= ecc_decoder_cr_data_7[p];
            endcase
        end
    end
end

always @(negedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(handshake[p] == rd_batch[p] + 1 && end_of_packet[p]) begin   //end of packet多周期触发 fixme
            rd_eop[p] <= 1;
        end else begin
            rd_eop[p] <= 0;
        end
    end
end

always @(negedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(handshake[p] == rd_batch[p] + 1 && end_of_packet[p]) begin
            wrr_next[p] <= 1;
        end else begin
            wrr_next[p] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_read_request_next[s]) begin
            sram_read_request_mask_e[s] = sram_read_request_mask_e[s] + 1;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_read_request_next[s]) begin
            if(sram_read_request_mask_e[s] == 15) begin
                sram_read_request_mask[s] <= 16'hFFFF;
            end else begin
                sram_read_request_mask[s][sram_read_request_mask_e[s]] <= 0;
            end
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_read_request_next[s]) begin
            if(sram_read_request_mask[s] & sram_read_request[s] != 0) begin
                sram_read_request_masked[s] <= sram_read_request_mask[s] & sram_read_request[s];
            end else begin
                sram_read_request_masked[s] <= sram_read_request[s];
            end
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_read_request_masked[s] != 0 && sram_reading[s] == 0) begin
            casex(sram_read_request_masked[s]) 
                16'bxxxxxxxxxxxxxxx1: sram_reading_request[s] <= 4'h0;
                16'bxxxxxxxxxxxxxx10: sram_reading_request[s] <= 4'h1;
                16'bxxxxxxxxxxxxx100: sram_reading_request[s] <= 4'h2;
                16'bxxxxxxxxxxxx1000: sram_reading_request[s] <= 4'h3;
                16'bxxxxxxxxxxx10000: sram_reading_request[s] <= 4'h4;
                16'bxxxxxxxxxx100000: sram_reading_request[s] <= 4'h5;
                16'bxxxxxxxxx1000000: sram_reading_request[s] <= 4'h6;
                16'bxxxxxxxx10000000: sram_reading_request[s] <= 4'h7;
                16'bxxxxxxx100000000: sram_reading_request[s] <= 4'h8;
                16'bxxxxxx1000000000: sram_reading_request[s] <= 4'h9;
                16'bxxxxx10000000000: sram_reading_request[s] <= 4'ha;
                16'bxxxx100000000000: sram_reading_request[s] <= 4'hb;
                16'bxxx1000000000000: sram_reading_request[s] <= 4'hc;
                16'bxx10000000000000: sram_reading_request[s] <= 4'hd;
                16'bx100000000000000: sram_reading_request[s] <= 4'he;
                16'b1000000000000000: sram_reading_request[s] <= 4'hf;
                default: begin end
            endcase
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_read_request_masked[s] != 0 && sram_reading[s] == 0) begin
            sram_reading[s] <= 1;
            $display("sram = %d",s);
            sram_rd_page[s] <= queue_head_page[sram_reading_request[s]];
        end
        //中途断开，需要重置
        if(sram_rd_batch[s] == 7) begin
            sram_reading[s] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_reading[s] == 1) begin
            sram_got_data[s] <= 1;
        end else begin
            sram_got_data[s] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_reading[s] == 1) begin
            sram_rd_batch[s] <= sram_rd_batch[s] + 1;
        end else begin
            sram_rd_batch[s] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_reading[s] == 1) begin
            sram_rd_en[s] <= 1;
            sram_rd_addr[s] <= {sram_rd_page[s], sram_rd_batch[s]};
        end else begin
            sram_rd_en[s] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_reading[s] == 1 && sram_rd_batch[s] == 0) begin
            jt_rd_en[s] <= 1;
            jt_rd_addr[s] <= sram_rd_page[s];
        end else begin
            jt_rd_en[s] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_reading[s] == 1 && sram_rd_batch[s] == 1 && queue_not_empty[sram_read_request[s]]) begin
            queue_head_sram[sram_read_request[s]] <= jt_dout[s] >> 11;
            queue_head_page[sram_read_request[s]] <= jt_dout[s];
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_got_data[s] == 1) begin
            case(sram_rd_batch[s])
                3'd0: ecc_decoder_data_7[sram_reading_request[s]] <= sram_dout[s];
                3'd1: ecc_decoder_data_0[sram_reading_request[s]] <= sram_dout[s];
                3'd2: ecc_decoder_data_1[sram_reading_request[s]] <= sram_dout[s];
                3'd3: ecc_decoder_data_2[sram_reading_request[s]] <= sram_dout[s];
                3'd4: ecc_decoder_data_3[sram_reading_request[s]] <= sram_dout[s];
                3'd5: ecc_decoder_data_4[sram_reading_request[s]] <= sram_dout[s];
                3'd6: ecc_decoder_data_5[sram_reading_request[s]] <= sram_dout[s];
                3'd7: ecc_decoder_data_6[sram_reading_request[s]] <= sram_dout[s];
            endcase
        end else begin
            sram_rd_en[s] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_got_data[s] == 1 && sram_rd_batch[s] == 0) begin
            ecc_rd_en[s] <= 1;
            ecc_rd_addr[s] <= sram_rd_page[s];
        end else begin
            ecc_rd_en[s] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_got_data[s] == 1 && sram_rd_batch[s] == 1) begin
            ecc_decoder_code[sram_reading_request[s]] <= ecc_dout[s];
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        ecc_decoder_enable[sram_reading_request[s]] <= sram_got_data[s] == 1 && sram_rd_batch[s] == 0;
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_reading[s]) begin
            end_of_packet[sram_reading_request[s]] <= sram_reading_packet_length[sram_reading_request[s]] == port_reading_packet_length[sram_reading_request[s]];
        end else begin
            end_of_packet[sram_reading_request[s]] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(!sram_reading[s]) begin
            handshake_reset[sram_reading_request[s]] <= 0;
        end else if(sram_reading_packet_length[sram_reading_request[s]] == port_reading_packet_length[sram_reading_request[s]]) begin
            handshake_reset[sram_reading_request[s]] <= 1;
            handshake[sram_reading_request[s]] <= sram_rd_batch[s] - 1; //FIXME
        end else if(sram_rd_batch[p] == 0 && sram_got_data[p]) begin
            handshake_reset[sram_reading_request[s]] <= 1;
            handshake[sram_reading_request[s]] <= sram_rd_batch[s] - 1; //FIXME
        end
    end
end

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(queue_tail_page[p] == queue_head_page[p] && queue_tail_sram[p] == queue_tail_sram[p]) begin
            queue_not_empty[p] <= 0;
        end else begin
            queue_not_empty[p] <= 1;
        end
    end
end

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
    .begin_of_packet(begin_of_packet),
    .new_packet(port_new_packet),
    .search_get(search_get)
    // .unlock(port_unlock)
);


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

    .jt_wr_en(jt_wr_en),
    .jt_wr_addr(jt_wr_addr),
    .jt_din(jt_din),
    .jt_rd_en(jt_rd_en),
    .jt_rd_addr(jt_rd_addr),
    .jt_dout(jt_dout),

    .wr_op(wr_op),
    .wr_or(wr_or),
    .wr_port(wr_port),
    .rd_addr(rd_addr),
    .rd_op(rd_op),
    .rd_port(rd_port),

    .request_port(request_port),
    .page_amount(page_amount),

    .null_ptr(null_ptr),
    .free_space(free_space),
    .delta_free_space(delta_free_space),
    .delta_page_amount(delta_page_amount)
);

endmodule