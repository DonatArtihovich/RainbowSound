`timescale 1ns / 1ps

module wave_gen_tb #(
    parameter CLK_FREQ_MHZ          = 50,
    parameter TESTBENCH_DURATION_MS = 50,

    parameter WAVE_FILE_PATH = "../../../out/wave.dat",

    parameter reg [1 : 0] WAVE_TYPE   = 2, // SINE
    parameter             LUT_BYTES   = 32,
    parameter             SAMPLE_BITS = 8,

    parameter             FREQ_DIV = 100,

    parameter SOUND_AMPLITUDE     = 1.0,
    parameter SOUND_AMPLITUDE_DIV = 1
);

localparam PHASE_BITS = $clog2(LUT_BYTES);

reg clk = 0;
reg resetn = 0;
reg gen_en = 0;

always #(500 / CLK_FREQ_MHZ) clk <= ~clk;

wire [SAMPLE_BITS - 1 : 0] sample_tdata;
wire                       sample_tvalid;

wave_gen #(
    .WAVE_TYPE   (WAVE_TYPE),
    .LUT_BYTES   (LUT_BYTES),
    .SAMPLE_BITS (SAMPLE_BITS)
) UUT (
    .clk    (clk),
    .resetn (resetn),

    .gen_en   (gen_en),
    .freq_div (FREQ_DIV),

    .phase_shift (0),

    .amp     (SOUND_AMPLITUDE),
    .amp_div (SOUND_AMPLITUDE_DIV),

    .sample_tdata   (sample_tdata),
    .sample_tvalid  (sample_tvalid)
);

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
    #100; resetn <= 1; gen_en <= 1;

    #(1_000_000 * TESTBENCH_DURATION_MS);
    $fclose(fid);
    $finish;
end
endmodule