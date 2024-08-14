//file name: dut.v
module dut(
    input               clk,
    input               rst_n,
    input       [7:0]   I_rxd    ,
    input               I_rx_dv  ,
    output reg  [7:0]   O_txd    ,
    output reg          O_tx_en
);

always @(posedge clk)
begin
    if(~rst_n) begin
        O_txd   <= 8'b0;
        O_tx_en <= 1'b0;
    end else begin
        O_txd   <= I_rxd;
        O_tx_en <= I_rx_dv;
    end
end

endmodule
