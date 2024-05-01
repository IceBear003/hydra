`timescale  1ns/1ns

module top_sram 
(
    input    wire    sys_clk     ,   
    input    wire    sys_rst_n   ,
    input   wire    [15:0]  wr_sop  ,
    input   wire    [15:0]  wr_eop  ,
    input   wire    [15:0]  wr_vld  ,
    input   wire    [15:0][15:0]  wr_data ,
    input   wire    [15:0]  ready   ,

    output  logic   [15:0]  rd_sop  ,
    output  logic   [15:0]  rd_eop  ,
    output  logic   [15:0]  rd_vld  ,
    output  logic   [15:0][15:0]  rd_data   ,
    output  logic   [15:0]  page_fr ,
    output  logic   [15:0]  data_fr ,
    output  logic   wr_s    ,
    output  logic   wr_b    ,
    output  logic   [4:0]   sram_now    ,
    output  logic   [15:0]  addr_vld      
    

);
logic   [31:0]  en_a    ;
logic   [15:0][2:0] prior   ;
logic   [15:0][2:0] pri     ;
logic   [15:0][3:0] dest_port   ;
logic   [15:0][15:0]    port_data   ;
logic   [15:0]  port_en ;
logic   [15:0]  wr_eop_1    ;
//logic   [4:0]   sram_now    ;
logic   [31:0]  en_b    ;
//logic   [15:0]  page_fr ;
logic   [31:0][15:0]   data_ina    ;
logic   [31:0][10:0]    ptr_f   ;
logic   [31:0]    ptr_nxt   ;
logic   [31:0][10:0]    cnt_em  ;
logic   [31:0][2:0]     sram_sta    ;
logic   [15:0][4:0] port_sram   ;
logic   [15:0][4:0] wr_port_sram   ;
logic   [15:0][10:0] port_addr   ;
logic   [15:0]   port_out   ;
logic   [31:0][10:0] rd_addr   ;
logic   [15:0][20:0] addr_in   ;
logic   [15:0]   ready_1   ;
logic   [15:0][4:0] dest_sram   ;
logic   [15:0][4:0] rd_cnt     ;
logic   [15:0]  new_vld     ;
logic   [15:0][8:0] port_left   ;
logic   [15:0][8:0] addr_left   ;
//sram_now待定
logic   [10:0]  sram_mx ;
logic   [31:0]  port_wr_eop ;
    ;
logic   [15:0][127:0]   pre_dat ;
logic   [15:0][15:0]   pre_dec ;
logic   [15:0]  dat_en  ;
logic   [15:0][8:0] cnt_out ;
logic   [15:0][1023:0]  port_buf    ;
logic   [15:0]  dest_buf    ;
logic   [15:0]  dest_ocu    ;
logic   [15:0][8:0] cnt_in  ;
logic   [15:0][8:0] data_len    ;
logic   [15:0]  buf_en  ;
logic   [15:0]  buf_in  ;
logic   [31:0]  page_en ;
logic   [31:0]  ptr_fi ;
logic   [15:0]  wr_eop_dest ;
//logic   [15:0]  data_fr ;

integer i;

initial begin
    page_fr <= 0;
    data_fr <= 0;
    en_a <= 0;
    en_b <= 0;
    wr_port_sram <= 0;
    port_sram <= 0;
    pri <= 0;
    port_out <= 0;
    addr_vld <= 0;
    prior <= 0;
    //wr_vld <= 0;
    //$display("11111");
end

always@(wr_sop,wr_port_sram,sram_sta) begin
    sram_mx = 0;
    sram_now = 0;
    for(i=0;i!=8;i=i+1)
        if(sram_sta[i][0] == 1'b0) begin
            if(ptr_nxt[i] == 1'b0 && cnt_em[i] <= 11'd1536) begin
                sram_now = i;
                sram_mx = 1'b1;
            end
        end
        
    if(sram_mx == 1'b0) begin
        for(i=0;i!=8;i=i+1)
            if(sram_sta[i][0] == 1'b0) begin
                if(cnt_em[i] <= 11'd1536 && cnt_em[i] >= 11'd256) begin
                    sram_now = i;
                    sram_mx = 1'b1;
                end
            end
    end
    
    if(sram_mx == 1'b0) begin
        for(i=0;i!=8;i=i+1)
            if(sram_sta[i][0] == 1'b0) begin
                if(cnt_em[i] <= 11'd1536 && cnt_em[i] >= 11'd256) begin
                    sram_now = i;
                    sram_mx = 1'b1; 
                end
            end
    end
    
    if(sram_mx == 1'b0) begin
        for(i=0;i!=8;i=i+1)
            if(sram_sta[i][0] == 1'b0) begin
                sram_now = i;
                sram_mx = 1'b1;
            end
    end
end

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_eop_1 <= 0;
    else
        wr_eop_1 <= wr_eop;

always@(page_fr,port_en,sys_rst_n,sys_clk) begin
    if(sys_rst_n == 1'b0) begin
        wr_port_sram = 0;
        port_sram = 0;
        port_addr = 0;
        sram_sta = 0;
        pri = 0;
        port_out = 0;
        dest_ocu = 0;
    end
    else
    for(i=0;i<16;i=i+1)
        if(page_fr[i] == 1'b1 && port_en[i] == 1'b1) begin
            //$display("i = %d",i);
            wr_port_sram[i] = i;
            //$display("wr_port_sram[i] = %d",wr_port_sram[i]);
            port_sram[i] = wr_port_sram[i];
            
            sram_sta[port_sram[i]][0] = 1'b1;
            //pri[dest_port[i]] = prior[i];
            //port_out[dest_port[i]] = 1'b1;
            //$display("port_out[i] = %d",port_out[i]);
            //$display("dest_port[i] = %d",dest_port[i]);
            //$display("port_addr[i] = %d",port_addr[i]);
            //$display("prior[i] = %d",prior[i]);
            //dest_ocu[dest_port[i]] = 1'b1;
        end
        /*else if(page_fr[i] == 1'b0 && port_en[i] == 1'b1)
            port_out[dest_port[i]] = 1'b0;*/
end

always@(page_fr,port_en,sys_rst_n,sys_clk,ptr_fi) begin
    if(sys_rst_n == 1'b0) begin
        wr_port_sram = 0;
        port_sram = 0;
        port_addr = 0;
        sram_sta = 0;
        pri = 0;
        port_out = 0;
        dest_ocu = 0;
    end
    else
    for(i=0;i<16;i=i+1)
        if(page_fr[i] == 1'b1 && port_en[i] == 1'b1 && ptr_fi[wr_port_sram[i]] == 1'b1) begin
            pri[dest_port[i]] = prior[i];
            port_out[dest_port[i]] = 1'b1;
            port_addr[dest_port[i]] = ptr_f[port_sram[i]];
            $display("i = %d",i);
            $display("port_out[i] = %d",port_out[i]);
            $display("dest_port[i] = %d",dest_port[i]);
            $display("port_addr[i] = %d",port_addr[i]);
            $display("prior[i] = %d",prior[i]);
            dest_ocu[dest_port[i]] = 1'b1;
        end
        else if(page_fr[i] == 1'b0 && port_en[i] == 1'b1)
            port_out[dest_port[i]] = 1'b0;
end

/*
always@(page_fr,port_en) begin
    for(i=0;i<16;i=i+1)
        if(page_fr[i] == 1'b1 && port_en[i] == 1'b1)
            port_out[dest_port[i]] = 1'b1;
        else if(page_fr[i] == 1'b0 && port_en[i] == 1'b1)
            port_out[dest_port[i]] = 1'b0;
end
*/
//port_out在某些情况下没有触发

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ready_1 = 0;
    else
        for(i=0;i<16;i=i+1)
            ready_1[i] <= ready[i];

//如果同时取出的两个数据存在同一个sram中

always@(port_en,wr_eop_1,sys_clk,sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        en_a <= 1'b0;
        data_ina <= 1'b0;
        //port_wr_eop <= 1'b0;
    end
    else
    for(i=0;i<16;i=i+1) begin
        if(port_en[i] == 1'b1) begin
            //$display("i = %d",i);
            //$display("wr_port_sram[i] = %d",wr_port_sram[i]);
            en_a[wr_port_sram[i]] = 1'b1;
            //$display("en_a[wr_port_sram[i]] = %d",en_a[wr_port_sram[i]]);
            data_ina[wr_port_sram[i]] = port_data[i];
            //$display("ptr_f[i] = %d",ptr_f[i]);
            //$display("port_data[i] = %d",port_data[i]);
            //$display("data_ina[wr_port_sram[i]] = %d",data_ina[wr_port_sram[i]]);
            port_addr[dest_port[i]] = ptr_f[port_sram[i]];
            //将wr_eop输入端口，以防输入数据最后页不满
            //$display("wr_eop[i] = %d",wr_eop[i]);
            wr_eop_dest[dest_port[i]] = wr_eop[i];
            port_wr_eop[wr_port_sram[i]] = wr_eop[i];
        end
        if(wr_eop_1[i] == 1'b1)
            en_a[wr_port_sram[i]] <= 1'b0;
    end

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        wr_eop_dest <= 0;
        port_wr_eop <= 0;
    end
    else begin
        for(i=0;i<16;i=i+1)
            if(wr_eop_dest[i] == 1'b1)
                wr_eop_dest[i] <= 1'b0;
        for(i=0;i<32;i=i+1)
            if(port_wr_eop[i] == 1'b1)
                port_wr_eop[i] <= 1'b0;
    end
            

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        dest_ocu <= 1'b0;
        sram_sta <= 1'b0;
    end
    else
    for(i=0;i<16;i=i+1)
        if(wr_eop_1[i] == 1'b1) begin
            dest_ocu[dest_port[i]] = 1'b0;
            sram_sta[wr_port_sram[i]][0] = 1'b0;
            port_out[dest_port[i]] <= 1'b0;
        end

assign  rd_sop = ready_1;

//如果要同时读一个sram

always@(rd_sop,addr_vld)
    if(sys_rst_n == 1'b0) begin
        dest_sram <= 1'b0;
        rd_addr <= 1'b0;
        en_b <= 1'b0;
        //rd_vld <= 1'b0;
    end
    else
    for(i=0;i<16;i=i+1)
        if(rd_sop[i] == 1'b1 && addr_vld[i] == 1'b1) begin
            dest_sram[i] = addr_in[i][20:16];
            rd_addr[dest_sram[i]] = addr_in[i][15:5];
            sram_sta[dest_sram[i]][1] = 1'b1;
            en_b[dest_sram[i]] = 1'b1;
            //$display("                   dest_sram[i] = %d",dest_sram[i]);
            //$display("                   addr_in[i] = %b",addr_in[i]);
            //$display("                    rd_addr[dest_sram[i]] = %b",rd_addr[dest_sram[i]]);
            if(addr_in[i][4:0] == 0)
                new_vld[i] = 1'b1;
            else
                addr_in[i] = addr_in[i] + 31;
            rd_vld[i] <= 1'b1;
        end

logic   [15:0][8:0]   cnt_fir;
logic   [15:0]  rd_b    ;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_b <= 0;
    else
        for(i=0;i<16;i=i+1)
            if(rd_sop[i] == 1'b1)
                rd_b[i] = 1'b1;
            else if(rd_eop[i] == 1'b1)
                rd_b[i] = 1'b0;
            

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        cnt_fir <= 0;
        rd_vld <= 0;
    end
    else
        for(i=0;i<16;i=i+1) begin
            if(rd_b[i] == 1'b1) begin
                cnt_fir[i] <= cnt_fir[i] + 1'b1;
                ////$display("                                                cnt_fir[i] = %d",cnt_fir[i]);
                if(cnt_fir[i] == 10)
                    rd_vld[i] <= 1'b1;
                if(cnt_out[i] == addr_left[dest_sram[i]] + 8)
                    rd_vld[i] <= 1'b0;
            end
            else if(rd_eop[i] == 1'b1)
                cnt_fir[i] <= 1'b0;
        end
                
    
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        port_left <= 1'b0;
        addr_left <= 1'b0;
        cnt_out <= 1'b0;
    end
    else
    for(i=0;i<16;i=i+1)
        if(cnt_fir[i] == 2) begin
            port_left[i] = pre_dat[i][127:119];
            ////$display("pre_dat[i] = %b",pre_dat[i]);
            ////$display("out_dat[i] = %b",out_dat[i]);
            ////$display("port_left[i] = %d",port_left[i]);
            ////$display("                dat_en[i] = %d",dat_en[i]);
            //addr_left[i] = port_left[i];
            cnt_out[i] <= 1'b1;
        end
/*
always@(posedge sys_clk or  negedge sys_rst_n)
    for(i=0;i<16;i=i+1)
        if(wr_vld[i] == 1'b1) begin
            cnt_in[i] = cnt_in[i] + 1'b1;
            if(cnt_in[i] == data_len[i])
                page_en[wr_port_sram[i]] = 1'b1;
        end
     */   
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        rd_eop <= 1'b0;
    end
    else
    for(i=0;i<16;i=i+1)
        if(cnt_out[dest_sram[i]] >= 1'b1) begin
            if(cnt_out[dest_sram[i]] != addr_left[dest_sram[i]] + 8) begin
                
                cnt_out[dest_sram[i]] <= cnt_out[dest_sram[i]] + 1'b1;
                ////$display("pre_dat[i] = %b",pre_dat[i]);
                ////$display("cnt_out[i] = %b",cnt_out[i]);
                ////$display("                addr_left[dest_sram[i]] = %d",addr_left[dest_sram[i]]);
            end
            else if(cnt_fir[i] > 8)begin
                cnt_out[dest_sram[i]] <= 1'b0;
                rd_eop[i] <= 1'b1;
                en_b[dest_sram[i]] <= 1'b0;
            end
        end
        else
            rd_eop[i] <= 1'b0;
/*
always@(posedge sys_clk or  negedge sys_rst_n)
    if(cnt_out[0] >= 1'b1) begin
        if(cnt_out[0] != addr_left[0])
            cnt_out[0] <= cnt_out[0] + 1'b1;
        else begin
            cnt_out[0] <= 1'b0;
            rd_eop[0] <= 1'b1;
        end
    end
    else
        rd_eop[0] <= 1'b0;
*/
always@(rd_vld,dat_en,sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        addr_in <= 1'b0;
        port_left <= 1'b0;
        new_vld <= 1'b0;
    end
    else
    for(i=0;i<16;i=i+1)
        if(rd_vld[i] == 1'b1 && dat_en[dest_sram[i]] == 1'b1) begin
            port_left[i] = port_left[i] - 8;
            $display("i = %d",i);
            $display("                         addr_in[i] = %b",addr_in[i]);
            $display("addr_left[dest_sram[i]] = %d",addr_left[dest_sram[i]]);
            $display("cnt_out[dest_sram[i]] = %d",cnt_out[dest_sram[i]]);
            $display("dest_sram[i] = %d",dest_sram[i]);
            if(addr_in[i][4:0] > 0) begin
                rd_addr[dest_sram[i]] = addr_in[i][15:5];
                addr_in[i] = addr_in[i] + 31;
            end
            else if(addr_in[i][4:0] == 0) begin
                rd_addr[dest_sram[i]] = addr_in[i][15:5];
                //addr_in[i] = addr_in[i] + 31;
                if(addr_left[dest_sram[i]] - 8 >= cnt_out[dest_sram[i]])
                    new_vld[i] = 1'b1;
            end
            $display("                   rd_addr[dest_sram[i]] = %d",rd_addr[dest_sram[i]]);
            $display("                         addr_in[i] = %b",addr_in[i]);
        end
        else if(dat_en[dest_sram[i]] == 1'b0)
            new_vld[i] = 1'b0;

logic   [15:0][2:0] out_cnt ;
logic   [15:0][127:0]    out_dat ;

always@(pre_dat,dat_en)
    if(sys_rst_n == 1'b0)
        out_dat <= 0;
    else
        for(i=0;i<32;i=i+1)
            if(dat_en[dest_sram[i]] == 1)
                out_dat[i] = pre_dat[i];


always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        rd_data <= 1'b0;
        out_cnt <= 1'b0;
    end
    else
    for(i=0;i<16;i=i+1)
        if(rd_sop[i] == 1'b1)
            out_cnt[i] <= 1'b0;
        else if(rd_vld[i] == 1'b1) begin //应和dat_en产生联系
            if((dat_en[dest_sram[i]] == 1'b1 && rd_vld[i] == 1'b1) || out_cnt == 8)
                out_cnt[i] = 1'b0;
            case(out_cnt[i])
            0:rd_data[i] = out_dat[i][127:112];
            1:rd_data[i] = out_dat[i][111:96];
            2:rd_data[i] = out_dat[i][95:80];
            3:rd_data[i] = out_dat[i][79:64];
            4:rd_data[i] = out_dat[i][63:48];
            5:rd_data[i] = out_dat[i][47:32];
            6:rd_data[i] = out_dat[i][31:16];
            7:rd_data[i] = out_dat[i][15:0];
            endcase
            out_cnt[i] <= out_cnt[i] + 1'b1;
            //rd_data[i] = pre_dat[i][15:0];
            //$display("      out_dat[i] = %b",out_dat[i]);
            //$display("rd_data = %b",rd_data[i]);
            //$display("out_cnt = %d",out_cnt[i]);
        end
        else if(rd_vld[i] == 1'b0) begin
            out_cnt[i] = 0;
            out_dat[i] = 0;
            rd_data[i] = 0;
        end

data_init   data_init_inst_0
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[0]      )   ,
    .wr_sop     (wr_sop[0]      )   ,
    .wr_data    (wr_data[0]     )   ,
    .wr_vld     (wr_vld[0]      )   ,
    .prior      (prior[0]       )   ,
    
    .data_len   (data_len[0]    )   ,
    .page_fr    (page_fr[0]     )   ,
    .data_fr    (data_fr[0]     )   ,
    .wr_s       (wr_s           )   ,
    .wr_b       (wr_b           )   ,
    .data_en    (port_en[0]     )   ,
    .dest_port  (dest_port[0]   )   ,       
    .data_out   (port_data[0]   )

);
data_init   data_init_inst_1
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[1]      )   ,
    .wr_sop     (wr_sop[1]      )   ,
    .wr_data    (wr_data[1]     )   ,
    .wr_vld     (wr_vld[1]      )   ,
    .prior      (prior[1]       )   ,
    
    .data_len   (data_len[1]    )   ,
    .page_fr    (page_fr[1]     )   ,
    .data_en    (port_en[1]     )   ,
    .dest_port  (dest_port[1]   )   ,       
    .data_out   (port_data[1]   )

);
data_init   data_init_inst_2
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[2]      )   ,
    .wr_sop     (wr_sop[2]      )   ,
    .wr_data    (wr_data[2]     )   ,
    .wr_vld     (wr_vld[2]      )   ,
    .prior      (prior[2]       )   ,
    
    .data_len   (data_len[2]    )   ,
    .page_fr    (page_fr[2]     )   ,
    .data_en    (port_en[2]     )   ,
    .dest_port  (dest_port[2]   )   ,       
    .data_out   (port_data[2]   )

);
data_init   data_init_inst_3
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[3]      )   ,
    .wr_sop     (wr_sop[3]      )   ,
    .wr_data    (wr_data[3]     )   ,
    .wr_vld     (wr_vld[3]      )   ,
    .prior      (prior[3]       )   ,
    
    .data_len   (data_len[3]    )   ,
    .page_fr    (page_fr[3]     )   ,
    .data_en    (port_en[3]     )   ,
    .dest_port  (dest_port[3]   )   ,       
    .data_out   (port_data[3]   )

);/*
data_init   data_init_inst_4
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[4]      )   ,
    .wr_sop     (wr_sop[4]      )   ,
    .wr_data    (wr_data[4]     )   ,
    .wr_vld     (wr_vld[4]      )   ,
    
    .data_len   (data_len[4]    )   ,
    .page_fr    (page_fr[4]     )   ,
    .data_en    (port_en[4]     )   ,
    .dest_port  (dest_port[4]   )   ,       
    .data_out   (port_data[4]   )

);
data_init   data_init_inst_5
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[5]      )   ,
    .wr_sop     (wr_sop[5]      )   ,
    .wr_data    (wr_data[5]     )   ,
    .wr_vld     (wr_vld[5]      )   ,
    
    .data_len   (data_len[5]    )   ,
    .page_fr    (page_fr[5]     )   ,
    .data_en    (port_en[5]     )   ,
    .dest_port  (dest_port[5]   )   ,       
    .data_out   (port_data[5]   )

);
data_init   data_init_inst_6
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[6]      )   ,
    .wr_sop     (wr_sop[6]      )   ,
    .wr_data    (wr_data[6]     )   ,
    .wr_vld     (wr_vld[6]      )   ,
    
    .data_len   (data_len[6]    )   ,
    .page_fr    (page_fr[6]     )   ,
    .data_en    (port_en[6]     )   ,
    .dest_port  (dest_port[6]   )   ,       
    .data_out   (port_data[6]   )

);
data_init   data_init_inst_7
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[7]      )   ,
    .wr_sop     (wr_sop[7]      )   ,
    .wr_data    (wr_data[7]     )   ,
    .wr_vld     (wr_vld[7]      )   ,
    
    .data_len   (data_len[7]    )   ,
    .page_fr    (page_fr[7]     )   ,
    .data_en    (port_en[7]     )   ,
    .dest_port  (dest_port[7]   )   ,       
    .data_out   (port_data[7]   )

);
data_init   data_init_inst_8
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[8]      )   ,
    .wr_sop     (wr_sop[8]      )   ,
    .wr_data    (wr_data[8]     )   ,
    .wr_vld     (wr_vld[8]      )   ,
    
    .data_len   (data_len[8]    )   ,
    .page_fr    (page_fr[8]     )   ,
    .data_en    (port_en[8]     )   ,
    .dest_port  (dest_port[8]   )   ,       
    .data_out   (port_data[8]   )

);
data_init   data_init_inst_9
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[9]      )   ,
    .wr_sop     (wr_sop[9]      )   ,
    .wr_data    (wr_data[9]     )   ,
    .wr_vld     (wr_vld[9]      )   ,
    
    .data_len   (data_len[9]    )   ,
    .page_fr    (page_fr[9]     )   ,
    .data_en    (port_en[9]     )   ,
    .dest_port  (dest_port[9]   )   ,       
    .data_out   (port_data[9]   )

);
data_init   data_init_inst_10
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[10]      )   ,
    .wr_sop     (wr_sop[10]      )   ,
    .wr_data    (wr_data[10]     )   ,
    .wr_vld     (wr_vld[10]      )   ,
    
    .data_len   (data_len[10]    )   ,
    .page_fr    (page_fr[10]     )   ,
    .data_en    (port_en[10]     )   ,
    .dest_port  (dest_port[10]   )   ,       
    .data_out   (port_data[10]   )

);
data_init   data_init_inst_11
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[11]      )   ,
    .wr_sop     (wr_sop[11]      )   ,
    .wr_data    (wr_data[11]     )   ,
    .wr_vld     (wr_vld[11]      )   ,
    
    .data_len   (data_len[11]    )   ,
    .page_fr    (page_fr[11]     )   ,
    .data_en    (port_en[11]     )   ,
    .dest_port  (dest_port[11]   )   ,       
    .data_out   (port_data[11]   )

);
data_init   data_init_inst_12
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[12]      )   ,
    .wr_sop     (wr_sop[12]      )   ,
    .wr_data    (wr_data[12]     )   ,
    .wr_vld     (wr_vld[12]      )   ,
    
    .data_len   (data_len[12]    )   ,
    .page_fr    (page_fr[12]     )   ,
    .data_en    (port_en[12]     )   ,
    .dest_port  (dest_port[12]   )   ,       
    .data_out   (port_data[12]   )

);
data_init   data_init_inst_13
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[13]      )   ,
    .wr_sop     (wr_sop[13]      )   ,
    .wr_data    (wr_data[13]     )   ,
    .wr_vld     (wr_vld[13]      )   ,
    
    .data_len   (data_len[13]    )   ,
    .page_fr    (page_fr[13]     )   ,
    .data_en    (port_en[13]     )   ,
    .dest_port  (dest_port[13]   )   ,       
    .data_out   (port_data[13]   )

);
data_init   data_init_inst_14
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[14]      )   ,
    .wr_sop     (wr_sop[14]      )   ,
    .wr_data    (wr_data[14]     )   ,
    .wr_vld     (wr_vld[14]      )   ,
    
    .data_len   (data_len[14]    )   ,
    .page_fr    (page_fr[14]     )   ,
    .data_en    (port_en[14]     )   ,
    .dest_port  (dest_port[14]   )   ,       
    .data_out   (port_data[14]   )

);
data_init   data_init_inst_15
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_eop     (wr_eop[15]      )   ,
    .wr_sop     (wr_sop[15]      )   ,
    .wr_data    (wr_data[15]     )   ,
    .wr_vld     (wr_vld[15]      )   ,
    
    .data_len   (data_len[15]    )   ,
    .page_fr    (page_fr[15]     )   ,
    .data_en    (port_en[15]     )   ,
    .dest_port  (dest_port[15]   )   ,       
    .data_out   (port_data[15]   )

);
*/
/*
generate
    genvar j;

    for(j=0;j<16;j=j+1) begin
        data_init   data_init_inst
        (
            .data_len   (data_len[j]    )   ,

            .page_fr    (page_fr[j]     )   ,
            .data_en    (port_en[j]     )   ,
            .dest_port  (dest_port[j]   )   ,
            .data_out   (port_data[j]   )

        );
        
        sram_que    sram_que_inst
        (
            .rd_sop     (rd_sop[j]      )   ,
            .port_en    (port_out[j]    )   ,
            .prior      (pri[j]         )   ,
            .sram_num   (port_sram[j]   )   ,
            .ptr_1      (port_addr[j]   )   ,
            .pre_dec    (addr_in[j]     )   ,
            .new_vld    (new_vld[j]     )   ,
            .addr_en    (addr_vld[j]    )   ,
            .ready_1    (ready_1[j]     )   ,
            .rd_vld     (rd_vld[j]      )

        );
    end
endgenerate
*/

sram_que    sram_que_inst_0
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
        .rd_sop     (rd_sop[0]      )   ,
        .port_en    (port_out[0]    )   ,
        .prior      (pri[0]         )   ,
        .sram_num   (port_sram[0]   )   ,
        .ptr_1      (port_addr[0]   )   ,
        .pre_dec    (addr_in[0]     )   ,
        .new_vld    (new_vld[0]     )   ,
        .addr_en    (addr_vld[0]    )   ,
        .ready_1    (ready_1[0]     )   ,
        .ready      (ready[0]       )   ,
        .rd_vld     (rd_vld[0]      )   ,
        .rd_eop     (rd_eop[0]      )   ,
        .que_num    (0              )   ,
        .wr_eop     (wr_eop_dest[0] )   

 );
sram_que    sram_que_inst_1
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
        .rd_sop     (rd_sop[1]      )   ,
        .port_en    (port_out[1]    )   ,
        .prior      (pri[1]         )   ,
        .sram_num   (port_sram[1]   )   ,
        .ptr_1      (port_addr[1]   )   ,
        .pre_dec    (addr_in[1]     )   ,
        .new_vld    (new_vld[1]     )   ,
        .addr_en    (addr_vld[1]    )   ,
        .ready_1    (ready_1[1]     )   ,
        .ready      (ready[1]       )   ,
        .rd_vld     (rd_vld[1]      )   ,
        .wr_eop     (wr_eop_dest[1] )   ,
        .que_num    (1              )   ,
        .rd_eop     (rd_eop[1]      )

 );
sram_que    sram_que_inst_2
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
        .rd_sop     (rd_sop[2]      )   ,
        .port_en    (port_out[2]    )   ,
        .prior      (pri[2]         )   ,
        .sram_num   (port_sram[2]   )   ,
        .ptr_1      (port_addr[2]   )   ,
        .pre_dec    (addr_in[2]     )   ,
        .new_vld    (new_vld[2]     )   ,
        .addr_en    (addr_vld[2]    )   ,
        .ready_1    (ready_1[2]     )   ,
        .ready      (ready[2]       )   ,
        .rd_vld     (rd_vld[2]      )   ,
        .wr_eop     (wr_eop_dest[2] )   ,
        .que_num    (2              )   ,
        .rd_eop     (rd_eop[2]      )

 );
sram_que    sram_que_inst_3
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
        .rd_sop     (rd_sop[3]      )   ,
        .port_en    (port_out[3]    )   ,
        .prior      (pri[3]         )   ,
        .sram_num   (port_sram[3]   )   ,
        .ptr_1      (port_addr[3]   )   ,
        .pre_dec    (addr_in[3]     )   ,
        .new_vld    (new_vld[3]     )   ,
        .addr_en    (addr_vld[3]    )   ,
        .ready_1    (ready_1[3]     )   ,
        .ready      (ready[3]       )   ,
        .rd_vld     (rd_vld[3]      )   ,
        .wr_eop     (wr_eop_dest[3] )   ,
        .que_num    (3              )   ,
        .rd_eop     (rd_eop[3]      )

 );/*
sram_que    sram_que_inst_4
(
        .rd_sop     (rd_sop[4]      )   ,
        .port_en    (port_out[4]    )   ,
        .prior      (pri[4]         )   ,
        .sram_num   (port_sram[4]   )   ,
        .ptr_1      (port_addr[4]   )   ,
        .pre_dec    (addr_in[4]     )   ,
        .new_vld    (new_vld[4]     )   ,
        .addr_en    (addr_vld[4]    )   ,
        .ready_1    (ready_1[4]     )   ,
        .rd_vld     (rd_vld[4]      )

 );
sram_que    sram_que_inst_5
(
        .rd_sop     (rd_sop[5]      )   ,
        .port_en    (port_out[5]    )   ,
        .prior      (pri[5]         )   ,
        .sram_num   (port_sram[5]   )   ,
        .ptr_1      (port_addr[5]   )   ,
        .pre_dec    (addr_in[5]     )   ,
        .new_vld    (new_vld[5]     )   ,
        .addr_en    (addr_vld[5]    )   ,
        .ready_1    (ready_1[5]     )   ,
        .rd_vld     (rd_vld[5]      )

 );
sram_que    sram_que_inst_6
(
        .rd_sop     (rd_sop[6]      )   ,
        .port_en    (port_out[6]    )   ,
        .prior      (pri[6]         )   ,
        .sram_num   (port_sram[6]   )   ,
        .ptr_1      (port_addr[6]   )   ,
        .pre_dec    (addr_in[6]     )   ,
        .new_vld    (new_vld[6]     )   ,
        .addr_en    (addr_vld[6]    )   ,
        .ready_1    (ready_1[6]     )   ,
        .rd_vld     (rd_vld[6]      )

 );
sram_que    sram_que_inst_7
(
        .rd_sop     (rd_sop[7]      )   ,
        .port_en    (port_out[7]    )   ,
        .prior      (pri[7]         )   ,
        .sram_num   (port_sram[7]   )   ,
        .ptr_1      (port_addr[7]   )   ,
        .pre_dec    (addr_in[7]     )   ,
        .new_vld    (new_vld[7]     )   ,
        .addr_en    (addr_vld[7]    )   ,
        .ready_1    (ready_1[7]     )   ,
        .rd_vld     (rd_vld[7]      )

 );
sram_que    sram_que_inst_8
(
        .rd_sop     (rd_sop[8]      )   ,
        .port_en    (port_out[8]    )   ,
        .prior      (pri[8]         )   ,
        .sram_num   (port_sram[8]   )   ,
        .ptr_1      (port_addr[8]   )   ,
        .pre_dec    (addr_in[8]     )   ,
        .new_vld    (new_vld[8]     )   ,
        .addr_en    (addr_vld[8]    )   ,
        .ready_1    (ready_1[8]     )   ,
        .rd_vld     (rd_vld[8]      )

 );
sram_que    sram_que_inst_9
(
        .rd_sop     (rd_sop[9]      )   ,
        .port_en    (port_out[9]    )   ,
        .prior      (pri[9]         )   ,
        .sram_num   (port_sram[9]   )   ,
        .ptr_1      (port_addr[9]   )   ,
        .pre_dec    (addr_in[9]     )   ,
        .new_vld    (new_vld[9]     )   ,
        .addr_en    (addr_vld[9]    )   ,
        .ready_1    (ready_1[9]     )   ,
        .rd_vld     (rd_vld[9]      )

 );
sram_que    sram_que_inst_10
(
        .rd_sop     (rd_sop[10]      )   ,
        .port_en    (port_out[10]    )   ,
        .prior      (pri[10]         )   ,
        .sram_num   (port_sram[10]   )   ,
        .ptr_1      (port_addr[10]   )   ,
        .pre_dec    (addr_in[10]     )   ,
        .new_vld    (new_vld[10]     )   ,
        .addr_en    (addr_vld[10]    )   ,
        .ready_1    (ready_1[10]     )   ,
        .rd_vld     (rd_vld[10]      )

 );
sram_que    sram_que_inst_11
(
        .rd_sop     (rd_sop[11]      )   ,
        .port_en    (port_out[11]    )   ,
        .prior      (pri[11]         )   ,
        .sram_num   (port_sram[11]   )   ,
        .ptr_1      (port_addr[11]   )   ,
        .pre_dec    (addr_in[11]     )   ,
        .new_vld    (new_vld[11]     )   ,
        .addr_en    (addr_vld[11]    )   ,
        .ready_1    (ready_1[11]     )   ,
        .rd_vld     (rd_vld[11]      )

 );
sram_que    sram_que_inst_12
(
        .rd_sop     (rd_sop[12]      )   ,
        .port_en    (port_out[12]    )   ,
        .prior      (pri[12]         )   ,
        .sram_num   (port_sram[12]   )   ,
        .ptr_1      (port_addr[12]   )   ,
        .pre_dec    (addr_in[12]     )   ,
        .new_vld    (new_vld[12]     )   ,
        .addr_en    (addr_vld[12]    )   ,
        .ready_1    (ready_1[12]     )   ,
        .rd_vld     (rd_vld[12]      )

 );
sram_que    sram_que_inst_13
(
        .rd_sop     (rd_sop[13]      )   ,
        .port_en    (port_out[13]    )   ,
        .prior      (pri[13]         )   ,
        .sram_num   (port_sram[13]   )   ,
        .ptr_1      (port_addr[13]   )   ,
        .pre_dec    (addr_in[13]     )   ,
        .new_vld    (new_vld[13]     )   ,
        .addr_en    (addr_vld[13]    )   ,
        .ready_1    (ready_1[13]     )   ,
        .rd_vld     (rd_vld[13]      )

 );
sram_que    sram_que_inst_14
(
        .rd_sop     (rd_sop[14]      )   ,
        .port_en    (port_out[14]    )   ,
        .prior      (pri[14]         )   ,
        .sram_num   (port_sram[14]   )   ,
        .ptr_1      (port_addr[14]   )   ,
        .pre_dec    (addr_in[14]     )   ,
        .new_vld    (new_vld[14]     )   ,
        .addr_en    (addr_vld[14]    )   ,
        .ready_1    (ready_1[14]     )   ,
        .rd_vld     (rd_vld[14]      )

 );
sram_que    sram_que_inst_15
(
        .rd_sop     (rd_sop[15]      )   ,
        .port_en    (port_out[15]    )   ,
        .prior      (pri[15]         )   ,
        .sram_num   (port_sram[15]   )   ,
        .ptr_1      (port_addr[15]   )   ,
        .pre_dec    (addr_in[15]     )   ,
        .new_vld    (new_vld[15]     )   ,
        .addr_en    (addr_vld[15]    )   ,
        .ready_1    (ready_1[15]     )   ,
        .rd_vld     (rd_vld[15]      )

 );*/


sram_ctrl   sram_ctrl_inst_0
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
     .en_a       (en_a[0]        )   ,
     .data_ina   (data_ina[0]    )   ,
     .en_b       (en_b[0]        )   ,
     .addr_inb     (rd_addr[0]     )   ,
     .wr_eop     (port_wr_eop[0] )   ,
     .rd_eop     (rd_eop[0]      )   ,
     .cnt_out    (cnt_out[0]     )   ,
     .addr_left  (addr_left[0]   )   ,
            
     .ptr_1      (ptr_f[0]       )   ,
     .ptr_2      (ptr_nxt[0]     )   ,
     .data_out   (pre_dat[0]     )   ,
     .out_en     (dat_en[0]      )   ,
     .cnt_em     (cnt_em[0]      )   ,
     .ptr_fi    (ptr_fi[0]     )

);
sram_ctrl   sram_ctrl_inst_1
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
     .en_a       (en_a[1]        )   ,
     .data_ina   (data_ina[1]    )   ,
     .en_b       (en_b[1]        )   ,
     .addr_inb     (rd_addr[1]     )   ,
     .wr_eop     (port_wr_eop[1] )   ,
     .rd_eop     (rd_eop[1]      )   ,
     .cnt_out    (cnt_out[1]     )   ,
     .addr_left  (addr_left[1]   )   ,
            
     .ptr_1      (ptr_f[1]       )   ,
     .ptr_2      (ptr_nxt[1]     )   ,
     .data_out   (pre_dat[1]     )   ,
     .out_en     (dat_en[1]      )   ,
     .cnt_em     (cnt_em[1]      )   ,
     .ptr_fi    (ptr_fi[1]     )

);
sram_ctrl   sram_ctrl_inst_2
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
     .en_a       (en_a[2]        )   ,
     .data_ina   (data_ina[2]    )   ,
     .en_b       (en_b[2]        )   ,
     .addr_inb     (rd_addr[2]     )   ,
     .wr_eop     (port_wr_eop[2] )   ,
     .rd_eop     (rd_eop[2]      )   ,
     .cnt_out    (cnt_out[2]     )   ,
     .addr_left  (addr_left[2]   )   ,
            
     .ptr_1      (ptr_f[2]       )   ,
     .ptr_2      (ptr_nxt[2]     )   ,
     .data_out   (pre_dat[2]     )   ,
     .out_en     (dat_en[2]      )   ,
     .cnt_em     (cnt_em[2]      )   ,
     .ptr_fi    (ptr_fi[2]     )

);
sram_ctrl   sram_ctrl_inst_3
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
     .en_a       (en_a[3]        )   ,
     .data_ina   (data_ina[3]    )   ,
     .en_b       (en_b[3]        )   ,
     .addr_inb     (rd_addr[3]     )   ,
     .wr_eop     (port_wr_eop[3] )   ,
     .rd_eop     (rd_eop[3]      )   ,
     .cnt_out    (cnt_out[3]     )   ,
     .addr_left  (addr_left[3]   )   ,
            
     .ptr_1      (ptr_f[3]       )   ,
     .ptr_2      (ptr_nxt[3]     )   ,
     .data_out   (pre_dat[3]     )   ,
     .out_en     (dat_en[3]      )   ,
     .cnt_em     (cnt_em[3]      )   ,
     .ptr_fi    (ptr_fi[3]     )

);
sram_ctrl   sram_ctrl_inst_4
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
     .en_a       (en_a[4]        )   ,
     .data_ina   (data_ina[4]    )   ,
     .en_b       (en_b[4]        )   ,
     .addr_inb     (rd_addr[4]     )   ,
     .wr_eop     (port_wr_eop[4] )   ,
     .rd_eop     (rd_eop[4]      )   ,
     .cnt_out    (cnt_out[4]     )   ,
     .addr_left  (addr_left[4]   )   ,
            
     .ptr_1      (ptr_f[4]       )   ,
     .ptr_2      (ptr_nxt[4]     )   ,
     .data_out   (pre_dat[4]     )   ,
     .out_en     (dat_en[4]      )   ,
     .cnt_em     (cnt_em[4]      )   ,
     .ptr_fi    (ptr_fi[4]     )

);
sram_ctrl   sram_ctrl_inst_5
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
     .en_a       (en_a[5]        )   ,
     .data_ina   (data_ina[5]    )   ,
     .en_b       (en_b[5]        )   ,
     .addr_inb     (rd_addr[5]     )   ,
     .wr_eop     (port_wr_eop[5] )   ,
     .rd_eop     (rd_eop[5]      )   ,
     .cnt_out    (cnt_out[5]     )   ,
     .addr_left  (addr_left[5]   )   ,
            
     .ptr_1      (ptr_f[5]       )   ,
     .ptr_2      (ptr_nxt[5]     )   ,
     .data_out   (pre_dat[5]     )   ,
     .out_en     (dat_en[5]      )   ,
     .cnt_em     (cnt_em[5]      )   ,
     .ptr_fi    (ptr_fi[5]     )

);
sram_ctrl   sram_ctrl_inst_6
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
     .en_a       (en_a[6]        )   ,
     .data_ina   (data_ina[6]    )   ,
     .en_b       (en_b[6]        )   ,
     .addr_inb     (rd_addr[6]     )   ,
     .wr_eop     (port_wr_eop[6] )   ,
     .rd_eop     (rd_eop[6]      )   ,
     .cnt_out    (cnt_out[6]     )   ,
     .addr_left  (addr_left[6]   )   ,
            
     .ptr_1      (ptr_f[6]       )   ,
     .ptr_2      (ptr_nxt[6]     )   ,
     .data_out   (pre_dat[6]     )   ,
     .out_en     (dat_en[6]      )   ,
     .cnt_em     (cnt_em[6]      )   ,
     .ptr_fi    (ptr_fi[6]     )

);
sram_ctrl   sram_ctrl_inst_7
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
     .en_a       (en_a[7]        )   ,
     .data_ina   (data_ina[7]    )   ,
     .en_b       (en_b[7]        )   ,
     .addr_inb     (rd_addr[7]     )   ,
     .wr_eop     (port_wr_eop[7] )   ,
     .rd_eop     (rd_eop[7]      )   ,
     .cnt_out    (cnt_out[7]     )   ,
     .addr_left  (addr_left[7]   )   ,
            
     .ptr_1      (ptr_f[7]       )   ,
     .ptr_2      (ptr_nxt[7]     )   ,
     .data_out   (pre_dat[7]     )   ,
     .out_en     (dat_en[7]      )   ,
     .cnt_em     (cnt_em[7]      )   ,
     .ptr_fi    (ptr_fi[7]     )

);/*
sram_ctrl   sram_ctrl_inst_8
(
     .en_a       (en_a[8]        )   ,
     .data_ina   (data_ina[8]    )   ,
     .en_b       (en_b[8]        )   ,
     .addr_inb     (rd_addr[8]     )   ,
     .wr_eop     (port_wr_eop[8] )   ,
     .rd_eop     (rd_eop[8]      )   ,
     .cnt_out    (cnt_out[8]     )   ,
     .addr_left  (addr_left[8]   )   ,
            
     .ptr_1      (ptr_f[8]       )   ,
     .ptr_2      (ptr_nxt[8]     )   ,
     .data_out   (pre_dat[8]     )   ,
     .out_en     (dat_en[8]      )   ,
     .cnt_em     (cnt_em[8]      )

);
sram_ctrl   sram_ctrl_inst_9
(
     .en_a       (en_a[9]        )   ,
     .data_ina   (data_ina[9]    )   ,
     .en_b       (en_b[9]        )   ,
     .addr_inb     (rd_addr[9]     )   ,
     .wr_eop     (port_wr_eop[9] )   ,
     .rd_eop     (rd_eop[9]      )   ,
     .cnt_out    (cnt_out[9]     )   ,
     .addr_left  (addr_left[9]   )   ,
            
     .ptr_1      (ptr_f[9]       )   ,
     .ptr_2      (ptr_nxt[9]     )   ,
     .data_out   (pre_dat[9]     )   ,
     .out_en     (dat_en[9]      )   ,
     .cnt_em     (cnt_em[9]      )

);
sram_ctrl   sram_ctrl_inst_10
(
     .en_a       (en_a[10]        )   ,
     .data_ina   (data_ina[10]    )   ,
     .en_b       (en_b[10]        )   ,
     .addr_inb     (rd_addr[10]     )   ,
     .wr_eop     (port_wr_eop[10] )   ,
     .rd_eop     (rd_eop[10]      )   ,
     .cnt_out    (cnt_out[10]     )   ,
     .addr_left  (addr_left[10]   )   ,
            
     .ptr_1      (ptr_f[10]       )   ,
     .ptr_2      (ptr_nxt[10]     )   ,
     .data_out   (pre_dat[10]     )   ,
     .out_en     (dat_en[10]      )   ,
     .cnt_em     (cnt_em[10]      )

);
sram_ctrl   sram_ctrl_inst_11
(
     .en_a       (en_a[11]        )   ,
     .data_ina   (data_ina[11]    )   ,
     .en_b       (en_b[11]        )   ,
     .addr_inb     (rd_addr[11]     )   ,
     .wr_eop     (port_wr_eop[11] )   ,
     .rd_eop     (rd_eop[11]      )   ,
     .cnt_out    (cnt_out[11]     )   ,
     .addr_left  (addr_left[11]   )   ,
            
     .ptr_1      (ptr_f[11]       )   ,
     .ptr_2      (ptr_nxt[11]     )   ,
     .data_out   (pre_dat[11]     )   ,
     .out_en     (dat_en[11]      )   ,
     .cnt_em     (cnt_em[11]      )

);
sram_ctrl   sram_ctrl_inst_12
(
     .en_a       (en_a[12]        )   ,
     .data_ina   (data_ina[12]    )   ,
     .en_b       (en_b[12]        )   ,
     .addr_inb     (rd_addr[12]     )   ,
     .wr_eop     (port_wr_eop[12] )   ,
     .rd_eop     (rd_eop[12]      )   ,
     .cnt_out    (cnt_out[12]     )   ,
     .addr_left  (addr_left[12]   )   ,
            
     .ptr_1      (ptr_f[12]       )   ,
     .ptr_2      (ptr_nxt[12]     )   ,
     .data_out   (pre_dat[12]     )   ,
     .out_en     (dat_en[12]      )   ,
     .cnt_em     (cnt_em[12]      )

);
sram_ctrl   sram_ctrl_inst_13
(
     .en_a       (en_a[13]        )   ,
     .data_ina   (data_ina[13]    )   ,
     .en_b       (en_b[13]        )   ,
     .addr_inb     (rd_addr[13]     )   ,
     .wr_eop     (port_wr_eop[13] )   ,
     .rd_eop     (rd_eop[13]      )   ,
     .cnt_out    (cnt_out[13]     )   ,
     .addr_left  (addr_left[13]   )   ,
            
     .ptr_1      (ptr_f[13]       )   ,
     .ptr_2      (ptr_nxt[13]     )   ,
     .data_out   (pre_dat[13]     )   ,
     .out_en     (dat_en[13]      )   ,
     .cnt_em     (cnt_em[13]      )

);
sram_ctrl   sram_ctrl_inst_14
(
     .en_a       (en_a[14]        )   ,
     .data_ina   (data_ina[14]    )   ,
     .en_b       (en_b[14]        )   ,
     .addr_inb     (rd_addr[14]     )   ,
     .wr_eop     (port_wr_eop[14] )   ,
     .rd_eop     (rd_eop[14]      )   ,
     .cnt_out    (cnt_out[14]     )   ,
     .addr_left  (addr_left[14]   )   ,
            
     .ptr_1      (ptr_f[14]       )   ,
     .ptr_2      (ptr_nxt[14]     )   ,
     .data_out   (pre_dat[14]     )   ,
     .out_en     (dat_en[14]      )   ,
     .cnt_em     (cnt_em[14]      )

);
sram_ctrl   sram_ctrl_inst_15
(
     .en_a       (en_a[15]        )   ,
     .data_ina   (data_ina[15]    )   ,
     .en_b       (en_b[15]        )   ,
     .addr_inb     (rd_addr[15]     )   ,
     .wr_eop     (port_wr_eop[15] )   ,
     .rd_eop     (rd_eop[15]      )   ,
     .cnt_out    (cnt_out[15]     )   ,
     .addr_left  (addr_left[15]   )   ,
            
     .ptr_1      (ptr_f[15]       )   ,
     .ptr_2      (ptr_nxt[15]     )   ,
     .data_out   (pre_dat[15]     )   ,
     .out_en     (dat_en[15]      )   ,
     .cnt_em     (cnt_em[15]      )

);
sram_ctrl   sram_ctrl_inst_16
(
     .en_a       (en_a[16]        )   ,
     .data_ina   (data_ina[16]    )   ,
     .en_b       (en_b[16]        )   ,
     .addr_inb     (rd_addr[16]     )   ,
     .wr_eop     (port_wr_eop[16] )   ,
     .rd_eop     (rd_eop[16]      )   ,
     .cnt_out    (cnt_out[16]     )   ,
     .addr_left  (addr_left[16]   )   ,
            
     .ptr_1      (ptr_f[16]       )   ,
     .ptr_2      (ptr_nxt[16]     )   ,
     .data_out   (pre_dat[16]     )   ,
     .out_en     (dat_en[16]      )   ,
     .cnt_em     (cnt_em[16]      )

);
sram_ctrl   sram_ctrl_inst_17
(
     .en_a       (en_a[17]        )   ,
     .data_ina   (data_ina[17]    )   ,
     .en_b       (en_b[17]        )   ,
     .addr_inb     (rd_addr[17]     )   ,
     .wr_eop     (port_wr_eop[17] )   ,
     .rd_eop     (rd_eop[17]      )   ,
     .cnt_out    (cnt_out[17]     )   ,
     .addr_left  (addr_left[17]   )   ,
            
     .ptr_1      (ptr_f[17]       )   ,
     .ptr_2      (ptr_nxt[17]     )   ,
     .data_out   (pre_dat[17]     )   ,
     .out_en     (dat_en[17]      )   ,
     .cnt_em     (cnt_em[17]      )

);
sram_ctrl   sram_ctrl_inst_18
(
     .en_a       (en_a[18]        )   ,
     .data_ina   (data_ina[18]    )   ,
     .en_b       (en_b[18]        )   ,
     .addr_inb     (rd_addr[18]     )   ,
     .wr_eop     (port_wr_eop[18] )   ,
     .rd_eop     (rd_eop[18]      )   ,
     .cnt_out    (cnt_out[18]     )   ,
     .addr_left  (addr_left[18]   )   ,
            
     .ptr_1      (ptr_f[18]       )   ,
     .ptr_2      (ptr_nxt[18]     )   ,
     .data_out   (pre_dat[18]     )   ,
     .out_en     (dat_en[18]      )   ,
     .cnt_em     (cnt_em[18]      )

);
sram_ctrl   sram_ctrl_inst_19
(
     .en_a       (en_a[19]        )   ,
     .data_ina   (data_ina[19]    )   ,
     .en_b       (en_b[19]        )   ,
     .addr_inb     (rd_addr[19]     )   ,
     .wr_eop     (port_wr_eop[19] )   ,
     .rd_eop     (rd_eop[19]      )   ,
     .cnt_out    (cnt_out[19]     )   ,
     .addr_left  (addr_left[19]   )   ,
            
     .ptr_1      (ptr_f[19]       )   ,
     .ptr_2      (ptr_nxt[19]     )   ,
     .data_out   (pre_dat[19]     )   ,
     .out_en     (dat_en[19]      )   ,
     .cnt_em     (cnt_em[19]      )

);
sram_ctrl   sram_ctrl_inst_20
(
     .en_a       (en_a[20]        )   ,
     .data_ina   (data_ina[20]    )   ,
     .en_b       (en_b[20]        )   ,
     .addr_inb     (rd_addr[20]     )   ,
     .wr_eop     (port_wr_eop[20] )   ,
     .rd_eop     (rd_eop[20]      )   ,
     .cnt_out    (cnt_out[20]     )   ,
     .addr_left  (addr_left[20]   )   ,
            
     .ptr_1      (ptr_f[20]       )   ,
     .ptr_2      (ptr_nxt[20]     )   ,
     .data_out   (pre_dat[20]     )   ,
     .out_en     (dat_en[20]      )   ,
     .cnt_em     (cnt_em[20]      )

);
sram_ctrl   sram_ctrl_inst_21
(
     .en_a       (en_a[21]        )   ,
     .data_ina   (data_ina[21]    )   ,
     .en_b       (en_b[21]        )   ,
     .addr_inb     (rd_addr[21]     )   ,
     .wr_eop     (port_wr_eop[21] )   ,
     .rd_eop     (rd_eop[21]      )   ,
     .cnt_out    (cnt_out[21]     )   ,
     .addr_left  (addr_left[21]   )   ,
            
     .ptr_1      (ptr_f[21]       )   ,
     .ptr_2      (ptr_nxt[21]     )   ,
     .data_out   (pre_dat[21]     )   ,
     .out_en     (dat_en[21]      )   ,
     .cnt_em     (cnt_em[21]      )

);
sram_ctrl   sram_ctrl_inst_22
(
     .en_a       (en_a[22]        )   ,
     .data_ina   (data_ina[22]    )   ,
     .en_b       (en_b[22]        )   ,
     .addr_inb     (rd_addr[22]     )   ,
     .wr_eop     (port_wr_eop[22] )   ,
     .rd_eop     (rd_eop[22]      )   ,
     .cnt_out    (cnt_out[22]     )   ,
     .addr_left  (addr_left[22]   )   ,
            
     .ptr_1      (ptr_f[22]       )   ,
     .ptr_2      (ptr_nxt[22]     )   ,
     .data_out   (pre_dat[22]     )   ,
     .out_en     (dat_en[22]      )   ,
     .cnt_em     (cnt_em[22]      )

);
sram_ctrl   sram_ctrl_inst_23
(
     .en_a       (en_a[23]        )   ,
     .data_ina   (data_ina[23]    )   ,
     .en_b       (en_b[23]        )   ,
     .addr_inb     (rd_addr[23]     )   ,
     .wr_eop     (port_wr_eop[23] )   ,
     .rd_eop     (rd_eop[23]      )   ,
     .cnt_out    (cnt_out[23]     )   ,
     .addr_left  (addr_left[23]   )   ,
            
     .ptr_1      (ptr_f[23]       )   ,
     .ptr_2      (ptr_nxt[23]     )   ,
     .data_out   (pre_dat[23]     )   ,
     .out_en     (dat_en[23]      )   ,
     .cnt_em     (cnt_em[23]      )

);
sram_ctrl   sram_ctrl_inst_24
(
     .en_a       (en_a[24]        )   ,
     .data_ina   (data_ina[24]    )   ,
     .en_b       (en_b[24]        )   ,
     .addr_inb     (rd_addr[24]     )   ,
     .wr_eop     (port_wr_eop[24] )   ,
     .rd_eop     (rd_eop[24]      )   ,
     .cnt_out    (cnt_out[24]     )   ,
     .addr_left  (addr_left[24]   )   ,
            
     .ptr_1      (ptr_f[24]       )   ,
     .ptr_2      (ptr_nxt[24]     )   ,
     .data_out   (pre_dat[24]     )   ,
     .out_en     (dat_en[24]      )   ,
     .cnt_em     (cnt_em[24]      )

);
sram_ctrl   sram_ctrl_inst_25
(
     .en_a       (en_a[25]        )   ,
     .data_ina   (data_ina[25]    )   ,
     .en_b       (en_b[25]        )   ,
     .addr_inb     (rd_addr[25]     )   ,
     .wr_eop     (port_wr_eop[25] )   ,
     .rd_eop     (rd_eop[25]      )   ,
     .cnt_out    (cnt_out[25]     )   ,
     .addr_left  (addr_left[25]   )   ,
            
     .ptr_1      (ptr_f[25]       )   ,
     .ptr_2      (ptr_nxt[25]     )   ,
     .data_out   (pre_dat[25]     )   ,
     .out_en     (dat_en[25]      )   ,
     .cnt_em     (cnt_em[25]      )

);
sram_ctrl   sram_ctrl_inst_26
(
     .en_a       (en_a[26]        )   ,
     .data_ina   (data_ina[26]    )   ,
     .en_b       (en_b[26]        )   ,
     .addr_inb     (rd_addr[26]     )   ,
     .wr_eop     (port_wr_eop[26] )   ,
     .rd_eop     (rd_eop[26]      )   ,
     .cnt_out    (cnt_out[26]     )   ,
     .addr_left  (addr_left[26]   )   ,
            
     .ptr_1      (ptr_f[26]       )   ,
     .ptr_2      (ptr_nxt[26]     )   ,
     .data_out   (pre_dat[26]     )   ,
     .out_en     (dat_en[26]      )   ,
     .cnt_em     (cnt_em[26]      )

);
sram_ctrl   sram_ctrl_inst_27
(
     .en_a       (en_a[27]        )   ,
     .data_ina   (data_ina[27]    )   ,
     .en_b       (en_b[27]        )   ,
     .addr_inb     (rd_addr[27]     )   ,
     .wr_eop     (port_wr_eop[27] )   ,
     .rd_eop     (rd_eop[27]      )   ,
     .cnt_out    (cnt_out[27]     )   ,
     .addr_left  (addr_left[27]   )   ,
            
     .ptr_1      (ptr_f[27]       )   ,
     .ptr_2      (ptr_nxt[27]     )   ,
     .data_out   (pre_dat[27]     )   ,
     .out_en     (dat_en[27]      )   ,
     .cnt_em     (cnt_em[27]      )

);
sram_ctrl   sram_ctrl_inst_28
(
     .en_a       (en_a[28]        )   ,
     .data_ina   (data_ina[28]    )   ,
     .en_b       (en_b[28]        )   ,
     .addr_inb     (rd_addr[28]     )   ,
     .wr_eop     (port_wr_eop[28] )   ,
     .rd_eop     (rd_eop[28]      )   ,
     .cnt_out    (cnt_out[28]     )   ,
     .addr_left  (addr_left[28]   )   ,
            
     .ptr_1      (ptr_f[28]       )   ,
     .ptr_2      (ptr_nxt[28]     )   ,
     .data_out   (pre_dat[28]     )   ,
     .out_en     (dat_en[28]      )   ,
     .cnt_em     (cnt_em[28]      )

);
sram_ctrl   sram_ctrl_inst_29
(
     .en_a       (en_a[29]        )   ,
     .data_ina   (data_ina[29]    )   ,
     .en_b       (en_b[29]        )   ,
     .addr_inb     (rd_addr[29]     )   ,
     .wr_eop     (port_wr_eop[29] )   ,
     .rd_eop     (rd_eop[29]      )   ,
     .cnt_out    (cnt_out[29]     )   ,
     .addr_left  (addr_left[29]   )   ,
            
     .ptr_1      (ptr_f[29]       )   ,
     .ptr_2      (ptr_nxt[29]     )   ,
     .data_out   (pre_dat[29]     )   ,
     .out_en     (dat_en[29]      )   ,
     .cnt_em     (cnt_em[29]      )

);
sram_ctrl   sram_ctrl_inst_30
(
     .en_a       (en_a[30]        )   ,
     .data_ina   (data_ina[30]    )   ,
     .en_b       (en_b[30]        )   ,
     .addr_inb     (rd_addr[30]     )   ,
     .wr_eop     (port_wr_eop[30] )   ,
     .rd_eop     (rd_eop[30]      )   ,
     .cnt_out    (cnt_out[30]     )   ,
     .addr_left  (addr_left[30]   )   ,
            
     .ptr_1      (ptr_f[30]       )   ,
     .ptr_2      (ptr_nxt[30]     )   ,
     .data_out   (pre_dat[30]     )   ,
     .out_en     (dat_en[30]      )   ,
     .cnt_em     (cnt_em[30]      )

);
sram_ctrl   sram_ctrl_inst_31
(
     .en_a       (en_a[31]        )   ,
     .data_ina   (data_ina[31]    )   ,
     .en_b       (en_b[31]        )   ,
     .addr_inb     (rd_addr[31]     )   ,
     .wr_eop     (port_wr_eop[31] )   ,
     .rd_eop     (rd_eop[31]      )   ,
     .cnt_out    (cnt_out[31]     )   ,
     .addr_left  (addr_left[31]   )   ,
            
     .ptr_1      (ptr_f[31]       )   ,
     .ptr_2      (ptr_nxt[31]     )   ,
     .data_out   (pre_dat[31]     )   ,
     .out_en     (dat_en[31]      )   ,
     .cnt_em     (cnt_em[31]      )

);
*/





endmodule