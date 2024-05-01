`include "./v3.0/sram_state.sv"
`include "./v3.0/sram.sv"
`include "./v3.0/ecc_encoder.sv"
`include "./v3.0/ecc_decoder.sv"
`include "./v3.0/port.sv"

module controller(
    input clk,
    input rst_n,

    //16 Ports
    input [15:0] wr_sop,
    input [15:0] wr_eop,
    input [15:0] wr_vld,
    input [15:0] [15:0] wr_data,
    output reg [15:0] full = 0,
    output reg [15:0] almost_full = 0
);

integer port_i;
always @(posedge clk) begin
    for(port_i = 0; port_i < 16; port_i = port_i + 1) begin
        
    end
end

wire [15:0] port_writting;
wire [15:0] port_is_ctrl_frame;
wire [15:0] [2:0] port_batch;
wire [15:0] [2:0] port_prior;
wire [15:0] [3:0] port_dest_port;
wire [15:0] [15:0] port_data;

port port [15:0]
(
    .clk(clk),
    .wr_sop(wr_sop),
    .wr_eop(wr_eop),
    .wr_vld(wr_vld),
    .wr_data(wr_data),

    .writting(port_writting),
    .is_ctrl_frame(port_is_ctrl_frame),
    .batch(port_batch),
    .prior(port_prior),
    .dest_port(port_dest_port),
    .data(port_data)
);

reg [15:0][127:0] wr_buffer;
wire [15:0][7:0] ecc_encoder_code;

ecc_encoder ecc_encoder [15:0]
(
    .data(wr_buffer),
    .code(ecc_encoder_code)
);

reg [15:0][127:0] rd_buffer;
wire [15:0][7:0] ecc_decoder_code;
wire [15:0][127:0] cr_rd_buffer;

ecc_decoder ecc_decoder [15:0]
(
    .data(rd_buffer),
    .code(ecc_decoder_code),
    .cr_data(cr_rd_buffer)
);

endmodule
