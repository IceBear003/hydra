`timescale  1ns/1ns

module  data_init
(
    input   wire    sys_clk     ,   
    input   wire    sys_rst_n   ,
    input   wire    wr_sop  ,
    input   wire    wr_eop  ,
    input   wire    wr_vld  ,
    input   wire    [15:0]  wr_data ,

    output  logic   data_en ,
    output  logic   data_fr ,
    output  logic   page_fr ,
    output  logic   [3:0]   dest_port   ,
    output  logic   [2:0]   prior       ,
    output  logic   [8:0]   data_len    ,
    output  logic   [15:0]  data_out    ,
    output  logic   wr_s    ,
    output  logic   wr_b

);

//reg     wr_s    ;
//reg     wr_b    ;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
    begin
        wr_s <= 1'b0;
        wr_b <= 1'b0;
    end
    else if(wr_sop == 1'b1)
        wr_s <= 1'b1;
    else if(wr_s == 1'b1 && wr_vld == 1'b1)
        wr_b <= 1'b1;
    else if(wr_eop == 1'b1)
    begin
        wr_s <= 1'b0;
        wr_b <= 1'b0;
    end

assign  data_fr = (wr_s == 1'b1) && (wr_b == 1'b0);

logic   [2:0]   cnt_page    ;
logic   page_fr_1   ;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        cnt_page <= 1'b0;
        page_fr_1 <= 0;
    end
    else if((wr_s == 1'b1) && (wr_b == 1'b0)) begin
        cnt_page = 1'b0;
        page_fr_1 = 1'b1;
    end
    else if(data_en == 1'b1 && cnt_page <= 3'd6) begin
        cnt_page = cnt_page + 1'b1;
        page_fr_1 = 1'b0;
        /*$display("                 cnt_page = %d",cnt_page);
        $display("wr_s = %d",wr_s);
        $display("wr_b = %d",wr_b);
        $display("wr_vld = %d",wr_vld);
        $display("                                                          page_fr_1 = %d",page_fr_1);*/
    end
    else if(data_en == 1'b1) begin
        cnt_page = 1'b0;
        page_fr_1 = 1'b1;
        //$display("                  cnt_page = %d",cnt_page);
        //$display("wr_vld = %d",wr_vld);
        //$display("                                                          page_fr_1 = %d",page_fr_1);
    end
/*
always@(data_en,cnt_page,wr_vld,wr_sop,wr_eop,sys_rst_n) begin
    if(((wr_s == 1'b1) && (wr_b == 1'b0)) || cnt_page == 1'b0)
        page_fr_1 = 1'b1;
    else
        page_fr_1 = 1'b0;
end*/

//assign  page_fr_1 = (cnt_page == 1'b0 && wr_vld == 1'b1) ? 1'b1 : 1'b0;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        page_fr <= 0;
    else begin
        page_fr <= page_fr_1;
        //if(wr_vld == 1'b1)
        //$display("                                                          page_fr_1 = %d",page_fr_1);
    end

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
    begin
        data_en <= 1'b0;
        data_out <= 1'bx;
    end
    else if(wr_vld == 1'b0)
        data_en <= 1'b0;
    else if(wr_s == 1'b1 && wr_b == 1'b0 && wr_vld == 1'b1)
    begin
        data_len = wr_data[15:7];
        dest_port = wr_data[3:0];
        prior = wr_data[6:4];
        data_out = wr_data;
        data_en = 1'b1;
        
    end
    else if(wr_s == 1'b1 && wr_vld == 1'b1)
    begin
        data_out = wr_data;
        data_en = 1'b1;
        //$display("data                              _out = %d",data_out);
    end

data_pro    data_pro_inst
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .data_en        (data_en        )   ,
    .data_fr        (data_fr        )   ,
    .data_out       (data_out       )         

);

endmodule