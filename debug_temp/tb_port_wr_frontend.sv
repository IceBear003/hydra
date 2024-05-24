`timescale 1ns/1ns

module tb_port_wr_frontend();

reg clk;
reg rst_n;

reg        wr_sop  ;
reg        wr_eop  ;
reg        wr_vld  ;
reg    [15:0]   wr_data ;
reg match_suc;


//reg    [15:0]   ready   ;

initial
    begin
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

always@(posedge clk or  negedge rst_n)
    if(state == RD_CTRL) begin
        data_up = 35;
        if(data_up < 32)
            data_up = 32;
    end

always@(posedge clk or  negedge rst_n)
    if(rst_n == 4'b0)
        wr_data <= 4'b0;
    else if(state == RD_CTRL) begin
        //wr_data <= $random % 65536;
        wr_data[15:7] <= data_up;
        wr_data[6:4] <= $random % 8;
        wr_data[3:0] <= $random;
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
    if(rst_n == 0 || match_suc == 1) begin
        match_suc <= 0;
    end else if(cnt == 43) begin
        match_suc <= 1;
    end

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
    end
    
always@(posedge clk or  negedge rst_n)
    if(wr_sop == 1)
    begin
        wr_sop <= 0;
    end

wire [3:0] new_dest_port;
wire [2:0] new_prior;
wire [8:0] new_length;
wire [3:0] cur_dest_port;
wire [2:0] cur_prior;
wire [8:0] cur_length;
wire pause;
wire [15:0] xfer_data;
wire xfer_data_vld;
wire [2:0] wr_state;
wire [1:0] xfer_state;

port_wr_frontend port_wr_frontend_inst
(
    .clk (clk),
    .rst_n (rst_n),

    .wr_sop (wr_sop),
    .wr_eop (wr_eop),
    .wr_vld (wr_vld),
    .wr_data (wr_data),

    .new_dest_port (new_dest_port),
    .xfer_data (xfer_data),
    .xfer_data_vld (xfer_data_vld),
    .new_length (new_length),
    .new_prior (new_prior),
    .cur_dest_port (cur_dest_port),
    .cur_prior (cur_prior),
    .cur_length (cur_length),
    .pause (pause),
    .match_suc (match_suc),
    .wr_state (wr_state),
    .xfer_state (xfer_state)

);

endmodule
