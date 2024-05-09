// module port(
//     input clk,

//     input wr_sop,
//     input wr_eop,
//     input wr_vld,
//     input [15:0] wr_data,

//     //当前正在接收的数据包的基本信息
//     //在wr_sop后的第一个wr_vld时更新，一周期后生效
//     output reg new_packet = 0,          //表示一个新的数据包进入了，驱动后端搜索过程
//     output reg [3:0] dest_port = 4'b0,  //输出端口
//     output reg [2:0] prior = 0,         //优先级
//     output reg [8:0] length = 0,        //数据包长度(单位:半字)

//     //从前端发来的搜索成功信号
//     input search_sucessfully,

//     //当前数据包搜索成功后
//     //向后端发送数据的标志信号
//     output reg data_vld = 0,       
//     //向后端发送的一半字数据
//     output reg [15:0] data = 16'b0,
//     //当data_vld为高的前一个周期为高
//     //叫停后端的搜索过程
//     output reg begin_of_packet = 0,
//     //当前数据包在第一个data_vld为高时也为高
//     output reg start_of_packet = 0
// );

// reg [15:0] buffer [63:0];

// reg delay_cnt_en = 0;
// reg [5:0] delay_cnt = 0;

// reg xfer_en = 0;
// reg [5:0] xfer_ptr = 0;

// reg is_ctrl_frame = 0;
// reg [5:0] wr_ptr = 0;
// reg [5:0] end_ptr;

// always @(posedge clk) begin
//     if(wr_sop)
//         is_ctrl_frame <= 1;
//     else if(wr_vld)
//         is_ctrl_frame <= 0;
// end

// always @(posedge clk) begin
//     if((is_ctrl_frame && wr_vld) || (delay_cnt == 32 && search_get == 0)) begin
//         delay_cnt_en <= 1;
//     end
//     if(delay_cnt == 32) begin
//         delay_cnt_en <= 0;
//     end
// end

// always @(posedge clk) begin
//     if(delay_cnt_en) begin
//         delay_cnt <= delay_cnt + 1;
//         $display("                                    delay_cnt = %d",delay_cnt);
//     end else begin
//         delay_cnt <= 0;
//     end
// end

// always @(posedge clk) begin
//     if(delay_cnt == 32 && search_get) begin
//         xfer_en <= 1;
//     end else if (xfer_ptr == end_ptr) begin
//         xfer_en <= 0;
//         end_ptr <= 1'bx;
//     end else if (wr_eop && xfer_ptr == wr_ptr - 1) begin
//         xfer_en <= 0;
//         end_ptr <= 1'bx;
//     end
// end

// always @(posedge clk) begin
//     if(delay_cnt == 32 && search_get) begin
//         start_of_packet <= 1;
//     end else begin
//         start_of_packet <= 0;
//     end
// end

// always @(posedge clk) begin
//     if(delay_cnt == 31) begin
//         begin_of_packet <= 1;
//     end else begin
//         begin_of_packet <= 0;
//     end
// end

// always @(posedge clk) begin
//     if(wr_eop && xfer_ptr != wr_ptr - 1) begin
//         end_ptr <= wr_ptr - 1;
//     end
// end

// always @(posedge clk) begin
//     if(wr_vld) begin
//         buffer[wr_ptr] <= wr_data;
//         wr_ptr <= wr_ptr + 1;
//     end
// end

// always @(posedge clk) begin
//     if(is_ctrl_frame && wr_vld) begin
//         dest_port <= wr_data[3:0];
//         prior <= wr_data[6:4];
//         length <= wr_data[15:7];
//         new_packet <= 1;
//     end else begin
//         new_packet <= 0;
//     end
// end

// always @(posedge clk) begin
//     if(xfer_en && xfer_ptr != wr_ptr) begin
//         data <= buffer[xfer_ptr];
//         data_vld <= 1;
//         xfer_ptr <= xfer_ptr + 1;
//     end else begin
//         data_vld <= 0;
//     end
// end

// endmodule