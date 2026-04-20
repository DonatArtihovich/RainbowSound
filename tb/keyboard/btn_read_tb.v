`timescale 1ns / 1ps

module btn_read_tb #(
    parameter CLK_FREQ_MHZ     = 50.0,
    
    parameter HOLD_DURATION_MS = 10,
    parameter HOLD_LEVEL       = 1
);

reg clk = 0;
reg resetn = 0;

always #(500 / CLK_FREQ_MHZ) clk <= ~clk;

reg btn = 0;
wire btn_state;

btn_read #(
    .CLK_FREQ_MHZ (CLK_FREQ_MHZ),

    .HOLD_DURATION_MS (HOLD_DURATION_MS),
    .HOLD_LEVEL (HOLD_LEVEL)
) UUT (
    .clk    (clk),
    .resetn (resetn),

    .btn_in (btn),
    .state (btn_state)
);

initial begin: init_rst
    #100; resetn <= 1;
    #10;
    btn <= 1;
    #(1_000_000 * HOLD_DURATION_MS / 2);
    btn <= 0;
    #100;
    btn <= 1;
    #(1_000_000 * HOLD_DURATION_MS);
    btn <= 0;
    #1000;
    btn <= 1;
    #100
    btn <= 0;
    #10000;
    $finish;
end

endmodule