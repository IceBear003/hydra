`timescale  1ns/1ns

module tb_fifo_null_pages();

reg         sys_clk     ;
reg         rst_n   ;

reg         pop_head    ;
wire   [10:0]    head_addr   ;

reg     push_tail   ;
reg [10:0]  tail_addr   ;

initial
    begin
        sys_clk     =   1'b1;
        rst_n   <=  4'b0;
      #40
        rst_n   <=  1'b1;
      #4
        pop_head <= 1'b1;
        push_tail <= 1'b0;
      #8184
        push_tail <= 1'b1;
      #1024
        pop_head <= 1'b0;
end

always@(posedge sys_clk or negedge rst_n)
    if(rst_n == 1'b0)
        tail_addr <= 0;
    else if(push_tail == 1'b1)
        tail_addr <= tail_addr + 1'b1;

always #2 sys_clk =   ~sys_clk;



fifo_null_pages fifo_null_pages_inst
(
    .clk        (sys_clk        )   ,
    .rst_n      (rst_n          )   ,
    
    .pop_head   (pop_head       )   ,
    .head_addr  (head_addr      )   ,
    .push_tail  (push_tail      )   ,
    .tail_addr  (tail_addr      )

);

endmodule