`timescale 1ns / 1ps

module wave_gen #(
    parameter [1 : 0] WAVE_TYPE = 0,
    parameter         LUT_BYTES = 32,
    parameter         SAMPLE_BITS = 8
) (
    input wire clk,
    input wire resetn,

    input wire gen_en,

    input wire [31 : 0] freq_div,

    input wire [7 : 0] amp,
    input wire [7 : 0] amp_div,
    
    input wire signed [$clog2(LUT_BYTES) - 1 : 0] phase_shift,

    output wire [SAMPLE_BITS - 1 : 0] sample_tdata,
    output wire                       sample_tvalid
);

localparam PHASE_BITS = $clog2(LUT_BYTES);

reg [$clog2(LUT_BYTES) - 1 : 0] phase = 0;

wire signed [PHASE_BITS - 1 : 0] phase_shifted = phase + phase_shift;
wire [PHASE_BITS - 1 : 0] phase_i = (phase_shifted > LUT_BYTES
                                         ? phase_shifted - LUT_BYTES
                                         : (phase_shifted < 0
                                             ? LUT_BYTES + phase_shifted
                                             : phase_shifted));

reg [31 : 0] freq_cnt = 0;

always @(posedge clk) begin
    if (~resetn) begin
        phase    <= 0;
        freq_cnt <= 0;
    end else if (gen_en) begin
        freq_cnt <= freq_cnt == freq_div - 1? 0 : freq_cnt + 1;

        if (!freq_div || freq_cnt == freq_div - 2) phase <= (phase == LUT_BYTES - 1)? 0 : phase + 1;
    end
end

wire wosc_tvalid;

wave_oscillator #(
    .WAVE_TYPE (WAVE_TYPE),
    .LUT_BYTES (LUT_BYTES),
    .SAMPLE_BITS (SAMPLE_BITS)
) wosc_i (
    .clk    (clk),
    .resetn (resetn),

    .amp     (amp),
    .amp_div (amp_div),

    .phase         (phase_i),
    .sample_tdata  (sample_tdata),
    .sample_tvalid (wosc_tvalid)
);

assign sample_tvalid = wosc_tvalid && gen_en;

endmodule