module port_wr_sram_matcher(
    input clk,
    input rst_n,

    /*
     * �����ò���
     * |- match_mode - SRAM����ģʽ
     *      |- 0 - ��̬����ģʽ
     *      |- 1 - �붯̬����ģʽ
     *      |- 2/3 - ȫ��̬����ģʽ
     * |- match_threshold - ƥ����ֵ����ƥ��ʱ��������ֵ��һ�����κο��õļ����ƥ��
     *      |- ��̬����ģʽ ���Ϊ0
     *      |- �붯̬����ģʽ ���Ϊ16
     *      |- ȫ��̬����ģʽ ���Ϊ30
     */
    input [1:0] match_mode,
    input [4:0] match_threshold,

    /* ��ǰ�˽������ź� */
    input [3:0] new_dest_port,
    input [8:0] new_length,
    input match_enable,
    output reg match_suc,

    /*
     * ���˽������ź� 
     * |- viscous - �˿��Ƿ���ճ��״̬
     * |- matching_sram - ��ǰ����ƥ���SRAM
     * |- matching_best_sram - ��ǰƥ�䵽���ŵ�SRAM
     */
    input viscous,
    input [4:0] matching_sram,
    output reg [4:0] matching_best_sram,
    output update_matched_sram,

    /* 
     * ��ǰê����SRAM��״̬
     * |- accessible - SRAM�Ƿ����
     * |- free_space - SRAMʣ��ռ䣨���֣�
     * |- packet_amount - SRAM���°��˿ڶ�Ӧ�����ݰ�����
     */
    input accessible,
    input [10:0] free_space,
    input [8:0] packet_amount,

    output reg [1:0] match_state
);

/* 
 * ƥ��״̬
 * |- 0 - δƥ��
 * |- 1 - ƥ����(�����match_enableһ��)
 * |- 2 - ƥ�����(��match_endͬ������)
 */


/* 
 * ƥ���ź�
 * |- matching_find - �Ƿ��Ѿ�ƥ�䵽���õ�SRAM
 * |- matching_tick - ��ǰƥ��ʱ��
 * |- max_amount - ��ǰ����SRAM��Ŀ�Ķ˿ڵ�������
 */
reg matching_find;
reg [7:0] matching_tick;
reg [8:0] max_amount;

/* ճ��ƥ��֧��
 * |- old_dest_port - ��һƥ�����ݰ���Ŀ�Ķ˿�
 * |- old_free_space - ��һƥ�䵽��SRAM��ʣ��ռ�
 */
reg [3:0] old_dest_port;
reg [10:0] old_free_space;
reg [10:0] best_free_space;

assign update_matched_sram = match_enable && ~match_suc && matching_find;

always @(posedge clk) begin
    if(~rst_n) begin
        match_state <= 2'd0;
        match_suc <= 0;
    end else if(match_state == 2'd0 && match_enable) begin
        if(new_dest_port == old_dest_port && old_free_space >= new_length && viscous) begin
            /* ճ��ƥ��ɹ�(�¾�Ŀ�Ķ˿���ͬ��SRAM���㹻�ռ����Դ���ճ��״̬)��ֱ����������ƥ��׶� */
            match_suc <= 1;
            match_state <= 2'd2;
            old_free_space <= old_free_space - new_length;
        end else begin
            match_state <= 2'd1;
        end
    end else if(match_state == 2'd1 && matching_find && matching_tick >= match_threshold) begin
        /* ����ƥ��ɹ�(ʱ��ﵽ��ֵ���н��) */
        match_suc <= 1;
        match_state <= 2'd2;
        old_free_space <= best_free_space - new_length;
        old_dest_port <= new_dest_port;
    end else if(match_state == 2'd2) begin
        match_suc <= 0;
        match_state <= 2'd0;
    end
end

always @(posedge clk) begin
    if(match_enable) begin
        matching_tick <= matching_tick + 1;
    end else begin
        matching_tick <= 0;
    end
end

always @(posedge clk) begin
    if(~match_enable || match_suc) begin
        matching_find <= 0;
        max_amount <= 0;
    end else if(~accessible) begin                  /* δ��ռ�� */
    end else if(free_space < new_length) begin      /* �ռ��㹻 */
    end else if(packet_amount >= max_amount) begin  /* �ȵ�ǰ���� */
        best_free_space <= free_space;
        matching_best_sram <= matching_sram;
        max_amount <= packet_amount;
        matching_find <= 1;
    end
end

endmodule

//ճ����ײ����