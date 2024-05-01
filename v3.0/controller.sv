`include "./v3.0/sram_state.sv"
`include "./v3.0/sram.sv"
`include "./v3.0/ecc_encoder.sv"
`include "./v3.0/ecc_decoder.sv"
`include "./v3.0/port.sv"

module controller(
    output reg [15:0][127:0] ecc_encoder_data,
    input [15:0][7:0] ecc_encoder_code,
    output reg [15:0][127:0] ecc_decoder_data,
    output reg [15:0][7:0] ecc_decoder_code,
    input [15:0][127:0] ecc_decoder_cr_data
);

genvar i;
generate
    for(i = 0; i < 32; i = i + 1)
    begin: sram_related
        sram sram
        (

        );
        sram_state sram_state
        (

        );
    end
endgenerate
generate
    for(i = 0; i < 32; i = i + 1)
    begin: port_related
        port port
        (

        );
        ecc_encoder ecc_encoder
        (
            .data(ecc_encoder_data[i]),
            .code(ecc_encoder_code[i])
        );
        ecc_decoder ecc_decoder
        (
            .data(ecc_decoder_data[i]),
            .code(ecc_decoder_code[i]),
            .cr_data(ecc_decoder_cr_data[i])
        );
    end
endgenerate

endmodule
