`include "../defs.v"

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
             default:   control_o <= `NOP;
        endcase
    end



endmodule
