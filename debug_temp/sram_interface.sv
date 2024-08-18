
module sram_interface
(
    input clk,
    input rst_n,

    /* time_stamp - ʱ��� */
    input [4:0] time_stamp,
    /* sram_idx - SRAM��� */
    input [4:0] sram_idx,

    /* 
     * д�봫������IO 
     * |- wr_xfer_data_vld - д�봫��������Ч�ź�
     * |- wr_xfer_data - д�봫������
     * |- wr_end_of_packet - д�봫������ź�
     */
    input wr_xfer_data_vld,
    input [15:0] wr_xfer_data,
    input wr_end_of_packet,

    /* 
     * ������� 
     * |- join_enable - ����������ź�
     * |- join_time_stamp - �������ʱ���
     * |- join_dest_port - �������Ŀ�Ķ˿�
     * |- join_prior - ����������ȼ�
     * |- join_head - ���������ҳ��ַ
     * |- join_tail - �������βҳ��ַ
     */
    output reg join_enable,
    output reg [5:0] join_time_stamp,
    output reg [4:0] join_dest_port,
    output reg [2:0] join_prior,
    output reg [10:0] join_head,
    output reg [10:0] join_tail,

    /*
     * ƴ������ 
     * |- concatenate_enable - ƴ������ʹ���ź�
     * |- concatenate_head - ƴ��������ҳ��ַ
     * |- concatenate_tail - ƴ������βҳ��ַ
     */
    input concatenate_enable,
    input [10:0] concatenate_head,
    input [15:0] concatenate_tail,

    /* 
     * ������������IO
     * |- rd_page_down - ��ҳ�ź�
     * |- rd_page - ����ҳ��ַ
     * |- rd_xfer_data - ������������
     * |- rd_next_page - ����ҳ����һҳ��ַ
     * |- rd_ecc_code - ����ҳ��(136,128)ECCУ����
     */
    input rd_page_down,
    input [10:0] rd_page,
    output [15:0] rd_xfer_data,
    output [15:0] rd_next_page,
    output [7:0] rd_ecc_code,

    /* free_space - ʣ��ռ䣨��λ:ҳ�� */
    output reg [10:0] free_space
    
    /* SRAM��дIO
    ,
    (*DONT_TOUCH="YES"*) output wr_en,
    (*DONT_TOUCH="YES"*) output [13:0] wr_addr,
    (*DONT_TOUCH="YES"*) output [15:0] din,
    (*DONT_TOUCH="YES"*) output rd_en,
    (*DONT_TOUCH="YES"*) output [13:0] rd_addr,
    (*DONT_TOUCH="YES"*) input [15:0] dout
    */
);

/* ECC����洢 8��2048 RAM */
(* ram_style = "block" *) reg [7:0] ecc_codes [2047:0];
reg ec_wr_en;
reg [10:0] ec_wr_addr;
wire [7:0] ec_din;
wire [10:0] ec_rd_addr;
reg [7:0] ec_dout;
always @(posedge clk) if(ec_wr_en) ecc_codes[ec_wr_addr] <= ec_din;
always @(posedge clk) ec_dout <= ecc_codes[ec_rd_addr];
/* ECC���뻺���� */
reg [15:0] ecc_encoder_buffer [7:0];

/* ��ת�� 16��2048 RAM */
(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
reg [10:0] jt_wr_addr;
reg [15:0] jt_din;
wire [10:0] jt_rd_addr;
reg [15:0] jt_dout;
always @(posedge clk) jump_table[jt_wr_addr] <= jt_din;
always @(posedge clk) jt_dout <= jump_table[jt_rd_addr];

/* ���ж��� 11��2048 RAM */
(* ram_style = "block" *) reg [10:0] null_pages [2047:0];
reg [10:0] np_wr_addr;
reg [10:0] np_din;
always @(posedge clk) null_pages[np_wr_addr] <= np_din;
wire [10:0] np_rd_addr;
reg [10:0] np_dout;
always @(posedge clk) np_dout <= null_pages[np_rd_addr];

/*
 * ���ж��е�ά�����ʼ��
 * |- np_head_ptr - ���ж��е�ͷָ��
 * |- np_tail_ptr - ���ж��е�βָ��
 * |- np_perfusion - ���ж��еĹ�ע����
 */
reg [10:0] np_head_ptr;
reg [10:0] np_tail_ptr;
reg [11:0] np_perfusion;

/*
 * д�����
 * |- wr_page - д��ҳ��ַ
 * |- wr_batch - д�������Ƭ���
 * |- wr_state - ���ݰ�д���Զ���
 *             |- 0 - �����ݰ�д��
 *             |- 1 - ����д�����ݰ��ĵ�һҳ
 *             |- 2 - ����д�����ݰ��ĺ���ҳ
 */
reg [10:0] wr_page;
reg [2:0] wr_batch;
reg [1:0] wr_state;

/*
 * ��������
 * |- rd_batch - ������Ƭ���
 */
reg [3:0] rd_batch; 

/* ����ECCУ���벢д��洢�� */
always @(posedge clk) begin
    if(wr_xfer_data_vld) begin
        if(wr_batch == 0) begin                                             /* ҳ��ʱ�������壬����������Ӱ��ECC���� */
            ecc_encoder_buffer[1] <= 16'h0000;
            ecc_encoder_buffer[2] <= 16'h0000;
            ecc_encoder_buffer[3] <= 16'h0000;
            ecc_encoder_buffer[4] <= 16'h0000;
            ecc_encoder_buffer[5] <= 16'h0000;
            ecc_encoder_buffer[6] <= 16'h0000;
            ecc_encoder_buffer[7] <= 16'h0000;
        end
        ecc_encoder_buffer[wr_batch] <= wr_xfer_data;
    end
end

always @(posedge clk) begin
    if(wr_batch == 3'd7 && wr_xfer_data_vld || wr_end_of_packet) begin      /* ҳĩʱ׼�������д��ECC����洢�� */
        ec_wr_en <= 1;
        ec_wr_addr <= wr_page;
    end else begin
        ec_wr_en <= 0;
    end
end

ecc_encoder ecc_encoder( 
    .data_0(ecc_encoder_buffer[0]),
    .data_1(ecc_encoder_buffer[1]),
    .data_2(ecc_encoder_buffer[2]),
    .data_3(ecc_encoder_buffer[3]),
    .data_4(ecc_encoder_buffer[4]),
    .data_5(ecc_encoder_buffer[5]),
    .data_6(ecc_encoder_buffer[6]),
    .data_7(ecc_encoder_buffer[7]),
    .code(ec_din)
);

/* �Ӵ洢���ж���ECCУ���� */
assign ec_rd_addr = rd_page;
assign rd_ecc_code = ec_dout;

/* ƴ��������/���ݰ���ͬҳд�� ʱ��ת���ĸ��� */
always @(posedge clk) begin
    if(concatenate_enable) begin                                        /* ��ͬ���ݰ�����ת����ƴ�� */
        jt_wr_addr <= concatenate_head;
        jt_din <= concatenate_tail;
    // end else if(wr_end_of_packet) begin                                 /* ���ݰ�βҳָ������ */
    end else if(~wr_xfer_data_vld) begin
    end else if(wr_page != join_tail) begin         /* ���ݰ���������ҳ��ƴ�� */
        jt_wr_addr <= wr_page;
        jt_din <= {sram_idx, np_dout};
    end 
end

/* ����ת���ж�ȡ��ǰҳ����һҳ��ַ */
assign jt_rd_addr = rd_page;
assign rd_next_page = jt_dout;

/* β��Ԥ�� & ������ҳ��ַ��ѯ */
assign np_rd_addr = (wr_state == 2'd0 && wr_xfer_data_vld) 
                    ? np_head_ptr + wr_xfer_data[15:10]                 /* �����ݰ��տ�ʼ����ʱԤ�����ݰ�βҳ��ַ */
                    : np_head_ptr;                                      /* ����ʱ���ѯ������ҳ��ַ */

/* �ӿ��ж�����ȡ������ҳ */
always @(posedge clk) begin
    if(!rst_n) begin 
        np_head_ptr <= 0;
    end if(wr_batch == 0 && wr_xfer_data_vld) begin                     /* ��һҳ�տ�ʼ��ʱ�򵯳���ҳ */
        np_head_ptr <= np_head_ptr + 1;
    end
end

/* ��ʼ�����ж��� & ���ձ���ȡ��ҳ */
always @(posedge clk) begin
    if(!rst_n) begin
        np_perfusion <= 0;                                              /* ��ע��0��ʼ */
        np_tail_ptr <= 0;
    end else if(rd_page_down) begin                                     /* ���ն�����ҳ */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= rd_page;
    end else if(np_perfusion != 12'd2048) begin                         /* ��ע��2047���� */
        np_tail_ptr <= np_tail_ptr + 1;
        np_wr_addr <= np_tail_ptr;
        np_din <= np_perfusion;
        np_perfusion <= np_perfusion + 1;
    end
end

/* ���ݰ�д���Զ���״̬ת�� */
always @(posedge clk) begin
    if(!rst_n) begin
        wr_state <= 2'd0;
    end else if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_state <= 2'd1;
    end else if(wr_state == 2'd1 && wr_batch == 3'd7 && wr_xfer_data_vld) begin
        wr_state <= 2'd2;
    end else if(wr_state == 2'd2 && wr_end_of_packet) begin
        wr_state <= 2'd0;
    end
end

/* �����´�д���ҳ��ַ */
always @(posedge clk) begin
    if((wr_batch == 3'd7 && wr_xfer_data_vld) || wr_state == 2'd0) begin
        wr_page <= np_dout;
    end
end

/* д����Ƭ������ */
always @(posedge clk) begin
    if(!rst_n || wr_end_of_packet) begin
        wr_batch <= 0;
    end else if(wr_xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
    end
end

/* ��д��ʱ���ɲ������������ */
wire [3:0] out_of_date_stamp = time_stamp[3:0] + 2;
always @(posedge clk) begin
    join_enable <= wr_state == 2'd0 && wr_xfer_data_vld;                /* ����������� */
    if(~rst_n) begin
        join_time_stamp <= 6'd34;
        join_dest_port <= 0;
        join_prior <= 0;
        join_head <= 0;
    end else if(wr_state == 2'd0 && wr_xfer_data_vld) begin             /* ����������������Ϣ */
        join_time_stamp <= {1'b0, time_stamp + 5'd1};                   /* ����ģ����ʱ�������²����ʱ���ͬ�� */
        join_dest_port <= wr_xfer_data[3:0];
        join_prior <= wr_xfer_data[6:4];
        join_head <= wr_page;
        if(sram_idx == 7) begin
            //$display("interface = %d %d %d", wr_xfer_data[6:4],wr_xfer_data[3:0],(time_stamp + 5'd1) >> 1);
        end
    end else if(time_stamp[3:0] == join_time_stamp[3:0] && ~(wr_state == 2'd1 && wr_batch == 3'd1)) begin
        join_time_stamp <= 6'd34;                                       /* 16���ں������������ */
    end
    if(wr_state == 2'd1 && wr_batch == 3'd1) begin                      /* β��Ԥ����ɺ�׷�������������ݰ�βҳ��ַ */
        join_tail <= np_dout;
    end
    if(sram_idx == 7) begin
        //$display("wr_face = %d %d %d",wr_state,wr_xfer_data_vld,wr_xfer_data);
    end
end

/* ������Ƭ������ */
always @(posedge clk) begin
    if(~rst_n) begin
        rd_batch <= 4'd8;
    end if(rd_page_down) begin
        rd_batch <= 1;                                                  /* ��ҳʱ����һ����Ƭ���ӦΪ1 */
    end else if(rd_batch != 4'd8) begin
        rd_batch <= rd_batch + 1;
    end
end

/* д�����ݰ����ȳ־û� */
reg [6:0] packet_length;                                                /* 7λ�Ƿ�ֹ�����������ݰ����������free_space���������� */
always @(posedge clk) begin
    if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        packet_length <= wr_xfer_data[15:10] + 1;
    end
end 

/* ʣ��ռ���� */
always @(posedge clk) begin
    if(~rst_n) begin
        free_space <= 11'd2047;
    end 
    else if(join_enable && rd_page_down) begin
        free_space <= free_space - packet_length + 1;
    end else if(join_enable) begin
        free_space <= free_space - packet_length;
    end else if(rd_page_down) begin
        free_space <= free_space + 1;
    end
end

sram sram(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_xfer_data_vld),
    .wr_addr({wr_page, wr_batch}),
    .din(wr_xfer_data),
    .rd_en(rd_page_down || rd_batch != 4'd8),
    .rd_addr({rd_page, rd_page_down ? 3'd0 : rd_batch[2:0]}),   /* ��ҳʱ����Ƭ���ӦΪ0������ʱ����Ϊrd_addr_batch */
    .dout(rd_xfer_data)
); 

// assign wr_en = wr_xfer_data_vld;
// assign wr_addr = sram_wr_addr;
// assign din = wr_xfer_data;
// assign rd_en = rd_page_down || rd_batch != 4'd8;
// assign rd_addr = sram_rd_addr;
// assign rd_xfer_data = dout;

endmodule