`timescale 1ns / 1ps

module SupersawWave_Synth #(

    parameter         LUT_BYTES = 32,
    parameter         SAMPLE_BITS = 8
) (
    input wire  clk,
    input wire  resetn,
    input wire  [7 : 0] freq_div_mul,

    input wire  [31 : 0]               amp_mul,
    input wire  [31 : 0]               amp_div,
    input wire  [SAMPLE_BITS - 1 : 0] pwm_period,

    input wire  gen_en,

    output wire pwm_out
);

localparam OSC_QTY = 4;

reg [SAMPLE_BITS - 1 : 0] pwm_period_reg = {SAMPLE_BITS{1'b1}};
wire [31 : 0] freq_div = (pwm_period_reg + 1) * freq_div_mul;

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

wire [SAMPLE_BITS - 1 : 0] wave_tdata [0 : OSC_QTY - 1];
wire [OSC_QTY - 1 : 0]     wave_tvalid;

wave_gen #(
    .WAVE_TYPE (3'b11),
    .LUT_BYTES (LUT_BYTES),
    .SAMPLE_BITS (SAMPLE_BITS)
) wave_gen_fund (
    .clk    (clk),
    .resetn (resetn),

    .gen_en (gen_en),
    
    .sample_max  (pwm_period_reg),
    .freq_div    (freq_div),
    .amp_mul     (amp_mul),
    .amp_div     (amp_div),
    .phase_shift (0),

    .sample_tdata  (wave_tdata[0]),
    .sample_tvalid (wave_tvalid[0])
);

wave_gen #(
    .WAVE_TYPE (3'b11),
    .LUT_BYTES (LUT_BYTES),
    .SAMPLE_BITS (SAMPLE_BITS)
) wave_gen_sub (
    .clk    (clk),
    .resetn (resetn),

    .gen_en (gen_en),
    
    .sample_max  (pwm_period_reg),
    .freq_div    (freq_div * 2),
    .amp_mul     (amp_mul * 7),
    .amp_div     (amp_div * 10),
    .phase_shift (0),

    .sample_tdata  (wave_tdata[1]),
    .sample_tvalid (wave_tvalid[1])
);

wave_gen #(
    .WAVE_TYPE (3'b11),
    .LUT_BYTES (LUT_BYTES),
    .SAMPLE_BITS (SAMPLE_BITS)
) wave_gen_side0 (
    .clk    (clk),
    .resetn (resetn),

    .gen_en (gen_en),
    
    .sample_max  (pwm_period_reg),
    .freq_div    (freq_div * 98 / 100),
    .amp_mul     (amp_mul * 8),
    .amp_div     (amp_div * 10),
    .phase_shift (0),

    .sample_tdata  (wave_tdata[2]),
    .sample_tvalid (wave_tvalid[2])
);

wave_gen #(
    .WAVE_TYPE (3'b11),
    .LUT_BYTES (LUT_BYTES),
    .SAMPLE_BITS (SAMPLE_BITS)
) wave_gen_side1 (
    .clk    (clk),
    .resetn (resetn),

    .gen_en (gen_en),
    
    .sample_max  (pwm_period_reg),
    .freq_div    (freq_div * 103 / 100),
    .amp_mul     (amp_mul * 8),
    .amp_div     (amp_div * 10),
    .phase_shift (0),

    .sample_tdata  (wave_tdata[3]),
    .sample_tvalid (wave_tvalid[3])
);

add_mixer #(
    .OSC_QTY     (OSC_QTY),
    .SAMPLE_BITS (SAMPLE_BITS)
) add_mixer_i (
    .resetn (resetn),

    .sample_tdata  (sample_tdata),
    .sample_tvalid (sample_tvalid),
    .wave_tdata  ({wave_tdata[3], wave_tdata[2], wave_tdata[1], wave_tdata[0]}),
    .wave_tvalid (wave_tvalid)
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