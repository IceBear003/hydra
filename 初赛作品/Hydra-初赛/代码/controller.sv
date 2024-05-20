//`include "./������Ʒ/����/���Ż�/port_frontend.sv"
//`include "./������Ʒ/����/���Ż�/ecc_encoder.sv"
//`include "./������Ʒ/����/���Ż�/ecc_decoder.sv"
//`include "./������Ʒ/����/���Ż�/dual_port_sram.sv"
//`include "./������Ʒ/����/���Ż�/sram_state.sv"

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
    output reg [15:0] [15:0] rd_data
);
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

    reg [31:0] jt_wr_en = 0;
    reg [10:0] jt_wr_addr [31:0];
    reg [15:0] jt_din [31:0];

    reg jt_rd_en [31:0];
    reg [10:0] jt_rd_addr [31:0];
    wire [15:0] jt_dout [31:0];

    reg wr_or [31:0];
    reg wr_op [31:0];
    
    reg [11:0] delta_free_space [31:0];
    reg [11:0] delta_page_amount [31:0];

    reg [3:0] wr_port [31:0];
    reg rd_op [31:0];
    reg [3:0] rd_port [31:0];
    reg [10:0] rd_addr [31:0];

    reg [3:0] request_port [31:0];
    wire [10:0] page_amount [31:0];

    wire [10:0] null_ptr [31:0];
    wire [10:0] free_space [31:0];


reg [4:0] cnt_32 = 0;
always @(posedge clk) begin
    cnt_32 <= cnt_32 + 1;
end
reg [3:0] cnt_16 = 0;
always @(posedge clk) begin
    cnt_16 <= cnt_16 + 1;
end

reg much_space [31:0];
reg locking [31:0];
wire [31:0] much_space_c;
wire [31:0] locking_c;

assign much_space_c = {much_space[31], much_space[30], much_space[29], much_space[28], much_space[27], much_space[26], much_space[25], much_space[24], much_space[23], much_space[22], much_space[21], much_space[20], much_space[19], much_space[18], much_space[17], much_space[16], much_space[15], much_space[14], much_space[13], much_space[12], much_space[11], much_space[10], much_space[9], much_space[8], much_space[7], much_space[6], much_space[5], much_space[4], much_space[3], much_space[2], much_space[1], much_space[0]};
assign locking_c = {locking[31], locking[30], locking[29], locking[28], locking[27], locking[26], locking[25], locking[24], locking[23], locking[22], locking[21], locking[20], locking[19], locking[18], locking[17], locking[16], locking[15], locking[14], locking[13], locking[12], locking[11], locking[10], locking[9], locking[8], locking[7], locking[6], locking[5], locking[4], locking[3], locking[2], locking[1], locking[0]};


//������ؼĴ���
reg [4:0] searching_sram_index [15:0];
reg [4:0] searching_distribution [15:0];
reg [10:0] max_amount [15:0];
reg [5:0] search_cnt [15:0];
reg searching [15:0];

//�־û��Ĵ���
//��ǰ����д��SRAM�����ݰ�
reg [3:0] cur_dest_port [15:0];
reg [2:0] cur_prior [15:0];
reg [8:0] cur_length [15:0];
reg [4:0] cur_distribution [15:0];
reg [4:0] last_distribution [15:0];
//�ϸ���д��SRAM�����ݰ�
reg [2:0] last_dest_queue [15:0];   //Ŀ�Ķ���(3+4)
reg [3:0] last_dest_port [15:0];
reg [10:0] last_page [15:0];        //��д���ҳ��ַ

//���ݰ��Ƿ��Ѿ���������Ҫ�������ĩ�ˣ�ָ������ͷβ��ַ����
reg [15:0] packet_merge = 0;
//���ݰ��ƺ��źţ��ӵ�һ�������͵����һ������д��sram
reg packet_signal_reset[15:0];
//�ϸ����ݰ���ͷβ��ַ(5+11)
reg [15:0] last_packet_head_addr [15:0];
reg [15:0] last_packet_tail_addr [15:0];
//���ݰ���ͷβ��ַ(5+11)
reg [15:0] packet_head_addr [15:0];
reg [15:0] packet_tail_addr [15:0];
//���ݰ��Ѿ�������İ�����
reg [8:0] packet_length [15:0];
//���ݰ����������±�
reg [2:0] packet_batch [15:0];

//�ϴ�д���ҳ��ַ
reg [10:0] wr_last_page [15:0];
//����д���ҳ��ַ
reg [10:0] wr_page [15:0];

//ECC����Ƿ񵽱��洢��ʱ��
//ʵ������ecc_encoder_enable��һ��
reg ecc_result [15:0];
//ECC����洢��SRAM�ı��
//����һ�����ݰ�ĩβҳ��У�飬��洢ʱ�������ݰ��������֮��
//��ʱdistribution�����Ѿ������£�������Ҫ����洢ECCУ����Ŀ��SRAM
reg [4:0] ecc_sram [15:0];

reg [15:0] waiting_ready = 0;

//��ȡ
//�˿����������ĸ�SRAM������
reg [5:0] reading_sram [15:0];
//SRAM���ڴ����ĸ��˿ڵ�����
reg [3:0] processing_request [31:0];
//�˿������ҳ��ַ
reg [10:0] reading_page [15:0];
//�˿�����İ�����
reg [2:0] reading_batch [15:0];
//����׼����ϣ��˿ڿɽ�һ������
reg handshake [31:0];

reg sram_occupy [31:0];

reg [4:0] queue_head_sram [15:0][7:0];
reg [10:0] queue_head_page [15:0][7:0];
reg [4:0] queue_tail_sram [15:0][7:0];
reg [10:0] queue_tail_page [15:0][7:0];
reg [7:0] queue_not_empty [15:0];
reg [31:0][3:0] sram_distribution = 0;

reg [2:0] reading_priority [15:0];

genvar port;
generate for(port = 0; port < 16; port = port + 1) begin : Ports

    //�˿����ڶ�ȡ�ĸ����е����ݰ�
    //��0��7���ȶȵݼ�
    //reg [2:0] reading_priority[port];
    //�˿����ڶ�ȡ�����ݰ���ʣ�೤��(����)
    reg [8:0] reading_packet_length;
    //���������-ҳ��ֹλ
    reg [3:0] output_batch; //�����ʼΪ8+
    //���������-ҳ��ֹλ
    reg [2:0] end_batch;
    //��ǰ���ݰ��Ƿ��Ѿ���ȡ����
    reg packet_length_got;

    

    reg next_packet;
    reg [7:0] wrr_mask;
    reg [2:0] wrr_start;
    reg [2:0] wrr_end;

    reg [7:0] queue_waiting;

    //��SRAM��ȡ�굱ǰҳ�����а���
    //�����������ź�ʱ����ʹ��ECC
    always @(posedge clk) begin
        if(handshake[reading_sram[port]] == 1 && processing_request[reading_sram[port]] == port) begin
            ecc_decoder_enable[port] <= 1;
        end else begin
            ecc_decoder_enable[port] <= 0;
        end
    end

    //��ECC�������е�ʱ���������������
    //����һ�����ڿ�ʼ�ۼ�ֱ����ǰҳ�����һ������
    //batch 0��1��ʱ�򣬷��͵�һ�����֣���һ���ں���Ч��
    always @(posedge clk) begin
        if(!rst_n || rd_eop[port]) begin
            output_batch <= 9;
        end else if(ecc_decoder_enable[port] == 1) begin
            output_batch <= 0;
        end else if(output_batch <= end_batch) begin
            output_batch <= output_batch + 1;
        end
    end

    //����batch���Ͱ���
    always @(posedge clk) begin
        if(!rst_n || rd_eop[port]) begin
            rd_data[port] <= 0;
        end else if(output_batch <= end_batch) begin
            case(output_batch) 
                3'd0: rd_data[port] <= ecc_decoder_cr_data_7[port];
                3'd1: rd_data[port] <= ecc_decoder_cr_data_6[port];
                3'd2: rd_data[port] <= ecc_decoder_cr_data_5[port];
                3'd3: rd_data[port] <= ecc_decoder_cr_data_4[port];
                3'd4: rd_data[port] <= ecc_decoder_cr_data_3[port];
                3'd5: rd_data[port] <= ecc_decoder_cr_data_2[port];
                3'd6: rd_data[port] <= ecc_decoder_cr_data_1[port];
                3'd7: rd_data[port] <= ecc_decoder_cr_data_0[port];
            endcase
        end
    end

    //rd vldʹ�ܣ���output batch�ۼƵ�ҳβ֮����Ϊ0����ʾ����������
    always @(posedge clk) begin
        rd_vld[port] <= output_batch <= end_batch;
        
    end

    //��ȡ���ݰ��ĵ�һ�����ֵĸ�9λ
    //�õ����ݰ��ĳ��ȣ���ȻӦ�ü�ȥ���ư��ֱ�����ռ��һ����

    //ÿ������һ�����ݼ�1��ֱ��0Ϊֹ
    always @(posedge clk) begin
        if(rd_vld[port] == 1 && packet_length_got == 0) begin
            reading_packet_length <= rd_data[port][15:7] - 2;
        end else if(output_batch <= end_batch) begin
            reading_packet_length <= reading_packet_length - 1;
        end
    end

    //��ǰҳ�����ˣ�����Ҫ����һҳ��
    //�־û���һҳ�ļ���������
    always @(posedge clk) begin
        if(!rst_n || rd_eop[port]) begin
            end_batch <= 0;
        end else if(packet_length_got == 1 && output_batch == end_batch) begin
            end_batch <= reading_batch[port];
            reading_batch[port] <= reading_packet_length > 15 ? 7 : reading_packet_length - 7;
        end else if(packet_length_got == 0) begin
            end_batch <= 7;
            reading_batch[port] <= 7;
        end
    end

    //ά��packet length got�ڻ�ȡ������֮ǰһֱΪ0
    always @(posedge clk) begin
        if(rd_sop[port] == 1) begin
            packet_length_got <= 0;
        end else if(rd_vld[port] == 1 && packet_length_got == 0) begin 
            packet_length_got <= 1;
        end
    end

    reg is_reading;

    //��������ݰ���ͷ������һҳ��ʼ�����ʱ����Ϊ��һҳ�Ķ�ȡ��׼��
    //jt �� rd en��rd addr��SRAMģ��ʵ��
    //��ת��Ӧ���п� ���ﻹûȷ��
    always @(posedge clk) begin
        if(!rst_n || rd_eop[port]) begin
            reading_sram[port] <= 32;
        end else if(rd_sop[port] == 1 ||
            (handshake[reading_sram[port]] == 1 && processing_request[reading_sram[port]] == port 
            && is_reading == 1)) begin
            reading_sram[port] <= queue_head_sram[port][reading_priority[port]];
            reading_page[port] <= queue_head_page[port][reading_priority[port]];
        end
    end

    //������Ϊ0��ʱ��˵���ٷ����һ������һ�����ھͿ�������rd eop��
    //����ʹ��WRR�ֻ�

    always @(posedge clk) begin
        if(rd_vld[port] == 1 && reading_packet_length == 0) begin
            rd_eop[port] <= 1;
            next_packet <= 1;
        end else begin
            rd_eop[port] <= 0;
            next_packet <= 0;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            is_reading <= 0;
        end if((handshake[reading_sram[port]] == 1 && processing_request[reading_sram[port]] == port 
        && reading_packet_length <= 15 && reading_packet_length > 0)) begin
            is_reading <= 0;
        end else if(ready[port] == 1) begin
            is_reading <= 1;
        end
    end

    wire [3:0] port_1;
    assign port_1 = port;
    
    //WRRλ����ˢ�£���next_packetΪ��ʱˢ��
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

    //�ȴ���ȡ�Ķ��У������봦�������next_packetΪ��ʱˢ��
    //ע�⣬�����õ����ϴ�next_packet�Ѿ�ˢ�ºõ�wrr_mask�����������ˢ�µ�
    always @(posedge clk) begin
        if(next_packet == 1 && wrr_en == 1 && (wrr_mask & queue_not_empty[port] != 0)) begin
            queue_waiting <= wrr_mask & queue_not_empty[port];
        end else begin
            queue_waiting <= queue_not_empty[port];
        end
    end

    
    //���ݶ������ж�������λ��
    //����е�����
    always @(posedge clk) begin
        if(wr_eop[port] == 1) begin
            waiting_ready[port] <= 1;
        end else if(ready[port] == 1) begin
            waiting_ready[port] <= 0;
        end
    end

    //���ݶ������ж�������λ��
    always @(posedge clk) begin
        if(ready[port] == 1 && waiting_ready[port] == 1) begin
            case(queue_waiting & ~(queue_waiting - 1)) 
                8'h01: reading_priority[port] <= 3'd0;
                8'h02: reading_priority[port] <= 3'd1;
                8'h04: reading_priority[port] <= 3'd2;
                8'h08: reading_priority[port] <= 3'd3;
                8'h10: reading_priority[port] <= 3'd4;
                8'h20: reading_priority[port] <= 3'd5;
                8'h40: reading_priority[port] <= 3'd6;
                8'h80: reading_priority[port] <= 3'd7;
                default: begin end
            endcase
        end
    end

    //readyʱ����sop
    always @(posedge clk) begin
        if(rd_sop[port] == 1) begin
            rd_sop[port] <= 0;
        end else if(ready[port]) begin
            rd_sop[port] <= 1;
        end
    end

    //��ʼ����ǰ����״̬��Ϣ
    always @(posedge clk) begin
        if(rd_sop[port] == 1) begin
            reading_packet_length <= 0;
        end
    end
    

    always @(posedge clk) begin
        full[port] <= (locking_c | much_space_c) == 0;
    end

    /* 
        ����
    */

    //ˢ��ÿ���˿���һ����������SRAM���
    always @(posedge clk) begin
        searching_sram_index[port] <= (cnt_32 + port) % 32;
    end
    //ѯ����һ����������SRAM���ж���(�������ڻ�����ƥ��SRAM�����ݰ���)Ŀ�Ķ˿ڵİ���
    always @(posedge clk) begin
        request_port[(cnt_32 + port) % 32] <= port_dest_port[port];
    end
    //���µ����ݰ����뻺������Ӧ������������32���ں��������
    always @(posedge clk) begin
        if(!rst_n) begin
            searching[port] <= 0;
        end else if(port_new_packet_into_buf[port] == 1) begin
            searching[port] <= 1;
        end else if(search_cnt[port] == 31) begin
            searching[port] <= 0;
        end
    end
    //����������������31ʱ���ڽ��е�32������������32֮��һ���ڱ�����
    //���Խ������32��ʱ����Ϊ������ȫ����ɵ�ʱ��
    always @(posedge clk) begin
        if(!rst_n) begin
            search_cnt[port] <= 0;
        end else if(searching[port] == 1) begin
            search_cnt[port] <= search_cnt[port] + 1;
        end else if(searching[port] == 0) begin
            search_cnt[port] <= 0;
        end
    end
    //�������߼�
    //�����и����˴��ŵ�С���� FIXME
    always @(posedge clk) begin
        if (!(searching[port] == 1 || port_new_packet_into_buf[port] == 1)) begin     //�°����ˣ����üĴ���
            max_amount[port] <= 0;
            search_get[port] <= 0;
        end else if (locking[searching_sram_index[port]] == 1) begin    //������������  
        end else if (free_space[searching_sram_index[port]] < port_length[port]) begin      //�������ռ䲻����
        end else if (max_amount[port] > page_amount[searching_sram_index[port]]) begin     //��ƫ�ü����˿��������ٵ�
        end else begin
            max_amount[port] <= page_amount[searching_sram_index[port]];
            searching_distribution[port] <= searching_sram_index[port];
            locking[searching_sram_index[port]] <= 1;
            locking[searching_distribution[port]] <= 0;
            search_get[port] <= 1;
        end
    end

    /*
        �־û�
    */
    //�����������������ζ��Ҫ��ʼд�����ݰ���
    //�־û����ݰ���Ŀ�Ķ˿�
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_dest_port[port] <= port_dest_port[port];
        end
    end
    //�־û����ݰ���Ŀ�Ķ���
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_prior[port] <= port_prior[port];
        end
    end
    //�־û����ݰ��ĳ���
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            cur_length[port] <= port_length[port];
        end
    end
    //�־û����������SRAM
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
        �������ݰ�
    */
    //�������ݰ����Σ���������ɵ�ʱ������Ϊ0
    always @(posedge clk) begin
        if(!rst_n) begin
            packet_batch[port] <= 0;
        end else if(search_cnt[port] == 32 || packet_length[port] == cur_length[port] + 1) begin
            packet_batch[port] <= 0;
        end else if(port_data_vld[port]) begin
            //���ݰ�����֮��ʱ������
            //��ʹ���ݰ�������Ϻ��Կ��Ե���������ʹ��
            packet_batch[port] <= packet_batch[port] + 1;
        end
    end
    //��ǰ�Ѿ�����ĳ�����������������ϵ�ʱ������Ϊ1������Ϊʲô������Ϊ0
    //����Ϊ�������Ϊ0����ô���ݰ����һ�����ִ����ʱ����cur_length����1���Ƚϴ�С��ʱ��Ҫ����һ��+1������߼�
    //��ô�Ż���ô����
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_length[port] <= 1;
        end else if(port_data_vld[port]) begin      //����Ч���ݵ���������
            packet_length[port] <= packet_length[port] + 1;
        end else if(packet_length[port] == cur_length[port] + 1) begin
            packet_length[port] <= 0;
        end
    end
    //�ӵ�һ����Ч���ݷ��������һ�����ݱ�д��SRAM
    always @(posedge clk) begin
        if(search_cnt[port] == 32) begin
            packet_signal_reset[port] <= 1;
        end else if(!port_data_vld[port]) begin
            packet_signal_reset[port] <= 0;
        end
    end

    /*
        д��ת��
    */
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7 && packet_length[port] != cur_length[port]) begin
            jt_wr_en[cur_distribution[port]] <= 1;
        end else if(packet_length[port] == cur_length[port]) begin
            jt_wr_en[cur_distribution[port]] <= 1;
        end else if(port == cnt_32 >> 1 && packet_merge[port] 
        && packet_batch[sram_distribution[queue_tail_sram[last_dest_port[port]][last_dest_queue[port]]]] != 7
         && queue_not_empty[last_dest_port[port]][last_dest_queue[port]]) begin
            jt_wr_en[queue_tail_sram[last_dest_port[port]][last_dest_queue[port]]] <= 1;
            last_distribution[port] <= queue_tail_sram[last_dest_port[port]][last_dest_queue[port]];
        end else if(jt_wr_en[last_distribution[port]] == 1 && !packet_merge[port] 
                    && ((sram_occupy[last_distribution[port]] 
                    && packet_batch[sram_distribution[last_distribution[port]]] != 7) 
                    || !sram_occupy[last_distribution[port]])) begin
            jt_wr_en[last_distribution[port]] <= 0;
        end else if(!(queue_tail_sram[last_dest_port[port]][last_dest_queue[port]] == cur_distribution[port] &&
        packet_merge != 0) && 
        (packet_batch[port] != 7 || packet_length[port] == cur_length[port] + 1)) begin
            jt_wr_en[cur_distribution[port]] <= 0;
        end
    end
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7 && packet_length[port] != cur_length[port]) begin
            jt_wr_addr[cur_distribution[port]] <= wr_page[port];
        end else if(packet_length[port] == cur_length[port]) begin
            jt_wr_addr[cur_distribution[port]] <= wr_page[port];
        end else if(port == cnt_32 >> 1 && packet_merge[port] &&
            packet_batch[sram_distribution[queue_tail_sram[last_dest_port[port]][last_dest_queue[port]]]] != 7) begin
            jt_wr_addr[queue_tail_sram[last_dest_port[port]][last_dest_queue[port]]] <= 
            queue_tail_page[last_dest_port[port]][last_dest_queue[port]];
        end
    end
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_batch[port] == 7 && packet_length[port] != cur_length[port]) begin
            jt_din[cur_distribution[port]] <= {cur_distribution[port],null_ptr[cur_distribution[port]]};
        end else if(packet_length[port] == cur_length[port]) begin
            jt_din[cur_distribution[port]] <= {cur_distribution[port],null_ptr[cur_distribution[port]]};
        end else if(port == cnt_32 >> 1 && packet_merge[port] &&
            packet_batch[sram_distribution[queue_tail_sram[last_dest_port[port]][last_dest_queue[port]]]] != 7) begin
            jt_din[queue_tail_sram[last_dest_port[port]][last_dest_queue[port]]] <= last_packet_head_addr[port];
        end
    end
    
    
    //���ݰ�ͷβ��ַ�ļ���
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
        if(packet_length[port] == cur_length[port] + 1) begin
            last_packet_tail_addr[port] <= packet_tail_addr[port];
        end
    end

    //��ǰһ����������һҳ�ĵ�ַ
    //��ʹ��һҳû������Ҳû�����ã���Ϊ��ҳû�б��������ж���
    always @(posedge clk) begin
        if(!rst_n) begin
            wr_page[port] <= 0;
        end else if(port_data_vld[port] && packet_batch[port] == 7) begin
            wr_page[port] <= null_ptr[cur_distribution[port]];
        end else if(search_cnt[port] == 32) begin   //���ݰ�ͷҲ��Ҫ��ǰ����
            wr_page[port] <= null_ptr[searching_distribution[port]];
        end
    end
    //������һҳ��ַ��ʱ�򣬳־û���һҳ�ĵ�ַ������д��ת��
    always @(posedge clk) begin
        if(port_data_vld[port] && packet_length[port] == cur_length[port]) begin
            wr_last_page[port] <= wr_page[port];
        end
    end
    //��������ʼʹ��ҳ��ʱ�򣬰����������ж���
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
    //�־û��ϸ����ݰ���Ŀ�Ķ���(3+4)������Ϊ�������ݰ�������Ϻ󣬽���ͷβ����
    //����ĩ��ʱ��Ҫ֪�����ĸ����У���ֹ��ʱ��cur_dest_port/prior�����Ѿ�����
    always @(posedge clk) begin
        if(!rst_n) begin
            last_dest_queue[port] <= 0;
            last_dest_port[port] <= 0;
        end else if(port_data_vld[port] && packet_length[port] == cur_length[port]) begin
            last_dest_queue[port] <= cur_prior[port];
            last_dest_port[port] <= cur_dest_port[port];
        end
    end
    //��ѯ���������ݰ������β��������ͬ�˿ھͲ����ͻ
    always @(posedge clk) begin
        if(!rst_n) begin
            queue_tail_sram[port][0] <= 0;
            queue_tail_sram[port][1] <= 0;
            queue_tail_sram[port][2] <= 0;
            queue_tail_sram[port][3] <= 0;
            queue_tail_sram[port][4] <= 0;
            queue_tail_sram[port][5] <= 0;
            queue_tail_sram[port][6] <= 0;
            queue_tail_sram[port][7] <= 0;
            queue_not_empty[port] <= 0;
        end else if(port == cnt_32 >> 1 && packet_merge[port] 
        && packet_batch[sram_distribution[queue_tail_sram[last_dest_port[port]][last_dest_queue[port]]]] != 7) begin
            if(!queue_not_empty[last_dest_port[port]][last_dest_queue[port]]) begin
                queue_not_empty[last_dest_port[port]][last_dest_queue[port]] <= 1;
                queue_head_sram[last_dest_port[port]][last_dest_queue[port]] <= last_packet_head_addr[port][15:11];
                queue_head_page[last_dest_port[port]][last_dest_queue[port]] <= last_packet_head_addr[port][10:0];
            end
            if(packet_length[port] == cur_length[port] + 1) begin
                queue_tail_sram[last_dest_port[port]][last_dest_queue[port]] <= packet_tail_addr[port][15:11];
                queue_tail_page[last_dest_port[port]][last_dest_queue[port]] <= packet_tail_addr[port][10:0];
            end else begin
                queue_tail_sram[last_dest_port[port]][last_dest_queue[port]] <= last_packet_tail_addr[port][15:11];
                queue_tail_page[last_dest_port[port]][last_dest_queue[port]] <= last_packet_tail_addr[port][10:0];
            end
        end
    end
    //�Ƿ��Ѿ��������ȼ�����ĩ�ˣ�1-��Ҫ���룬0-�Ѿ�����
    always @(posedge clk) begin
        if(packet_length[port] == cur_length[port]) begin
            packet_merge[port] <= 1;
        end else if(port == cnt_32 >> 1 && packet_merge[port] 
        && packet_batch[sram_distribution[queue_tail_sram[last_dest_port[port]][last_dest_queue[port]]]] != 7) begin
            packet_merge[port] <= 0;
        end
    end

    /*
        д��SRAM
    */
    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_wr_addr[cur_distribution[port]] <= {wr_page[port], packet_batch[port]};
        end 
    end
    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_wr_en[cur_distribution[port]] <= 1;
        end else if(packet_length[port]) begin
            sram_wr_en[cur_distribution[port]] <= 0;
        end
    end
    always @(posedge clk) begin
        if(port_data_vld[port]) begin
            sram_din[cur_distribution[port]] <= port_data[port];
        end
    end

    /*
        ECCУ��
    */
    //һҳд���˻������ݰ������˵�ʱ��ʹ��ECC
    always @(posedge clk) begin
        if((port_data_vld[port] && packet_batch[port] == 7) || packet_length[port] == cur_length[port]) begin
            ecc_encoder_enable[port] <= 1;
        end else begin
            ecc_encoder_enable[port] <= 0;
        end
    end
    //ʹ��ECC��ʱ���¼һ�����ECC�Ľ��Ӧ����ŵ��ĸ�SRAM������ǰ���ݰ���SRAM��
    always @(posedge clk) begin
        if((port_data_vld[port] && packet_batch[port] == 7) || packet_length[port] == cur_length[port]) begin
            ecc_sram[port] <= cur_distribution[port];
        end else begin
            ecc_sram[port] <= cur_distribution[port];
        end
    end
    //��һ�ģ��ȴ�ecc���׼���ã�batch=0��ʱ��ecc�ڸ��½����=1��ʱ�򼴿ɻ�ȡ����������always��
    //����ecc_resultҲ�Ƿ�ֹ�ڿ�ͷһҳbatch=1��ʱ���󴥷�ECC����/�洢����
    always @(posedge clk) begin
        if(ecc_encoder_enable[port] == 1) begin
            ecc_result[port] <= 1;
        end else if(packet_batch[port] == 1) begin
            ecc_result[port] <= 0;
        end
    end
    //��ȡ������Ϳ���д�ˣ���batch=1��ʱ��
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
    //��ͬ���ε�����д��ECC������
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
    //����һ�����ݿ�ʼд��ʱ���ECC������
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

    always @(posedge clk) begin
        if(port_data_vld[port] == 1) begin
            case(packet_batch[port]) 
                3'b000 : ecc_encoder_data_0[port] <= port_data[port];
                3'b001 : ecc_encoder_data_1[port] <= port_data[port];
                3'b010 : ecc_encoder_data_2[port] <= port_data[port];
                3'b011 : ecc_encoder_data_3[port] <= port_data[port];
                3'b100 : ecc_encoder_data_4[port] <= port_data[port];
                3'b101 : ecc_encoder_data_5[port] <= port_data[port];
                3'b110 : ecc_encoder_data_6[port] <= port_data[port];
                3'b111 : ecc_encoder_data_7[port] <= port_data[port];
            endcase
        end else
            ecc_encoder_data_0[port] <= 0;
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
        .data_0(ecc_decoder_data_0[port]),
        .data_1(ecc_decoder_data_1[port]),
        .data_2(ecc_decoder_data_2[port]),
        .data_3(ecc_decoder_data_3[port]),
        .data_4(ecc_decoder_data_4[port]),
        .data_5(ecc_decoder_data_5[port]),
        .data_6(ecc_decoder_data_6[port]),
        .data_7(ecc_decoder_data_7[port]),
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


genvar sram;
generate for(sram = 0; sram < 32; sram = sram + 1) begin : SRAMs

    //���������ȡ��ǰSRAM�Ķ˿�
    wire [15:0] requesting_ports;
    //�����봦��������������ȡ��ǰSRAM�Ķ˿�
    reg [15:0] requesting_ports_masked;

    //����ά��
    //����ʵ�ֶ���˿�ͬʱ��ȡʱ����ѯ���ҳ����
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
        if(!rst_n) begin
            mask <= 16'hFFFF;
        end else if(next_request) begin
            mask <= 16'hFFFF >> mask_start;
        end
    end

    //�����Ͳ��ᱬmulti driven
    assign requesting_ports = {
        reading_sram[15] == sram,
        reading_sram[14] == sram,
        reading_sram[13] == sram,
        reading_sram[12] == sram,
        reading_sram[11] == sram,
        reading_sram[10] == sram,
        reading_sram[9] == sram,
        reading_sram[8] == sram,
        reading_sram[7] == sram,
        reading_sram[6] == sram,
        reading_sram[5] == sram,
        reading_sram[4] == sram,
        reading_sram[3] == sram,
        reading_sram[2] == sram,
        reading_sram[1] == sram,
        reading_sram[0] == sram
    };

    always @(posedge clk) begin
        if(requesting_ports & mask != 0) begin
            requesting_ports_masked <= requesting_ports & mask;
        end else begin
            requesting_ports_masked <= requesting_ports;
        end
    end

    //�Ƿ����ڴ�������
    reg processing_enable;
    //�������󵽵ڼ�������
    reg [3:0] processing_batch; //��ֵӦ��Ϊ9
    //���ڴ����ĸ��˿ڵ�����
    reg [3:0] processing_port;
    //��ǰ�Ƿ���һҳ�Ŀ�ͷ
    reg start_of_page;

    reg [2:0] read_batch;

    //ֻҪ������Ȼ���ڴ���
    always @(posedge clk) begin
        processing_enable <= requesting_ports_masked != 0;
    end

    //��һҳ��ʼ��ʱ��batch����Ϊ0
    //��ȡ��ʱ��batch�ۼӣ�ֱ��reading_batch+1 (��߿ɴ�9)
    //batch����0��ʱ��sram��ȡ0λ�õİ��֣�����1��ʱ�������ȡ0λ�õİ��ֵ�ECC������
    always @(posedge clk) begin
        if(processing_enable == 1 && start_of_page == 1) begin
            processing_batch <= 0;
            start_of_page <= 0;
            read_batch <= reading_batch[processing_port];
        end else if(processing_batch <= read_batch + 3) begin
            processing_batch <= processing_batch + 1;
        end else begin
            start_of_page <= 1;
        end
    end

    //��һҳ������ʼǰ��������ǰ���ڶ�ȡ�ĸ��˿�
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

    always @(posedge clk) begin
        if(processing_enable == 1 && start_of_page == 1) begin
            case(requesting_ports_masked & ~(requesting_ports_masked - 1))
                16'h0001: processing_request[sram] <= 4'h0;
                16'h0002: processing_request[sram] <= 4'h1;
                16'h0004: processing_request[sram] <= 4'h2;
                16'h0008: processing_request[sram] <= 4'h3;
                16'h0010: processing_request[sram] <= 4'h4;
                16'h0020: processing_request[sram] <= 4'h5;
                16'h0040: processing_request[sram] <= 4'h6;
                16'h0080: processing_request[sram] <= 4'h7;
                16'h0100: processing_request[sram] <= 4'h8;
                16'h0200: processing_request[sram] <= 4'h9;
                16'h0400: processing_request[sram] <= 4'hA;
                16'h0800: processing_request[sram] <= 4'hB;
                16'h1000: processing_request[sram] <= 4'hC;
                16'h2000: processing_request[sram] <= 4'hD;
                16'h4000: processing_request[sram] <= 4'hE;
                16'h8000: processing_request[sram] <= 4'hF;
                default: begin end
            endcase
        end
    end

    //һҳ�տ�ʼ��ȡ��ʱ�򣬲�ѯ��ת������˿���jt dout�ĵ���
    always @(posedge clk) begin
        if(processing_enable == 1 && processing_batch == 0) begin
            jt_rd_en[sram] <= 1;
            jt_rd_addr[sram] <= reading_page[processing_port];
        end else if(processing_enable == 1 && processing_batch == 2) begin
            {queue_head_sram[processing_port][reading_priority[processing_port]], 
            queue_head_page[processing_port][reading_priority[processing_port]]} <= 
            jt_dout[sram];
        end
        
    end

    //һҳ�տ�ʼ��ʱ���ȡECCУ����
    //�ڵ�һ���ֶ�ȡ��ϵ�ʱ��ECCУ����д���˿ڵ�ECCУ������
    always @(posedge clk) begin
        if(processing_enable == 0) begin
        end else if(processing_batch == 0) begin
            ecc_rd_en[sram] <= 1;
            ecc_rd_addr[sram] <= reading_page[processing_port];
        end else if(processing_batch == 2) begin
            ecc_decoder_code[processing_port] <= ecc_dout[sram];
        end
    end

    //��ȡ����
    always @(posedge clk) begin
        if(processing_enable == 1 && processing_batch <= read_batch + 2) begin
            sram_rd_en[sram] <= 1;
            sram_rd_addr[sram][2:0] <= processing_batch;
            sram_rd_addr[sram][13:3] <= reading_page[processing_port];
        end
    end

    //ҳ��ȫ��ȡ���������������źŴ����˿���ECCʹ�ܵ�ʵ���Լ��������������
    always @(posedge clk) begin
        if(processing_batch == read_batch + 3) begin
            handshake[sram] <= 1;
            next_request <= 1;
        end else begin
            handshake[sram] <= 0;
            next_request <= 0;
        end
    end

    //ECC��������װ�batch=1~8������գ�batch=0��
    always @(posedge clk) begin
        if(processing_enable == 1) begin
            case(processing_batch)
                4'h2: ecc_decoder_data_7[processing_port] <= sram_dout[sram];
                4'h3: ecc_decoder_data_6[processing_port] <= sram_dout[sram];
                4'h4: ecc_decoder_data_5[processing_port] <= sram_dout[sram];
                4'h5: ecc_decoder_data_4[processing_port] <= sram_dout[sram];
                4'h6: ecc_decoder_data_3[processing_port] <= sram_dout[sram];
                4'h7: ecc_decoder_data_2[processing_port] <= sram_dout[sram];
                4'h8: ecc_decoder_data_1[processing_port] <= sram_dout[sram];
                4'h9: ecc_decoder_data_0[processing_port] <= sram_dout[sram];
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
        .rst_n(rst_n),
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
        .rst_n(rst_n),
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