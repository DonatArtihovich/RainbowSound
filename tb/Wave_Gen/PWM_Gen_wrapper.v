module PWM_Gen_wrapper (
    input wire clk,
    input wire reset,
    output wire pwm
);

SimpleWave_Synth #(
    .FREQ_DIV_MUL (40),

    .WAVE_TYPE (0),
    .LUT_BYTES (32),
    .SAMPLE_BITS (8)
)
UUT
(
    .clk    (clk),
    .resetn (reset),

    .amp_mul    (1),
    .amp_div    (1),
    .pwm_period (255),

    .gen_en  (1),
    .pwm_out (pwm)
);

endmodule