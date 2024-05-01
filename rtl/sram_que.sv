`timescale  1ns/1ns

module sram_que
(
    input    wire    sys_clk     ,   
    input    wire    sys_rst_n   ,
    input   logic   port_en  ,
    inout   wire    ready    ,
    input   wire    ready_1    ,
    input   logic   [2:0]   prior   ,
    input   logic   [4:0]   sram_num    ,
    input   logic   [10:0]  ptr_1   ,
    input   logic   [4:0]   page_cnt    ,
    input   logic   new_vld     ,
    input   logic   [8:0]   addr_left   ,
    input   logic   rd_eop  ,
    input   logic   rd_vld  ,
    input   logic   wr_eop  ,
    input   logic   [3:0]   que_num ,
    
    
    output  logic   [20:0]  rd_addr ,
    input  logic   rd_sop  ,
    output  logic   [15:0]  rd_data ,
    output  logic   [20:0]  pre_dec ,
    output  logic   addr_en 
    
);

logic   wr_new;
logic   [8:0]   addr_cnt   ;

reg [511:0][20:0]  que_0    ;
reg [511:0][20:0]  que_1    ;
reg [511:0][20:0]  que_2    ;
reg [511:0][20:0]  que_3    ;
reg [511:0][20:0]  que_4    ;
reg [511:0][20:0]  que_5    ;
reg [511:0][20:0]  que_6    ;
reg [511:0][20:0]  que_7    ;
logic   [7:0][8:0]   head    ;
logic   [7:0][8:0]   tail    ;

//将每个端口连接16个端口，对于每个队列设置缓冲队列，拼接队列

initial begin
    que_0 <= 0;
    que_1 <= 0;
    que_2 <= 0;
    que_3 <= 0;
    que_4 <= 0;
    que_5 <= 0;
    que_6 <= 0;
    que_7 <= 0;
    head <= 72'h8040201008040201;
    tail <= 0;
    rd_addr <= 0;
    wr_new <= 0;
    addr_cnt <= 0;
    rd_data <= 0;
    pre_dec <= 0;
    addr_en <= 0;
end
//将每一种情况加上display
//记录每个队列是否正在读入，以及每个队列存储数据数量

//3114 2555 

logic   [7:0][9:0]  data_num    ;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_num <= 0;
    else if(wr_eop == 1'b1) begin
        data_num[prior] <= data_num[prior] + 1;
        $display("prior = %d",prior);
        $display("data_num[prior] = %d",data_num[prior]);
    end

always@(port_en) begin
    if(port_en == 1'b1) begin
        if(prior == 0)
            if(sram_num == que_0[tail[0]][20:16] && ptr_1 == que_0[tail[0]][15:5] 
            + que_0[tail[0]][4:0] + 1 && que_0[tail[0]][4:0] != 32 && wr_new == 1'b0) begin
                $display("que_0[tail[0]] = %b",que_0[tail[0]]);
                que_0[tail[0]] = que_0[tail[0]] + 1;
                $display("que_0[tail[0]] = %b",que_0[tail[0]]);
            end
            else begin
                $display("que_0[ tail[0]] = %b",que_0[tail[0]]);
                tail[0] = tail[0] + 1'b1;
                if(tail[0] == 512)
                    tail[0] = 1'b0;
                que_0[tail[0]] = ({sram_num,ptr_1,5'b00000});
                $display("que_0[tail[0]] = %b",que_0[tail[0]]);
            end
        else if(prior == 1)
            if(sram_num == que_1[tail[1]][20:16] && ptr_1 == que_1[tail[1]][15:5] + 1
            + que_1[tail[1]][4:0] && que_1[tail[1]][4:0] != 32 && wr_new == 1'b0) begin
                $display("que_1[tail[1]] = %b",que_1[tail[1]]);
                que_1[tail[1]] = que_1[tail[1]] + 1;
                $display("que_1[tail[1]] = %b",que_1[tail[1]]);
            end
            else begin
                $display("que_1[ tail[1]] = %b",que_1[tail[1]]);
                tail[1] = tail[1] + 1'b1;
                if(tail[1] == 512)
                    tail[1] = 1'b0;
                que_1[tail[1]] = ({sram_num,ptr_1,5'b00000});
                $display("que_1[tail[1]] = %b",que_1[tail[1]]);
            end
        else if(prior == 2)
            if(sram_num == que_2[tail[2]][20:16] && ptr_1 == que_2[tail[2]][15:5] + 1
            + que_2[tail[2]][4:0] && que_2[tail[2]][4:0] != 32 && wr_new == 1'b0) begin
                $display("que_2[tail[2]] = %b",que_2[tail[2]]);
                que_2[tail[2]] = que_2[tail[2]] + 1;
                $display("que_2[tail[2]] = %b",que_2[tail[2]]);
            end
            else begin
                $display("que_2[ tail[2]] = %b",que_2[tail[2]]);
                tail[2] = tail[2] + 1'b1;
                if(tail[2] == 512)
                    tail[2] = 1'b0;
                que_2[tail[2]] = ({sram_num,ptr_1,5'b00000});
                $display("que_2[tail[2]] = %b",que_2[tail[2]]);
            end
        else if(prior == 3)
            if(sram_num == que_3[tail[3]][20:16] && ptr_1 == que_3[tail[3]][15:5] + 1
            + que_3[tail[3]][4:0] && que_3[tail[3]][4:0] != 32 && wr_new == 1'b0) begin
                $display("que_3[tail[3]] = %b",que_3[tail[3]]);
                que_3[tail[3]] = que_3[tail[3]] + 1;
                $display("que_3[tail[3]] = %b",que_3[tail[3]]);
            end
            else begin
                $display("que_3[ tail[3]] = %b",que_3[tail[3]]);
                tail[3] = tail[3] + 1'b1;
                if(tail[3] == 512)
                    tail[3] = 1'b0;
                que_3[tail[3]] = ({sram_num,ptr_1,5'b00000});
                $display("que_3[tail[3]] = %b",que_3[tail[3]]);
            end
        else if(prior == 4)
            if(sram_num == que_4[tail[4]][20:16] && ptr_1 == que_4[tail[4]][15:5] + 1
            + que_4[tail[4]][4:0] && que_4[tail[4]][4:0] != 32 && wr_new == 1'b0) begin
                $display("que_4[tail[4]] = %b",que_4[tail[4]]);
                que_4[tail[4]] = que_4[tail[4]] + 1;
                $display("que_4[tail[4]] = %b",que_4[tail[4]]);
            end
            else begin
                $display("que_4[ tail[4]] = %b",que_4[tail[4]]);
                tail[4] = tail[4] + 1'b1;
                if(tail[4] == 512)
                    tail[4] = 1'b0;
                que_4[tail[4]] = ({sram_num,ptr_1,5'b00000});
                $display("que_4[tail[4]] = %b",que_4[tail[4]]);
            end
        else if(prior == 5)
            if(sram_num == que_5[tail[5]][20:16] && ptr_1 == que_5[tail[5]][15:5] + 1
            + que_5[tail[5]][4:0] && que_5[tail[5]][4:0] != 32 && wr_new == 1'b0) begin
                $display("que_5[tail[5]] = %b",que_5[tail[5]]);
                que_5[tail[5]] = que_5[tail[5]] + 1;
                $display("que_5[tail[5]] = %b",que_5[tail[5]]);
            end
            else begin
                $display("que_5[ tail[5]] = %b",que_5[tail[5]]);
                tail[5] = tail[5] + 1'b1;
                if(tail[5] == 512)
                    tail[5] = 1'b0;
                que_5[tail[5]] = ({sram_num,ptr_1,5'b00000});
                $display("que_5[tail[5]] = %b",que_5[tail[5]]);
            end
        else if(prior == 6)
            if(sram_num == que_6[tail[6]][20:16] && ptr_1 == que_6[tail[6]][15:5] + 1
            + que_6[tail[6]][4:0] && que_6[tail[6]][4:0] != 32 && wr_new == 1'b0) begin
                $display("que_6[tail[6]] = %b",que_6[tail[6]]);
                que_6[tail[6]] = que_6[tail[6]] + 1;
                $display("que_6[tail[6]] = %b",que_6[tail[6]]);
            end
            else begin
                $display("que_6[ tail[6]] = %b",que_6[tail[6]]);
                tail[6] = tail[6] + 1'b1;
                if(tail[6] == 512)
                    tail[6] = 1'b0;
                que_6[tail[6]] = ({sram_num,ptr_1,5'b00000});
                $display("que_6[tail[6]] = %b",que_6[tail[6]]);
            end
        else if(prior == 7)
            if(sram_num == que_7[tail[7]][20:16] && ptr_1 == que_7[tail[7]][15:5] + 1
            + que_7[tail[7]][4:0] && que_7[tail[7]][4:0] != 32 && wr_new == 1'b0) begin
                $display("que_7[tail[7]] = %b",que_7[tail[7]]);
                que_7[tail[7]] = que_7[tail[7]] + 1;
                $display("que_7[tail[7]] = %b",que_7[tail[7]]);
            end
            else begin
                $display("que_7[ tail[7]] = %b",que_7[tail[7]]);
                tail[7] = tail[7] + 1'b1;
                if(tail[7] == 512)
                    tail[7] = 1'b0;
                que_7[tail[7]] = ({sram_num,ptr_1,5'b00000});
                $display("que_7[tail[7]] = %b",que_7[tail[7]]);
            end
        $display("ptr_1 = %d",ptr_1);
        $display("tail[prior] = %d",tail[prior]);
        $display("prior = %d",prior);
        $display("que_num = %d",que_num);
    end    
end

//4113 5552 1565

logic   [2:0]   rd_que  ;
//这里，有点问题
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b1)
    if(ready == 1'b1) begin
        if(tail[0] != head[0] - 1 && !(port_en == 1'b1 && prior == 0 && data_num[0] == 0))
            rd_que = 0;
        else if(tail[1] != head[1] - 1 && !(port_en == 1'b1 && prior == 1 && data_num[1] == 0))
            rd_que = 1;
        else if(tail[2] != head[2] - 1 && !(port_en == 1'b1 && prior == 2 && data_num[2] == 0))
            rd_que = 2;
        else if(tail[3] != head[3] - 1 && !(port_en == 1'b1 && prior == 3 && data_num[3] == 0))
            rd_que = 3;
        else if(tail[4] != head[4] - 1 && !(port_en == 1'b1 && prior == 4 && data_num[4] == 0))
            rd_que = 4;
        else if(tail[5] != head[5] - 1 && !(port_en == 1'b1 && prior == 5 && data_num[5] == 0))
            rd_que = 5;
        else if(tail[6] != head[6] - 1 && !(port_en == 1'b1 && prior == 6 && data_num[6] == 0))
            rd_que = 6;
        else if(tail[7] != head[7] - 1 && !(port_en == 1'b1 && prior == 7 && data_num[7] == 0))
            rd_que = 7;
        $display("                                     rd_que = %d",rd_que);
        $display("prior = %d",prior);
        $display("data_num[prior] = %d",data_num[prior]);
        $display("head = %d",head[rd_que]);
        $display("tail = %d",tail[rd_que]);
        $display("que_num = %d",que_num);
    end
    
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b1)
    if(ready_1 == 1'b1) begin
        addr_cnt = addr_left;
    end
/*
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b1)
    if(rd_vld == 1'b1)
        if(rd_que == 0)
            pre_dec = que_0[head[0]][19:5];
        else if(rd_que == 1)
            pre_dec = que_1[head[1]][19:5];
        else if(rd_que == 2)
            pre_dec = que_2[head[2]][19:5];
        else if(rd_que == 3)
            pre_dec = que_3[head[3]][19:5];
        else if(rd_que == 4)
            pre_dec = que_4[head[4]][19:5];
        else if(rd_que == 5)
            pre_dec = que_5[head[5]][19:5];
        else if(rd_que == 6)
            pre_dec = que_6[head[6]][19:5];
        else if(rd_que == 7)
            pre_dec = que_7[head[7]][19:5];
    else
        if(tail[0] != head[0])
            pre_dec = que_0[head[0]][19:5];
        else if(tail[1] != head[1])
            pre_dec = que_1[head[1]][19:5];
        else if(tail[2] != head[2])
            pre_dec = que_2[head[2]][19:5];
        else if(tail[3] != head[3])
            pre_dec = que_3[head[3]][19:5];
        else if(tail[4] != head[4])
            pre_dec = que_4[head[4]][19:5];
        else if(tail[5] != head[5])
            pre_dec = que_5[head[5]][19:5];
        else if(tail[6] != head[6])
            pre_dec = que_6[head[6]][19:5];
        else if(tail[7] != head[7])
            pre_dec = que_7[head[7]][19:5];
*/            
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b1)
    if(rd_sop == 1'b1) begin
        if(rd_que == 0)
            rd_addr = que_0[tail[0]][20:5];
        else if(rd_que == 1)
            rd_addr = que_1[tail[1]][20:5];
        else if(rd_que == 2)
            rd_addr = que_2[tail[2]][20:5];
        else if(rd_que == 3)
            rd_addr = que_3[tail[3]][20:5];
        else if(rd_que == 4)
            rd_addr = que_4[tail[4]][20:5];
        else if(rd_que == 5)
            rd_addr = que_5[tail[5]][20:5];
        else if(rd_que == 6)
            rd_addr = que_6[tail[6]][20:5];
        else if(rd_que == 7)
            rd_addr = que_7[tail[7]][20:5];
    end

always@(rd_sop,new_vld)
    if(sys_rst_n == 1'b1)
    if(rd_sop == 1'b1 || new_vld == 1'b1) begin
        if(rd_que == 0) begin
            pre_dec = que_0[head[0]];
            head[0] = head[0] + 1'b1;
            if(head[0] == 512)
                head[0] = 1'b0;
            addr_cnt = addr_cnt - rd_addr[4:0];
            $display("                  pre_dec = %b",pre_dec);
            $display("head[0] = %d",head[0]);
            $display("tail[0] = %d",tail[0]);
        end
        else if(rd_que == 1) begin
            pre_dec = que_1[head[1]];
            head[1] = head[1] + 1'b1;
            if(head[1] == 512)
                head[1] = 1'b0;
            addr_cnt = addr_cnt - rd_addr[4:0];
            $display("                  pre_dec = %b",pre_dec);
            $display("head[1] = %d",head[1]);
            $display("tail[1] = %d",tail[1]);
        end
        else if(rd_que == 2) begin
            pre_dec = que_2[head[2]];
            head[2] = head[2] + 1'b1;
            if(head[2] == 512)
                head[2] = 1'b0;
            addr_cnt = addr_cnt - rd_addr[4:0];
            $display("                  pre_dec = %b",pre_dec);
            $display("head[0] = %d",head[2]);
            $display("tail[0] = %d",tail[2]);
        end
        else if(rd_que == 3) begin
            pre_dec = que_3[head[3]];
            head[3] = head[3] + 1'b1;
            if(head[3] == 512)
                head[3] = 1'b0;
            addr_cnt = addr_cnt - rd_addr[4:0];
            $display("                  pre_dec = %b",pre_dec);
            $display("head[3] = %d",head[3]);
            $display("tail[3] = %d",tail[3]);
        end
        else if(rd_que == 4) begin
            pre_dec = que_4[head[4]];
            head[4] = head[4] + 1'b1;
            if(head[4] == 512)
                head[4] = 1'b0;
            addr_cnt = addr_cnt - rd_addr[4:0];
            $display("                  pre_dec = %b",pre_dec);
            $display("head[4] = %d",head[4]);
            $display("tail[4] = %d",tail[4]);
        end
        else if(rd_que == 5) begin
            pre_dec = que_5[head[5]];
            head[5] = head[5] + 1'b1;
            if(head[5] == 512)
                head[5] = 1'b0;
            addr_cnt = addr_cnt - rd_addr[4:0];
            $display("                  pre_dec = %b",pre_dec);
            $display("head[5] = %d",head[5]);
            $display("tail[5] = %d",tail[5]);
        end
        else if(rd_que == 6) begin
            pre_dec = que_6[head[6]];
            head[6] = head[6] + 1'b1;
            if(head[6] == 512)
                head[6] = 1'b0;
            addr_cnt = addr_cnt - rd_addr[4:0];
            $display("                  pre_dec = %b",pre_dec);
            $display("head[6] = %d",head[6]);
            $display("tail[6] = %d",tail[6]);
        end
        else if(rd_que == 7) begin
            pre_dec = que_7[head[7]];
            head[7] = head[7] + 1'b1;
            if(head[7] == 512)
                head[7] = 1'b0;
            addr_cnt = addr_cnt - rd_addr[4:0];
            $display("                  pre_dec = %b",pre_dec);
            $display("head[7] = %d",head[7]);
            $display("tail[7] = %d",tail[7]);
        end
        $display("que_num = %d",que_num);
        addr_en = 1'b1;
    end

always@(posedge sys_clk or  negedge sys_rst_n)
    if(addr_en == 1'b1)
        addr_en <= 1'b0;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b1)
    if(rd_eop == 1'b1 && addr_cnt > 0)
        if(rd_que == 0) begin
            if(head[0] == 0)
                head[0] = 511;
            else
                head[0] = head[0] - 1'b1;
            que_0[head[0]][15:5] = que_0[head[0]][15:5] + (que_0[head[0]][4:0] - addr_cnt);
            que_0[head[0]][4:0] = addr_cnt;
        end
        else if(rd_que == 1) begin
            if(head[1] == 0)
                head[1] = 511;
            else
                head[1] = head[1] - 1'b1;
            que_1[head[1]][15:5] = que_1[head[1]][15:5] + (que_1[head[1]][4:0] - addr_cnt);
            que_1[head[1]][4:0] = addr_cnt;
        end
        else if(rd_que == 2) begin
            if(head[2] == 0)
                head[2] = 511;
            else
                head[2] = head[2] - 1'b1;
            que_2[head[2]][15:5] = que_2[head[2]][15:5] + (que_2[head[2]][4:0] - addr_cnt);
            que_2[head[2]][4:0] = addr_cnt;
        end
        else if(rd_que == 3) begin
            if(head[3] == 0)
                head[3] = 511;
            else
                head[3] = head[3] - 1'b1;
            que_3[head[3]][15:5] = que_3[head[3]][15:5] + (que_3[head[3]][4:0] - addr_cnt);
            que_3[head[3]][4:0] = addr_cnt;
        end
        else if(rd_que == 4) begin
            if(head[4] == 0)
                head[4] = 511;
            else
                head[4] = head[4] - 1'b1;
            que_4[head[4]][15:5] = que_4[head[4]][15:5] + (que_4[head[4]][4:0] - addr_cnt);
            que_4[head[4]][4:0] = addr_cnt;
        end
        else if(rd_que == 5) begin
            if(head[5] == 0)
                head[5] = 511;
            else
                head[5] = head[5] - 1'b1;
            que_5[head[5]][15:5] = que_5[head[5]][15:5] + (que_5[head[5]][4:0] - addr_cnt);
            que_5[head[5]][4:0] = addr_cnt;
        end
        else if(rd_que == 6) begin
            if(head[6] == 0)
                head[6] = 511;
            else
                head[6] = head[6] - 1'b1;
            que_6[head[6]][15:5] = que_6[head[6]][15:5] + (que_6[head[6]][4:0] - addr_cnt);
            que_6[head[6]][4:0] = addr_cnt;
        end
        else if(rd_que == 7) begin
            if(head[7] == 0)
                head[7] = 511;
            else
                head[7] = head[7] - 1'b1;
            que_7[head[7]][15:5] = que_7[head[7]][15:5] + (que_7[head[7]][4:0] - addr_cnt);
            que_7[head[7]][4:0] = addr_cnt;
        end

/*
begin
        if(tail[]size(que_0))
            rd_addr = que_0.pop_front;
        else if(tail[]size(que_1))
            rd_addr = que_1.pop_front;
        else if(tail[]size(que_2))
            rd_addr = que_2.pop_front;
        else if(tail[]size(que_3))
            rd_addr = que_3.pop_front;
        else if(tail[]size(que_4))
            rd_addr = que_4.pop_front;
        else if(tail[]size(que_5))
            rd_addr = que_5.pop_front;
        else if(tail[]size(que_6))
            rd_addr = que_6.pop_front;
        else if(tail[]size(que_7))
            rd_addr = que_7.pop_front;
        else if(tail[]size(que_8))
            rd_addr = que_8.pop_front;
    end*/

endmodule