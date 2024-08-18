module port_wr_frontend(
    input clk,
    input rst_n,

    /* 外界与前端交互的信号 */
    input wr_sop,
    input wr_eop,
    input wr_vld,
    input [15:0] wr_data,
    output reg pause,

    /*
     * 向后端发送数据包的信号
     * |- xfer_ready - 传输准备开始信号
     * |- xfer_data_vld - xfer_data是否有效
     * |- xfer_data - 当前周期传输的一半字数据
     * |- end_of_packet - 当前传输的半字是否为数据包最后半字
     */
    output xfer_ready,
    output reg xfer_data_vld,
    output reg [15:0] xfer_data,
    output reg end_of_packet,

    /*
     * 与匹配模块交互的信号
     * |- match_suc - 匹配完毕信号，可以开始发送缓冲区的数据
     * |- match_enable - 使能匹配进程的信号
     * |- match_dest_port, match_length - 被匹配的数据包的目标端口与长度(半字)
     *                                    用于匹配时判断SRAM对该数据包的喜好程度
     */
    input match_suc,
    output reg match_enable,
    output reg [3:0] match_dest_port,
    output reg [8:0] match_length
);

/*
 * wr_state - 数据包写入前端缓冲区自动机:
 *          |- 0 - 当前无数据包写入(初始态或wr_eop拉高后)
 *          |- 1 - 数据包即将写入(wr_sop拉高后)
 *          |- 2 - 数据包正在写入(wr_vld第一次拉高后)
 *          |- 3 - 数据包完成写入(传输完毕所有半字后)
 */
reg [1:0] wr_state;

/*
 * xfer_state - 前端缓冲区传输数据自动机
 *            |- 0 - 当前未传输数据
 *            |- 1 - 正在传输一个数据包的数据
 *            |- 2 - 当前数据包传输暂停(wr_vld拉低过长时间，适用于缓冲区内数据发送完毕但数据包写入仍未完成的情况)
 */
reg [1:0] xfer_state;

/* 前端缓冲区
 * |- buffer - 缓冲区 16×64 FIFO
 * |- wr_ptr - 写入指针
 * |- xfer_ptr - 传输指针
 * |- end_ptr - 包尾指针
 */
reg [15:0] buffer [63:0];
reg [5:0] wr_ptr;
reg [5:0] xfer_ptr;
reg [6:0] end_ptr;

wire [5:0] wr_ptr_pls_1 = wr_ptr + 6'd1;
wire [5:0] wr_ptr_pls_2 = wr_ptr + 6'd2;
wire [5:0] wr_ptr_pls_3 = wr_ptr + 6'd3;
wire [5:0] xfer_ptr_pls_1 = xfer_ptr + 6'd1;

/* wr_length - 数据包长度，用于更新包尾指针 */
reg [8:0] wr_length;

/* 
 * pst_match_suc - 匹配成功信号持久化
 *                 假设先后来了A,B两个数据包，若B数据包已完成匹配，但A数据包未传输完毕 
 *                 则需要一个持久化的match_suc启动B数据包的传输（match_suc仅拉高一周期）
 */
reg pst_match_suc;

assign xfer_ready = xfer_state == 2'd0 && (match_suc || pst_match_suc);

/* 写入前端缓冲区自动机状态转移 */
always @(posedge clk) begin
    if(~rst_n) begin
        wr_state <= 2'd0;
    end else if(wr_state == 2'd0 && wr_sop) begin
        wr_state <= 2'd1;
    end else if(wr_state == 2'd1 && wr_vld) begin
        wr_state <= 2'd2;
    end else if(wr_state == 2'd2 && wr_length == match_length) begin
        wr_state <= 2'd3;
    end else if(wr_state == 2'd3 && wr_eop) begin
        wr_state <= 2'd0; 
    end
end

/* 前端缓冲区传输数据自动机状态转移 */
always @(posedge clk) begin
    if(~rst_n) begin
        xfer_state <= 2'd0;
    end else if(xfer_state == 2'd0 && (match_suc || pst_match_suc)) begin
        /* 匹配完毕，开始传输数据 */
        xfer_state <= 2'd1;
    end else if(xfer_state == 2'd1 && xfer_ptr_pls_1 == end_ptr) begin
        /* 数据包传输完毕，进入传输空闲态 */
        xfer_state <= 2'd0;
    end else if(xfer_state == 2'd1 && xfer_ptr_pls_1 == wr_ptr) begin
        /* 当前可传输的数据传输完毕，进入传输暂停态 */
        xfer_state <= 2'd2;
    end else if(xfer_state == 2'd2 && xfer_ptr != wr_ptr) begin
        /* 有新的可传输的数据，从传输暂停态脱离 */
        xfer_state <= 2'd1;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        wr_ptr <= 0;
    end else if(wr_vld) begin
        buffer[wr_ptr] <= wr_data;
        wr_ptr <= wr_ptr + 1;
        if (wr_state == 2'd1) begin                 /* 在写入数据包第一个半字时，载入数据包的目的端口与长度信息 */
            match_dest_port <= wr_data[3:0];
            match_length <= wr_data[15:7];
        end
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        end_ptr <= 8'hFF;
    end else if(wr_state == 2'd3) begin             /* 传输完所有半字后，wr_ptr即为当前数据包的末端位置 */
        end_ptr <= wr_ptr;
    end else if(xfer_state == 2'd1 && xfer_ptr_pls_1 == end_ptr) begin
        end_ptr <= 7'd64;
    end
end

always @(posedge clk) begin
    if(wr_state == 2'd0) begin
        wr_length <= 0;
    end else if (wr_vld) begin
        wr_length <= wr_length + 1;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        match_enable <= 0;
    end else if(wr_vld && wr_state == 2'd1) begin                           /* 使能匹配过程 */
        match_enable <= 1;
    end else if(xfer_state == 2'd0 && (match_suc || pst_match_suc)) begin   /* 重置 */
        match_enable <= 0;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        pst_match_suc <= 0;
    end else if(xfer_state == 3'd0) begin
        pst_match_suc <= 0;
    end else if(match_suc) begin
        pst_match_suc <= 1;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        end_of_packet <= 0;
    end else if(xfer_state == 2'd1 && xfer_ptr_pls_1 == end_ptr) begin
        /* 数据包即将被传输完毕，将最后一半字标记为末端 */
        end_of_packet <= 1;
    end else begin
        end_of_packet <= 0;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        xfer_ptr <= 0;
        xfer_data_vld <= 0;
    end else if(xfer_state == 2'd1) begin
        xfer_data <= buffer[xfer_ptr];
        xfer_ptr <= xfer_ptr + 1;
        xfer_data_vld <= 1;
    end else begin
        xfer_data_vld <= 0;
    end
end

/*
 * pause - 暂停写入信号，以下两种情况会使写入暂停
 *       |- 情况I - 缓冲区即将被填满（提前两拍，保证外界响应前写入半字仍可被正常处理）
 *       |- 情况II - 缓冲区中存在仍未匹配到SRAM的数据包（此时若不暂停，新写入的数据包将会干扰匹配过程与结果）
 */
 always @(posedge clk) begin
    pause <= (wr_ptr_pls_3 == xfer_ptr) ||
             (wr_ptr_pls_2 == xfer_ptr) ||
             (wr_ptr_pls_1 == xfer_ptr) ||
             (wr_state == 2'd0 && match_enable && ~match_suc);
end

endmodule