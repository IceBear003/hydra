module port_rd_dispatch(
    input clk,
    input rst_n,

    input wrr_en,
    input [7:0] queue_available,
    input next,
    output reg [2:0] prior
);

//1 MUX + (4 DOORS / 0 DOORS)
wire [7:0] masked = wrr_en ? wrr_mask & queue_available : queue_available;
//4 DOORS + 1 MUX
wire [7:0] fixed = (masked == 8'h00) ? queue_available : masked;
//3 DOORS
always @(posedge clk) begin
    if(fixed[0]) prior <= 3'd0;
    else if(fixed[1]) prior <= 3'd1;
    else if(fixed[2]) prior <= 3'd2;
    else if(fixed[3]) prior <= 3'd3;
    else if(fixed[4]) prior <= 3'd4;
    else if(fixed[5]) prior <= 3'd5;
    else if(fixed[6]) prior <= 3'd6;
    else prior <= 3'd7;
end

reg [7:0] wrr_mask;
reg [2:0] wrr_start;
reg [2:0] wrr_end;

always @(posedge clk) begin
    if(~rst_n) begin
        wrr_mask <= 8'hFF;
        wrr_start <= 3'd0;
        wrr_end <= 3'd7;
    end else if(next) begin
        if(wrr_start != wrr_end) begin
            wrr_start <= wrr_start + 1;
            wrr_mask[wrr_start] <= 0;
        end else if(wrr_end == 3'd0) begin
            wrr_mask <= 8'hFF;
            wrr_start <= 3'd0;
            wrr_end <= 3'd7;
        end else begin
            wrr_end <= wrr_end - 1;
            wrr_start <= 3'd0;
            wrr_mask <= 8'hFF >> (3'd7 - wrr_end);
        end
    end
end

endmodule