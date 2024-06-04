`include "sram.sv"
`include "sram_ecc_encoder.sv"

module sram_interface
#(parameter SRAM_IDX = 0)
(
    input clk,
    input rst_n,

    //需要32组MUX16-1
    input wr_wr_xfer_data_vld,
    input [15:0] wr_xfer_data,
    input wr_end_of_packet,

    //包的首尾页地址，无需多选器
    output reg [15:0] wr_packet_head_addr,
    output reg [15:0] wr_packet_tail_addr,

    input [3:0] check_port,
    output [8:0] check_amount,
    output reg [10:0] free_space
);

// 0 - idle
// 1 - packet writting the first page
// 2 - packet writting the left pages
reg [1:0] state;
reg [2:0] wr_batch;

reg [8:0] packet_amount [15:0];
assign check_amount = packet_amount[check_port];

integer port;
always @(posedge clk) begin
    if(!rst_n) begin
        free_space <= 11'd2047;
        for(port = 0; port < 16; port = port + 1) begin
            packet_amount[port] <= 0;
        end
    end else if(state == 2'd0 && wr_wr_xfer_data_vld) begin
        free_space <= free_space - wr_xfer_data[15:7];
        packet_amount[wr_xfer_data[3:0]] <= packet_amount[wr_xfer_data[3:0]] + 1;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        state <= 2'd0;
    end else if(state == 2'd0 && wr_wr_xfer_data_vld) begin
        state <= 2'd1;
    end else if(state == 2'd1 && wr_batch == 3'd7 && wr_wr_xfer_data_vld) begin
        state <= 2'd2;
    end else if(state == 2'd2 && wr_end_of_packet) begin
        state <= 2'd0;
    end
end

always @(posedge clk) begin
    if(!rst_n || wr_end_of_packet) begin
        wr_batch <= 0;
    end else if(wr_wr_xfer_data_vld) begin
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

//ECC
(* ram_style = "block" *) reg [7:0] ecc_storage [2047:0];
reg [10:0] es_wr_addr;
reg [7:0] es_din;

reg [15:0] ecc_buffer [7:0];
wire [7:0] ecc_result;

always @(posedge clk) begin
    if(wr_wr_xfer_data_vld == 0) begin
    end else if(wr_batch == 3'd0) begin
        ecc_buffer[0] <= wr_xfer_data;
        ecc_buffer[1] <= 0;
        ecc_buffer[2] <= 0;
        ecc_buffer[3] <= 0;
        ecc_buffer[4] <= 0;
        ecc_buffer[5] <= 0;
        ecc_buffer[6] <= 0;
        ecc_buffer[7] <= 0;
    end else begin
        ecc_buffer[wr_batch] <= wr_xfer_data;
    end
end

always @(posedge clk) begin
    if(wr_batch == 7 || wr_end_of_packet) begin
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
        wr_packet_head_addr <= np_top;
    end else if(state != 2'd2) begin
    end else if(wr_end_of_packet == 0) begin
        jump_table[jt_wr_addr] <= np_top;
    end else begin
        wr_packet_tail_addr <= np_top;
    end
end

sram sram(
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_wr_xfer_data_vld),
    .wr_addr({np_top, wr_batch}),
    .din(wr_xfer_data)/*,
    .rd_en(),
    .rd_addr(),
    .dout()*/
);

sram_ecc_encoder sram_ecc_encoder( 
    .data_0(ecc_buffer[0]),
    .data_1(ecc_buffer[1]),
    .data_2(ecc_buffer[2]),
    .data_3(ecc_buffer[3]),
    .data_4(ecc_buffer[4]),
    .data_5(ecc_buffer[5]),
    .data_6(ecc_buffer[6]),
    .data_7(ecc_buffer[7]),
    .code(ecc_result)
);

endmodule