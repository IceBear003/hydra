module port(
    input clk,

    input wr_sop,
    input wr_eop,
    input wr_vld,
    input [15:0] wr_data,

    input xfer_stop,

    output reg [2:0] prior = 3'b0,
    output reg [3:0] dest_port = 4'b0,
    //前32拍延迟32拍发出，后续拍数据的延迟情况取决于vld
    output reg [15:0] data = 16'b0,
    output reg [8:0] length = 0,
    output reg writting = 0,
    output reg unlock = 0
);

reg is_ctrl_frame = 0;

//数据包缓冲区 32×16
reg [31:0][15:0] buffer = 0;

//多数据包数据缓冲管理
//兼容32周期的搜索时序
reg xfer_en = 0;
reg [4:0] xfer_ptr = 0;
reg [4:0] write_ptr = 0;
reg [4:0] last_ptr = 0;

//为突发传输准备
reg [3:0] heartbeat = 0;
 
always @(posedge clk) begin 
    if(wr_sop) begin
        is_ctrl_frame <= 1;
    end
    if(wr_eop) begin
        prior <= 3'b0;
        dest_port <= 4'b0;
        data <= 16'b0;
        last_ptr <= write_ptr;
    end
    writting <= wr_vld;

    if(xfer_en) begin
        data <= buffer[xfer_ptr];
        if(xfer_ptr + 1 == write_ptr || (xfer_ptr == 31 && write_ptr == 0)) begin
            xfer_en <= 0;
        end
        if((xfer_ptr == last_ptr) && xfer_stop) begin
            xfer_en <= 0;
        end
        //$display("last_ptr = %d",last_ptr);
        //$display("xfer_ptr = %d",xfer_ptr);
        //$display("xfer_stop = %d",xfer_stop);
        //$display("data = %d",data);
        xfer_ptr <= xfer_ptr + 1;
    end

    if(wr_vld) begin
        unlock <= 1;
        heartbeat <= 0;
        if(is_ctrl_frame) begin
            dest_port <= wr_data[3:0];
            prior <= wr_data[6:4];
            length <= wr_data[15:7];
            buffer[write_ptr] <= {7'b0, wr_data[15:7]};
            is_ctrl_frame <= 0;
        end
        else begin
            buffer[write_ptr] <= wr_data;
        end
        if(write_ptr + 1 == xfer_ptr || (write_ptr == 31 && xfer_ptr == 0)) begin
            xfer_en <= 1;
        end
        write_ptr <= write_ptr + 1;
        //$display("         write_ptr = %d",write_ptr);
    end else begin
        if(heartbeat == 15) begin
            heartbeat <= 0;
            unlock <= 1;
        end
        heartbeat <= heartbeat + 1;
    end
end

endmodule