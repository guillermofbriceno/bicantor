`include "src/defs.v"

module decoder
(
    input       [31:0]              instruction_i,
    input                           was_fetched_i,
    output wire [`CTRL_BUS]         control_o
);
    wire [6:0] opcode_w;
    reg [`CTRL_BUS] precheck_control;
    reg [`CTRL_BUS] postcheck_control;

    assign control_o = was_fetched_i ? postcheck_control : 0;

    always @(*) begin
        casez(instruction_i)
            // LUI Type
            `INST_LUI:      precheck_control <= `LUI_CTRL;
            // AUIPC Type
            `INST_AUIPC:    precheck_control <= `AUIPC_CTRL;
            // JAL Type
            `INST_JAL:      precheck_control <= `JAL_CTRL;
            // JALR Type
            `INST_JALR:     precheck_control <= `JALR_CTRL;
            // BRANCH Type
            `INST_BEQ:      precheck_control <= `BRANCH_CTRL;
            `INST_BNE:      precheck_control <= `BRANCH_CTRL;
            `INST_BLT:      precheck_control <= `BRANCH_CTRL;
            `INST_BGE:      precheck_control <= `BRANCH_CTRL;
            `INST_BLTU:     precheck_control <= `BRANCH_CTRL;
            `INST_BGEU:     precheck_control <= `BRANCH_CTRL;
            // ALUI Type
            `INST_ADDI:     precheck_control <= `ALUI_CTRL;
            `INST_SLTI:     precheck_control <= `ALUI_CTRL;
            `INST_SLTIU:    precheck_control <= `ALUI_CTRL;
            `INST_XORI:     precheck_control <= `ALUI_CTRL;
            `INST_ORI:      precheck_control <= `ALUI_CTRL;
            `INST_ANDI:     precheck_control <= `ALUI_CTRL;
            `INST_SLLI:     precheck_control <= `ALUI_CTRL;
            `INST_SRLI:     precheck_control <= `ALUI_CTRL;
            `INST_SRAI:     precheck_control <= `ALUI_CTRL;
            // ALU Type
            `INST_ADD:      precheck_control <= `ALUR_CTRL;
            `INST_SUB:      precheck_control <= `ALUR_CTRL;
            `INST_SLL:      precheck_control <= `ALUR_CTRL;
            `INST_SLT:      precheck_control <= `ALUR_CTRL;
            `INST_SLTU:     precheck_control <= `ALUR_CTRL;
            `INST_XOR:      precheck_control <= `ALUR_CTRL;
            `INST_SRL:      precheck_control <= `ALUR_CTRL;
            `INST_SRA:      precheck_control <= `ALUR_CTRL;
            `INST_OR:       precheck_control <= `ALUR_CTRL;
            `INST_AND:      precheck_control <= `ALUR_CTRL;
            // Catch anything else
            default:        precheck_control <= `INVALID_INST_CTRL;
        endcase

        if (   precheck_control[`REGWRITE]     && 
              (instruction_i[`RD_ENC]  == 0)   && 
             !(precheck_control == `JALR_CTRL) &&
             !(precheck_control == `JAL_CTRL )   )
            postcheck_control <= `INVALID_INST_CTRL;
        else
            postcheck_control <= precheck_control;

//        if ( precheck_control[`REGWRITE]    &&
//            (instruction_i[`RD_ENC] == 0)  &&
//            (precheck_control[`RS1_ACTIVE] && (instruction_i[`])))
            
    end



endmodule
