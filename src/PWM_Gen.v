`timescale 1ns / 1ps

module PWM_Gen #(
    parameter PWM_PERIOD_BITS = 16
) (
    input wire clk,
    input wire resetn,

    input wire [PWM_PERIOD_BITS - 1 : 0] pwm_period,
    input wire [PWM_PERIOD_BITS - 1 : 0] pwm_pulse,
    input wire inv,

    output wire pwm_out
);

reg [PWM_PERIOD_BITS - 1 : 0] dur_cnt = 0;

always @(posedge clk) begin
    if (~resetn) begin
        dur_cnt <= 0;
    end else begin
        dur_cnt <= (dur_cnt < pwm_period)? dur_cnt + 1 : 0;
    end
end

assign pwm_out = ((dur_cnt < pwm_pulse) ^ inv) && resetn;

endmodule