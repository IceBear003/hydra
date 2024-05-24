module port_wr_frontend(
    input clk,
    input rst_n,

    input wr_sop,
    input wr_vld,
    input [15:0] wr_data,
    input wr_eop,
    output reg pause,

    /*
     * To the module "port_backend"
     */
    //Whether the data in buffer are transfering to backend.
    output reg xfer_data_vld,
    output reg [15:0] xfer_data,
    //The info of the packet transfering to the backend.
    output reg end_of_packet,
    output reg [3:0] cur_dest_port,
    output reg [2:0] cur_prior,
    output reg [8:0] cur_length,

    /*
     * To the module "port_sram_matcher"
     */
    //Whether the process of matching SRAM is finished.
    input match_suc,
    output reg match_enable,
    //The length & dest_port is needed to match an SRAM.
    output reg [3:0] new_dest_port,
    output reg [2:0] new_prior,
    output reg [8:0] new_length
);

/*
 * wr_state: 
 *      0: No new packet written into the port.
 *      1: A new packet is to be written into the port.
 *      2: Data of the new packet are being written.
 *      3: The writting process of the new packet is to be finished.
 */
reg [2:0] wr_state;

/*
 * xfer_state: 
 *      0: Not transfering data from buffer to backend.
 *      1: Transfering data from buffer to backend.
 *      2: Transfering data from buffer to backend PAUSED.
 */
reg [1:0] xfer_state;

reg [15:0] buffer [63:0];
reg [5:0] wr_ptr;
reg [5:0] xfer_ptr;
reg [7:0] end_ptr;

reg [8:0] wr_length;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        wr_state <= 3'd0;
    end else if(wr_state == 3'd0 && wr_sop) begin
        wr_state <= 3'd1;
    end else if(wr_state == 3'd1 && wr_vld) begin
        wr_state <= 3'd2;
    end else if(wr_state == 3'd2 && wr_length == new_length) begin
        wr_state <= 3'd3;
    end else if(wr_state == 3'd3 && wr_eop) begin
        wr_state <= 3'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        wr_ptr <= 0;
    end else if(wr_vld) begin
        wr_ptr <= wr_ptr + 1;
        if (wr_state == 3'd1) begin
            new_length <= wr_data[15:7];
            new_prior <= wr_data[6:4];
            new_dest_port <= wr_data[3:0];
        end
    end
end

always @(posedge clk) begin
    if(wr_vld && wr_state == 3'd1) begin
        match_enable <= 1;
    end else if (match_suc == 1) begin
        match_enable <= 0;
    end
end

always @(posedge clk) begin
    if(wr_vld) begin
        buffer[wr_ptr] <= wr_data;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        end_ptr <= 8'hFF;
    end else if(wr_state == 3'd3) begin
        end_ptr <= wr_ptr;
    end
end

always @(posedge clk) begin
    if(wr_state == 3'd0) begin
        wr_length <= 0;
    end else if (wr_vld) begin
        wr_length <= wr_length + 1;
    end
end

always @(posedge clk) begin
    pause <= (wr_ptr + 6'd2 == xfer_ptr) || 
             (wr_state == 3'd3 && match_enable) || 
             (wr_state == 3'd0 && match_enable);
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        xfer_state <= 3'd0;
    end else if(xfer_state == 3'd0 && match_suc) begin
        xfer_state <= 3'd1;
        cur_length <= new_length;
        cur_prior <= new_prior;
        cur_dest_port <= new_dest_port;
    end else if(xfer_state == 3'd1 && xfer_ptr + 6'd1 == wr_ptr) begin
        xfer_state <= 3'd2;
    end else if(xfer_state == 3'd1 && xfer_ptr + 6'd1 == end_ptr) begin
        xfer_state <= 3'd0;                                                 //TODO"持有的延迟"   
    end else if(xfer_state == 3'd2 && xfer_ptr != wr_ptr) begin
        xfer_state <= 3'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        end_of_packet <= 0;
    end else if(xfer_state == 3'd1 && xfer_ptr == end_ptr) begin
        end_of_packet <= 1;
    end else begin
        end_of_packet <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        xfer_ptr <= 0;
        xfer_data_vld <= 0;
    end else if(xfer_state == 3'd1) begin
        xfer_ptr <= xfer_ptr + 1;
        xfer_data_vld <= 1;
    end else begin
        xfer_data_vld <= 0;
    end
end

always @(posedge clk) begin
    if(xfer_state == 3'd1) begin
        xfer_data <= buffer[xfer_ptr];
    end
end

endmodule