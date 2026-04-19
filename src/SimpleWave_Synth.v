`timescale 1ns / 1ps

module SimpleWave_Synth #(
    parameter         FREQ_DIV = 256, // Must be [256; 0xFFFFFFFF] and be multiple of 256

    parameter [1 : 0] WAVE_TYPE = 0,
    parameter         LUT_BYTES = 32,
    parameter         SAMPLE_BITS = 8
) (
    input wire  clk,
    input wire  resetn,

    input wire  gen_en,

    output wire pwm_out
);

wire [SAMPLE_BITS - 1 : 0] sample_tdata;
wire                       sample_tvalid;

wave_gen #(
    .WAVE_TYPE (WAVE_TYPE),
    .LUT_BYTES (LUT_BYTES),
    .SAMPLE_BITS (SAMPLE_BITS)
) wave_gen_i (
    .clk    (clk),
    .resetn (resetn),

    .gen_en (gen_en),

    .freq_div (FREQ_DIV),
    .amp     (1),
    .amp_div (1),
    .phase_shift (0),

    .sample_tdata  (sample_tdata),
    .sample_tvalid (sample_tvalid)
);

pwm_gen #(
    .PWM_PERIOD_BITS (SAMPLE_BITS)
) pwm_gen_i (
    .clk    (clk),
    .resetn (resetn),

    .freq_div   (0),
    .inv        (0),
    .pwm_period ({SAMPLE_BITS{1'b1}}),
    .pwm_pulse  (sample_tdata),
    .pwm_out    (pwm_out)
);

endmodule