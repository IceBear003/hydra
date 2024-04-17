`timescale  1ns/1ns

module  tb_top_sram ();

reg         sys_clk     ;
reg         sys_rst_n   ;

reg    [3:0]    wr_sop  ;
reg    [3:0]    wr_eop  ;
reg    [3:0]    wr_vld  ;
reg    [3:0][15:0]   wr_data ;
reg    [15:0]   ready   ;

initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  4'b0;
        wr_sop      <=  4'b0;
        wr_eop      <=  4'b0;
        wr_vld      <=  4'b0;
        wr_data     <=  4'b0;
        ready       <=  4'b0;
      #40
        sys_rst_n   <=  1'b1;
      #40
        wr_sop  <= 4'b1111;
      #160
        ready[0] <= 1'b1;
        ready[1] <= 1'b1;
        ready[2] <= 1'b1;
        ready[3] <= 1'b1;
      #4
        ready[0] <= 4'b0;
        ready[1] <= 4'b0;
        ready[2] <= 4'b0;
        ready[3] <= 4'b0;
      #360
        ready[0] <= 1'b1;
        ready[1] <= 1'b1;
        ready[2] <= 1'b1;
        ready[3] <= 1'b1;
      #4
        ready[0] <= 4'b0;
        ready[1] <= 4'b0;
        ready[2] <= 4'b0;
        ready[3] <= 4'b0;
      #560
        ready[0] <= 1'b1;
      #4
        ready[0] <= 4'b0;
    end

always #2 sys_clk =   ~sys_clk;

parameter   IDLE    =   2'b00   ,
            RD_CTRL =   2'b01   ,
            RD_BTW  =   2'b10   ,
            RD_DATA =   2'b11   ;
            
reg     [1:0]   state   ;
reg     [11:0]   cnt     ;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 4'b0)
        state <= IDLE;
    else
        case(state)
            IDLE:
                if(wr_sop == 4'b1111)
                    state <= RD_CTRL;
                else
                    state <= IDLE;
            RD_CTRL:
                state <= RD_DATA;
            RD_DATA:
                if(wr_eop == 4'b1111)
                    state = IDLE;
                else
                    state <= RD_DATA;
            default:
                state <= IDLE;
        endcase

wire    [8:0]  data_up ;

assign  data_up =   (state == RD_CTRL) ? (512+16) / 16 : data_up;

integer i;

always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 4'b0)
        wr_data <= 4'b0;
    else if(state == RD_CTRL) begin
        //wr_data <= $random % 65536;
        for(i=0;i<4;i=i+1) begin
            wr_data[i][15:7] <= data_up;
            wr_data[i][6:4] <= $random % 8;
            wr_data[i][3:0] <= 3-i;
        end
    end
    else if(state == RD_DATA)
        for(i=0;i<4;i=i+1)
            wr_data[i] <= cnt;
            
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 4'b0 || state == IDLE)
    begin
        wr_vld = 4'b0;
        cnt <= 4'b0;
    end
    else if(state == RD_CTRL)
    begin
        wr_vld <= 4'b1111;
        cnt <= cnt + 1'b1;
    end
    else if(state == RD_DATA && cnt < data_up)
    begin
        wr_vld <= 4'b1111;
        cnt <= cnt + 1'b1;
    end
    else if(cnt == data_up && state == RD_DATA)
    begin
        cnt <= 4'b0;
        wr_eop <= 4'b1111;
        wr_vld = 4'b0;
    end

reg     [3:0]   eop_t;
reg     [3:0]   eop_ti;
   
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 4'b0)
    begin
        wr_eop <= 4'b0;
        eop_t <= 4'b0;
        eop_ti <= 4'b0;
    end
    else if(wr_eop == 4'b1111)
    begin
        wr_eop <= 4'b0;
        eop_t <= 4'b1111;
    end
    else if(eop_t == 4'b1111)
    begin
        eop_t <= 4'b0;
        eop_ti <= 4'b1111;
    end
    else if(eop_ti == 4'b1111)
    begin
        eop_ti <= 4'b0;
        wr_sop <= 4'b1111;
    end
    
always@(posedge sys_clk or  negedge sys_rst_n)
    if(wr_sop == 4'b1111)
    begin
        wr_sop <= 4'b0;
        
    end

wire   [15:0]  rd_sop  ;
wire   [15:0]  rd_eop  ;
wire   [15:0]  rd_vld  ;
wire   [3:0][15:0]  rd_data   ;
wire   [15:0]  page_fr  ;
wire   [15:0]  data_fr  ;
wire    wr_s    ;
wire    wr_b    ;
wire    [4:0]   sram_now    ;
logic   [15:0]  addr_vld    ;

top_sram    top_sram_inst
(
    .sys_clk        (sys_clk        )   ,
    .sys_rst_n      (sys_rst_n      )   ,
    .wr_sop         (wr_sop         )   ,
    .wr_eop         (wr_eop         )   ,
    .wr_vld         (wr_vld         )   ,
    .wr_data        (wr_data        )   ,
    .ready          (ready          )   ,

    .rd_sop         (rd_sop         )   ,
    .rd_eop         (rd_eop         )   ,
    .rd_vld         (rd_vld         )   ,
    .rd_data        (rd_data        )   ,
    .page_fr        (page_fr        )   ,
    .data_fr        (data_fr        )   ,
    .wr_s           (wr_s           )   ,
    .wr_b           (wr_b           )   ,
    .sram_now       (sram_now       )   ,
    .addr_vld       (addr_vld       )

);

endmodule