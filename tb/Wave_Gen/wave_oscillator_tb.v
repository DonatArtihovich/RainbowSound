`timescale 1ns / 1ps

module wave_oscillator_tb #(
    parameter CLK_FREQ_MHZ          = 50,
    parameter TESTBENCH_DURATION_MS = 10,

    parameter WAVE_FILE_PATH = "../../../out/wave.dat",

    parameter reg [1 : 0] WAVE_TYPE   = 2, // SINE
    parameter             LUT_BYTES   = 32,
    parameter             SAMPLE_BITS = 8,

    parameter SOUND_AMPLITUDE     = 1.0,
    parameter SOUND_AMPLITUDE_DIV = 1,

    parameter WAVE_PHASE_SHIFT = 0
);

localparam PHASE_BITS = $clog2(LUT_BYTES);

reg clk = 0;
reg resetn = 0;

always #(500 / CLK_FREQ_MHZ) clk <= ~clk;

reg  [PHASE_BITS - 1 : 0] phase = 0;
wire [SAMPLE_BITS - 1 : 0] sample_tdata;
wire                       sample_tvalid;

wave_oscillator #(
    .WAVE_TYPE   (WAVE_TYPE),
    .LUT_BYTES   (LUT_BYTES),
    .SAMPLE_BITS (SAMPLE_BITS)
) UUT (
    .clk    (clk),
    .resetn (resetn),

    .amp     (SOUND_AMPLITUDE),
    .amp_div (SOUND_AMPLITUDE_DIV),

    .phase       (phase),
    .phase_shift (WAVE_PHASE_SHIFT),

    .sample_tdata   (sample_tdata),
    .sample_tvalid  (sample_tvalid)
);

// phase shifting
always @(posedge clk) begin
    if (~resetn) begin
        phase <= 0;
    end else begin
        phase <= (phase == LUT_BYTES - 1)? 0 : phase + 1;
    end
end


// File writing
integer fid;
//
always @(posedge clk) begin
    if (resetn && sample_tvalid) begin
        $fwrite(fid, "%c", sample_tdata);
    end
end

initial begin: init_rst
    fid = $fopen(WAVE_FILE_PATH, "wb");
    #100; resetn <= 1;

    #(1_000_000 * TESTBENCH_DURATION_MS);
    $fclose(fid);
    $finish;
end
endmodule