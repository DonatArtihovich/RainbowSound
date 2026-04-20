`timescale 1ns / 1ps

module pwm_gen #(
    parameter PWM_PERIOD_BITS = 16
) (
    input wire clk,
    input wire resetn,

    input wire [31 : 0] freq_div,

    input wire [PWM_PERIOD_BITS - 1 : 0] pwm_period,
    input wire [PWM_PERIOD_BITS - 1 : 0] pwm_pulse,
    input wire inv,

    output wire pwm_out
);

reg [PWM_PERIOD_BITS - 1 : 0] dur_cnt = 0;
reg [31 : 0] div_cnt = 0;

always @(posedge clk) begin
    if (~resetn) begin
        dur_cnt <= 0;
        div_cnt <= 0;
    end else begin
        div_cnt <= div_cnt + 1;

        if (div_cnt == freq_div - 1 || !freq_div) begin
            dur_cnt <= (dur_cnt < pwm_period)? dur_cnt + 1 : 0;
            div_cnt <= 0;
        end
    end
end

assign pwm_out = ((dur_cnt < pwm_pulse) ^ inv) && resetn;

endmodule