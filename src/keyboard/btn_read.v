`timescale 1ns / 1ps

module btn_read #(
    parameter CLK_FREQ_MHZ = 50,

    parameter HOLD_DURATION_MS = 10,
    parameter HOLD_LEVEL = 1
) (
    input wire clk,
    input wire resetn,

    input wire btn_in,

    output wire state
);

localparam integer HOLD_DURATION_TICKS = HOLD_DURATION_MS * CLK_FREQ_MHZ * 1_000.0;

reg [$clog2(HOLD_DURATION_TICKS) : 0] hold_cnt = 0;

always @(posedge clk) begin
    if (~resetn) begin
        hold_cnt <= 0;
    end else begin
        hold_cnt <= (btn_in == HOLD_LEVEL)? hold_cnt + (~&hold_cnt) : 0;
    end
end

assign state = resetn && hold_cnt >= HOLD_DURATION_TICKS - 1;

endmodule