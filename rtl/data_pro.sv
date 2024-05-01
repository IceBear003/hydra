`timescale  1ns/1ns

module data_pro
(
    input   wire    sys_clk     ,   
    input   wire    sys_rst_n   ,
    input   logic   data_en ,
    input   logic   data_fr ,
    input   logic   [15:0]  addr        ,
    input   logic   [15:0]  data_out    , 
    
    output  logic   page_en ,
    output  logic   [127:0] page_dat    

);

logic   fir_page    ;
logic   [4:0]   port_sram   ;
logic   [2:0]   cnt_page    ;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_page <= 1'b0;
    else if(data_en == 1'b1 && cnt_page <= 3'd6)
        cnt_page = cnt_page + 1'b1;
    else if(data_en == 1'b1)
        cnt_page = 1'b0;
                
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        page_dat <= 1'b0;
    else if(data_en == 1'b1 && cnt_page != 1'b0) begin
        page_dat = page_dat << 16 + data_out;
        page_en = 1'b0;
        if(cnt_page == 3'd7)
            page_en = 1'b1;
    end
    else if(data_en == 1'b1 && cnt_page == 1'b0)
        page_dat = data_out;
            
endmodule      
