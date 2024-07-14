`timescale 1ns/1ns

module tb_hydra();

reg clk;
reg rst_n;

reg [15:0] wr_sop  ;
reg [15:0] wr_eop  ;
reg [15:0] wr_vld  ;
reg [15:0][15:0] wr_data ;
reg match_suc;

integer file;

//reg    [15:0]   ready   ;

initial
    begin
        //file = $fopen("in.txt","r+");
        clk     =   1'b1;
        rst_n   <=  1'b0;
        wr_sop      <=  1'b0;
        wr_eop      <=  1'b0;
        wr_vld      <=  1'b0;
        wr_data     <=  1'b0;
      #40
        rst_n   <=  1'b1;
      #40
        wr_sop  <= 1;
      #300
        $fclose(file);
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
                if(wr_sop == 1)
                    state <= RD_CTRL;
                else
                    state <= IDLE;
            RD_CTRL:
                state <= RD_DATA;
            RD_DATA:
                if(wr_eop == 1)
                    state = IDLE;
                else
                    state <= RD_DATA;
            default:
                state <= IDLE;
        endcase

reg    [8:0]  data_up ;

//assign  data_up =   (state == RD_CTRL) ? (512+16) / 16 : data_up;
/*
always@(posedge clk or  negedge rst_n) begin
    if(rst_n) begin
        $fdisplay("%b %b %b %b",wr_sop,wr_eop,wr_vld,wr_data);
    end
end
*/
always@(posedge clk or  negedge rst_n)
    if(state == RD_CTRL) begin
        /*data_up = ($random);
        if(data_up > 100)
            data_up = data_up % 100;
        if(data_up < 32)
            data_up = 32;*/
        data_up = 32;
        
    end

always@(posedge clk or  negedge rst_n)
    if(rst_n == 4'b0)
        wr_data <= 4'b0;
    else if(state == RD_CTRL) begin
        //wr_data <= $random % 65536;
        wr_data[0][15:7] <= data_up;
        wr_data[0][6:4] <= $random % 8;
        wr_data[0][3:0] <= $random;
    end
    else if(state == RD_DATA)
        wr_data <= cnt;
            
always@(posedge clk or  negedge rst_n)
    if(rst_n == 0 || state == IDLE)
    begin
        wr_vld = 0;
        cnt <= 0;
    end
    else if(state == RD_CTRL)
    begin
        wr_vld <= 1;
        cnt <= cnt + 1'b1;
    end
    else if(state == RD_DATA && cnt < data_up + 1)
    begin
        //if(cnt >= 32 && cnt <= 74)
        //    wr_vld <= 0;
        //else
            wr_vld <= 1;
        cnt <= cnt + 1'b1;
    end
    else if(cnt == data_up + 1 && state == RD_DATA)
    begin
        cnt <= 0;
        wr_eop <= 1;
        wr_vld = 0;
    end

reg     [3:0]   eop_t;
reg     [3:0]   eop_ti;

always@(posedge clk or  negedge rst_n)
    if(cnt == 31) begin
        match_suc <= 1;
    end else 
        match_suc <= 0;


always@(posedge clk or  negedge rst_n)
    if(rst_n == 0)
    begin
        wr_eop <= 0;
        eop_t <= 0;
        eop_ti <= 0;
    end
    else if(wr_eop == 1)
    begin
        wr_eop <= 0;
        eop_t <= 1;
    end
    else if(eop_t == 1)
    begin
        eop_t <= 0;
        eop_ti <= 1;
    end
    else if(eop_ti == 1)
    begin
        eop_ti <= 0;
        wr_sop <= 1;
        //match_suc <= 1;
    end
    
always@(posedge clk or  negedge rst_n)
    if(wr_sop == 1)
    begin
        wr_sop <= 0;
    end


reg wrr_enable = 1;
reg [4:0] match_threshold = 15;
reg [1:0] match_mode = 2;
    //????????????????
reg [3:0] viscosity = 0;


hydra hydra_inst
(
    .clk (clk),
    .rst_n (rst_n),

    .wr_sop (wr_sop),
    .wr_eop (wr_eop),
    .wr_vld (wr_vld),
    .wr_data (wr_data),

    .wrr_enable (wrr_enable),
    .match_threshold (match_threshold),
    .match_mode (match_mode),
    .viscosity (viscosity)

);

endmodule
