`include "ecc_encoder.sv"
`include "ecc_decoder.sv"
`include "sram.sv"
`include "sram_state.sv"
`include "port.sv"
module controller(
    input clk,
    input rst_n,

    //Ports
    input [15:0] port_wr_en,
    input [15:0] port_is_ctrl_frame,
    input [15:0][2:0] port_batch,
    input [15:0][2:0] port_prior,
    input [15:0][3:0] port_dest_port,
    input [15:0][15:0] port_data,

    //ECC
    input [15:0][7:0] port_ecc_encoder_code,
    output reg [15:0][127:0] port_ecc_encoder_data,
    output reg [15:0][127:0] port_ecc_decoder_data,
    output reg [15:0][7:0] port_ecc_decoder_code,
    input [15:0][127:0] port_ecc_decoder_cr_data,

    //SRAMs
    output reg [31:0] sram_wr_en,
    output reg [31:0][13:0] sram_wr_addr,
    output reg [31:0][15:0] sram_din,

    //SRAM State
    output reg [31:0] sram_wr_ecc_en,
    output reg [31:0][10:0] sram_wr_ecc_addr,
    output reg [31:0][7:0] sram_wr_ecc_code,
    output reg [31:0][10:0] sram_rd_ecc_addr,
    input [31:0][7:0] sram_rd_ecc_code,
    output reg [31:0] sram_wr_op,
    output reg [31:0][3:0] sram_wr_port,
    output reg [31:0] sram_rd_op,
    output reg [31:0][3:0] sram_rd_port,
    output reg [31:0][10:0] sram_rd_addr,
    input [511:0][10:0] sram_page_amount,
    input [31:0][2:0] sram_state,
    input [31:0][10:0] sram_null_ptr,
    input [31:0][10:0] sram_free_space
);

integer port;
integer sram;

reg [15:0][4:0] port_sram;
reg [31:0] hooked_sram;
reg [3:0][10:0] tmp_sram_port_amount;
reg [2:0] tmp_sram_state;

reg recursion_trigger = 0;
reg [3:0] recursion_index = 4'b0;

reg [5:0] tmp_free_sram = 6'b100000;
reg no_better_choice = 1;

always @(posedge recursion_trigger) begin
    recursion_trigger = 0;
    
    if(recursion_index >= 16) begin
        if(no_better_choice) begin
            if(tmp_free_sram[5]);
                //Pull up SRAM to FULL
            else;
        end
    end
    else begin
        sram = port_sram[recursion_index];
        tmp_sram_port_amount = sram_page_amount[sram << 4 + recursion_index];
    
        if(tmp_sram_port_amount[recursion_index] > 11'd1536) // > 0.75
            for(sram = 0; sram < 32; sram = sram + 1) begin
                tmp_sram_state = sram_state[sram];
                if(hooked_sram[sram] ||
                    tmp_sram_state[2] ||
                    tmp_sram_state[1]);
                else begin
                    tmp_sram_port_amount = sram_page_amount[sram << 4 + recursion_index];
                    if(tmp_sram_port_amount < 11'd1536 &&
                        tmp_sram_port_amount > 11'd512) begin
                        port_sram[recursion_index] = sram;
                        hooked_sram[sram] = 1;
                        no_better_choice = 0;
                    end
    
                    tmp_free_sram = sram;
                end
            end
            
        recursion_trigger = recursion_trigger + 1;
    end
end

always @(posedge clk) begin
    for(port = 0; port < 16; port = port + 1) begin
        if(port_wr_en[port]) begin
            sram_wr_en[port_sram[port]] <= 1;
            sram_wr_addr[port_sram[port]] <= sram_null_ptr[port_sram[port]] << 3 + port_batch[port];
            sram_din[port_sram[port]] <= port_data[port];

            sram_wr_op[port_sram[port]] <= 1;

            sram_wr_ecc_addr[port_sram[port]] <= sram_null_ptr[port_sram[port]];
            port_ecc_encoder_data[port] <= port_ecc_encoder_data[port] + port_data[port] << (port_batch[port] * 16);

            if(port_batch[port] == 8) begin
                sram_wr_ecc_en[port_sram[port]] <= 1;
                sram_wr_ecc_code[port_sram[port]] <= port_ecc_encoder_code[port];
            end
        end
    end
end

always @(negedge clk) begin
    sram_wr_op <= 32'b0;
    sram_rd_op <= 32'b0;
    sram_wr_ecc_en <= 32'b0;
end

port port_0(
    .clk(clk),
    .wr_en(port_wr_en[0]),
    .is_ctrl_frame(port_is_ctrl_frame[0]),
    .batch(port_batch[0]),
    .prior(port_prior[0]),
    .dest_port(port_dest_port[0]),
    .data(port_data[0]) 
);
port port_1(
    .clk(clk),
    .wr_en(port_wr_en[1]),
    .is_ctrl_frame(port_is_ctrl_frame[1]),
    .batch(port_batch[1]),
    .prior(port_prior[1]),
    .dest_port(port_dest_port[1]),
    .data(port_data[1]) 
);
port port_2(
    .clk(clk),
    .wr_en(port_wr_en[2]),
    .is_ctrl_frame(port_is_ctrl_frame[2]),
    .batch(port_batch[2]),
    .prior(port_prior[2]),
    .dest_port(port_dest_port[2]),
    .data(port_data[2]) 
);
port port_3(
    .clk(clk),
    .wr_en(port_wr_en[3]),
    .is_ctrl_frame(port_is_ctrl_frame[3]),
    .batch(port_batch[3]),
    .prior(port_prior[3]),
    .dest_port(port_dest_port[3]),
    .data(port_data[3]) 
);
port port_4(
    .clk(clk),
    .wr_en(port_wr_en[4]),
    .is_ctrl_frame(port_is_ctrl_frame[4]),
    .batch(port_batch[4]),
    .prior(port_prior[4]),
    .dest_port(port_dest_port[4]),
    .data(port_data[4]) 
);
port port_5(
    .clk(clk),
    .wr_en(port_wr_en[5]),
    .is_ctrl_frame(port_is_ctrl_frame[5]),
    .batch(port_batch[5]),
    .prior(port_prior[5]),
    .dest_port(port_dest_port[5]),
    .data(port_data[5]) 
);
port port_6(
    .clk(clk),
    .wr_en(port_wr_en[6]),
    .is_ctrl_frame(port_is_ctrl_frame[6]),
    .batch(port_batch[6]),
    .prior(port_prior[6]),
    .dest_port(port_dest_port[6]),
    .data(port_data[6]) 
);
port port_7(
    .clk(clk),
    .wr_en(port_wr_en[7]),
    .is_ctrl_frame(port_is_ctrl_frame[7]),
    .batch(port_batch[7]),
    .prior(port_prior[7]),
    .dest_port(port_dest_port[7]),
    .data(port_data[7]) 
);
port port_8(
    .clk(clk),
    .wr_en(port_wr_en[8]),
    .is_ctrl_frame(port_is_ctrl_frame[8]),
    .batch(port_batch[8]),
    .prior(port_prior[8]),
    .dest_port(port_dest_port[8]),
    .data(port_data[8]) 
);
port port_9(
    .clk(clk),
    .wr_en(port_wr_en[9]),
    .is_ctrl_frame(port_is_ctrl_frame[9]),
    .batch(port_batch[9]),
    .prior(port_prior[9]),
    .dest_port(port_dest_port[9]),
    .data(port_data[9]) 
);
port port_10(
    .clk(clk),
    .wr_en(port_wr_en[10]),
    .is_ctrl_frame(port_is_ctrl_frame[10]),
    .batch(port_batch[10]),
    .prior(port_prior[10]),
    .dest_port(port_dest_port[10]),
    .data(port_data[10]) 
);
port port_11(
    .clk(clk),
    .wr_en(port_wr_en[11]),
    .is_ctrl_frame(port_is_ctrl_frame[11]),
    .batch(port_batch[11]),
    .prior(port_prior[11]),
    .dest_port(port_dest_port[11]),
    .data(port_data[11]) 
);
port port_12(
    .clk(clk),
    .wr_en(port_wr_en[12]),
    .is_ctrl_frame(port_is_ctrl_frame[12]),
    .batch(port_batch[12]),
    .prior(port_prior[12]),
    .dest_port(port_dest_port[12]),
    .data(port_data[12]) 
);
port port_13(
    .clk(clk),
    .wr_en(port_wr_en[13]),
    .is_ctrl_frame(port_is_ctrl_frame[13]),
    .batch(port_batch[13]),
    .prior(port_prior[13]),
    .dest_port(port_dest_port[13]),
    .data(port_data[13]) 
);
port port_14(
    .clk(clk),
    .wr_en(port_wr_en[14]),
    .is_ctrl_frame(port_is_ctrl_frame[14]),
    .batch(port_batch[14]),
    .prior(port_prior[14]),
    .dest_port(port_dest_port[14]),
    .data(port_data[14]) 
);
port port_15(
    .clk(clk),
    .wr_en(port_wr_en[15]),
    .is_ctrl_frame(port_is_ctrl_frame[15]),
    .batch(port_batch[15]),
    .prior(port_prior[15]),
    .dest_port(port_dest_port[15]),
    .data(port_data[15]) 
);

ecc_encoder ecc_encoder_0(
    .data(port_ecc_encoder_data[0]),
    .sec_code(port_ecc_encoder_code[0])
);
ecc_decoder ecc_decoder_0(
    .data(port_ecc_decoder_data[0]),
    .sec_code(port_ecc_decoder_code[0]),
    .cr_data(port_ecc_decoder_cr_data[0])
);

ecc_encoder ecc_encoder_1(
    .data(port_ecc_encoder_data[1]),
    .sec_code(port_ecc_encoder_code[1])
);
ecc_decoder ecc_decoder_1(
    .data(port_ecc_decoder_data[1]),
    .sec_code(port_ecc_decoder_code[1]),
    .cr_data(port_ecc_decoder_cr_data[1])
);

ecc_encoder ecc_encoder_2(
    .data(port_ecc_encoder_data[2]),
    .sec_code(port_ecc_encoder_code[2])
);
ecc_decoder ecc_decoder_2(
    .data(port_ecc_decoder_data[2]),
    .sec_code(port_ecc_decoder_code[2]),
    .cr_data(port_ecc_decoder_cr_data[2])
);

ecc_encoder ecc_encoder_3(
    .data(port_ecc_encoder_data[3]),
    .sec_code(port_ecc_encoder_code[3])
);
ecc_decoder ecc_decoder_3(
    .data(port_ecc_decoder_data[3]),
    .sec_code(port_ecc_decoder_code[3]),
    .cr_data(port_ecc_decoder_cr_data[3])
);

ecc_encoder ecc_encoder_4(
    .data(port_ecc_encoder_data[4]),
    .sec_code(port_ecc_encoder_code[4])
);
ecc_decoder ecc_decoder_4(
    .data(port_ecc_decoder_data[4]),
    .sec_code(port_ecc_decoder_code[4]),
    .cr_data(port_ecc_decoder_cr_data[4])
);

ecc_encoder ecc_encoder_5(
    .data(port_ecc_encoder_data[5]),
    .sec_code(port_ecc_encoder_code[5])
);
ecc_decoder ecc_decoder_5(
    .data(port_ecc_decoder_data[5]),
    .sec_code(port_ecc_decoder_code[5]),
    .cr_data(port_ecc_decoder_cr_data[5])
);

ecc_encoder ecc_encoder_6(
    .data(port_ecc_encoder_data[6]),
    .sec_code(port_ecc_encoder_code[6])
);
ecc_decoder ecc_decoder_6(
    .data(port_ecc_decoder_data[6]),
    .sec_code(port_ecc_decoder_code[6]),
    .cr_data(port_ecc_decoder_cr_data[6])
);

ecc_encoder ecc_encoder_7(
    .data(port_ecc_encoder_data[7]),
    .sec_code(port_ecc_encoder_code[7])
);
ecc_decoder ecc_decoder_7(
    .data(port_ecc_decoder_data[7]),
    .sec_code(port_ecc_decoder_code[7]),
    .cr_data(port_ecc_decoder_cr_data[7])
);

ecc_encoder ecc_encoder_8(
    .data(port_ecc_encoder_data[8]),
    .sec_code(port_ecc_encoder_code[8])
);
ecc_decoder ecc_decoder_8(
    .data(port_ecc_decoder_data[8]),
    .sec_code(port_ecc_decoder_code[8]),
    .cr_data(port_ecc_decoder_cr_data[8])
);

ecc_encoder ecc_encoder_9(
    .data(port_ecc_encoder_data[9]),
    .sec_code(port_ecc_encoder_code[9])
);
ecc_decoder ecc_decoder_9(
    .data(port_ecc_decoder_data[9]),
    .sec_code(port_ecc_decoder_code[9]),
    .cr_data(port_ecc_decoder_cr_data[9])
);

ecc_encoder ecc_encoder_10(
    .data(port_ecc_encoder_data[10]),
    .sec_code(port_ecc_encoder_code[10])
);
ecc_decoder ecc_decoder_10(
    .data(port_ecc_decoder_data[10]),
    .sec_code(port_ecc_decoder_code[10]),
    .cr_data(port_ecc_decoder_cr_data[10])
);

ecc_encoder ecc_encoder_11(
    .data(port_ecc_encoder_data[11]),
    .sec_code(port_ecc_encoder_code[11])
);
ecc_decoder ecc_decoder_11(
    .data(port_ecc_decoder_data[11]),
    .sec_code(port_ecc_decoder_code[11]),
    .cr_data(port_ecc_decoder_cr_data[11])
);

ecc_encoder ecc_encoder_12(
    .data(port_ecc_encoder_data[12]),
    .sec_code(port_ecc_encoder_code[12])
);
ecc_decoder ecc_decoder_12(
    .data(port_ecc_decoder_data[12]),
    .sec_code(port_ecc_decoder_code[12]),
    .cr_data(port_ecc_decoder_cr_data[12])
);

ecc_encoder ecc_encoder_13(
    .data(port_ecc_encoder_data[13]),
    .sec_code(port_ecc_encoder_code[13])
);
ecc_decoder ecc_decoder_13(
    .data(port_ecc_decoder_data[13]),
    .sec_code(port_ecc_decoder_code[13]),
    .cr_data(port_ecc_decoder_cr_data[13])
);

ecc_encoder ecc_encoder_14(
    .data(port_ecc_encoder_data[14]),
    .sec_code(port_ecc_encoder_code[14])
);
ecc_decoder ecc_decoder_14(
    .data(port_ecc_decoder_data[14]),
    .sec_code(port_ecc_decoder_code[14]),
    .cr_data(port_ecc_decoder_cr_data[14])
);

ecc_encoder ecc_encoder_15(
    .data(port_ecc_encoder_data[15]),
    .sec_code(port_ecc_encoder_code[15])
);
ecc_decoder ecc_decoder_15(
    .data(port_ecc_decoder_data[15]),
    .sec_code(port_ecc_decoder_code[15]),
    .cr_data(port_ecc_decoder_cr_data[15])
);

dual_port_sram sram_0(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[0]),
    .wr_addr(sram_wr_addr[0]),
    .din(sram_din[0])
);

dual_port_sram sram_1(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[1]),
    .wr_addr(sram_wr_addr[1]),
    .din(sram_din[1])
);

dual_port_sram sram_2(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[2]),
    .wr_addr(sram_wr_addr[2]),
    .din(sram_din[2])
);

dual_port_sram sram_3(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[3]),
    .wr_addr(sram_wr_addr[3]),
    .din(sram_din[3])
);

dual_port_sram sram_4(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[4]),
    .wr_addr(sram_wr_addr[4]),
    .din(sram_din[4])
);

dual_port_sram sram_5(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[5]),
    .wr_addr(sram_wr_addr[5]),
    .din(sram_din[5])
);

dual_port_sram sram_6(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[6]),
    .wr_addr(sram_wr_addr[6]),
    .din(sram_din[6])
);

dual_port_sram sram_7(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[7]),
    .wr_addr(sram_wr_addr[7]),
    .din(sram_din[7])
);

dual_port_sram sram_8(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[8]),
    .wr_addr(sram_wr_addr[8]),
    .din(sram_din[8])
);

dual_port_sram sram_9(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[9]),
    .wr_addr(sram_wr_addr[9]),
    .din(sram_din[9])
);

dual_port_sram sram_10(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[10]),
    .wr_addr(sram_wr_addr[10]),
    .din(sram_din[10])
);

dual_port_sram sram_11(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[11]),
    .wr_addr(sram_wr_addr[11]),
    .din(sram_din[11])
);

dual_port_sram sram_12(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[12]),
    .wr_addr(sram_wr_addr[12]),
    .din(sram_din[12])
);

dual_port_sram sram_13(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[13]),
    .wr_addr(sram_wr_addr[13]),
    .din(sram_din[13])
);

dual_port_sram sram_14(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[14]),
    .wr_addr(sram_wr_addr[14]),
    .din(sram_din[14])
);

dual_port_sram sram_15(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[15]),
    .wr_addr(sram_wr_addr[15]),
    .din(sram_din[15])
);

dual_port_sram sram_16(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[16]),
    .wr_addr(sram_wr_addr[16]),
    .din(sram_din[16])
);

dual_port_sram sram_17(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[17]),
    .wr_addr(sram_wr_addr[17]),
    .din(sram_din[17])
);

dual_port_sram sram_18(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[18]),
    .wr_addr(sram_wr_addr[18]),
    .din(sram_din[18])
);

dual_port_sram sram_19(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[19]),
    .wr_addr(sram_wr_addr[19]),
    .din(sram_din[19])
);

dual_port_sram sram_20(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[20]),
    .wr_addr(sram_wr_addr[20]),
    .din(sram_din[20])
);

dual_port_sram sram_21(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[21]),
    .wr_addr(sram_wr_addr[21]),
    .din(sram_din[21])
);

dual_port_sram sram_22(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[22]),
    .wr_addr(sram_wr_addr[22]),
    .din(sram_din[22])
);

dual_port_sram sram_23(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[23]),
    .wr_addr(sram_wr_addr[23]),
    .din(sram_din[23])
);

dual_port_sram sram_24(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[24]),
    .wr_addr(sram_wr_addr[24]),
    .din(sram_din[24])
);

dual_port_sram sram_25(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[25]),
    .wr_addr(sram_wr_addr[25]),
    .din(sram_din[25])
);

dual_port_sram sram_26(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[26]),
    .wr_addr(sram_wr_addr[26]),
    .din(sram_din[26])
);

dual_port_sram sram_27(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[27]),
    .wr_addr(sram_wr_addr[27]),
    .din(sram_din[27])
);

dual_port_sram sram_28(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[28]),
    .wr_addr(sram_wr_addr[28]),
    .din(sram_din[28])
);

dual_port_sram sram_29(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[29]),
    .wr_addr(sram_wr_addr[29]),
    .din(sram_din[29])
);

dual_port_sram sram_30(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[30]),
    .wr_addr(sram_wr_addr[30]),
    .din(sram_din[30])
);

dual_port_sram sram_31(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sram_wr_en[31]),
    .wr_addr(sram_wr_addr[31]),
    .din(sram_din[31])
);

sram_state sram_state_0(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[0]),
    .wr_ecc_addr(sram_wr_ecc_addr[0]),
    .wr_ecc_code(sram_wr_ecc_code[0]),
    .rd_ecc_addr(sram_rd_ecc_addr[0]),
    .rd_ecc_code(sram_rd_ecc_code[0]),
    .wr_op(sram_wr_op[0]),
    .wr_port(sram_wr_port[0]),
    .rd_op(sram_rd_op[0]),
    .rd_port(sram_rd_port[0]),
    .rd_addr(sram_rd_addr[0]),
    .port_amount(sram_page_amount[15:0]),
    .state(sram_state[0]),
    .null_ptr(sram_null_ptr[0]),
    .free_space(sram_free_space[0])
);

sram_state sram_state_1(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[1]),
    .wr_ecc_addr(sram_wr_ecc_addr[1]),
    .wr_ecc_code(sram_wr_ecc_code[1]),
    .rd_ecc_addr(sram_rd_ecc_addr[1]),
    .rd_ecc_code(sram_rd_ecc_code[1]),
    .wr_op(sram_wr_op[1]),
    .wr_port(sram_wr_port[1]),
    .rd_op(sram_rd_op[1]),
    .rd_port(sram_rd_port[1]),
    .rd_addr(sram_rd_addr[1]),
    .port_amount(sram_page_amount[31:16]),
    .state(sram_state[1]),
    .null_ptr(sram_null_ptr[1]),
    .free_space(sram_free_space[1])
);

sram_state sram_state_2(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[2]),
    .wr_ecc_addr(sram_wr_ecc_addr[2]),
    .wr_ecc_code(sram_wr_ecc_code[2]),
    .rd_ecc_addr(sram_rd_ecc_addr[2]),
    .rd_ecc_code(sram_rd_ecc_code[2]),
    .wr_op(sram_wr_op[2]),
    .wr_port(sram_wr_port[2]),
    .rd_op(sram_rd_op[2]),
    .rd_port(sram_rd_port[2]),
    .rd_addr(sram_rd_addr[2]),
    .port_amount(sram_page_amount[47:32]),
    .state(sram_state[2]),
    .null_ptr(sram_null_ptr[2]),
    .free_space(sram_free_space[2])
);

sram_state sram_state_3(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[3]),
    .wr_ecc_addr(sram_wr_ecc_addr[3]),
    .wr_ecc_code(sram_wr_ecc_code[3]),
    .rd_ecc_addr(sram_rd_ecc_addr[3]),
    .rd_ecc_code(sram_rd_ecc_code[3]),
    .wr_op(sram_wr_op[3]),
    .wr_port(sram_wr_port[3]),
    .rd_op(sram_rd_op[3]),
    .rd_port(sram_rd_port[3]),
    .rd_addr(sram_rd_addr[3]),
    .port_amount(sram_page_amount[63:48]),
    .state(sram_state[3]),
    .null_ptr(sram_null_ptr[3]),
    .free_space(sram_free_space[3])
);

sram_state sram_state_4(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[4]),
    .wr_ecc_addr(sram_wr_ecc_addr[4]),
    .wr_ecc_code(sram_wr_ecc_code[4]),
    .rd_ecc_addr(sram_rd_ecc_addr[4]),
    .rd_ecc_code(sram_rd_ecc_code[4]),
    .wr_op(sram_wr_op[4]),
    .wr_port(sram_wr_port[4]),
    .rd_op(sram_rd_op[4]),
    .rd_port(sram_rd_port[4]),
    .rd_addr(sram_rd_addr[4]),
    .port_amount(sram_page_amount[79:64]),
    .state(sram_state[4]),
    .null_ptr(sram_null_ptr[4]),
    .free_space(sram_free_space[4])
);

sram_state sram_state_5(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[5]),
    .wr_ecc_addr(sram_wr_ecc_addr[5]),
    .wr_ecc_code(sram_wr_ecc_code[5]),
    .rd_ecc_addr(sram_rd_ecc_addr[5]),
    .rd_ecc_code(sram_rd_ecc_code[5]),
    .wr_op(sram_wr_op[5]),
    .wr_port(sram_wr_port[5]),
    .rd_op(sram_rd_op[5]),
    .rd_port(sram_rd_port[5]),
    .rd_addr(sram_rd_addr[5]),
    .port_amount(sram_page_amount[95:80]),
    .state(sram_state[5]),
    .null_ptr(sram_null_ptr[5]),
    .free_space(sram_free_space[5])
);

sram_state sram_state_6(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[6]),
    .wr_ecc_addr(sram_wr_ecc_addr[6]),
    .wr_ecc_code(sram_wr_ecc_code[6]),
    .rd_ecc_addr(sram_rd_ecc_addr[6]),
    .rd_ecc_code(sram_rd_ecc_code[6]),
    .wr_op(sram_wr_op[6]),
    .wr_port(sram_wr_port[6]),
    .rd_op(sram_rd_op[6]),
    .rd_port(sram_rd_port[6]),
    .rd_addr(sram_rd_addr[6]),
    .port_amount(sram_page_amount[111:96]),
    .state(sram_state[6]),
    .null_ptr(sram_null_ptr[6]),
    .free_space(sram_free_space[6])
);

sram_state sram_state_7(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[7]),
    .wr_ecc_addr(sram_wr_ecc_addr[7]),
    .wr_ecc_code(sram_wr_ecc_code[7]),
    .rd_ecc_addr(sram_rd_ecc_addr[7]),
    .rd_ecc_code(sram_rd_ecc_code[7]),
    .wr_op(sram_wr_op[7]),
    .wr_port(sram_wr_port[7]),
    .rd_op(sram_rd_op[7]),
    .rd_port(sram_rd_port[7]),
    .rd_addr(sram_rd_addr[7]),
    .port_amount(sram_page_amount[127:112]),
    .state(sram_state[7]),
    .null_ptr(sram_null_ptr[7]),
    .free_space(sram_free_space[7])
);

sram_state sram_state_8(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[8]),
    .wr_ecc_addr(sram_wr_ecc_addr[8]),
    .wr_ecc_code(sram_wr_ecc_code[8]),
    .rd_ecc_addr(sram_rd_ecc_addr[8]),
    .rd_ecc_code(sram_rd_ecc_code[8]),
    .wr_op(sram_wr_op[8]),
    .wr_port(sram_wr_port[8]),
    .rd_op(sram_rd_op[8]),
    .rd_port(sram_rd_port[8]),
    .rd_addr(sram_rd_addr[8]),
    .port_amount(sram_page_amount[143:128]),
    .state(sram_state[8]),
    .null_ptr(sram_null_ptr[8]),
    .free_space(sram_free_space[8])
);

sram_state sram_state_9(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[9]),
    .wr_ecc_addr(sram_wr_ecc_addr[9]),
    .wr_ecc_code(sram_wr_ecc_code[9]),
    .rd_ecc_addr(sram_rd_ecc_addr[9]),
    .rd_ecc_code(sram_rd_ecc_code[9]),
    .wr_op(sram_wr_op[9]),
    .wr_port(sram_wr_port[9]),
    .rd_op(sram_rd_op[9]),
    .rd_port(sram_rd_port[9]),
    .rd_addr(sram_rd_addr[9]),
    .port_amount(sram_page_amount[159:144]),
    .state(sram_state[9]),
    .null_ptr(sram_null_ptr[9]),
    .free_space(sram_free_space[9])
);

sram_state sram_state_10(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[10]),
    .wr_ecc_addr(sram_wr_ecc_addr[10]),
    .wr_ecc_code(sram_wr_ecc_code[10]),
    .rd_ecc_addr(sram_rd_ecc_addr[10]),
    .rd_ecc_code(sram_rd_ecc_code[10]),
    .wr_op(sram_wr_op[10]),
    .wr_port(sram_wr_port[10]),
    .rd_op(sram_rd_op[10]),
    .rd_port(sram_rd_port[10]),
    .rd_addr(sram_rd_addr[10]),
    .port_amount(sram_page_amount[175:160]),
    .state(sram_state[10]),
    .null_ptr(sram_null_ptr[10]),
    .free_space(sram_free_space[10])
);

sram_state sram_state_11(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[11]),
    .wr_ecc_addr(sram_wr_ecc_addr[11]),
    .wr_ecc_code(sram_wr_ecc_code[11]),
    .rd_ecc_addr(sram_rd_ecc_addr[11]),
    .rd_ecc_code(sram_rd_ecc_code[11]),
    .wr_op(sram_wr_op[11]),
    .wr_port(sram_wr_port[11]),
    .rd_op(sram_rd_op[11]),
    .rd_port(sram_rd_port[11]),
    .rd_addr(sram_rd_addr[11]),
    .port_amount(sram_page_amount[191:176]),
    .state(sram_state[11]),
    .null_ptr(sram_null_ptr[11]),
    .free_space(sram_free_space[11])
);

sram_state sram_state_12(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[12]),
    .wr_ecc_addr(sram_wr_ecc_addr[12]),
    .wr_ecc_code(sram_wr_ecc_code[12]),
    .rd_ecc_addr(sram_rd_ecc_addr[12]),
    .rd_ecc_code(sram_rd_ecc_code[12]),
    .wr_op(sram_wr_op[12]),
    .wr_port(sram_wr_port[12]),
    .rd_op(sram_rd_op[12]),
    .rd_port(sram_rd_port[12]),
    .rd_addr(sram_rd_addr[12]),
    .port_amount(sram_page_amount[207:192]),
    .state(sram_state[12]),
    .null_ptr(sram_null_ptr[12]),
    .free_space(sram_free_space[12])
);

sram_state sram_state_13(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[13]),
    .wr_ecc_addr(sram_wr_ecc_addr[13]),
    .wr_ecc_code(sram_wr_ecc_code[13]),
    .rd_ecc_addr(sram_rd_ecc_addr[13]),
    .rd_ecc_code(sram_rd_ecc_code[13]),
    .wr_op(sram_wr_op[13]),
    .wr_port(sram_wr_port[13]),
    .rd_op(sram_rd_op[13]),
    .rd_port(sram_rd_port[13]),
    .rd_addr(sram_rd_addr[13]),
    .port_amount(sram_page_amount[223:208]),
    .state(sram_state[13]),
    .null_ptr(sram_null_ptr[13]),
    .free_space(sram_free_space[13])
);

sram_state sram_state_14(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[14]),
    .wr_ecc_addr(sram_wr_ecc_addr[14]),
    .wr_ecc_code(sram_wr_ecc_code[14]),
    .rd_ecc_addr(sram_rd_ecc_addr[14]),
    .rd_ecc_code(sram_rd_ecc_code[14]),
    .wr_op(sram_wr_op[14]),
    .wr_port(sram_wr_port[14]),
    .rd_op(sram_rd_op[14]),
    .rd_port(sram_rd_port[14]),
    .rd_addr(sram_rd_addr[14]),
    .port_amount(sram_page_amount[239:224]),
    .state(sram_state[14]),
    .null_ptr(sram_null_ptr[14]),
    .free_space(sram_free_space[14])
);

sram_state sram_state_15(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[15]),
    .wr_ecc_addr(sram_wr_ecc_addr[15]),
    .wr_ecc_code(sram_wr_ecc_code[15]),
    .rd_ecc_addr(sram_rd_ecc_addr[15]),
    .rd_ecc_code(sram_rd_ecc_code[15]),
    .wr_op(sram_wr_op[15]),
    .wr_port(sram_wr_port[15]),
    .rd_op(sram_rd_op[15]),
    .rd_port(sram_rd_port[15]),
    .rd_addr(sram_rd_addr[15]),
    .port_amount(sram_page_amount[255:240]),
    .state(sram_state[15]),
    .null_ptr(sram_null_ptr[15]),
    .free_space(sram_free_space[15])
);

sram_state sram_state_16(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[16]),
    .wr_ecc_addr(sram_wr_ecc_addr[16]),
    .wr_ecc_code(sram_wr_ecc_code[16]),
    .rd_ecc_addr(sram_rd_ecc_addr[16]),
    .rd_ecc_code(sram_rd_ecc_code[16]),
    .wr_op(sram_wr_op[16]),
    .wr_port(sram_wr_port[16]),
    .rd_op(sram_rd_op[16]),
    .rd_port(sram_rd_port[16]),
    .rd_addr(sram_rd_addr[16]),
    .port_amount(sram_page_amount[271:256]),
    .state(sram_state[16]),
    .null_ptr(sram_null_ptr[16]),
    .free_space(sram_free_space[16])
);

sram_state sram_state_17(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[17]),
    .wr_ecc_addr(sram_wr_ecc_addr[17]),
    .wr_ecc_code(sram_wr_ecc_code[17]),
    .rd_ecc_addr(sram_rd_ecc_addr[17]),
    .rd_ecc_code(sram_rd_ecc_code[17]),
    .wr_op(sram_wr_op[17]),
    .wr_port(sram_wr_port[17]),
    .rd_op(sram_rd_op[17]),
    .rd_port(sram_rd_port[17]),
    .rd_addr(sram_rd_addr[17]),
    .port_amount(sram_page_amount[287:272]),
    .state(sram_state[17]),
    .null_ptr(sram_null_ptr[17]),
    .free_space(sram_free_space[17])
);

sram_state sram_state_18(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[18]),
    .wr_ecc_addr(sram_wr_ecc_addr[18]),
    .wr_ecc_code(sram_wr_ecc_code[18]),
    .rd_ecc_addr(sram_rd_ecc_addr[18]),
    .rd_ecc_code(sram_rd_ecc_code[18]),
    .wr_op(sram_wr_op[18]),
    .wr_port(sram_wr_port[18]),
    .rd_op(sram_rd_op[18]),
    .rd_port(sram_rd_port[18]),
    .rd_addr(sram_rd_addr[18]),
    .port_amount(sram_page_amount[303:288]),
    .state(sram_state[18]),
    .null_ptr(sram_null_ptr[18]),
    .free_space(sram_free_space[18])
);

sram_state sram_state_19(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[19]),
    .wr_ecc_addr(sram_wr_ecc_addr[19]),
    .wr_ecc_code(sram_wr_ecc_code[19]),
    .rd_ecc_addr(sram_rd_ecc_addr[19]),
    .rd_ecc_code(sram_rd_ecc_code[19]),
    .wr_op(sram_wr_op[19]),
    .wr_port(sram_wr_port[19]),
    .rd_op(sram_rd_op[19]),
    .rd_port(sram_rd_port[19]),
    .rd_addr(sram_rd_addr[19]),
    .port_amount(sram_page_amount[319:304]),
    .state(sram_state[19]),
    .null_ptr(sram_null_ptr[19]),
    .free_space(sram_free_space[19])
);

sram_state sram_state_20(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[20]),
    .wr_ecc_addr(sram_wr_ecc_addr[20]),
    .wr_ecc_code(sram_wr_ecc_code[20]),
    .rd_ecc_addr(sram_rd_ecc_addr[20]),
    .rd_ecc_code(sram_rd_ecc_code[20]),
    .wr_op(sram_wr_op[20]),
    .wr_port(sram_wr_port[20]),
    .rd_op(sram_rd_op[20]),
    .rd_port(sram_rd_port[20]),
    .rd_addr(sram_rd_addr[20]),
    .port_amount(sram_page_amount[335:320]),
    .state(sram_state[20]),
    .null_ptr(sram_null_ptr[20]),
    .free_space(sram_free_space[20])
);

sram_state sram_state_21(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[21]),
    .wr_ecc_addr(sram_wr_ecc_addr[21]),
    .wr_ecc_code(sram_wr_ecc_code[21]),
    .rd_ecc_addr(sram_rd_ecc_addr[21]),
    .rd_ecc_code(sram_rd_ecc_code[21]),
    .wr_op(sram_wr_op[21]),
    .wr_port(sram_wr_port[21]),
    .rd_op(sram_rd_op[21]),
    .rd_port(sram_rd_port[21]),
    .rd_addr(sram_rd_addr[21]),
    .port_amount(sram_page_amount[351:336]),
    .state(sram_state[21]),
    .null_ptr(sram_null_ptr[21]),
    .free_space(sram_free_space[21])
);

sram_state sram_state_22(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[22]),
    .wr_ecc_addr(sram_wr_ecc_addr[22]),
    .wr_ecc_code(sram_wr_ecc_code[22]),
    .rd_ecc_addr(sram_rd_ecc_addr[22]),
    .rd_ecc_code(sram_rd_ecc_code[22]),
    .wr_op(sram_wr_op[22]),
    .wr_port(sram_wr_port[22]),
    .rd_op(sram_rd_op[22]),
    .rd_port(sram_rd_port[22]),
    .rd_addr(sram_rd_addr[22]),
    .port_amount(sram_page_amount[367:352]),
    .state(sram_state[22]),
    .null_ptr(sram_null_ptr[22]),
    .free_space(sram_free_space[22])
);

sram_state sram_state_23(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[23]),
    .wr_ecc_addr(sram_wr_ecc_addr[23]),
    .wr_ecc_code(sram_wr_ecc_code[23]),
    .rd_ecc_addr(sram_rd_ecc_addr[23]),
    .rd_ecc_code(sram_rd_ecc_code[23]),
    .wr_op(sram_wr_op[23]),
    .wr_port(sram_wr_port[23]),
    .rd_op(sram_rd_op[23]),
    .rd_port(sram_rd_port[23]),
    .rd_addr(sram_rd_addr[23]),
    .port_amount(sram_page_amount[383:368]),
    .state(sram_state[23]),
    .null_ptr(sram_null_ptr[23]),
    .free_space(sram_free_space[23])
);

sram_state sram_state_24(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[24]),
    .wr_ecc_addr(sram_wr_ecc_addr[24]),
    .wr_ecc_code(sram_wr_ecc_code[24]),
    .rd_ecc_addr(sram_rd_ecc_addr[24]),
    .rd_ecc_code(sram_rd_ecc_code[24]),
    .wr_op(sram_wr_op[24]),
    .wr_port(sram_wr_port[24]),
    .rd_op(sram_rd_op[24]),
    .rd_port(sram_rd_port[24]),
    .rd_addr(sram_rd_addr[24]),
    .port_amount(sram_page_amount[399:384]),
    .state(sram_state[24]),
    .null_ptr(sram_null_ptr[24]),
    .free_space(sram_free_space[24])
);

sram_state sram_state_25(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[25]),
    .wr_ecc_addr(sram_wr_ecc_addr[25]),
    .wr_ecc_code(sram_wr_ecc_code[25]),
    .rd_ecc_addr(sram_rd_ecc_addr[25]),
    .rd_ecc_code(sram_rd_ecc_code[25]),
    .wr_op(sram_wr_op[25]),
    .wr_port(sram_wr_port[25]),
    .rd_op(sram_rd_op[25]),
    .rd_port(sram_rd_port[25]),
    .rd_addr(sram_rd_addr[25]),
    .port_amount(sram_page_amount[415:400]),
    .state(sram_state[25]),
    .null_ptr(sram_null_ptr[25]),
    .free_space(sram_free_space[25])
);

sram_state sram_state_26(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[26]),
    .wr_ecc_addr(sram_wr_ecc_addr[26]),
    .wr_ecc_code(sram_wr_ecc_code[26]),
    .rd_ecc_addr(sram_rd_ecc_addr[26]),
    .rd_ecc_code(sram_rd_ecc_code[26]),
    .wr_op(sram_wr_op[26]),
    .wr_port(sram_wr_port[26]),
    .rd_op(sram_rd_op[26]),
    .rd_port(sram_rd_port[26]),
    .rd_addr(sram_rd_addr[26]),
    .port_amount(sram_page_amount[431:416]),
    .state(sram_state[26]),
    .null_ptr(sram_null_ptr[26]),
    .free_space(sram_free_space[26])
);

sram_state sram_state_27(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[27]),
    .wr_ecc_addr(sram_wr_ecc_addr[27]),
    .wr_ecc_code(sram_wr_ecc_code[27]),
    .rd_ecc_addr(sram_rd_ecc_addr[27]),
    .rd_ecc_code(sram_rd_ecc_code[27]),
    .wr_op(sram_wr_op[27]),
    .wr_port(sram_wr_port[27]),
    .rd_op(sram_rd_op[27]),
    .rd_port(sram_rd_port[27]),
    .rd_addr(sram_rd_addr[27]),
    .port_amount(sram_page_amount[447:432]),
    .state(sram_state[27]),
    .null_ptr(sram_null_ptr[27]),
    .free_space(sram_free_space[27])
);

sram_state sram_state_28(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[28]),
    .wr_ecc_addr(sram_wr_ecc_addr[28]),
    .wr_ecc_code(sram_wr_ecc_code[28]),
    .rd_ecc_addr(sram_rd_ecc_addr[28]),
    .rd_ecc_code(sram_rd_ecc_code[28]),
    .wr_op(sram_wr_op[28]),
    .wr_port(sram_wr_port[28]),
    .rd_op(sram_rd_op[28]),
    .rd_port(sram_rd_port[28]),
    .rd_addr(sram_rd_addr[28]),
    .port_amount(sram_page_amount[463:448]),
    .state(sram_state[28]),
    .null_ptr(sram_null_ptr[28]),
    .free_space(sram_free_space[28])
);

sram_state sram_state_29(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[29]),
    .wr_ecc_addr(sram_wr_ecc_addr[29]),
    .wr_ecc_code(sram_wr_ecc_code[29]),
    .rd_ecc_addr(sram_rd_ecc_addr[29]),
    .rd_ecc_code(sram_rd_ecc_code[29]),
    .wr_op(sram_wr_op[29]),
    .wr_port(sram_wr_port[29]),
    .rd_op(sram_rd_op[29]),
    .rd_port(sram_rd_port[29]),
    .rd_addr(sram_rd_addr[29]),
    .port_amount(sram_page_amount[479:464]),
    .state(sram_state[29]),
    .null_ptr(sram_null_ptr[29]),
    .free_space(sram_free_space[29])
);

sram_state sram_state_30(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[30]),
    .wr_ecc_addr(sram_wr_ecc_addr[30]),
    .wr_ecc_code(sram_wr_ecc_code[30]),
    .rd_ecc_addr(sram_rd_ecc_addr[30]),
    .rd_ecc_code(sram_rd_ecc_code[30]),
    .wr_op(sram_wr_op[30]),
    .wr_port(sram_wr_port[30]),
    .rd_op(sram_rd_op[30]),
    .rd_port(sram_rd_port[30]),
    .rd_addr(sram_rd_addr[30]),
    .port_amount(sram_page_amount[495:480]),
    .state(sram_state[30]),
    .null_ptr(sram_null_ptr[30]),
    .free_space(sram_free_space[30])
);

sram_state sram_state_31(
    .clk(clk),
    .wr_ecc_en(sram_wr_ecc_en[31]),
    .wr_ecc_addr(sram_wr_ecc_addr[31]),
    .wr_ecc_code(sram_wr_ecc_code[31]),
    .rd_ecc_addr(sram_rd_ecc_addr[31]),
    .rd_ecc_code(sram_rd_ecc_code[31]),
    .wr_op(sram_wr_op[31]),
    .wr_port(sram_wr_port[31]),
    .rd_op(sram_rd_op[31]),
    .rd_port(sram_rd_port[31]),
    .rd_addr(sram_rd_addr[31]),
    .port_amount(sram_page_amount[511:496]),
    .state(sram_state[31]),
    .null_ptr(sram_null_ptr[31]),
    .free_space(sram_free_space[31])
);

endmodule