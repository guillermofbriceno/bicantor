`include "src/defs.v"

module decoder
(
    input       [31:0]               instruction_i,
    output reg  [`CTRL_BUS]          control_o
);
    wire [6:0] opcode_w;

    assign opcode_w = instruction_i[6:0];

    always @(*) begin
        case(opcode_w)
            `ALUI_OP:   control_o <= `ALUI_CTRL;
            `ALUR_OP:   control_o <= `ALUR_CTRL;
            `LUI_OP :   control_o <= `LUI_CTRL;
            `AUIPC_OP:  control_o <= `AUIPC_CTRL;
            `JAL_OP:    control_o <= `JAL_CTRL;
            `JALR_OP:   control_o <= `JALR_CTRL;
            `BRANCH_OP: control_o <= `BRANCH_CTRL;
             default:   control_o <= `NOP;
        endcase
    end



endmodule
