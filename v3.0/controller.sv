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

reg [4:0] cnt = 0;

integer i;

reg [4:0] distribution [15:0];
reg [3:0] bind_dest_port [15:0];

always @(posedge clk) begin
    for(i = 0; i < 16; i = i + 1) begin
        if(port_new_packet[i] && port_writting[i]) begin
            //                 dest_port      length
            //判断已经被绑定的ditribution的sram是否空间充足
                //若充足，则不做搜索操作
                //若不充足，则查看预分配（dest port）是否可用
                    //若可用则直接用                      force_mode
                    //若不可用就等待，将xfer_stop拉高，进入强制搜索模式
        end
        
        //如果正在进入数据(加数据有效信号)
            //已经分配好SRAM，
            //直接取nullptr
            //开始调用sram写
            //累计8个
            //触发ECC，写ECC
        //无论何时，则开始分配流程，
            //如果不是强制搜索模式
                //即当端口自己作为dest port，择优
                //看SRAM是否正在被写、是否被别的端口预分配占用、是否有己方的大量数据
                //如果sram数据量过少并且可用的SRAM数量过少，则不预分配，拉高almost_full
            //如果是强制搜索模式
                //看SRAM是否正在被写、是否有己方的数据
                //如果得不到结果，拉高full、把xfer_ptr往后移直到write_ptr
                //如果可用的SRAM，就正常写
    end
    cnt <= cnt + 1;
end

wire [15:0] [2:0] port_prior;
wire [15:0] [3:0] port_dest_port;
wire [15:0] [15:0] port_data;
wire [15:0] [8:0] port_length;
wire [15:0] port_writting;
wire [15:0] port_new_packet;
wire [15:0] port_unlock;

port port [15:0]
(
    .clk(clk),

    .wr_sop(wr_sop),
    .wr_eop(wr_eop),
    .wr_vld(wr_vld),
    .wr_data(wr_data),

    .prior(port_prior),
    .dest_port(port_dest_port),
    .data(port_data),
    .length(port_length),
    .writting(port_writting),
    .new_packet(port_new_packet)
    // .unlock(port_unlock)
);

reg [15:0][127:0] ecc_encoder_data;
wire [15:0][7:0] ecc_encoder_code;

ecc_encoder ecc_encoder [15:0]
(
    .data(ecc_encoder_data),
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

reg [31:0] sram_wr_en;
reg [31:0][13:0] sram_wr_addr;
reg [31:0][15:0] sram_din;

reg [31:0] sram_rd_en;
reg [31:0][13:0] sram_rd_addr;
wire [31:0][15:0] sram_dout;

sram sram [31:0]
(
    .clk(clk),
    .rst_n(rst_n),
    
    .wr_en(sram_wr_en),
    .wr_addr(sram_wr_addr),
    .din(sram_din),
    
    .rd_en(sram_rd_en),
    .rd_addr(sram_rd_addr),
    .dout(sram_dout)
);

reg [31:0] ecc_wr_en;
reg [31:0][10:0] ecc_wr_addr;
reg [31:0][7:0] ecc_din;

reg [31:0]ecc_rd_en;
reg [31:0][10:0] ecc_rd_addr;
wire [31:0][7:0] ecc_dout;

reg [31:0]wr_op;
reg [31:0][3:0] wr_port;
reg [31:0]rd_op;
reg [31:0][3:0] rd_port;
reg [31:0][10:0] rd_addr;

wire [31:0][15:0][10:0] port_amount;

reg [31:0]lock_en;
reg [31:0]lock_dis;
wire [31:0]locking;

wire [31:0][10:0] null_ptr;
wire [31:0][10:0] free_space;

sram_state sram_state [31:0] 
(
    .clk(clk),
    .rst_n(rst_n),

    .ecc_wr_en(ecc_wr_en),
    .ecc_wr_addr(ecc_wr_addr),
    .ecc_din(ecc_din),
    .ecc_rd_en(ecc_rd_en),
    .ecc_rd_addr(ecc_rd_addr),
    .ecc_dout(ecc_dout),

    .wr_op(wr_op),
    .wr_port(wr_port),
    .rd_addr(rd_addr),
    .rd_op(rd_op),
    .rd_port(rd_port),

    .port_amount(port_amount),

    .lock_dis(lock_dis),
    .lock_en(lock_en),
    .locking(locking),

    .null_ptr(null_ptr),
    .free_space(free_space)
);

endmodule
