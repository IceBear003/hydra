module port(
    input clk,

    //INTERFACE
    input wr_sop,
    input wr_eop,
    input wr_vld,
    input [15:0] wr_data,
    output reg full = 0,
    output reg almost_full = 0,

    input ready,
    output reg rd_sop = 0,
    output reg rd_eop = 0,
    output reg rd_vld = 0,
    output reg [15:0] rd_data = 16'b0,

    //INTERNAL
    output reg wr_en = 0,
    output reg is_ctrl_frame = 0,
    output reg [2:0] batch = 3'b0,
    output reg [2:0] prior = 3'b0,
    output reg [3:0] dest_port = 4'b0,
    output reg [15:0] data = 16'b0
);

always @(posedge clk) begin 
    if(wr_sop) begin
        is_ctrl_frame = 1;
    end
    if(wr_eop) begin
        batch = 3'b0;
        prior = 3'b0;
        dest_port = 4'b0;
        data = 16'b0;
    end
    wr_en = wr_vld;
    if(wr_vld) begin
        if(is_ctrl_frame) begin
            dest_port = wr_data[3:0];
            prior = wr_data[6:4];
            data[2:0] = wr_data[9:7];
            data[13:8] = wr_data[15:10];
            is_ctrl_frame = 0;
        end
        else 
            data = wr_data;
        batch = batch + 1;
    end
end

endmodule