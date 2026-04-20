`timescale 1ns / 1ps

module SimpleWave_Synth #(
    parameter         FREQ_DIV_MUL = 40,

    parameter [1 : 0] WAVE_TYPE = 0,
    parameter         LUT_BYTES = 32,
    parameter         SAMPLE_BITS = 8
) (
    input wire  clk,
    input wire  resetn,

    input wire  [7 : 0]               amp_mul,
    input wire  [7 : 0]               amp_div,
    input wire  [SAMPLE_BITS - 1 : 0] pwm_period,

    input wire  gen_en,

    output wire pwm_out
);


reg [SAMPLE_BITS - 1 : 0] pwm_period_reg = {SAMPLE_BITS{1'b1}};
wire [31 : 0] freq_div = (pwm_period_reg + 1) * FREQ_DIV_MUL;

reg [31 : 0] freq_cnt = 0;

always @(posedge clk) begin
    if (~resetn) begin
        pwm_period_reg <= {SAMPLE_BITS{1'b1}};
        freq_cnt       <= 0;
    end else if (gen_en) begin
        freq_cnt <= freq_cnt == freq_div - 1? 0 : freq_cnt + 1;

        if (!freq_div || freq_cnt == freq_div - 1) pwm_period_reg <= pwm_period;
    end
end

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
    
    .sample_max  (pwm_period_reg),
    .freq_div    (freq_div),
    .amp_mul     (amp_mul),
    .amp_div     (amp_div),
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
    .pwm_period (pwm_period_reg),
    .pwm_pulse  (sample_tdata),
    .pwm_out    (pwm_out)
);

endmodule