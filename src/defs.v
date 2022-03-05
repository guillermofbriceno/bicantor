`define NOP 32'b0
`define TEMP1 32'h00001234
`define RS1_ENC 19:15
`define RS2_ENC 24:20
`define RD_ENC 11:07

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
`define RS1_ACTIVE 3
`define RS2_ACTIVE 4
`define REGWRITE 5
`define SLOT0_ONLY 6
`define COND_BRANCH 7
`define ISSUE_PRI 8
`define ISSUE_SLOT 9
`define ALUI_OP 7'b0010011
`define ALUI_CTRL 10'b0000101000
`define ALUR_OP 7'b0110011
`define ALUR_CTRL 10'b0000111001
`define LUI_OP 7'b0110111
`define LUI_CTRL 10'b0000100000
`define CTRL_BUS 9:0

