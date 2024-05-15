`timescale 1ns/1ns
// `include "./初赛作品/代码/已优化/controller.sv"
`include "controller.sv"
module tb_controller();

reg clk;
reg rst_n;

reg    [15:0]    wr_sop  ;
reg    [15:0]    wr_eop  ;
reg    [15:0]    wr_vld  ;
reg    [15:0][15:0]   wr_data ;

reg    [15:0]    ready   ;

initial
    begin
        clk     =   1'b1;
        rst_n   <=  1'b0;
        wr_sop      <=  0;
        wr_eop      <=  0;
        wr_vld      <=  0;
        wr_data     <=  0;
      #40
        rst_n   <=  1'b1;
      #40
        wr_sop  <= 16'hFFFF;
      #400
        ready <= 16'h1;
    end

always #2 clk =   ~clk;

parameter   IDLE    =   2'b00   ,
            RD_CTRL =   2'b01   ,
            RD_BTW  =   2'b10   ,
            RD_DATA =   2'b11   ;
            
reg     [15:0][1:0]   state   ;
reg     [15:0][11:0]   cnt     ;

integer k;

always@(posedge clk or  negedge rst_n)
    if(rst_n == 4'b0)
        state <= IDLE;
    else
        for(k=0;k<16;k=k+1)
            case(state[k])
                IDLE:
                    if(wr_sop[k] == 1)
                        state[k] <= RD_CTRL;
                    else
                        state[k] <= IDLE;
                RD_CTRL:
                    state[k] <= RD_DATA;
                RD_DATA:
                    if(wr_eop[k] == 1)
                        state[k] = IDLE;
                    else
                        state[k] <= RD_DATA;
                default:
                    state[k] <= IDLE;
            endcase

reg    [15:0][8:0]  data_up = 0;

integer i,j;

always@(posedge clk or  negedge rst_n) begin
    for(j=0;j<16;j=j+1)
        if(wr_sop[j] == 1) begin
            data_up[j] = 32;
            if(data_up[j] < 32) begin
                data_up[j] = 32;
            end
        end
end

always@(posedge clk or  negedge rst_n)
    for(i=0;i<16;i=i+1)
    if(rst_n == 4'b0)
        wr_data <= 0;
    else if(state[i] == RD_CTRL) begin
        //wr_data <= $random % 65536;
        wr_data[i][15:7] <= data_up[i];
        wr_data[i][6:4] <= 1;
        wr_data[i][3:0] <= 1;
    end
    else if(state[i] == RD_DATA)
            wr_data[i] <= cnt[i];
            
always@(posedge clk or  negedge rst_n)
    for(i=0;i<16;i=i+1)
    if(rst_n == 0 || state[i] == IDLE)
    begin
        wr_vld[i] = 0;
        cnt[i] <= 0;
    end
    else if(state[i] == RD_CTRL)
    begin
        wr_vld[i] <= 1;
        cnt[i] <= cnt[i] + 1'b1;
    end
    else if(state[i] == RD_DATA && cnt[i] < data_up[i])
    begin
        wr_vld[i] <= 1;
        cnt[i] <= cnt[i] + 1'b1;
    end
    else if(cnt[i] == data_up[i] && state[i] == RD_DATA)
    begin
        cnt[i] <= 0;
        wr_vld[i] <= 0;
        wr_eop[i] <= 1;
    end

reg     [15:0]   eop_t;
reg     [15:0]   eop_ti;
   
always@(posedge clk or  negedge rst_n)
    if(rst_n == 0)
    begin
        wr_eop <= 0;
        eop_t <= 0;
        eop_ti <= 0;
    end
    else begin
        for(i=0;i<16;i=i+1) begin
            if(wr_eop[i] == 1)
                begin
                    wr_eop[i] <= 0;
                    eop_t[i] <= 1;
                end
            else if(eop_t[i] == 1)
                begin
                    eop_t[i] <= 0;
                    eop_ti[i] <= 1;
                end
            else if(eop_ti[i] == 1)
                begin
                    eop_ti[i] <= 0;
                    wr_sop[i] <= 1;
                end
        end
   
    end
    
always@(posedge clk or  negedge rst_n)
    for(i=0;i<16;i=i+1)
        if(wr_sop[i] == 1)
        begin
            wr_sop[i] <= 0;
        end

wire   [15:0]  rd_sop  ;
wire   [15:0]  rd_eop  ;
wire   [15:0]  rd_vld  ;
wire   [3:0][15:0]  rd_data   ;

controller  controller_inst
(
    .clk            (clk            )   ,
    .rst_n          (rst_n          )   ,

    .wr_sop         (wr_sop         )   ,
    .wr_eop         (wr_eop         )   ,
    .wr_vld         (wr_vld         )   ,
    .wr_data        (wr_data        )   ,

    .ready          (ready          )   ,
    .rd_sop         (rd_sop         )   ,
    .rd_eop         (rd_eop         )   ,
    .rd_vld         (rd_vld         )   ,
    .rd_data        (rd_data        )   
    
);

endmodule
