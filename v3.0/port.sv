module port(
    input clk,

    //INTERFACE
    input wr_sop,
    input wr_eop,
    input wr_vld,
    input [15:0] wr_data,

    //INTERNAL
    output reg writting = 0,
    output reg page_over = 0,
    output reg [2:0] prior = 3'b0,
    output reg [3:0] dest_port = 4'b0,
    output reg [15:0] data = 16'b0
);

reg is_ctrl_frame = 0;
reg [2:0] batch = 3'b0;
reg left = 0;

always @(posedge clk) begin 
    if(wr_sop) begin
        is_ctrl_frame <= 1;
    end
    if(wr_eop) begin
        batch <= 3'b0;
        prior <= 3'b0;
        dest_port <= 4'b0;
        data <= 16'b0;
    end
    writting <= wr_vld;
    if(wr_vld) begin
        if(is_ctrl_frame) begin
            dest_port <= wr_data[3:0];
            prior <= wr_data[6:4];
            data[2:0] <= wr_data[9:7];
            data[13:8] <= wr_data[15:10];
            left <= wr_data[15:7];
            is_ctrl_frame <= 0;
        end
        else begin
            data <= wr_data;
        end

        if(batch == 7 || left == 1) 
            page_over <= 1;
        batch <= batch + 1;
        left <= left - 1;
    end
end

endmodule