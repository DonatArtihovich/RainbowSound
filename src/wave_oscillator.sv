`timescale 1ns / 1ps

module wave_oscillator #(
    parameter real PI = 3.141592653589793,

    parameter [1 : 0] WAVE_TYPE = 0,
    parameter         LUT_BYTES = 32,

    parameter         SAMPLE_BITS = 8
) (
    input wire clk,
    input wire resetn,
    
    input wire [7 : 0] amp,
    input wire [7 : 0] amp_div,
    
    input wire        [$clog2(LUT_BYTES) - 1 : 0] phase,
    input wire signed [$clog2(LUT_BYTES) - 1 : 0] phase_shift,
    
    output reg [SAMPLE_BITS - 1 : 0] sample_tdata  = 0,
    output reg                       sample_tvalid = 0
);

localparam PHASE_BITS = $clog2(LUT_BYTES);

localparam MAX_SAMPLE = {SAMPLE_BITS{1'b1}};

reg [SAMPLE_BITS - 1 : 0] lut [0 : LUT_BYTES - 1];

typedef enum logic [1 : 0] {
    WSINE     = 2'b00,
    WSQUARE   = 2'b01,
    WTRIANGLE = 2'b10,
    WSAW      = 2'b11
} wave_t;

function [SAMPLE_BITS - 1 : 0] sine_gen;
    input [PHASE_BITS - 1 : 0] phase;
    begin
        sine_gen = (1 + $sin(2 * PI * phase / LUT_BYTES)) / 2 * MAX_SAMPLE;
    end
endfunction

function [SAMPLE_BITS - 1 : 0] square_gen;
    input [PHASE_BITS - 1 : 0] phase;
    begin
        square_gen = $sin(2 * PI * phase / LUT_BYTES) > 0? MAX_SAMPLE : 0;
    end
endfunction

function [SAMPLE_BITS - 1 : 0] triangle_gen;
    input [PHASE_BITS - 1 : 0] phase;

    begin
        triangle_gen = ((i < LUT_BYTES / 2)? i * 2.0 / LUT_BYTES * MAX_SAMPLE : MAX_SAMPLE - ((i * 1.0 / LUT_BYTES - 0.5) * MAX_SAMPLE * 2));
    end
endfunction

function [SAMPLE_BITS - 1 : 0] saw_gen;
    input [PHASE_BITS - 1 : 0] phase;

    begin
        saw_gen = (phase * 1.0 / LUT_BYTES) * MAX_SAMPLE;
    end
endfunction

integer i;
initial begin: LUT_INIT
    for (i = 0; i < LUT_BYTES; i = i + 1) begin
        case (WAVE_TYPE)
        WSINE:     lut[i] <= sine_gen(i + 1);
        WSQUARE:   lut[i] <= square_gen(i + 1);
        WTRIANGLE: lut[i] <= triangle_gen(i + 1);
        WSAW:      lut[i] <= saw_gen(i + 1);
        endcase
    end
end

wire signed [PHASE_BITS - 1 : 0] phase_shifted = phase + phase_shift;
wire [PHASE_BITS - 1 : 0] phase_i = (phase_shifted > LUT_BYTES
                                         ? phase_shifted - LUT_BYTES
                                         : (phase_shifted < 0
                                             ? LUT_BYTES + phase_shifted
                                             : phase_shifted));

always @(posedge clk) begin
    if (~resetn) begin
        sample_tdata  <= 0;
        sample_tvalid <= 0;
    end else begin
        sample_tdata  <= lut[phase_i] * (amp / amp_div);
        sample_tvalid <= 1;
    end
end

endmodule