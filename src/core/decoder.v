`include "../defs.v"

module decoder
(
    input       [31:0]               instruction,
    output reg  [`CTRL_BUS]          control
);

    always @(*) begin
        case(instruction[6:0])
            `ALUI_OP:   control <= `ALUI_CTRL;
            `ALUR_OP:   control <= `ALUR_CTRL;
             default:   control <= `NOP;
        endcase
    end



endmodule
