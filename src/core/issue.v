`include "src/defs.v"

module issue
(
    input              clock_i,

    input  wire [31:0] inst0_i,
    input  wire [31:0] inst1_i,
    input  wire [`CTRL_BUS] ctrl0_i,
    input  wire [`CTRL_BUS] ctrl1_i,
    input  wire             pred_0_i,
    input  wire             pred_1_i,
    input  wire [31:0]      pred_tgt_0_i,
    input  wire [31:0]      pred_tgt_1_i,

    input  wire [04:0] rd_addr0_i,
    input  wire [31:0] rd_data0_i,
    input  wire        rd_write0_i,

    input  wire [04:0] rd_addr1_i,
    input  wire [31:0] rd_data1_i,
    input  wire        rd_write1_i,

    input  wire [31:0] pc_0_i,
    input  wire [31:0] pc_1_i,

    output wire [31:0] rs1_data0_o,
    output wire [31:0] rs2_data0_o,

    output wire [31:0] rs1_data1_o,
    output wire [31:0] rs2_data1_o,

    output wire        issue0_special_stall_o,
    output wire        issue1_special_stall_o,

    output  wire [`CTRL_BUS] issued_ctrl0_o,
    output  wire [`CTRL_BUS] issued_ctrl1_o,
    output  wire [31:0]      issued_inst0_o,
    output  wire [31:0]      issued_inst1_o,
    output  wire             issued_pred_0_o,
    output  wire             issued_pred_1_o,
    output  wire [31:0]      issued_pred_tgt_0_o,
    output  wire [31:0]      issued_pred_tgt_1_o,
    output  wire [31:0]      issued_pc_0_o,
    output  wire [31:0]      issued_pc_1_o

`ifdef RISCV_FORMAL
   ,input   wire [`RVFI_BUS] rvfi_0_i
   ,input   wire [`RVFI_BUS] rvfi_1_i
   ,output  wire [`RVFI_BUS] rvfi_issued_0_o
   ,output  wire [`RVFI_BUS] rvfi_issued_1_o

   ,input   wire [63:0] rvfi_order_0_i
   ,input   wire [63:0] rvfi_order_1_i
   ,output  wire [63:0] rvfi_issued_order_0_o
   ,output  wire [63:0] rvfi_issued_order_1_o
`endif
);

    wire                    issue0_sw_req;
    wire                    issue1_sw_req;
    wire                    issue0_dnsw_req;
    wire                    issue1_dnsw_req;
    wire                    switch;
    wire                    inst_dep;

    /*
    *  Issue Logic
    */
    assign inst_dep =   ( (inst1_i[`RS1_ENC] == inst0_i[`RD_ENC])   &&
                          (ctrl1_i[`RS1_ACTIVE]                 )   &&
                          (inst1_i[`RS1_ENC] != 0               )   ||
                          (inst1_i[`RS2_ENC] == inst0_i[`RD_ENC])   &&
                          (ctrl1_i[`RS2_ACTIVE]                 )   &&
                          (inst1_i[`RS2_ENC] != 0               ) ) &&
                          (ctrl0_i[`REGWRITE] == 1              );
    
    assign issue0_sw_req    = ctrl0_i[`ISSUE_PRI] && (ctrl0_i[`ISSUE_SLOT] == 1);
    assign issue0_dnsw_req  = ctrl0_i[`ISSUE_PRI] && (ctrl0_i[`ISSUE_SLOT] == 0);

    assign issue1_sw_req    = ctrl1_i[`ISSUE_PRI] && (ctrl1_i[`ISSUE_SLOT] == 0);
    assign issue1_dnsw_req  = ctrl1_i[`ISSUE_PRI] && (ctrl1_i[`ISSUE_SLOT] == 1);

    assign issue0_special_stall_o = 0;
    assign issue1_special_stall_o = inst_dep || (issue1_dnsw_req && issue0_dnsw_req) || (issue0_dnsw_req && issue1_sw_req);

    assign switch = issue0_sw_req || (!issue0_dnsw_req && issue1_sw_req && !inst_dep);
    
    assign issued_inst0_o      = (switch) ? inst1_i     : inst0_i;
    assign issued_inst1_o      = (switch) ? inst0_i     : inst1_i;
    assign issued_ctrl0_o      = (switch) ? ctrl1_i     : ctrl0_i;
    assign issued_ctrl1_o      = (switch) ? ctrl0_i     : ctrl1_i;
    assign issued_pred_0_o     = (switch) ? pred_1_i    : pred_0_i;
    assign issued_pred_1_o     = (switch) ? pred_0_i    : pred_1_i;
    assign issued_pred_tgt_0_o = (switch) ? pred_tgt_1_i: pred_tgt_0_i;
    assign issued_pred_tgt_1_o = (switch) ? pred_tgt_0_i: pred_tgt_1_i;
    assign issued_pc_0_o       = (switch) ? pc_1_i      : pc_0_i;
    assign issued_pc_1_o       = (switch) ? pc_0_i      : pc_1_i;
`ifdef RISCV_FORMAL
    assign rvfi_issued_0_o     = (switch) ? rvfi_1_i    : rvfi_0_i;
    assign rvfi_issued_1_o     = (switch) ? rvfi_0_i    : rvfi_1_i;
    assign rvfi_issued_order_0_o = (switch) ? rvfi_order_1_i : rvfi_order_0_i;
    assign rvfi_issued_order_1_o = (switch) ? rvfi_order_0_i : rvfi_order_1_i;
`endif



    regfile REGFILE (
        .clock_i(clock_i),

        .A_rs1_addr_i   ( (issued_ctrl0_o[`ALU_SRC1_MUX] == `RS1_SEL) ? issued_inst0_o[`RS1_ENC] : 5'b0 ),
        .A_rs2_addr_i   ( (issued_ctrl0_o[`ALU_SRC2_MUX] == `RS2_SEL) ? issued_inst0_o[`RS2_ENC] : 5'b0 ),
        .A_rd_addr_i    (rd_addr0_i),
        .A_rd_data_i    (rd_data0_i),
        .A_rd_write_i   (rd_write0_i),

        .B_rs1_addr_i   ( (issued_ctrl1_o[`ALU_SRC1_MUX] == `RS1_SEL) ? issued_inst1_o[`RS1_ENC] : 5'b0 ),
        .B_rs2_addr_i   ( (issued_ctrl1_o[`ALU_SRC2_MUX] == `RS2_SEL) ? issued_inst1_o[`RS2_ENC] : 5'b0 ),
        .B_rd_addr_i    (rd_addr1_i),
        .B_rd_data_i    (rd_data1_i),
        .B_rd_write_i   (rd_write1_i),

        .A_rs1_data_o   (rs1_data0_o),
        .A_rs2_data_o   (rs2_data0_o),

        .B_rs1_data_o   (rs1_data1_o),
        .B_rs2_data_o   (rs2_data1_o)
    );

endmodule
