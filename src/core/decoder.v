`include "src/defs.v"

module decoder
(
    input       [31:0]              instruction_i,
    input                           was_fetched_i,
    output reg  [`CTRL_BUS]         control_o
);
    wire [6:0] opcode_w;

    assign opcode_w = instruction_i[6:0];

    //always @(*) begin
    //    case(opcode_w)
    //        `ALUI_OP:   control_o <= `ALUI_CTRL;
    //        `ALUR_OP:   control_o <= `ALUR_CTRL;
    //        `LUI_OP :   control_o <= `LUI_CTRL;
    //        `AUIPC_OP:  control_o <= `AUIPC_CTRL;
    //        `JAL_OP:    control_o <= `JAL_CTRL;
    //        `JALR_OP:   control_o <= `JALR_CTRL;
    //        `BRANCH_OP: control_o <= `BRANCH_CTRL;
    //         default:   control_o <= was_fetched_i ? `INVALID_INST_CTRL : 0;
    //    endcase
    //end

    always @(*) begin
        casez(instruction_i)
            // LUI Type
            `INST_LUI:      control_o <= `LUI_CTRL;
            // AUIPC Type
            `INST_AUIPC:    control_o <= `AUIPC_CTRL;
            // JAL Type
            `INST_JAL:      control_o <= `JAL_CTRL;
            // JALR Type
            `INST_JALR:     control_o <= `JALR_CTRL;
            // BRANCH Type
            `INST_BEQ:      control_o <= `BRANCH_CTRL;
            `INST_BNE:      control_o <= `BRANCH_CTRL;
            `INST_BLT:      control_o <= `BRANCH_CTRL;
            `INST_BGE:      control_o <= `BRANCH_CTRL;
            `INST_BLTU:     control_o <= `BRANCH_CTRL;
            `INST_BGEU:     control_o <= `BRANCH_CTRL;
            // ALUI Type
            `INST_ADDI:     control_o <= `ALUI_CTRL;
            `INST_SLTI:     control_o <= `ALUI_CTRL;
            `INST_SLTIU:    control_o <= `ALUI_CTRL;
            `INST_XORI:     control_o <= `ALUI_CTRL;
            `INST_ORI:      control_o <= `ALUI_CTRL;
            `INST_ANDI:     control_o <= `ALUI_CTRL;
            `INST_SLLI:     control_o <= `ALUI_CTRL;
            `INST_SRLI:     control_o <= `ALUI_CTRL;
            `INST_SRAI:     control_o <= `ALUI_CTRL;
            // ALU Type
            `INST_ADD:      control_o <= `ALUR_CTRL;
            `INST_SUB:      control_o <= `ALUR_CTRL;
            `INST_SLL:      control_o <= `ALUR_CTRL;
            `INST_SLT:      control_o <= `ALUR_CTRL;
            `INST_SLTU:     control_o <= `ALUR_CTRL;
            `INST_XOR:      control_o <= `ALUR_CTRL;
            `INST_SRL:      control_o <= `ALUR_CTRL;
            `INST_SRA:      control_o <= `ALUR_CTRL;
            `INST_OR:       control_o <= `ALUR_CTRL;
            `INST_AND:      control_o <= `ALUR_CTRL;
            // Catch anything else
            default:        control_o <= was_fetched_i ? `INVALID_INST_CTRL : 0;
        endcase
    end



endmodule
