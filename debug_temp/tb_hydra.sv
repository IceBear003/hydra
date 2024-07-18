`timescale 1ns/1ns

module tb_hydra();

reg clk;
reg rst_n;

reg [15:0] wr_sop  ;
reg [15:0] wr_eop  ;
reg [15:0] wr_vld  ;
reg [15:0][15:0] wr_data;
//reg match_suc;

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
        //wr_data     <=  1'b0;
      #40
        rst_n   <=  1'b1;
      #40
        wr_sop  <= 16'h00FF;
    end

always #2 clk =   ~clk;

parameter   IDLE    =   2'b00   ,
            RD_CTRL =   2'b01   ,
            RD_BTW  =   2'b10   ,
            RD_DATA =   2'b11   ;
            
reg     [15:0][1:0]   state   ;
reg     [15:0][11:0]   cnt     ;

integer i;

always@(posedge clk or  negedge rst_n)
for(i=0 ; i<16 ; i=i+1) begin
    if(rst_n == 4'b0)
        state[i] <= IDLE;
    else
        case(state[i])
            IDLE:
                if(wr_sop[i] == 1)
                    state[i] <= RD_CTRL;
                else
                    state[i] <= IDLE;
            RD_CTRL:
                state[i] <= RD_DATA;
            RD_DATA:
                if(wr_eop[i] == 1)
                    state[i] = IDLE;
                else
                    state[i] <= RD_DATA;
            default:
                state[i] <= IDLE;
        endcase
        end

reg    [8:0]  data_up[15:0] ;

//assign  data_up =   (state == RD_CTRL) ? (512+16) / 16 : data_up;
/*
always@(posedge clk or  negedge rst_n) begin
    if(rst_n) begin
        $fdisplay("%b %b %b %b",wr_sop,wr_eop,wr_vld,wr_data);
    end
end
*/
always@(posedge clk or  negedge rst_n)
for(i=0 ; i<16 ; i=i+1)
    if(state[i] == RD_CTRL) begin
        /*data_up = ($random);
        if(data_up > 100)
            data_up = data_up % 100;
        if(data_up < 32)
            data_up = 32;*/
        
            data_up[i] = 32;
        
    end

always@(posedge clk or  negedge rst_n)
for(i=0 ; i<16 ; i=i+1)
    if(rst_n == 4'b0)
        wr_data[i] <= 4'b0;
    else if(state[i] == RD_CTRL) begin
        //wr_data <= $random % 65536;
        wr_data[i][15:7] <= data_up[i] + 1;
        wr_data[i][6:4] <= 2;
        wr_data[i][3:0] <= 1;
    end
    else if(state[i] == RD_DATA)
        wr_data[i] <= cnt[i];
            
always@(posedge clk or  negedge rst_n)
for(i=0 ; i<16 ; i=i+1)
    if(rst_n == 0 || state == IDLE)
    begin
        wr_vld[i] = 0;
        cnt[i] <= 0;
    end
    else if(state[i] == RD_CTRL)
    begin
        wr_vld[i] <= 1;
        cnt[i] <= cnt[i] + 1'b1;
    end
    else if(state[i] == RD_DATA && cnt[i] < data_up[i] + 1)
    begin
        //if(cnt >= 32 && cnt <= 74)
        //    wr_vld[i] <= 0;
        //else
            wr_vld[i] <= 1;
        cnt[i] <= cnt[i] + 1'b1;
    end
    else if(cnt[i] == data_up[i] + 1 && state[i] == RD_DATA)
    begin
        cnt[i] <= 0;
        wr_eop[i] <= 1;
        wr_vld[i] = 0;
    end

reg     [3:0]   eop_t[15:0];
reg     [3:0]   eop_ti[15:0];

always@(posedge clk or  negedge rst_n)
    for(i=0 ; i<16 ; i=i+1) begin
        if(rst_n == 0)
        begin
            wr_eop[i] <= 0;
            eop_t[i] <= 0;
            eop_ti[i] <= 0;
        end
        else if(wr_eop[i] == 1)
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
            //match_suc <= 1;
        end
    end
    
always@(posedge clk or  negedge rst_n)
for(i=0 ; i<16 ; i=i+1)
    if(wr_sop[i] == 1)
    begin
        wr_sop[i] <= 0;
    end


reg wrr_enable = 1;
reg [4:0] match_threshold = 15;
reg [1:0] match_mode = 2;
    //????????????????
//reg [3:0] viscosity = 0;


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
    .match_mode (match_mode)

);

endmodule
