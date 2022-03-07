`include "src/defs.v"

module execute
(
    input wire [31:0]        inst0_i,
    input wire [31:0]        inst1_i,
    input wire [`CTRL_BUS]   ctrl0_i,
    input wire [`CTRL_BUS]   ctrl1_i,
    input wire [31:0]        pc_0_i,
    input wire [31:0]        pc_1_i,

    input wire [31:0]        rs1_0_i,
    input wire [31:0]        rs2_0_i,
    input wire [31:0]        rs1_1_i,
    input wire [31:0]        rs2_1_i,

    input wire               wm0_i,
    input wire [4:0]         am0_i,
    input wire               wm1_i,
    input wire [4:0]         am1_i,

    input wire               ww0_i,
    input wire [4:0]         aw0_i,
    input wire               ww1_i,
    input wire [4:0]         aw1_i,

    input wire [31:0]        bypass_lsu0_i,
    input wire [31:0]        bypass_wb0_i,
    input wire [31:0]        bypass_lsu1_i,
    input wire [31:0]        bypass_wb1_i,

    output     [31:0]        alu0_o,
    output     [31:0]        alu1_o
     
);
    wire [31:0] bypassed_in1_0;
    wire [31:0] bypassed_in2_0;
    wire [31:0] bypassed_in1_1;
    wire [31:0] bypassed_in2_1;

    wire [31:0] alu_in1_0;
    wire [31:0] alu_in2_0;
    wire [31:0] alu_in1_1;
    wire [31:0] alu_in2_1;

    wire [9:0] alu0_func;
    wire [9:0] alu1_func;

    wire [9:0] funct7_0;
    wire [9:0] funct7_1;

    assign funct7_0 = ctrl0_i[`FUNCT7_SEL] ? inst0_i[`F7_ENC] : 0;
    assign funct7_1 = ctrl1_i[`FUNCT7_SEL] ? inst1_i[`F7_ENC] : 0;

    assign alu0_func = {funct7_0, inst0_i[`F3_ENC]};
    assign alu1_func = {funct7_1, inst1_i[`F3_ENC]};

    bypass BYPASS(
        .rs1_exec0_i        (rs1_0_i),
        .rs2_exec0_i        (rs2_0_i),
        .bypass_lsu0_i      (bypass_lsu0_i),
        .bypass_wb0_i       (bypass_wb0_i),

        .rs1_exec1_i        (rs1_1_i),
        .rs2_exec1_i        (rs2_1_i),
        .bypass_lsu1_i      (bypass_lsu1_i),
        .bypass_wb1_i       (bypass_wb1_i),

        .r0_1_i             (ctrl0_i[`RS1_ACTIVE]),
        .r0_2_i             (ctrl0_i[`RS2_ACTIVE]),
        .a0_1_i             (inst0_i[`RS1_ENC]),
        .a0_2_i             (inst0_i[`RS2_ENC]),

        .r1_1_i             (ctrl1_i[`RS1_ACTIVE]),
        .r1_2_i             (ctrl1_i[`RS2_ACTIVE]),
        .a1_1_i             (inst1_i[`RS1_ENC]),
        .a1_2_i             (inst1_i[`RS2_ENC]),

        .wm0_i              (wm0_i),
        .am0_i              (am0_i),
        .wm1_i              (wm1_i),
        .am1_i              (am1_i),

        .ww0_i              (ww0_i),
        .aw0_i              (aw0_i),
        .ww1_i              (ww1_i),
        .aw1_i              (aw1_i),

        .bypassed_in1_0_o   (bypassed_in1_0),
        .bypassed_in2_0_o   (bypassed_in2_0),
        .bypassed_in1_1_o   (bypassed_in1_1),
        .bypassed_in2_1_o   (bypassed_in2_1)
    );

    /*
    *  ALU Slot 0
    */

    alu_src_sel ALU_SRC_SEL0 (
        .bypassed_in1_i(bypassed_in1_0),
        .bypassed_in2_i(bypassed_in2_0),
        .inst_i(inst0_i),
        .ctrl_i(ctrl0_i),
        .pc_i(pc_0_i),
        .alu_in1_o(alu_in1_0),
        .alu_in2_o(alu_in2_0)
    );

    alu ALU0 (
        .A_i(alu_in1_0),
        .B_i(alu_in2_0),
        .func_i(alu0_func),
        .out(alu0_o)
    );


    /*
    *  ALU Slot 1
    */

    alu_src_sel ALU_SRC_SEL1 (
        .bypassed_in1_i(bypassed_in1_1),
        .bypassed_in2_i(bypassed_in2_1),
        .inst_i(inst1_i),
        .ctrl_i(ctrl1_i),
        .pc_i(pc_1_i),
        .alu_in1_o(alu_in1_1),
        .alu_in2_o(alu_in2_1)
    );

    alu ALU1 (
        .A_i(alu_in1_1),
        .B_i(alu_in2_1),
        .func_i(alu1_func),
        .out(alu1_o)
    );

 endmodule

 module alu_src_sel
 (
    input      [31:0]       bypassed_in1_i,
    input      [31:0]       bypassed_in2_i,
    input      [31:0]       inst_i,
    input      [`CTRL_BUS]  ctrl_i,
    input      [31:0]       pc_i,

    output reg [31:0]       alu_in1_o,
    output reg [31:0]       alu_in2_o
 );
    always @(*) begin
        case(ctrl_i[`ALU_SRC1_MUX])
            `RS1_SEL  : alu_in1_o <= bypassed_in1_i;
            `U_IMM_SEL: alu_in1_o <= {inst_i[`U_IMM_ENC], 12'b0};
            default   : alu_in1_o <= bypassed_in1_i;
        endcase

        case(ctrl_i[`ALU_SRC2_MUX])
            `RS2_SEL  : alu_in2_o <= bypassed_in2_i;
            `I_IMM_SEL: alu_in2_o <= {{20{inst_i[`I_IMM_ENC]}}, inst_i[`I_IMM_ENC]};
            `S_IMM_SEL: alu_in2_o <= {{20{`S_IMM_ENC(inst_i)}}, `S_IMM_ENC(inst_i)};
            `PC_SEL   : alu_in2_o <= pc_i;
            default   : alu_in2_o <= bypassed_in2_i;
        endcase
    end
    
 endmodule
