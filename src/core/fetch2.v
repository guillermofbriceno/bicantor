`include "../defs.v"
`include "decoder.v"

module fetch2
(
    input  wire [31:0] inst_0_i,
    input  wire [31:0] inst_1_i

);
    wire [`CTRL_BUS] control_0_w;
    wire [`CTRL_BUS] control_1_w;

    decoder DECODE0(
        .instruction(inst_0_i),
        .control(control_0_w)
    );

    decoder DECODE1(
        .instruction(inst_1_i),
        .control(control_1_w)
    );

endmodule
