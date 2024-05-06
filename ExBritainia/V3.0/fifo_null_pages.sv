module fifo_null_pages
(
    input clk,
    input rst_n,

    input pop_head,
    output reg [10:0] head_addr,

    input push_tail,
    input [10:0] tail_addr
);

(* ram_style = "block" *) reg [10:0] fifo [2047:0]; //22Kbit
reg [10:0] head_ptr = 1;
reg [10:0] tail_ptr = 0;
reg initialized = 1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        head_ptr <= 1;
        tail_ptr <= 0;
        head_addr <= 0;
        fifo[0] <= 0;
        initialized <= 1;
    end else begin
        if(pop_head) 
            if(initialized) begin
                if(head_addr < 2047) begin
                    head_addr <= head_addr + 1;
                    $display("              head_addr = %d",head_addr);
                end else begin 
                    initialized <= 0;
                    head_addr <= fifo[head_ptr];
                end
            end else begin
                head_addr <= fifo[head_ptr + 1];
                head_ptr <= head_ptr + 1;
            end
        if(push_tail) begin
            fifo[tail_ptr + 1] <= tail_addr;
            tail_ptr <= tail_ptr + 1;
        end
    end
end

endmodule