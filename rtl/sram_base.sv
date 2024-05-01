`timescale  1ns/1ns

module  sram_base
(
    input    wire    sys_clk     ,   
    input    wire    sys_rst_n   ,
    input    wire    en_a    ,
    input    wire    en_b    ,
    input    wire    [13:0]  addr_a  ,
    input    wire    [13:0]  addr_b  ,
    input    wire    [15:0]  data_ina  ,
    
    output  logic   [15:0]  data_outb   
    
);

logic   [16383:0][15:0]  sram_reg        ;


always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_outb = 0;      
    else if(en_b == 1'b1) begin
        data_outb <= sram_reg[addr_b];
        //$display("     data_outb = %b",data_outb);
        //$display("     addr_b = %b",addr_b);
    end
            
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sram_reg <= 0;
    else if(en_a == 1'b1) begin
        sram_reg[addr_a] <= data_ina; 
        //$display("data_ina = %b",data_ina);
        //$display("addr_a = %b",addr_a);
    end
    
endmodule