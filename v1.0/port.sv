module port(
    input clk,
    
    //INTERNAL
    output reg [8:0] length,
    output reg [2:0] prior,
    output reg [3:0] dest_port,
    output reg [3:0] batch = 0,           //1-data valid 0-data not valid
    output reg [15:0] data,
    output reg [1:0] ctrl_flag,

    //INTERFACE
    input wr_sop,
    input wr_eop,
    input wr_vld,
    input [15:0] wr_data,
    output reg full,
    output reg almost_full,

    input ready,
    output rd_sop,
    output rd_eop,
    output rd_vld,
    output reg [15:0] rd_data
);

always @(posedge wr_sop) begin
    ctrl_flag = 3;
    batch = 0;
end

always @(posedge clk)
    if(wr_vld) begin
        if(ctrl_flag[0]) begin
            length = wr_data[15:8];
            prior = wr_data[7:5];
            dest_port = wr_data[4:0];
            ctrl_flag = 2;
        end
        else
            data = wr_data;
        batch = batch + 1;
        if(batch >= 9) begin
            ctrl_flag = 0;
            batch = 0;
        end
    end

endmodule