module port(
    input clk,

    input wr_sop,
    input wr_eop,
    input wr_vld,
    input [15:0] wr_data,

    input xfer_stop,

    output reg [3:0] dest_port = 4'b0,
    output reg [2:0] prior = 0,
    output reg [8:0] length = 0,
    output reg data_vld = 0,
    output reg [15:0] data = 16'b0,
    output reg start_of_packet = 0,

    //Use to trigger the update of the persistent dest_port & length in controller.sv
    output reg new_packet = 0
);

reg [63:0][15:0] buffer = 0;

reg delay_cnt_en = 0;
reg [5:0] delay_cnt = 0;

reg xfer_en = 0;
reg [5:0] xfer_ptr = 0;

reg is_ctrl_frame = 0;
reg [5:0] wr_ptr = 0;
reg [5:0] end_ptr;

always @(posedge clk) begin
    if(delay_cnt_en) begin
        delay_cnt <= delay_cnt + 1;
        $display("      delay_cnt = %d",delay_cnt);
    end else begin
        delay_cnt <= 0;
    end
end

always @(posedge clk) begin
    if(delay_cnt == 32) begin
        xfer_en <= 1;
        //start_of_packet <= 1;
    end else if (xfer_ptr == end_ptr) begin
        xfer_en <= 0;
        //start_of_packet <= 0;
        end_ptr <= 1'bx;
        $display("     end_ptr = %d",end_ptr);
    end else if (wr_eop && xfer_ptr == wr_ptr - 1) begin
        xfer_en <= 0;
        //start_of_packet <= 0;
        end_ptr <= 1'bx;
    end
    $display("  xfer_ptr = %d",xfer_ptr);
    $display("     end_ptr = %d",end_ptr);
end

always @(posedge clk) begin
    if(delay_cnt == 32) begin
        start_of_packet <= 1;
    end else begin
        start_of_packet <= 0;
    end
end

always @(posedge clk) begin
    if(wr_eop && xfer_ptr != wr_ptr - 1) begin
        end_ptr <= wr_ptr - 1;
        $display("                                          end_ptr = %d",end_ptr);
    end
end

always @(posedge clk) begin
    if(wr_vld) begin
        buffer[wr_ptr] <= wr_data;
        wr_ptr <= wr_ptr + 1;
        $display("wr_ptr = %d",wr_ptr);
        $display("        wr_data = %d",wr_data);
    end
end

always @(posedge clk) begin
    //is_ctrl_frame <= wr_sop;
    $display("            is_ctrl_frame = %d",is_ctrl_frame);
    $display("wr_vld = %d",wr_vld);
    $display("wr_sop = %d",wr_sop);
    if(wr_sop)
        is_ctrl_frame <= 1;
    else if(wr_vld)
        is_ctrl_frame <= 0;
end

always @(posedge clk) begin
    if(is_ctrl_frame && wr_vld) begin
        dest_port <= wr_data[3:0];
        prior <= wr_data[6:4];
        length <= wr_data[15:7];
        new_packet <= 1;
        //$display("wr_data = %d",wr_data);
    end else begin
        new_packet <= 0;
    end
end

always @(posedge clk) begin
    if(is_ctrl_frame && wr_vld) begin
        delay_cnt_en <= 1;
    end
    if(delay_cnt == 32) begin
        delay_cnt_en <= 0;
    end
end

always @(posedge clk) begin
    if(xfer_en && xfer_ptr != wr_ptr) begin
        data <= buffer[xfer_ptr];
        data_vld <= 1;
        xfer_ptr <= xfer_ptr + 1;
        $display("xfer_ptr = %d",xfer_ptr);
        $display("wr_ptr = %d",wr_ptr);
        $display("delay_cnt = %d",delay_cnt);
    end else begin
        data_vld <= 0;
        //start_of_packet <= 0;
    end
end

endmodule