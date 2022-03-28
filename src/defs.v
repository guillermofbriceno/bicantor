`define NOP 32'b0
`define RS1_ENC 19:15
`define RS2_ENC 24:20
`define RD_ENC 11:07
`define F7_ENC 31:25
`define F3_ENC 14:12
`define U_IMM_ENC(in) {in[31:12], 12'b0}
`define I_IMM_ENC(in) {{22{in[31]}}, in[30:20]}
`define S_IMM_ENC(in) {{22{in[31]}}, in[31:25], in[11:7]}
`define B_IMM_ENC(in) {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0}
`define J_IMM_ENC(in) {{12{in[31]}}, in[19:12], in[20], in[30:25], in[24:21], 1'b0}
`define TAG_RANGE(abits) 31:(31 - (29 - abits))
`define IDX_RANGE(abits) (31 - (29 - abits) - 1):2
`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BGE 3'b101
`define BLTU 3'b110
`define BGEU 3'b111

`define TEMP2 0
`define TEMP3 1
`define TEMP4 2

`define PC_MUX 2:0
`define PC_MUX_P8 0
`define TEMP5 1
`define TEMP6 2

`define BYPASS_MUX 3:0
`define BYPASS_NONE 0
`define BYPASS_LSU0 1
`define BYPASS_LSU1 2
`define BYPASS_WB0 3
`define BYPASS_WB1 4

`define ALU_SRC1_MUX 0:0
`define U_IMM_SEL 0
`define RS1_SEL 1
`define ALU_SRC2_MUX 2:1
`define I_IMM_SEL 0
`define S_IMM_SEL 1
`define PC_SEL 2
`define RS2_SEL 3
`define WB_MUX 3:3
`define ALU_SEL 0
`define PC_P4_SEL 1
`define RS1_ACTIVE 4
`define RS2_ACTIVE 5
`define REGWRITE 6
`define COND_BRANCH 14
`define ISSUE_PRI 8
`define ISSUE_SLOT 9
`define FUNCT7_SEL 10
`define FUNCT3_SEL 11
`define JAL 12
`define JALR 13
`define ALUI_OP 7'b0010011
`define ALUI_CTRL 15'b000100001010001
`define ALUR_OP 7'b0110011
`define ALUR_CTRL 15'b000110001110111
`define LUI_OP 7'b0110111
`define LUI_CTRL 15'b000000001000110
`define AUIPC_OP 7'b0010111
`define AUIPC_CTRL 15'b000000001000100
`define JAL_OP 7'b1101111
`define JAL_CTRL 15'b001000101001000
`define JALR_OP 7'b1100111
`define JALR_CTRL 15'b010000101011001
`define BRANCH_OP 7'b1100011
`define BRANCH_CTRL 15'b100100100110111
`define CTRL_BUS 14:0

