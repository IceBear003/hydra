module fifo_null_pages
(
    input clk,
    input rst_n,

    input pop_head,
    output reg [10:0] head_addr,

    input push_tail,
    input [10:0] tail_addr
);

reg [10:0] fifo [2047:0];
reg [10:0] head_ptr = 0;
reg [10:0] tail_ptr = 0;
reg initialized = 1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        head_ptr = 0;
        tail_ptr = 0;
        head_addr = 0;
        fifo[0] = 0;
    end

    if(pop_head && rst_n)
        if(initialized && head_addr < 2047) 
            head_addr = head_addr + 1;
        else begin
            initialized = 0;
            head_ptr = head_ptr + 1;
            head_addr = fifo[head_ptr];
        end
    if(push_tail && rst_n) begin
        tail_ptr = tail_ptr + 1;
        fifo[tail_ptr] = tail_addr;
    end
end

endmodule