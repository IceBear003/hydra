`timescale 1ns/1ns

module tb_ecc();

reg [127:0] data;
reg [7:0] code;

wire [127:0] cr_data;

reg clk;
reg rst_n;

initial begin
    clk <= 1'b1;
    rst_n <= 1'b0;
    #40
    rst_n <= 1'b1;
end

always #2 clk =   ~clk;

reg [1:0] cnt;
reg [6:0] c;

wire enable_d;
assign enable_d = (cnt == 3);
wire enable_e;
assign enable_e = (cnt == 1);

always@(posedge clk or negedge rst_n)
    if(rst_n == 0) begin
        data <= 0;
        cnt <= 0;
        c <= 0;
    end
    else begin
        cnt <= cnt + 1;
        if(cnt == 0) begin
            data <= $random;
            c <= $random % 128;
        end
        if(cnt == 1) begin
            data[c] <= ~data[c];
        end
    end

ecc_encoder ecc_encoder_inst
(
    .clk     (clk            )   ,
    .enable  (enable_e       )   ,
    .data_0  (data[15:0]     )   ,
    .data_1  (data[31:16]    )   ,
    .data_2  (data[47:32]    )   ,
    .data_3  (data[63:48]    )   ,
    .data_4  (data[79:64]    )   ,
    .data_5  (data[95:80]    )   ,
    .data_6  (data[111:96]   )   ,
    .data_7  (data[127:112]  )   ,
    .code    (code           )   

);

ecc_decoder ecc_decoder
(
    .clk (clk),
    .enable (enable_d),
    .data_0  (data[15:0]     )   ,
    .data_1  (data[31:16]    )   ,
    .data_2  (data[47:32]    )   ,
    .data_3  (data[63:48]    )   ,
    .data_4  (data[79:64]    )   ,
    .data_5  (data[95:80]    )   ,
    .data_6  (data[111:96]   )   ,
    .data_7  (data[127:112]  )   ,
    .code (code),
    .cr_data_0  (cr_data[15:0]     )   ,
    .cr_data_1  (cr_data[31:16]    )   ,
    .cr_data_2  (cr_data[47:32]    )   ,
    .cr_data_3  (cr_data[63:48]    )   ,
    .cr_data_4  (cr_data[79:64]    )   ,
    .cr_data_5  (cr_data[95:80]    )   ,
    .cr_data_6  (cr_data[111:96]   )   ,
    .cr_data_7  (cr_data[127:112]  )   
    );

endmodule