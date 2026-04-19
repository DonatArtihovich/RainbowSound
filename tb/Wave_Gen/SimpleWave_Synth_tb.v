`timescale 1ns / 1ps

module SimpleWave_Synth_tb #(
    parameter CLK_FREQ_MHZ          = 50,
    parameter TESTBENCH_DURATION_MS = 50,

    parameter WAVE_FILE_PATH = "../../../out/wave.dat",

    parameter reg [1 : 0] WAVE_TYPE   = 0, // SINE
    parameter             LUT_BYTES   = 32,
    parameter             SAMPLE_BITS = 8,

    parameter             FREQ_DIV    = 10240
);

reg clk = 0;
reg resetn = 0;
reg gen_en = 0;

always #(500 / CLK_FREQ_MHZ) clk <= ~clk;

wire pwm_out;

SimpleWave_Synth #(
    .FREQ_DIV (FREQ_DIV),

    .WAVE_TYPE (WAVE_TYPE),
    .LUT_BYTES (LUT_BYTES),
    .SAMPLE_BITS (SAMPLE_BITS)
)
UUT
(
    .clk    (clk),
    .resetn (resetn),

    .gen_en  (gen_en),
    .pwm_out (pwm_out)
);

// File writing
integer fid;
//
integer last_posedge_time = 0;
integer last_negedge_time = 0;

integer pwm_brightness = 0;

reg [31 : 0] pwm_period_cnt = 0;
reg [31 : 0] pulse_width_cnt = 0;

always @(posedge clk) begin 
    if (~resetn) begin
        pwm_period_cnt <= 0;
        pulse_width_cnt <= 0;
    end else if (gen_en) begin
        pwm_period_cnt <= pwm_period_cnt == 255? 0 : pwm_period_cnt + 1;
        if (pwm_out) pulse_width_cnt <= pulse_width_cnt + 1;
        
        if (pwm_period_cnt == 255) begin
             pulse_width_cnt <= 0;
             pwm_brightness = pulse_width_cnt / 255.0 * 100.0;
             $fwrite(fid, "%c", pwm_brightness);
        end
    end 
end

initial begin: init_rst
    fid = $fopen(WAVE_FILE_PATH, "wb");
    #100; resetn <= 1; gen_en <= 1;

    #(1_000_000 * TESTBENCH_DURATION_MS);
    $fclose(fid);
    $finish;
end
endmodule