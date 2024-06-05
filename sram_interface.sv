`include "sram.sv"
`include "sram_ecc_encoder.sv"
`include "sram_ecc_decoder.sv"

module sram_interface
#(parameter SRAM_IDX = 0)
(
    input clk,
    input rst_n,

    input wr_xfer_data_vld,
    input [15:0] wr_xfer_data,
    input wr_end_of_packet,
    output reg [15:0] wr_packet_head_addr,
    output reg [15:0] wr_packet_tail_addr,

    input rd_next,
    input [3:0] rd_port,
    input [15:0] rd_packet_head_addr,
    output [3:0] rd_xfer_port,
    output rd_xfer_data_vld,
    output [15:0] rd_xfer_data,
    output rd_end_of_packet,
    output reg [15:0] rd_next_packet_head_addr,

    input [3:0] check_port,
    output [8:0] check_amount,
    output reg [10:0] free_space
);

// 0 - idle
// 1 - writting the first page
// 2 - writting the left pages
reg [1:0] wr_state;
reg [2:0] wr_batch;

always @(posedge clk) begin
    if(!rst_n) begin
        wr_state <= 2'd0;
    end else if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        wr_state <= 2'd1;
    end else if(wr_state == 2'd1 && wr_batch == 3'd7 && wr_xfer_data_vld) begin
        wr_state <= 2'd2;
    end else if(wr_state == 2'd2 && wr_end_of_packet) begin
        wr_state <= 2'd0;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        wr_batch <= 0;
    end else if(wr_xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
    end else if(wr_end_of_packet) begin
        wr_batch <= 0;
    end
end

//READ

reg [2:0] rd_batch;
reg [2:0] rd_batch_1;
reg [2:0] rd_batch_2;

reg [10:0] rd_page [15:0];

always @(posedge clk) begin
    if(~rst_n || rd_next) begin
        rd_batch <= 0;
    end else begin
        rd_batch <= rd_batch + 1;
    end
end

always @(posedge clk) begin
    rd_batch_1 <= rd_batch;
    rd_batch_2 <= rd_batch_1;
end

//需要记录长度！！！

wire [15:0] sram_dout;

sram sram(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_xfer_data_vld),
    .wr_addr({np_top, wr_batch}),
    .din(wr_xfer_data),
    .rd_en(1'd1),
    .rd_addr({rd_page[rd_port], rd_batch}),
    .dout(sram_dout)
);

/*
 * Sub-module "null_pages": Recycling and reallocating data pages.
 */

(* ram_style = "block" *) reg [10:0] null_pages [2047:0];
reg np_init;
reg [10:0] np_head;
reg [10:0] np_tail;
reg [10:0] np_top;

always @(posedge clk) begin
    if(!rst_n) begin
        np_tail <= 0;
    end else if(rd_batch[port] == 7) begin //多次为7
        null_pages[np_tail] <= rd_page[port];
        np_tail <= np_tail + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        np_head <= 0;
        np_top <= 2047;
        np_init <= 1;
    end else if(wr_batch != 7 && ~wr_end_of_packet) begin
    end else if(np_init == 1 & np_top != 0) begin
        np_top <= np_top - 1;
    end else begin
        np_top <= null_pages[np_head];
        np_head <= np_head + 1;
        np_init <= 0;
    end
end

/*
 * Sub-module "ECC_manager": encode data written into SRAM;
 *                           decode data read from SRAM.
 */

(* ram_style = "block" *) reg [7:0] ecc_codes [2047:0];

 always @(posedge clk) begin
     ecc_codes[ec_wr_addr] <= ec_din;
 end
 
 always @(posedge clk) begin
     ec_dout <= ecc_codes[ec_rd_addr];
 end

reg [10:0] ec_wr_addr;
reg [7:0] ec_din;
reg [15:0] ecc_wr_buffer [7:0];
wire [7:0] ecc_wr_result;

always @(posedge clk) begin
    if(~wr_xfer_data_vld) begin
    end else if(wr_batch == 3'd0) begin
        ecc_wr_buffer[0] <= wr_xfer_data;
        ecc_wr_buffer[1] <= 0;
        ecc_wr_buffer[2] <= 0;
        ecc_wr_buffer[3] <= 0;
        ecc_wr_buffer[4] <= 0;
        ecc_wr_buffer[5] <= 0;
        ecc_wr_buffer[6] <= 0;
        ecc_wr_buffer[7] <= 0;
    end else begin
        ecc_wr_buffer[wr_batch] <= wr_xfer_data;
    end
end

always @(posedge clk) begin
    if(wr_batch == 7 || wr_end_of_packet) begin
        ec_wr_addr <= np_top;
        ec_din <= ecc_wr_result;
    end
end

sram_ecc_encoder sram_ecc_encoder( 
    .data_0(ecc_wr_buffer[0]),
    .data_1(ecc_wr_buffer[1]),
    .data_2(ecc_wr_buffer[2]),
    .data_3(ecc_wr_buffer[3]),
    .data_4(ecc_wr_buffer[4]),
    .data_5(ecc_wr_buffer[5]),
    .data_6(ecc_wr_buffer[6]),
    .data_7(ecc_wr_buffer[7]),
    .code(ecc_wr_result)
);

reg [10:0] ec_rd_addr;
reg [7:0] ec_dout;
reg [15:0] ecc_rd_buffer [7:0];
wire [15:0] ecc_rd_data [7:0];

always @(posedge clk) begin
    if(rd_batch_1 == 0) begin
        ecc_rd_buffer[0] <= sram_dout;
        ecc_rd_buffer[1] <= 16'h0000;
        ecc_rd_buffer[2] <= 16'h0000;
        ecc_rd_buffer[3] <= 16'h0000;
        ecc_rd_buffer[4] <= 16'h0000;
        ecc_rd_buffer[5] <= 16'h0000;
        ecc_rd_buffer[6] <= 16'h0000;
        ecc_rd_buffer[7] <= 16'h0000;
    end else begin
        ecc_rd_buffer[rd_batch_1] <= sram_dout;
    end
end

always @(posedge clk) begin
    if(rd_batch == 0) begin
        ec_rd_addr <= rd_page[rd_port];
    end
end

sram_ecc_decoder sram_ecc_decoder(
    .update(rd_batch_1 == 2'd0),
    .data_0(ecc_rd_buffer[0]),
    .data_1(ecc_rd_buffer[1]),
    .data_2(ecc_rd_buffer[2]),
    .data_3(ecc_rd_buffer[3]),
    .data_4(ecc_rd_buffer[4]),
    .data_5(ecc_rd_buffer[5]),
    .data_6(ecc_rd_buffer[7]),
    .data_7(ecc_rd_buffer[6]),
    .code(ec_dout),
    .cr_data_0(ecc_rd_data[0]),
    .cr_data_1(ecc_rd_data[1]),
    .cr_data_2(ecc_rd_data[2]),
    .cr_data_3(ecc_rd_data[3]),
    .cr_data_4(ecc_rd_data[4]),
    .cr_data_5(ecc_rd_data[5]),
    .cr_data_6(ecc_rd_data[6]),
    .cr_data_7(ecc_rd_data[7])
);

/*
 * Sub-module "jump_table": record the next page's address of every page.
 */

(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
reg [10:0] jt_wr_addr;
reg [10:0] jt_rd_addr;
reg [15:0] jt_dout;

always @(posedge clk) begin
    if(wr_batch == 7) begin
        jt_wr_addr <= np_top;
    end
end

always @(posedge clk) begin
    if(wr_state == 2'd1 && wr_batch == 3'd7) begin
        wr_packet_head_addr <= {SRAM_IDX, np_top};
    end
end

always @(posedge clk) begin
    if(wr_state == 2'd2 && (wr_batch == 3'd7 || wr_end_of_packet)) begin
        jump_table[jt_wr_addr] <= {SRAM_IDX, np_top};
    end
end

always @(posedge clk) begin
    if(wr_state == 2'd2 && wr_end_of_packet) begin
        wr_packet_tail_addr <= {SRAM_IDX, np_top};
    end
end

always @(posedge clk) begin
    jt_dout <= jump_table[jt_rd_addr];
end

always @(posedge clk) begin
    if(rd_batch == 3'd7) begin
        rd_page[rd_port] <= jt_dout;
    end
end

/*
 * Statistics for every port.
 */

reg [8:0] packet_amount [15:0];
assign check_amount = packet_amount[check_port];

integer port;
always @(posedge clk) begin
    if(!rst_n) begin
        free_space <= 11'd2047;
        for(port = 0; port < 16; port = port + 1) begin
            packet_amount[port] <= 0;
        end
    end else if(wr_state == 2'd0 && wr_xfer_data_vld) begin
        free_space <= free_space - wr_xfer_data[15:7];
        packet_amount[wr_xfer_data[3:0]] <= packet_amount[wr_xfer_data[3:0]] + 1;
    end
end

endmodule