`timescale 1ns/1ns

module tb_sram_ecc();

reg clk;
reg rst_n;

reg end_of_page;

initial begin
    clk <= 0;
    rst_n <= 0;
    #42
    rst_n <= 1;
end

always #2 clk = ~clk;

reg [7:0][15:0] data;
reg [7:0] code_1;

wire [7:0] code;
wire [15:0] cr_data;
wire [2:0] out_batch;

reg [2:0] in_batch;
reg [6:0] tmp_ch;

reg [15:0] data_1;
wire [2:0] in_batch_plus = in_batch + 2;
wire [2:0] in_batch_minus = in_batch - 1;

reg rs = 0;
reg ch = 0;

always @(posedge clk) begin
    if(!rst_n) begin
        in_batch <= 7;
        for(int i = 0; i < 8; i = i + 1)
            data[i] = $random;
        data_1 = data[0];
    end else begin
        $display("in_ batch = %d",in_batch);
        if(in_batch == 6) begin
            end_of_page <= 1;
            #4
            ch = 0;
            end_of_page <= 0;
            #76
            data_1 = data[0];
            #4;
        end
        if(in_batch == 7 && !ch) begin
            tmp_ch = $random;
            code_1 = code;
            ch = 1;
            data[tmp_ch[6:4]][1] = ~ data[tmp_ch[6:4]][1];
        end
        
        data_1 <= data[in_batch_plus];
        in_batch <= in_batch + 1;
        $display("in_batch = %d",in_batch);
    end
end

always @(posedge clk) begin
    if(in_batch == 6 && !rs) begin
        #4
        rs = 1;
    end
end

reg [15:0] cr_1;
always @(posedge clk) cr_1 <= cr_data;

always @(posedge clk) begin
    if(rst_n && out_batch == 7 && cr_data != cr_1 && in_batch != 7 && rs) begin
        in_batch <= 7;
        for(int i = 0; i < 8; i = i + 1)
            data[i] = $random;
        rs <= 0;
    end
end

ecc_encoder sram_ecc_encoder_inst( 
    .data_0(data[0]),
    .data_1(data[1]),
    .data_2(data[2]),
    .data_3(data[3]),
    .data_4(data[4]),
    .data_5(data[5]),
    .data_6(data[6]),
    .data_7(data[7]),
    .code(code)
);

ecc_decoder sram_ecc_decoder(
    .clk(clk),
    .rst_n(rst_n),

    .end_of_page(end_of_page),
    .in_batch(in_batch), 
    .data(data_1),
    .code(code_1),

    .out_batch(out_batch),
    .cr_data(cr_data)

);

endmodule