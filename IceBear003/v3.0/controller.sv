`include "./IceBear003/v3.0/sram_state.sv"
`include "./IceBear003/v3.0/sram.sv"
`include "./IceBear003/v3.0/ecc_encoder.sv"
`include "./IceBear003/v3.0/ecc_decoder.sv"
`include "./IceBear003/v3.0/port.sv"

module controller(
    input clk,
    input rst_n,

    //Config
    input wrr_en,

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

reg [15:0] new_packet = 0;
reg [15:0] searching = 0;

reg [4:0] cnt = 0;
reg [15:0][4:0] searching_sram_index;

always @(posedge clk) begin
    cnt <= cnt + 1;
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        searching_sram_index[wr_p1] <= (cnt + wr_p1) % 32;
        request_port[(cnt + wr_p1) % 32] <= cur_dest_port[wr_p1];
    end
end

integer wr_p1;
always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(new_packet[wr_p1] == 1) begin
            searching[wr_p1] <= 1;
        end
    end
end

reg [15:0][6:0] last_queue = 0;
reg [15:0][3:0] cur_dest_port = 0;
reg [15:0][2:0] cur_prior = 0;
reg [15:0][8:0] cur_length = 0;

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(start_of_packet[wr_p1] == 1) begin
            cur_dest_port[wr_p1] <= port_dest_port[wr_p1];
            cur_prior[wr_p1] <= port_prior[wr_p1];
            cur_length[wr_p1] <= port_length[wr_p1];
            distribution[wr_p1] <= searching_distribution[wr_p1];
        end
    end
end

reg [31:0] locking;
reg [15:0][10:0] max_amount;
reg [15:0][4:0] searching_distribution;
reg [15:0][4:0] distribution;
reg [15:0][10:0] wr_page;

reg [15:0][15:0] packet_en;
reg [15:0][15:0] packet_head_addr;
reg [15:0][15:0] packet_tail_addr;

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if((new_packet[wr_p1] == 1 || searching[wr_p1] == 1) 
            && !locking[searching_sram_index[wr_p1]]) begin
            if(page_amount[searching_sram_index[wr_p1]] >= max_amount[wr_p1]) begin
                //EXCHANGE
                max_amount[wr_p1] <= page_amount[searching_sram_index[cur_dest_port[wr_p1]]];
                searching_distribution[wr_p1] <= searching_sram_index[wr_p1];
                //LOCK UNLOCK
                locking[searching_distribution[wr_p1]] <= 0;
                locking[searching_sram_index[wr_p1]] <= 1;
                //PAGE LOAD
                wr_page[wr_p1] <= null_ptr[searching_sram_index[wr_p1]];
            end
        end
    end
end

reg [15:0][2:0] batch = 0;

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(batch[wr_p1] == 7 || start_of_packet[wr_p1]) begin
            wr_page[wr_p1] <= null_ptr[distribution[wr_p1]];
            wr_op[distribution[wr_p1]] <= cur_length[wr_p1] > 1;
            if(cur_length[wr_p1] != 1) begin
                jt_wr_en[distribution[wr_p1]] <= 1;
                jt_wr_addr[distribution[wr_p1]] <= wr_page[wr_p1];
                jt_din[distribution[wr_p1]] <= null_ptr[distribution[wr_p1]];
            end
            if(cur_length[wr_p1] <= 8) begin
                packet_tail_addr[wr_p1] <= null_ptr[distribution[wr_p1]];
            end
        end else begin
            wr_op[distribution[wr_p1]] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(wr_p1 = 0; wr_p1 < 16; wr_p1 = wr_p1 + 1) begin
        if(port_data_vld[wr_p1] == 1) begin
            batch[wr_p1] <= batch[wr_p1] + 1;
            sram_wr_en[distribution[wr_p1]] <= 1;
            sram_wr_addr[distribution[wr_p1]] <= {wr_page[wr_p1], batch[wr_p1]};
            sram_din[distribution[wr_p1]] <= port_data[wr_p1];
            cur_length[wr_p1] <= cur_length[wr_p1] - 1;
        end else if(cur_length[wr_p1] > 0) begin
            sram_wr_en[distribution[wr_p1]] <= 0;
        end else begin
            last_queue[wr_p1] <= {cur_dest_port[wr_p1], cur_prior[wr_p1]};
            packet_en[wr_p1] <= 1;
            locking[distribution[wr_p1]] <= 0;
            batch[wr_p1] <= 0;
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
        end
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
    if(packet_en[cnt >> 1]) begin
        if(cnt % 2 == 0) begin
            jt_wr_en[queue_tail_sram[last_queue[wr_p1]]] <= 1;
            jt_wr_addr[queue_tail_sram[last_queue[wr_p1]]] <= queue_tail_page[last_queue[wr_p1]];
            jt_din[queue_tail_sram[last_queue[wr_p1]]] <= packet_head_addr[wr_p1];
        end else begin
            queue_tail_sram[cnt >> 1] <= packet_tail_addr[15:11];
            queue_tail_page[cnt >> 1] <= packet_tail_addr[10:0];
        end
    end
end

//Read Mechanism

integer p,s;

reg wrr_next [15:0];
reg [7:0] wrr_mask [15:0];
reg [2:0] mask_e [15:0];
reg [2:0] mask_s [15:0];

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

//updated every clk
reg [7:0] port_queue_waiting [15:0];
reg [2:0] port_priority_reading [15:0];

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

//turn on right after "ready"
reg ready_delay [15:0];

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        rd_sop[p] <= ready[p] == 1 && port_queue_waiting[p] != 0;
    end
end

reg [15:0] sram_read_request [31:0];
//Use to disable request after finishing read packet
reg [5:0] port_read_packet_over [15:0];

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(rd_sop[p] == 1) begin
            sram_read_request[queue_head_sram[{p,port_priority_reading[p]}]][p] <= 1;
        end
        if(port_read_packet_over[p][5] == 1) begin
            sram_read_request[port_read_packet_over[p][4:0]][p] <= 0;
        end
    end
end

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        rd_eop[p] <= port_read_packet_over[p][5];
    end
end

always @(posedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        wrr_next[p] <= port_read_packet_over[p][5];
    end
end

reg [3:0] handshake_reset [15:0];
reg [2:0] handshake [15:0];
reg [2:0] rd_batch [15:0];

//reset batch at page beginning
always @(negedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(handshake_reset[p] == 0) begin
            rd_batch[p] <= 0;
        end else if(handshake[p] != rd_batch[p]) begin
            rd_batch[p] <= rd_batch[p] + 1;
        end
    end
end

always @(negedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(handshake_reset[p] == 0 || handshake[p] != rd_batch[p]) begin
            rd_vld[p] <= 1;
        end else begin
            rd_vld[p] <= 0;
        end
    end
end

always @(negedge clk) begin
    for(p = 0; p < 16; p = p + 1) begin
        if(handshake_reset[p] == 0 || handshake[p] != rd_batch[p]) begin
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

reg sram_read_request_next [31:0];
reg [3:0] sram_read_request_mask_e [31:0];
reg [15:0] sram_read_request_mask [31:0];
reg [15:0] sram_read_request_masked [31:0];

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

reg [3:0] sram_reading_request [31:0];
reg sram_reading [31:0];

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

reg [10:0] sram_rd_page[31:0];
reg [2:0] sram_rd_batch[31:0];
reg sram_got_data[31:0];

always @(posedge clk) begin
    for(s = 0; s < 32; s = s + 1) begin
        if(sram_read_request_masked[s] != 0 && sram_reading[s] == 0) begin
            sram_reading[s] <= 1;
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

reg [4:0] queue_head_sram [127:0];
reg [10:0] queue_head_page [127:0];
reg [4:0] queue_tail_sram [127:0];
reg [10:0] queue_tail_page [127:0];
reg [7:0] queue_not_empty [15:0];

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