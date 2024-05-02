`include "ecc_encoder.sv"
`include "ecc_decoder.sv"
`include "sram.sv"
`include "sram_state.sv"
`include "port.sv"
`include "port_state.sv"
module controller(
    input clk,
    input rst_n,
    input wr_sop_0,
    input wr_eop_0,
    input wr_vld_0,
    input [15:0] wr_data_0,
    output reg full_0,
    output reg almost_full_0,

    input ready_0,
    output rd_sop_0,
    output rd_eop_0,
    output rd_vld_0,
    output reg [15:0] rd_data_0
    );

/*
    Global
*/

/*
    Ports
*/

wire [8:0] length_0;
wire [2:0] priority_0;
wire [3:0] dest_port_0;
wire [3:0] batch_0;
wire [15:0] data_0;
wire [1:0] ctrl_flag_0;
reg [127:0] buf_0;
reg [15:0] distribution_addr_0;

port port_0(
    .length(length_0),
    .prior(priority_0),
    .dest_port(dest_port_0),
    .batch(batch_0),
    .data(data_0),
    .ctrl_flag(ctrl_flag_0),

    .wr_sop(wr_sop_0),
    .wr_eop(wr_eop_0),
    .wr_vld(wr_vld),
    .wr_data(wr_data_0),
    .full(full_0),
    .ready(ready_0),
    .rd_sop(rd_sop_0),
    .rd_eop(rd_eop_0),
    .rd_vld(rd_vld_0),
    .rd_data(rd_data_0)
);

always @(batch_0) begin
    if(ctrl_flag_0[1]) begin
        //distribution
    end

    //hook to sram and save
    wr_en_0 = 1;
    wr_addr_0 = data_0;
    din_0 = data_0;

    //save pack info to dest port

    case (batch_0)
        1:  if(ctrl_flag_0[1]) buf_0[15:0] = {2'b0, length_0[8:3], 5'b0, length_0[2:0]};
            else buf_0[15:0] = data_0;
        2: buf_0[31:16] = data_0;
        3: buf_0[47:32] = data_0;
        4: buf_0[63:48] = data_0;
        5: buf_0[79:64] = data_0;
        6: buf_0[95:80] = data_0;
        7: buf_0[111:96] = data_0;
        8: buf_0[127:112] = data_0;
    endcase
end

/*
    SRAMs
*/

reg wr_en_0;
reg [13:0] wr_addr_0;
reg [15:0] din_0; 

dual_port_sram sram_0(
    .clk(clk),
    .wr_en(wr_en_0),
    .wr_addr(wr_addr_0),
    .din(din_0)
);

reg [10:0] sec_addr_0;
wire [7:0] sec_code_0;
reg [10:0] addr_0;
wire addr_state_0;
wire [10:0] null_ptr_0;
wire [10:0] free_space_0;

sram_state sram_state_0(
    .clk(clk),
    .sec_addr(sec_addr_0),
    .sec_code(sec_code_0),
    .wr_addr(wr_addr_0[13:3]),
    .addr(addr_0),
    .addr_state(addr_state_0),
    .null_ptr(null_ptr_0),
    .free_space(free_space_0)
);

/*
    Logic
*/

always @(posedge clk) begin
    
end

endmodule