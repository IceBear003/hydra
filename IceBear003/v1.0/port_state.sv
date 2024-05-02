module port_state(
    input wrr
);

reg [16:0] queue_0_0 [$];
reg [16:0] queue_0_1 [$];
reg [16:0] queue_0_2 [$];
reg [16:0] queue_0_3 [$];
reg [16:0] queue_0_4 [$];
reg [16:0] queue_0_5 [$];
reg [16:0] queue_0_6 [$];
reg [16:0] queue_0_7 [$];

reg [13:0] total;
reg [13:0][7:0] queue_amount;
reg [8:0][31:0] sram_amount;

endmodule