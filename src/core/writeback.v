`include "src/defs.v"

module writeback
(
    input wire [31:0] alu0_out_i,
    input wire [31:0] alu1_out_i,
    input wire [31:0] pc_0_i,
    input wire [31:0] pc_1_i,

    input wire [`CTRL_BUS] ctrl_0_i,
    input wire [`CTRL_BUS] ctrl_1_i,

    output reg [31:0] rd_data0_o,
    output reg [31:0] rd_data1_o

);

    always @(*) begin
        case(ctrl_0_i[`WB_MUX])
            `ALU_SEL:   rd_data0_o <= alu0_out_i;
            `PC_P4_SEL: rd_data0_o <= pc_0_i + 4;
        endcase

        case(ctrl_1_i[`WB_MUX])
            `ALU_SEL:   rd_data1_o <= alu1_out_i;
            `PC_P4_SEL: rd_data1_o <= pc_1_i + 4;
        endcase
    end

endmodule
