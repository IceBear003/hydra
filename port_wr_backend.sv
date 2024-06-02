`include "port_ecc_encoder.sv"

module port_wr_backend(
    input xfer_data_vld,
    input [15:0] xfer_data,
    
    input end_of_packet,
    input [3:0] cur_dest_port,
    input [2:0] cur_prior,
    input [8:0] cur_length
);

reg [15:0] encoder_buffer [7:0];
wire [7:0] encoder_result;

port_ecc_encoder port_ecc_encoder(
    .data_0(encoder_buffer[0]),
    .data_1(encoder_buffer[1]),
    .data_2(encoder_buffer[2]),
    .data_3(encoder_buffer[3]),
    .data_4(encoder_buffer[4]),
    .data_5(encoder_buffer[5]),
    .data_6(encoder_buffer[6]),
    .data_7(encoder_buffer[7]),
    .code(encoder_result)
);

endmodule