`timescale 1ns / 1ps

module add_mixer #(
    parameter OSC_QTY     = 4,
    parameter SAMPLE_BITS = 8
) (
    input wire resetn,

    input wire [SAMPLE_BITS * OSC_QTY - 1 : 0] wave_tdata,
    input wire [OSC_QTY - 1 : 0]     wave_tvalid,

    output wire [SAMPLE_BITS - 1 : 0] sample_tdata,
    output reg                        sample_tvalid
);

logic [SAMPLE_BITS + OSC_QTY : 0] osc_sum = 0;

integer i;

always @* begin
    if (~resetn) begin
        osc_sum = 0;
    end else begin
        osc_sum = 0;

        for (i = 0; i < OSC_QTY; i = i + 1) begin
            osc_sum = osc_sum + (wave_tvalid[i]? wave_tdata[i * SAMPLE_BITS +: SAMPLE_BITS] : 0);
        end
    end
end

always @* begin
    if (~resetn) begin
        sample_tvalid = 0;
    end else begin
        sample_tvalid = 0;

        for (i = 0; i < OSC_QTY; i = i + 1) begin
            sample_tvalid = sample_tvalid | wave_tvalid[i];
        end
    end
end

assign sample_tdata  = (osc_sum / OSC_QTY);

endmodule