`timescale 1ns / 1ps

module PWM_Gen_tb #(
    parameter CLK_FREQ_MHZ          = 50.0,
    parameter TESTBENCH_DURATION_MS = 100,

    parameter     PWM_PERIOD_BITS  = 16,
    parameter     PWM_PERIOD       = {PWM_PERIOD_BITS{1'b1}},
    parameter     PWM_BRIGHTNESS   = 0.65,
    parameter reg PWM_INVERSION    = 0
);

localparam PWM_PULSE = PWM_PERIOD * (PWM_INVERSION? 1 - PWM_BRIGHTNESS : PWM_BRIGHTNESS);

reg clk = 0;
reg resetn = 0;

always #(500 / CLK_FREQ_MHZ) clk <= ~clk;

wire pwm_out;

PWM_Gen #(
    .PWM_PERIOD_BITS (PWM_PERIOD_BITS)
) UUT (
    .clk    (clk),
    .resetn (resetn),

    .inv        (PWM_INVERSION),
    .pwm_period (PWM_PERIOD),
    .pwm_pulse  (PWM_PULSE),
    .pwm_out    (pwm_out)
);
//
// Brightness counting
//
reg [31 : 0] pos_cnt = 0;
reg [31 : 0] neg_cnt = 0;

always @(posedge clk) begin
    if (~resetn) begin
        pos_cnt <= 0;
        neg_cnt <= 0;
    end else begin
        pos_cnt <= pos_cnt + pwm_out;
        neg_cnt <= neg_cnt + !pwm_out;
    end
end

initial begin: init_rst
    #100; resetn <= 1;
    $display("Start PWM_Gen testbench, PWM Period = %d ticks, PWM brightness = %.2lf%%", PWM_PERIOD, PWM_BRIGHTNESS);
    #(TESTBENCH_DURATION_MS * 1_000_000);
    
    $display("Total brightness: %d%%", pos_cnt * 100.0 / (pos_cnt + neg_cnt));
    $finish;
end

endmodule