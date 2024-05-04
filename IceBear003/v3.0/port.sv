module port(
    input clk,

    input wr_sop,
    input wr_eop,
    input wr_vld,
    input [15:0] wr_data,

    input xfer_stop,

    output reg [3:0] dest_port = 4'b0,
    output reg [8:0] length = 0,
    output reg data_vld = 0,
    output reg [15:0] data = 16'b0,

    //Use to trigger the update of the persistent dest_port & length in controller.sv
    output reg new_packet = 0
);

reg [63:0][15:0] buffer = 0;

reg delay_cnt_en = 0;
reg [5:0] delay_cnt = 0;

reg xfer_en = 0;
reg [5:0] xfer_ptr;

reg is_ctrl_frame = 0;
reg [5:0] wr_ptr;
reg [5:0] end_ptr;

always @(posedge clk) begin
    if(delay_cnt_en) begin
        delay_cnt <= delay_cnt + 1;
    end else begin
        delay_cnt <= 0;
    end
end

always @(posedge clk) begin
    if(delay_cnt == 32) begin
        xfer_en <= 1;
    end else if (xfer_ptr == end_ptr) begin
        xfer_en <= 0;
    end
end

always @(posedge clk) begin
    if(wr_eop) begin
        end_ptr <= wr_ptr;
    end
end

always @(posedge clk) begin
    if(wr_vld) begin
        buffer[wr_ptr] <= wr_data;
        wr_ptr <= wr_ptr + 1;
    end
end

always @(posedge clk) begin
    is_ctrl_frame <= wr_sop;
end

always @(posedge clk) begin
    if(is_ctrl_frame) begin
        dest_port <= wr_data[3:0];
        length <= wr_data[15:7];
        new_packet <= 1;
    end else begin
        new_packet <= 0;
    end
end

always @(posedge clk) begin
    if(is_ctrl_frame) begin
        delay_cnt_en <= 1;
    end
    if(delay_cnt == 32) begin
        delay_cnt_en <= 0;
    end
end

always @(posedge clk) begin
    if(xfer_en) begin
        data <= buffer[xfer_ptr];
        data_vld <= 1;
        xfer_ptr <= xfer_ptr + 1;
    end else begin
        data_vld <= 0;
    end
end

endmodule