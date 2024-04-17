module sram_state(
    input clk,

    //分出去文件：sram_ecc
    input [10:0] sec_addr,
    output reg [7:0] sec_code,

    //向一个地址写/读的时候更新
    input [10:0] wr_addr,
    input [10:0] rd_addr,

    //查询一个地址对应的页是否为空
    input [10:0] addr,
    output addr_state,

    //占用情况 2-WR 1-RD 0-DT
    input detect,
    output reg [2:0] occupied, 

    //空闲指针
    output reg [10:0] null_ptr,

    //剩余空间
    output reg [10:0] free_space = 2048
);

(*ram_style = "block"*) reg [7:0][2047:0] sec_codes;

always @(sec_addr) begin
    sec_code = sec_codes[sec_addr];
end

reg [31:0][63:0] page_state;
reg update_trigger = 0;
reg [5:0] recursion_index = 0;
reg [31:0] one_hot = 0;
integer i;

assign addr_state = page_state[addr];

always @(detect) 
    occupied[0] = detect;

always @(posedge clk) 
    occupied = 0;

//每次写入页的时候，置满，更新总容量并指导刷新空闲指针
always@(wr_addr) begin
    page_state[wr_addr] = 1;
    free_space = free_space - 1;
    update_trigger = 1;
    occupied[2] = 1;
end

//每次读出页的时候，置空并更新总容量
always@(rd_addr) begin
    page_state[rd_addr] = 0;
    free_space = free_space + 1;
    occupied[1] = 1;
end 

//最坏情况：递归了64次才找到空闲页，然而我们有时钟八个周期去干这件事情，爽死啦！
always @(posedge update_trigger) begin
    update_trigger = 0;                         //拉低更新触发器
    if(!page_state[recursion_index] == 0) begin //当前32页已经满了，数组下标加一
        recursion_index = recursion_index + 1;
        update_trigger = 1;                     //最有意思的一部分：拉高自己的触发器
                                                //这样可以实现"递归"(从0到63)，不用像for把电路复制64次
    end
    else begin
        null_ptr[10:5] = recursion_index;       //如果当前32页没满，说明我们搜索的空页就在它们里面
        null_ptr[4:0] = 0;                      //置低五位为0
        if(page_state[recursion_index]) begin   //如果全空则不会进入if，这样全空时就不用进行下面的额外的搜索
            //也是很巧妙的一部分，将一个数和其补码进行与运算，结果只有一个1，这个1就是原数中的第一个1
            //由于我们要找0，所以先取反，然后求补码，然后按位与
            one_hot = (~page_state[recursion_index]) & ~(~page_state[recursion_index] - 1);
            //把独热码减一，这样低位全是1，1的个数就是我们要求的位置！
            one_hot = one_hot - 1;
                null_ptr[4:0] = null_ptr[4:0] + 1;
            recursion_index = 0;                //找到空页了，把搜索下标重置
        end
    end
end

endmodule