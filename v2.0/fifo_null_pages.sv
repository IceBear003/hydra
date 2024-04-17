module fifo_null_pages
(
    input clk,
    input rst_n,

    input pop_head,
    output reg [10:0] head_addr,

    input push_tail,
    input [10:0] tail_addr
);

reg [15:0] buf_mem [255:0];
reg [7:0] head_ptr = 0;
reg [7:0] tail_ptr = 63;

reg [15:0] head;
reg [15:0] tail;

integer i;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 64; i = i + 1) 
            buf_mem[i] <= {i<<5,5'd31};
        for(i = 64; i < 256; i = i + 1) 
            buf_mem[i] <= 0;
    end
    else begin
        if(push_tail) begin
            tail = buf_mem[tail_ptr];
            if(tail[15:5] + tail[4:0] == tail_addr - 1 && tail[4:0] < 31)
                tail = tail + 1;
            else begin
                tail_ptr = tail_ptr + 1;
                tail = {tail_addr, 5'b0};
            end
            buf_mem[tail_ptr] = tail;
        end

        head = buf_mem[head_ptr];
        head_addr = head[15:5];
        if(pop_head) begin
            if(head[4:0] == 0) begin
                head_ptr = head_ptr + 1;
                head = buf_mem[head_ptr];
            end
            else begin
                head = head + 5'b11111;
                buf_mem[head_ptr] = head;
            end
        end
    end
end

endmodule