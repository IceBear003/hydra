`timescale  1ns/1ns

module  sram_ctrl
(
    input    wire    sys_clk     ,   
    input    wire    sys_rst_n   ,
    input    wire    en_a    ,
    input    wire    en_b    ,
    input    wire    wr_eop  ,  
    input    wire    rd_eop  , 
    input    wire    [3:0]  port_ina  ,
    input    wire    [3:0]  port_inb  ,
    input    wire    [10:0]  addr_inb  ,
    input    wire    [15:0]  data_ina  ,
    input    logic   [8:0]   cnt_out ,
    
    output  logic   [8:0]   addr_left    ,
    output  logic   [3:0]   mx_port     ,
    output  logic   [10:0]  ptr_1       ,
    output  logic   ptr_2       ,
    output  logic   [15:0]  port_con    ,
    output  logic   [127:0]  data_out   ,
    output  logic   out_en  ,
    output  wire    [11:0]  cnt_em      ,
    output  wire    rd_fin  ,
    output  logic   ptr_fi 

);

integer i,j;

logic   [13:0]  addr_a;
logic   [11:0]  tem_mx  ;
logic   [12:0]  cnt_reg ;
logic   [15:0][11:0]    port_cnt    ;
logic   [2047:0]    bit_im      ;
logic   [2047:0]    bit_cnt      ;
logic   [3:0]   cnt_page    ;
logic   [3:0]   cnt_page_rd    ;
logic   [10:0]  ptr_3   ;
logic   btim_en ;
logic   [7:0]   ecc_dat ;
logic   [15:0]  data_outb;
logic   [7:0]   sec_code    ;
logic   [127:0] data_out1   ;
logic   enc_eop ;
logic   page_en ;

logic   wr_eop_1    ;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_eop_1 <= 0;
    else begin
        wr_eop_1 <= wr_eop;
        ////$display("wr_eop = %d",wr_eop);
        ////$display("wr_eop_1 = %d",wr_eop_1);
    end

logic   en_c    ;
logic   en_d    ;
logic   en_e    ;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        en_c <= 1'b0;
        en_d <= 1'b0;
    end
    else begin
        en_c <= en_b;
        en_d <= en_a;
    end


always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_page <= 1'b0;
    else if(en_a == 1'b1 && cnt_page < 3'd7) begin
        cnt_page <= cnt_page + 1'b1;
        //$display("cnt_page = %d",cnt_page);
    end
    else if(en_a == 1'b1 || wr_eop == 1'b1) begin
        cnt_page <= 1'b0;
        //$display("cnt_page = %d",cnt_page);
    end
    else if(en_a == 1'b0 && wr_eop == 1'b0)
        cnt_page <= 1'b0;

logic   [127:0] page_dat    ;
logic   [127:0] out_dat     ;
        
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        page_dat <= 1'b0;
    else if(en_a == 1'b1 && cnt_page <= 3'd7) begin
        page_dat = page_dat << 16 + data_ina;
        //$display("          cnt_page = %d",cnt_page);
        //$display("wr_eop = %d",wr_eop);
        //page_en = 1'b0;
        if(wr_eop == 1'b1) begin
            //page_en = 1'b1;
            page_dat = page_dat << ((8 - cnt_page) << 4);
        end
        /*else if(cnt_page == 3'd7)
            page_en = 1'b1;*/
    end
    else if(en_a == 1'b1 && cnt_page == 1'b0)
        page_dat = data_ina;

logic   data_t  ;

always@(en_a,cnt_page,sys_rst_n,wr_eop,en_d,wr_eop_1) begin
    if(sys_rst_n == 1'b0) begin
        data_t = 0;
        page_en = 0;
    end
    else if((en_a == 1'b1 || en_d == 1'b1) && cnt_page <= 3'd7)
        if((en_d == 1'b1 && en_a == 1'b0) || (en_a == 1'b1 && en_d == 1'b0)) begin
            page_en = 1'b1;
            if((en_d == 1'b1 && en_a == 1'b0))
                data_t = 1;
            else 
                data_t = 0;
            //$display("                 page_en = %d",page_en);
            //page_dat = page_dat << ((8 - cnt_page) << 4);
        end
        else if(cnt_page == 3'd7)
            page_en = 1'b1;
        else
            page_en = 1'b0;
end

//可以用计数器解决末尾页不满

logic   page_vld    ;
logic   [5:0] page_cnt  ;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        page_vld = 1'b0;
    else
        page_vld <= page_en;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        cnt_page_rd <= 1'b0;
        page_cnt <= 1'b0;
    end
    else if(en_b == 1'b1 && cnt_page_rd <= 7) begin
        cnt_page_rd <= cnt_page_rd + 1'b1;
    end
    else if(en_b == 1'b1) begin
        cnt_page_rd <= 1'b1;
        if(cnt_page_rd == 4'd8)
            page_cnt <= page_cnt + 1'b1;
    end
    else if(rd_eop == 1'b1) begin
        page_cnt <= 1'b0;
        cnt_page_rd <= 1'b0;
    end


//assign en_e = ((en_b) & (~en_c));

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        data_out1 <= 0;
        data_outb <= 0;
        addr_left <= 0;
        out_en <= 0;
    end
    else if(en_b == 1'b1 && cnt_page_rd > 1'b1) begin
        
        //data_out1 <= (data_out1 << 16) + data_outb;
        
        //data_out1 = data_out1;
        ////$display("data_out1 = %b",data_out1);
        /*if(cnt_out == addr_left - 2 && page_cnt >= 2)
            data_out1 <= ((data_out1 << 16) + data_outb) << ((8 - cnt_page_rd) << 4);
        else*/
            data_out1 <= (data_out1 << 16) + data_outb;
        /*if(cnt_out == addr_left - 2 && page_cnt >= 2)
            out_en <= 1'b1;*/
        if(cnt_page_rd == 8)
            out_en <= 1'b1;
        else
            out_en <= 1'b0;
        if(cnt_out == 0 && cnt_page_rd == 2)
            addr_left = data_outb[15:7];
        //$display("cnt_out = %d",cnt_out);
        /*//$display("data_out1 = %b",data_out1);
        //$display("data_outb = %b",data_outb);
        //$display("data_out1 = %b",data_out1);
        //$display("addr_inb = %b",addr_inb);
        
        //$display("addr_left = %d",addr_left);
        //$display("                             out_en = %d",out_en);
        //$display("cnt_page_rd = %d",cnt_page_rd);
        //$display("data_out = %b",data_out);
        //$display("page_cnt = %d",page_cnt);*/
    end
    else if(en_b == 1'b1 && cnt_page_rd == 1'b1) begin
        
        /*if(cnt_out == addr_left - 2 && page_cnt >= 2)
            data_out1 = data_outb << ((8 - cnt_page_rd) << 4);
        else*/
            data_out1 <= data_outb;
        /*if(cnt_out == addr_left - 2 && page_cnt >= 2)
            out_en <= 1'b1;
        else*/
            out_en <= 1'b0;
        /*//$display("data_out1 = %b",data_out1);
        //$display("data_outb = %b",data_outb);
        //$display("en_b = %b",en_b);
        //$display("addr_inb = %b",addr_inb);*/
        
    end
    else if(en_b == 0)
        data_out1 <= 0;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
    begin
        port_cnt <= 0;
        bit_im <= 0;
    end
    else if(en_a == 1'b1 && cnt_page == 3'd0) begin
        port_cnt[port_ina] <= port_cnt[port_ina] + 1'b1;
        bit_im[ptr_1] <= 1'b1;
    end
    else if(en_b == 1'b1 && out_en == 1'b1) begin
        port_cnt[port_inb] <= port_cnt[port_inb] - 1'b1;
        bit_im[addr_inb] <= 1'b0;
    end

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_reg <= 1'b0;
    else if(en_a == 1'b1 && en_b == 1'b0 && cnt_page == 3'd1)
        cnt_reg <= cnt_reg + 1'b1;
    else if(en_a == 1'b0 && en_b == 1'b1 && cnt_page == 3'd1)
        cnt_reg <= cnt_reg - 1'b1;

assign  rd_fin  =   (cnt_page_rd == 3'd7) ? 1'b1 : 1'b0;

assign  cnt_em  =   12'd2048 - cnt_reg  ;

always@(cnt_page,en_d)
    if(sys_rst_n == 1'b0)
        addr_a <= 0;
    else begin
        addr_a <= (ptr_1 << 3) + cnt_page;
        //$display(" cnt_page = %d",cnt_page);
    end
        
logic   [13:0]  addr_b  ;

assign  addr_b = (addr_inb << 3) + cnt_page_rd - 1;

reg    tem_p   ;

always@(page_en,sys_rst_n,data_t)
    if(sys_rst_n == 1'b0) begin
        ptr_1 = 1'b0;
        ptr_2 = 1'b0;
        ptr_3 = 1'b0;
        ptr_fi = 0;
    end
    else if(page_en == 1'b1)begin
        bit_cnt = bit_im;
        bit_cnt = ~bit_cnt;
        //ptr_3 = ptr_1;
        ////$display("ptr_3 = %b",ptr_3);
        bit_cnt = bit_cnt & (bit_cnt ^ (bit_cnt - 1));
        //ptr_1 = $clog2(bit_cnt);
        for(i=0;i<2048;i=i+1)
            if(bit_cnt[i] == 1)
                ptr_1 = i;
        //$display("bit_cnt = %d",bit_cnt);
        ptr_2 = bit_im[ptr_1 + 1];
        ptr_fi = 1;
    end
    else if(page_en == 1'b0)
        ptr_fi = 0;


assign  btim_en = ((page_en == 1'b1 || wr_eop == 1'b1) && (enc_eop == 1'b1));

sram_base   sram_base_inst
(
    .sys_clk    (sys_clk    )   ,
    .sys_rst_n  (sys_rst_n  )   ,
    .en_a       (en_a       )   ,
    .en_b       (en_b       )   ,
    .addr_a     (addr_a     )   ,
    .addr_b     (addr_b     )   ,
    .data_ina   (data_ina   )   ,

    .data_outb  (data_outb  )   

);

ecc_encoder ecc_encoder_inst
(
    .data       (page_dat   )   ,
    
    .sec_code   (ecc_dat    )   ,
    .enc_eop    (enc_eop    )

);

ecc_decoder ecc_decoder_inst
(
    .data           (data_out1      )   ,
    .sec_code       (sec_code       )   ,
    .cnt_page_rd    (cnt_page_rd    )   ,
    
    .cr_data        (data_out       )

);

blk_mem_gen_0 blk_mem_gen_0_inst
(
    .clka       (sys_clk    )   ,
    .ena        (btim_en    )   ,
    .addra      (ptr_1      )   ,
    .dina       (ecc_dat    )   ,
    .addrb      (addr_b     )   ,
    .enb        (en_b       )   ,
    .clkb       (sys_clk    )   ,
    .doutb      (sec_code   )
    
);

endmodule