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

reg [4:0] cnt = 0;
always @(posedge clk) begin
    cnt <= cnt + 1;
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

reg [4:0] searching_sram_index [15:0];
reg [4:0] searching_distribution [15:0];
reg [10:0] max_amount [15:0];
reg [5:0] search_cnt [15:0];
reg searching [15:0];

reg [3:0] cur_dest_port [15:0];
reg [2:0] cur_prior [15:0];
reg [8:0] cur_length [15:0];
reg [4:0] cur_distribution [15:0];

reg packet_over [15:0];
reg packet_not_over [15:0];
reg [15:0] packet_head_addr [15:0];
reg [15:0] packet_tail_addr [15:0];
reg [8:0] packet_length [15:0];
reg [2:0] packet_batch [15:0];

reg [10:0] wr_page [15:0];

reg ecc_result [15:0];
reg [4:0] ecc_sram [15:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    always @(posedge clk) begin
        full[port] <= (locking | much_space) == 0;
    end

    always @(posedge clk) begin
        searching_sram_index[port] <= (cnt + port) % 32;
        request_port[(cnt + port) % 32] <= port_dest_port[port];
    end

    always @(posedge clk) begin
        if(port_new_packet[port] == 1) begin
            searching[port] <= 1;
        end else if(search_cnt[port] == 31) begin
            searching[port] <= 0;
        end
    end

    always @(posedge clk) begin
        if(searching[port] == 1) begin
            search_cnt[port] <= search_cnt[port] + 1;
        end else begin
            search_cnt[port] <= 0;
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_dest_port[port] <= port_dest_port[port];
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_prior[port] <= port_prior[port];
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_length[port] <= port_length[port];
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_distribution[port] <= searching_distribution[port];
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            search_get[port] <= 0;
        end else begin
            //搜到了置1
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            search_cnt[port] <= 0;
        end else begin
            search_cnt[port] <= search_cnt[port] + 1;
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_head_addr[port] <= null_ptr[cur_distribution[port]];
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_batch[port] <= 1;
        end else begin
            packet_batch[port] <= packet_batch[port] + 1;
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_length[port] <= 1;
        end else if(port_data_vld[port]) begin
            packet_length[port] <= packet_length[port] + 1;
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_not_over[port] <= 1;
        end else if(packet_length[port] == cur_length[port] - 1) begin
            packet_not_over[port] <= 0;
        end
    end

    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_over[port] <= 0;
        end else if(packet_length[port] == cur_length[port] - 1) begin
            packet_over[port] <= 1;
        end
    end

    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0) begin
            jt_wr_en[cur_distribution[port]] <= 1;
        end else if(packet_not_over[port]) begin
            jt_wr_en[cur_distribution[port]] <= 0;
        end
    end

    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0) begin
            jt_wr_addr[cur_distribution[port]] <= wr_last_page[port];
        end
    end
    
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0) begin
            jt_wr_din[cur_distribution[port]] <= wr_page[port];
        end
    end
    
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0) begin
            packet_tail_addr[port] <= wr_page[port];
        end
    end

    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7) begin
            wr_last_page[port] <= wr_page[port];
        end
    end

    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7) begin
            wr_page[port] <= null_ptr[cur_distribution[port]];
        end else if(search_cnt[port] == 32) begin
            wr_page[port] <= null_ptr[cur_distribution[port]];
        end
    end

    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 0) begin
            wr_op[cur_distribution[port]] <= 1;
        end else if(packet_not_over[port]) begin
            wr_op[cur_distribution[port]] <= 0;
        end
    end

    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_wr_addr[port] <= {wr_page[port], packet_batch[port]};
        end 
    end

    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_wr_en[cur_distribution[port]] <= 1;
        end else if(packet_not_over[port]) begin
            sram_wr_en[cur_distribution[port]] <= 0;
        end
    end

    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_din[cur_distribution[port]] <= port_data[port];
        end
    end

    always @(posedge clk) begin
        if((port_data_vld[port] && packet_batch[port] == 7)||
            packet_length[port] == packet_length[port] - 1) begin
            ecc_encoder_enable[port] <= 1;
        end else begin
            ecc_encoder_enable[port] <= 0;
        end
    end

    always @(posedge clk) begin
        if((port_data_vld[port] && packet_batch[port] == 7)||
            packet_length[port] == packet_length[port] - 1) begin
            ecc_encoder_enable[port] <= 1;
        end else begin
            ecc_encoder_enable[port] <= 0;
        end
    end

    always @(posedge clk) begin
        if((port_data_vld[port] && packet_batch[port] == 7)||
            packet_length[port] == packet_length[port] - 1) begin
            ecc_sram[port] <= cur_distribution[port];
        end else begin
            ecc_sram[port] <= cur_distribution[port];
        end
    end

    always @(posedge clk) begin
        if(ecc_encoder_enable[port] == 1) begin
            ecc_result <= 1;
        end else if(packet_batch[port] == 2) begin
            ecc_result <= 0;
        end
    end

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

    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_din[cur_distribution[port]] <= port_data[port];
        end
    end

    always @(posedge clk) begin
        if(searching[port]) begin
            sram_addr[cur_distribution[port]] <= port_addr[port];
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