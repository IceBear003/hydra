`include "sram.sv"
`include "sram_ecc_encoder.sv"

module sram_interface
#(parameter SRAM_IDX = 0)
(
    input clk,
    input rst_n,

    input xfer_data_vld,
    input [15:0] xfer_data,
    input end_of_packet,

    //包的首尾页地址，16*32选1
    output reg [15:0] packet_head_addr,
    output reg [15:0] packet_tail_addr
);

// 0 - idle
// 1 - packet writting the first page
// 2 - packet writting the left pages
reg [1:0] state;
reg [2:0] wr_batch;

always @(posedge clk) begin
    if(!rst_n) begin
        state <= 2'd0;
    end else if(state == 2'd0 && xfer_data_vld) begin
        state <= 2'd1;
    end else if(state == 2'd1 && wr_batch == 3'd7 && xfer_data_vld) begin
        state <= 2'd2;
    end else if(state == 2'd2 && end_of_packet) begin
        state <= 2'd0;
    end
end

always @(posedge clk) begin
    if(!rst_n || end_of_packet) begin
        wr_batch <= 0;
    end else if(xfer_data_vld) begin
        wr_batch <= wr_batch + 1;
    end
end

//空闲链表
(* ram_style = "block" *) reg [10:0] null_pages [2047:0];
reg np_init;
reg [10:0] np_head;
reg [10:0] np_tail;
reg [10:0] np_top;

always @(posedge clk) begin
    if(!rst_n) begin
        np_tail <= 0;
    end /*else if(rd_batch == 7) begin
        null_pages[np_tail] <= rd_addr;
        np_tail <= np_tail + 1;
    end */
end

always @(posedge clk) begin
    if(!rst_n) begin
        np_head <= 0;
        np_top <= 2047;
        np_init <= 1;
    end if(wr_batch != 7) begin
    end else if(np_init == 1 & np_top != 0) begin
        np_top <= np_top - 1;
    end else begin
        np_init <= 0;
        np_top <= null_pages[np_head + 1];
        np_head <= np_head + 1;
    end
end

//ECC存储
(* ram_style = "block" *) reg [7:0] ecc_storage [2047:0];
reg [10:0] es_wr_addr;
reg [7:0] es_din;

always @(posedge clk) begin
    if(wr_batch == 7 || end_of_packet) begin
        es_wr_addr <= np_top;
        es_din <= ecc_result;
    end
end

always @(posedge clk) begin
    ecc_storage[es_wr_addr] <= es_din;
end

//跳转表
(* ram_style = "block" *) reg [15:0] jump_table [2047:0];
reg [10:0] jt_wr_addr;

always @(posedge clk) begin
    if(wr_batch == 7) begin
        jt_wr_addr <= np_top;
    end
end

always @(posedge clk) begin
    if(state == 2'd1) begin
        packet_head_addr <= np_top;
    end else if(state != 2'd2) begin
    end else if(end_of_packet == 0) begin
        jump_table[jt_wr_addr] <= np_top;
    end else begin
        packet_tail_addr <= np_top;
    end
end

sram sram(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(xfer_data_vld),
    .wr_addr({np_top, wr_batch}),
    .din(xfer_data)/*,
    .rd_en(),
    .rd_addr(),
    .dout()*/
);

reg [15:0] encoder_buffer [7:0];
wire [7:0] ecc_result;

sram_ecc_encoder sram_ecc_encoder( 
    .data_0(encoder_buffer[0]),
    .data_1(encoder_buffer[1]),
    .data_2(encoder_buffer[2]),
    .data_3(encoder_buffer[3]),
    .data_4(encoder_buffer[4]),
    .data_5(encoder_buffer[5]),
    .data_6(encoder_buffer[6]),
    .data_7(encoder_buffer[7]),
    .code(ecc_result)
);

endmodule