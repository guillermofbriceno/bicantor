`include "src/defs.v"

module decode
(
    input  wire [31:0] inst0_i,
    input  wire [31:0] inst1_i,

    output  wire [31:0] inst0_o,
    output  wire [31:0] inst1_o,
    output  wire [`CTRL_BUS] ctrl0_o,
    output  wire [`CTRL_BUS] ctrl1_o,
    output  reg              stall_o = 0
);
    
    assign inst0_o = inst0_i;
    assign inst1_o = inst1_i;

    decoder DECODE0(
        .instruction_i(inst0_i),
        .control_o(ctrl0_o)
    );

    decoder DECODE1(
        .instruction_i(inst1_i),
        .control_o(ctrl1_o)
    );

endmodule
