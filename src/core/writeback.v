`include "src/defs.v"

module writeback
(
    input wire  [31:0] alu0_out_i,
    input wire  [31:0] alu1_out_i,
    input wire  [31:0] pc_0_i,
    input wire  [31:0] pc_1_i,

    input wire  [`CTRL_BUS] ctrl_0_i,
    input wire  [`CTRL_BUS] ctrl_1_i,

    input wire         misaligned_branch_i,

    output wire [31:0] rd_data0_o,
    output wire [31:0] rd_data1_o,
    output wire        trap0_o,
    output wire        trap1_o

);
    reg [31:0] rd_data0 = 0;
    reg [31:0] rd_data1 = 0;

    assign rd_data0_o = ( ctrl_0_i[`REGWRITE] ) ? rd_data0 : 0;
    assign rd_data1_o = ( ctrl_1_i[`REGWRITE] ) ? rd_data1 : 0;

    assign trap0_o = ctrl_0_i[`ILLEGAL] || misaligned_branch_i;
    assign trap1_o = ctrl_1_i[`ILLEGAL];

    always @(*) begin
        case(ctrl_0_i[`WB_MUX])
            `ALU_SEL:   rd_data0 <= alu0_out_i;
            `PC_P4_SEL: rd_data0 <= pc_0_i + 4;
        endcase

        case(ctrl_1_i[`WB_MUX])
            `ALU_SEL:   rd_data1 <= alu1_out_i;
            `PC_P4_SEL: rd_data1 <= pc_1_i + 4;
        endcase
    end

endmodule
