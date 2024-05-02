`timescale 1ns/1ns

module tb_sram_state();

reg clk;
reg rst_n;
 
    //ECC Storage
reg ecc_wr_en;
reg [10:0] ecc_wr_addr;
reg [7:0] ecc_din;

reg ecc_rd_en;
reg [10:0] ecc_rd_addr;
wire [7:0] ecc_dout;

    //SRAM Operations
reg wr_op;
reg [3:0] wr_port;
reg rd_op;
reg [3:0] rd_port;
reg [10:0] rd_addr;

wire [15:0][10:0] port_amount;

    //Lock
reg lock_en;
reg lock_dis;
wire locking;

    //Null Pages
wire [10:0] null_ptr;
wire [10:0] free_space;

initial begin
    clk <= 1'b1;
    rst_n <= 1'b0;
    #40
    rst_n <= 1'b1;
    #16
    ecc_rd_en <= 1'b1;
    #400
    rd_op <= 1'b1;
end

always #2 clk =   ~clk;

always@(posedge clk or negedge rst_n)
    if(rst_n == 0) begin
        ecc_wr_en <= 0;
        ecc_wr_addr <= 0;
        ecc_din <= 0;
    end
    else if (ecc_wr_en == 0)begin
        ecc_wr_en <= 1;
    end
    else if (ecc_wr_en == 1)begin
        ecc_din <= ecc_din + 1;
        ecc_wr_addr <= ecc_wr_addr + 1;
    end

always@(posedge clk or negedge rst_n)
    if(rst_n == 0) begin
        ecc_rd_en <= 0;
        ecc_rd_addr <= 0;
    end
    else if(ecc_rd_en == 1'b1)begin
        ecc_rd_addr <= ecc_rd_addr + 1;
    end

always@(posedge clk or negedge rst_n)
    if(rst_n == 0) begin
        lock_dis <= 0;
        lock_en <= 0;
    end else begin
        lock_dis <= $random % 2;
        lock_en <= $random % 2;
    end

always@(posedge clk or negedge rst_n)
    if(rst_n == 0) begin
        wr_op <= 0;
        wr_port <= 0;
    end else if(wr_op == 0) begin
        wr_op <= 1;
    end else if(wr_op == 1) begin    
        wr_port <= wr_port + 1;
    end

always@(posedge clk or negedge rst_n)
    if(rst_n == 0) begin
        rd_op <= 0;
        rd_port <= 0;
        rd_addr <= 0;
    end else if(rd_op == 1)begin
        rd_port <= rd_port + 1;
        rd_addr <= rd_addr + 1;
    end

sram_state  sram_state_inst
(
    .clk        (clk        )   ,
    .rst_n      (rst_n      )   ,

    .ecc_wr_en  (ecc_wr_en  )   ,
    .ecc_wr_addr(ecc_wr_addr)   ,
    .ecc_din    (ecc_din    )   ,
    .ecc_rd_en  (ecc_rd_en  )   ,
    .ecc_rd_addr(ecc_rd_addr)   ,
    .ecc_dout   (ecc_dout   )   ,

    .wr_op      (wr_op      )   ,
    .wr_port    (wr_port    )   ,
    .rd_addr    (rd_addr    )   ,
    .rd_op      (rd_op      )   ,
    .rd_port    (rd_port    )   ,

    .port_amount(port_amount)   ,

    .lock_dis   (lock_dis   )   ,
    .lock_en    (lock_en    )   ,
    .locking    (locking    )   ,

    .null_ptr   (null_ptr   )   ,
    .free_space (free_space )

);

endmodule