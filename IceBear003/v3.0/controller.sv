`include "./IceBear003/v3.0/sram_state.sv"
`include "./IceBear003/v3.0/sram.sv"
`include "./IceBear003/v3.0/ecc_encoder.sv"
`include "./IceBear003/v3.0/ecc_decoder.sv"
`include "./IceBear003/v3.0/port.sv"

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
reg [15:0][4:0] last_distribution = 0;
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
// reg [15:0][10:0] last_wr_page;
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
            wr_op[distribution[wr_p1]] <= cur_length[wr_p1] > 0;
            if(cur_length[wr_p1] > 7) begin

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
            last_distribution[wr_p1] <= distribution[wr_p1];
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

reg [15:0][6:0] processing_priority; //negedge update
reg [15:0] sop_trigger; //negedge update | need reset

reg [7:0] wrr_mask = 8'hFF;
reg [2:0] mask_s = 7;
reg [2:0] mask_e = 0;
always @(negedge clk) begin
    mask_e <= mask_e + 1;
    if(mask_e == mask_s) begin
        if(mask_s == 0) begin
            wrr_mask <= 8'hFF;
            mask_s <= 7;
        end else begin
            wrr_mask[mask_e] <= 0;
            mask_s <= mask_s - 1;
        end
        mask_e <= 0;
    end
end

integer p1;
always @(negedge clk) begin
    for(p1 = 0; p1 < 16; p1 = p1 + 1) begin
        if(ready[p1] == 1 && sop_trigger[p1] == 0) begin
            if(queue_empty[p1] & wrr_mask != 0) begin
                casex (queue_empty[p1] & wrr_mask)
                    8'b1xxxxxxx: processing_priority[p1] <= {p1, 3'd0};
                    8'b01xxxxxx: processing_priority[p1] <= {p1, 3'd1};
                    8'b001xxxxx: processing_priority[p1] <= {p1, 3'd2};
                    8'b0001xxxx: processing_priority[p1] <= {p1, 3'd3};
                    8'b00001xxx: processing_priority[p1] <= {p1, 3'd4};
                    8'b000001xx: processing_priority[p1] <= {p1, 3'd5};
                    8'b0000001x: processing_priority[p1] <= {p1, 3'd6};
                    8'b00000001: processing_priority[p1] <= {p1, 3'd7};
                endcase
            end else begin
                casex (queue_empty[p1])
                    8'b1xxxxxxx: processing_priority[p1] <= {p1, 3'd0};
                    8'b01xxxxxx: processing_priority[p1] <= {p1, 3'd1};
                    8'b001xxxxx: processing_priority[p1] <= {p1, 3'd2};
                    8'b0001xxxx: processing_priority[p1] <= {p1, 3'd3};
                    8'b00001xxx: processing_priority[p1] <= {p1, 3'd4};
                    8'b000001xx: processing_priority[p1] <= {p1, 3'd5};
                    8'b0000001x: processing_priority[p1] <= {p1, 3'd6};
                    8'b00000001: processing_priority[p1] <= {p1, 3'd7};
                endcase
            end
            sop_trigger[p1] <= queue_empty[p1] == 0;
        end
    end
end

// reg [15:0][4:0] processing_sram; //posedge update
// reg [15:0][10:0] processing_page; //posedge update
// reg [31:0][15:0] requesting_port; //nededge update | need reset

// integer p2;
// always @(posedge clk) begin
//     for(p2 = 0; p2 < 16; p2 = p2 + 1) begin
//         if(sop_trigger[p2]) begin
//             processing_sram[p2] <= queue_head[processing_priority[p2]] >> 11;
//             processing_page[p2] <= queue_head[processing_priority[p2]];
//             queue_head[processing_priority[p2]] <= jump_table[queue_head[processing_priority[p2]]];
//             rd_sop[p2] <= 1;
//         end
//         if(reading_packet_batch[p2] == 7) begin
//             processing_page[p2] <= queue_head[processing_priority[p2]];
//             queue_head[processing_priority[p2]] <= jump_table[queue_head[processing_priority[p2]]];
//         end
//     end
// end

// integer p3;
// always @(negedge clk) begin
//     for(p3 = 0; p3 < 16; p3 = p3 + 1) begin
//         if(sop_trigger[p3]) begin
//             requesting_port[processing_sram[p3]] <= 
//                 (16'b1 << p3) | requesting_port[processing_sram[p3]];
//             sop_trigger[p3] <= 0;
//         end
//     end
// end

// reg [31:0][3:0] processing_port; //posedge update
// reg [31:0] reading_starting_batches; //posedge update
// reg [15:0][2:0] reading_packet_batch;
// reg [15:0][8:0] reading_packet_length;

// reg [15:0] sending_trigger;

// integer s1;
// always @(posedge clk) begin
//     for(s1 = 0; s1 < 32; s1 = s1 + 1) begin
//         if(requesting_port[s1] != 0) begin
//             casex (requesting_port[s1]) 
//                 16'b1xxxxxxxxxxxxxxx: processing_port[s1] <= 4'h0;
//                 16'b01xxxxxxxxxxxxxx: processing_port[s1] <= 4'h1;
//                 16'b001xxxxxxxxxxxxx: processing_port[s1] <= 4'h2;
//                 16'b0001xxxxxxxxxxxx: processing_port[s1] <= 4'h3;
//                 16'b00001xxxxxxxxxxx: processing_port[s1] <= 4'h4;
//                 16'b000001xxxxxxxxxx: processing_port[s1] <= 4'h5;
//                 16'b0000001xxxxxxxxx: processing_port[s1] <= 4'h6;
//                 16'b00000001xxxxxxxx: processing_port[s1] <= 4'h7;
//                 16'b000000001xxxxxxx: processing_port[s1] <= 4'h8;
//                 16'b0000000001xxxxxx: processing_port[s1] <= 4'h9;
//                 16'b00000000001xxxxx: processing_port[s1] <= 4'ha;
//                 16'b000000000001xxxx: processing_port[s1] <= 4'hb;
//                 16'b0000000000001xxx: processing_port[s1] <= 4'hc;
//                 16'b00000000000001xx: processing_port[s1] <= 4'hd;
//                 16'b000000000000001x: processing_port[s1] <= 4'he;
//                 16'b0000000000000001: processing_port[s1] <= 4'hf;
//             endcase
//             reading_starting_batches[s1] <= 1;
//             sram_rd_en <= 1;
//             sram_rd_addr <= {processing_page[processing_port[s1]], 3'b000};
//         end
//         if(reading_starting_batches[s1] == 1 || reading_packet_length[s1] > 8) begin
//             reading_packet_batch[s1] <= reading_packet_batch[s1] + 1;
//             rd_buffer[processing_port[s1]] <= rd_buffer[processing_port[s1]] << 16 + sram_dout[s1];
//             if(reading_packet_batch[s1] == 7) begin
//                 ecc_decoder_enable[processing_port[s1]] <= 1;
//                 reading_starting_batches[s1] <= 0;
//                 sending_trigger[s1] <= 1;
//             end else begin
//                 ecc_decoder_enable[processing_port[s1]] <= 0;
//             end
//         end else if (reading_packet_batch[s1] > 0) begin
//             requesting_port[s1] <= requesting_port[s1] & ~(1 << processing_port[s1]);
//         end else begin
//             sending_trigger[s1] <= 0;
//         end
//     end
// end

// integer p4;
// always @(posedge clk) begin
//     for(p4 = 0; p4 < 16; p4 = p4 + 1) begin
//         if(sending_trigger[p4] == 1) begin
//             rd_vld[p4] <= 1;
//             if(reading_starting_batches[s1] && reading_packet_batch[s1] == 0) begin
//                 reading_packet_length[s1] <= rd_buffer[p4] - 1;
//             end else begin
//                 reading_packet_length[s1] <= reading_packet_length[s1] - 1;
//                 rd_data[p4] <= rd_buffer[p4];
//             end
//             rd_buffer[p4] <= rd_buffer[p4] >> 16;
//         end else begin
//             if(rd_vld[p4] == 1) begin
//                 rd_eop[p4] <= 1;
//             end
//             rd_vld[p4] <= 0;
//         end
//     end
// end

reg [127:0][4:0] queue_head_sram;
reg [127:0][10:0] queue_head_page;
reg [127:0][4:0] queue_tail_sram;
reg [127:0][10:0] queue_tail_page;
reg [15:0][7:0] queue_empty;

always @(negedge rst_n) begin
    // queue_head = 'b0;
    // queue_tail = 'b0;
    queue_empty = {128{1'b1}};
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
    // .unlock(port_unlock)
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