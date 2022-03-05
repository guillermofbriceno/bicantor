`include "pipeline.v"
`include "fetch1.v"
`include "regfile.v"
`include "issue.v"
`include "decode.v"

module core
(
    input  wire         clock_i,
    input  wire [63:0]  data_i,

    output wire [09:0]  addr_o
);
    reg exec_stall_ow = 0; //temp
    reg f2_stall_ow   = 0; //temp
    reg mem_stall_ow  = 0; //temp
    reg wb_stall_ow   = 0; //temp
    
    pipeline PIPELINE(
        .clock_i                (clock_i),

        // f1
        .f1_pc_we_o             (f1_pc_we_iw),
        .pc_f1_i                (pc_f1_ow),
        .f1_stall_i             (f1_stall_ow),

        // f2 or imem
        .iaddr_f2_o             (addr_o),
        .idata_f2_i             (data_i),
        .f2_stall_i             (f2_stall_ow),

        // decode
        .inst0_dec_o            (inst0_dec_iw),
        .inst1_dec_o            (inst1_dec_iw),
        .inst0_dec_i            (inst0_dec_ow),
        .inst1_dec_i            (inst1_dec_ow),
        .ctrl0_dec_i            (ctrl0_dec_ow),
        .ctrl1_dec_i            (ctrl1_dec_ow),
        .dec_stall_i            (dec_stall_ow),

        // issue
        .inst0_issue_o          (inst0_issue_iw),
        .inst1_issue_o          (inst1_issue_iw),
        .ctrl0_issue_o          (ctrl0_issue_iw),
        .ctrl1_issue_o          (ctrl1_issue_iw),
        .issued_inst0_i         (issued_inst0_ow),
        .issued_inst1_i         (issued_inst1_ow),
        .issued_ctrl0_i         (issued_ctrl0_ow),
        .issued_ctrl1_i         (issued_ctrl1_ow),
        .rs1_data0_issue_i      (rs1_data0_ow),
        .rs2_data0_issue_i      (rs2_data0_ow),
        .rs1_data1_issue_i      (rs1_data1_ow),
        .rs2_data1_issue_i      (rs2_data1_ow),
        .issue0_special_stall_i (issue0_special_stall_ow),
        .issue1_special_stall_i (issue1_special_stall_ow),


        // execute
        .inst0_exec_o           (inst0_exec_iw),
        .inst1_exec_o           (inst1_exec_iw),
        .ctrl0_exec_o           (ctrl0_exec_iw),
        .ctrl1_exec_o           (ctrl1_exec_iw),
        .rs1_data0_exec_o       (rs1_data0_exec_iw),
        .rs2_data0_exec_o       (rs2_data0_exec_iw),
        .rs1_data1_exec_o       (rs1_data1_exec_iw),
        .rs2_data1_exec_o       (rs2_data1_exec_iw),
        .exec_stall_i           (exec_stall_ow),

        // dmem
        .mem_stall_i(mem_stall_ow),

        // wb
        .wb_stall_i(wb_stall_ow)

    );

    wire [31:0] pc_f1_ow;

    fetch1 FETCH1(
        .clock_i    (clock_i),
        .pc_o       (pc_f1_ow),
        .stall_o    (f1_stall_ow)
    );

    wire        f1_stall_ow;

    // pipe

    wire [31:0] inst0_dec_iw;
    wire [31:0] inst1_dec_iw;

    decode DECODE(
        .inst0_i    (inst0_dec_iw),
        .inst1_i    (inst1_dec_iw),

        .inst0_o    (inst0_dec_ow),
        .inst1_o    (inst1_dec_ow),
        .ctrl0_o    (ctrl0_dec_ow),
        .ctrl1_o    (ctrl1_dec_ow),
        .stall_o    (dec_stall_ow)
    );

    wire [31:0]      inst0_dec_ow;
    wire [31:0]      inst1_dec_ow;
    wire [`CTRL_BUS] ctrl0_dec_ow;
    wire [`CTRL_BUS] ctrl1_dec_ow;
    wire             dec_stall_ow;

    // pipe
    
    wire [31:0] inst0_issue_iw;
    wire [31:0] inst1_issue_iw;
    wire [`CTRL_BUS] ctrl0_issue_iw;
    wire [`CTRL_BUS] ctrl1_issue_iw;

    // wb input wires
    wire [04:0] rd_addr0_wb_iw;
    wire [31:0] rd_data0_wb_iw;
    wire        rd_write0_wb_iw;

    wire [04:0] rd_addr1_wb_iw;
    wire [31:0] rd_data1_wb_iw;
    wire        rd_write1_wb_iw;

    issue ISSUE(
        .clock_i    (clock_i),

        .inst0_i    (inst0_issue_iw),
        .inst1_i    (inst1_issue_iw),
        
        .ctrl0_i    (ctrl0_issue_iw),
        .ctrl1_i    (ctrl1_issue_iw),

        .rd_addr0_i (rd_addr0_wb_iw),
        .rd_data0_i (rd_data0_wb_iw),
        .rd_write0_i(rd_write0_wb_iw),

        .rd_addr1_i (rd_addr1_wb_iw),
        .rd_data1_i (rd_data1_wb_iw),
        .rd_write1_i(rd_write1_wb_iw),

        .rs1_data0_o(rs1_data0_ow),
        .rs2_data0_o(rs2_data0_ow),

        .rs1_data1_o(rs1_data1_ow),
        .rs2_data1_o(rs2_data1_ow),

        .issue0_special_stall_o(issue0_special_stall_ow),
        .issue1_special_stall_o(issue1_special_stall_ow),
        .issued_ctrl0_o(issued_ctrl0_ow),
        .issued_ctrl1_o(issued_ctrl1_ow),
        .issued_inst0_o(issued_inst0_ow),
        .issued_inst1_o(issued_inst1_ow)
    );

    wire [31:0]         rs1_data0_ow;
    wire [31:0]         rs2_data0_ow;
    wire [31:0]         rs1_data1_ow;
    wire [31:0]         rs2_data1_ow;
    wire                issue0_special_stall_ow;
    wire                issue1_special_stall_ow;
    wire [`CTRL_BUS]    issued_ctrl0_ow;
    wire [`CTRL_BUS]    issued_ctrl1_ow;
    wire [31:0]         issued_inst0_ow;
    wire [31:0]         issued_inst1_ow;


    // pipe
    wire [31:0] inst0_exec_iw;
    wire [31:0] inst1_exec_iw;
    wire [`CTRL_BUS] ctrl0_exec_iw;
    wire [`CTRL_BUS] ctrl1_exec_iw;
    wire [31:0] rs1_data0_exec_iw;
    wire [31:0] rs2_data0_exec_iw;
    wire [31:0] rs1_data1_exec_iw;
    wire [31:0] rs2_data1_exec_iw;

endmodule
