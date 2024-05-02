`timescale 1ns/1ns

module tb_controller();

reg clk;
reg rst_n;

reg    [15:0]    wr_sop  ;
reg    [15:0]    wr_eop  ;
reg    [15:0]    wr_vld  ;
reg    [15:0][15:0]   wr_data ;

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
    end

always #2 clk =   ~clk;

parameter   IDLE    =   2'b00   ,
            RD_CTRL =   2'b01   ,
            RD_BTW  =   2'b10   ,
            RD_DATA =   2'b11   ;
            
reg     [1:0]   state   ;
reg     [11:0]   cnt     ;

always@(posedge clk or  negedge rst_n)
    if(rst_n == 4'b0)
        state <= IDLE;
    else
        case(state)
            IDLE:
                if(wr_sop[0] == 1)
                    state <= RD_CTRL;
                else
                    state <= IDLE;
            RD_CTRL:
                state <= RD_DATA;
            RD_DATA:
                if(wr_eop[0] == 1)
                    state = IDLE;
                else
                    state <= RD_DATA;
            default:
                state <= IDLE;
        endcase

wire    [8:0]  data_up ;

assign  data_up =   (state == RD_CTRL) ? (512+16) / 16 : data_up;

integer i;

always@(posedge clk or  negedge rst_n)
    if(rst_n == 4'b0)
        wr_data <= 0;
    else if(state == RD_CTRL) begin
        //wr_data <= $random % 65536;
        for(i=0;i<16;i=i+1) begin
            wr_data[i][15:7] <= data_up;
            wr_data[i][6:4] <= $random % 8;
            wr_data[i][3:0] <= 1;
        end
    end
    else if(state == RD_DATA)
        for(i=0;i<16;i=i+1)
            wr_data[i] <= cnt;
            
always@(posedge clk or  negedge rst_n)
    if(rst_n == 0 || state == IDLE)
    begin
        wr_vld = 0;
        cnt <= 0;
    end
    else if(state == RD_CTRL)
    begin
        for(i=0;i<16;i=i+1)
            wr_vld[i] <= 1;
        cnt <= cnt + 1'b1;
    end
    else if(state == RD_DATA && cnt < data_up)
    begin
        for(i=0;i<16;i=i+1)
            wr_vld[i] <= 1;
        cnt <= cnt + 1'b1;
    end
    else if(cnt == data_up && state == RD_DATA)
    begin
        cnt <= 0;
        for(i=0;i<16;i=i+1) begin
            wr_vld[i] <= 0;
            wr_eop[i] <= 1;
        end
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

controller  controller_inst
(
    .clk            (clk            )   ,
    .rst_n          (rst_n          )   ,

    .wr_sop         (wr_sop         )   ,
    .wr_eop         (wr_eop         )   ,
    .wr_vld         (wr_vld         )   ,
    .wr_data        (wr_data        )   
    

);

endmodule
