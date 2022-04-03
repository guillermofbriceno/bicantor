`include "src/defs.v"

module decode
(
    input  wire [31:0] inst0_i,
    input  wire [31:0] inst1_i,
    input  wire        pred_taken_0_i,
    input  wire        pred_taken_1_i,
    input  wire [31:0] pc_0_i,
    input  wire [31:0] pc_1_i,

    output  wire [31:0] inst0_o,
    output  wire [31:0] inst1_o,
    output  wire [`CTRL_BUS] ctrl0_o,
    output  wire [`CTRL_BUS] ctrl1_o,
    output  wire             wasnt_branch_o,
    output  wire [31:0]      fixed_pc_o,
    output  wire             pred_taken_1_o,
    output  reg              stall_o = 0
);

    wire wasnt_branch0;
    wire wasnt_branch1;
    
    assign inst0_o = inst0_i;
    assign inst1_o = inst1_i;

    assign pred_taken_1_o = pred_taken_0_i ? 0 : pred_taken_1_i;

    // there is an issue here, we need to go back to the original PC+4 if it
    // wasn't a branch
    assign wasnt_branch0 = !(ctrl0_o[`COND_BRANCH] || ctrl0_o[`JAL] || ctrl0_o[`JALR]) && (pred_taken_0_i);
    //assign wasnt_branch1 = !(ctrl1_o[`COND_BRANCH] || ctrl1_o[`JAL] || ctrl1_o[`JALR]) && (pred_taken_1_i);
    assign wasnt_branch1 = !(ctrl1_o[`COND_BRANCH] || ctrl1_o[`JAL] || ctrl1_o[`JALR]) && (pred_taken_1_o);
    assign wasnt_branch_o = wasnt_branch0 || wasnt_branch1;
    assign fixed_pc_o = ( !wasnt_branch0 && wasnt_branch1 ) ? pc_1_i : pc_0_i;

    decoder DECODE0(
        .instruction_i(inst0_i),
        .control_o(ctrl0_o)
    );

    decoder DECODE1(
        .instruction_i(inst1_i),
        .control_o(ctrl1_o)
    );

endmodule
