`include "src/defs.v"

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
        .pc_0_exec_o            (pc_0_exec_iw),
        .pc_1_exec_o            (pc_1_exec_iw),
        .rs1_data0_exec_o       (rs1_data0_exec_iw),
        .rs2_data0_exec_o       (rs2_data0_exec_iw),
        .rs1_data1_exec_o       (rs1_data1_exec_iw),
        .rs2_data1_exec_o       (rs2_data1_exec_iw),
        .alu_0_exec_i           (alu0_exec_ow),
        .alu_1_exec_i           (alu1_exec_ow),
        .exec_stall_i           (exec_stall_ow),

        // lsu
        .alu_0_lsu_o            (alu_0_lsu_iw),
        .alu_1_lsu_o            (alu_1_lsu_iw),
        .ctrl0_lsu_o            (ctrl0_lsu_iw),
        .ctrl1_lsu_o            (ctrl1_lsu_iw),
        .rd_addr_0_lsu_o        (rd_addr_0_lsu_iw),
        .rd_addr_1_lsu_o        (rd_addr_1_lsu_iw),
        .mem_stall_i            (mem_stall_ow),

        // wb
        .alu_0_wb_o             (alu_0_wb_iw),
        .alu_1_wb_o             (alu_1_wb_iw),
        .ctrl0_wb_o             (ctrl0_wb_iw),
        .ctrl1_wb_o             (ctrl1_wb_iw),
        .rd_addr_0_wb_o         (rd_addr_0_wb_iw),
        .rd_addr_1_wb_o         (rd_addr_1_wb_iw),
        .wb_stall_i             (wb_stall_ow)

    );

    wire [31:0] pc_f1_ow;
    wire        f1_pc_we_iw;

    fetch1 FETCH1(
        .clock_i                (clock_i),
        .pc_we_i                (f1_pc_we_iw),
        .pc_o                   (pc_f1_ow),
        .stall_o                (f1_stall_ow)
    );

    wire        f1_stall_ow;

    // pipe

    wire [31:0] inst0_dec_iw;
    wire [31:0] inst1_dec_iw;

    decode DECODE(
        .inst0_i                (inst0_dec_iw),
        .inst1_i                (inst1_dec_iw),

        .inst0_o                (inst0_dec_ow),
        .inst1_o                (inst1_dec_ow),
        .ctrl0_o                (ctrl0_dec_ow),
        .ctrl1_o                (ctrl1_dec_ow),
        .stall_o                (dec_stall_ow)
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

    issue ISSUE(
        .clock_i                (clock_i),

        .inst0_i                (inst0_issue_iw),
        .inst1_i                (inst1_issue_iw),
        
        .ctrl0_i                (ctrl0_issue_iw),
        .ctrl1_i                (ctrl1_issue_iw),

        .rd_addr0_i             (rd_addr_0_wb_iw),
        .rd_data0_i             (rd_data0_wb_ow),
        .rd_write0_i            (ctrl0_wb_iw[`REGWRITE]),

        .rd_addr1_i             (rd_addr_1_wb_iw),
        .rd_data1_i             (rd_data1_wb_ow),
        .rd_write1_i            (ctrl1_wb_iw[`REGWRITE]),

        .rs1_data0_o            (rs1_data0_ow),
        .rs2_data0_o            (rs2_data0_ow),

        .rs1_data1_o            (rs1_data1_ow),
        .rs2_data1_o            (rs2_data1_ow),

        .issue0_special_stall_o (issue0_special_stall_ow),
        .issue1_special_stall_o (issue1_special_stall_ow),
        .issued_ctrl0_o         (issued_ctrl0_ow),
        .issued_ctrl1_o         (issued_ctrl1_ow),
        .issued_inst0_o         (issued_inst0_ow),
        .issued_inst1_o         (issued_inst1_ow)
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
    wire [31:0] pc_0_exec_iw;
    wire [31:0] pc_1_exec_iw;
    wire [31:0] rs1_data0_exec_iw;
    wire [31:0] rs2_data0_exec_iw;
    wire [31:0] rs1_data1_exec_iw;
    wire [31:0] rs2_data1_exec_iw;

    execute EXECUTE( 
        .inst0_i                (inst0_exec_iw),
        .inst1_i                (inst1_exec_iw),
        .ctrl0_i                (ctrl0_exec_iw),
        .ctrl1_i                (ctrl1_exec_iw),
        .pc_0_i                 (pc_0_exec_iw),
        .pc_1_i                 (pc_1_exec_iw),

        .rs1_0_i                (rs1_data0_exec_iw),
        .rs2_0_i                (rs2_data0_exec_iw),
        .rs1_1_i                (rs1_data1_exec_iw),
        .rs2_1_i                (rs2_data1_exec_iw),

        .wm0_i                  (ctrl0_lsu_iw[`REGWRITE]),
        .am0_i                  (rd_addr_0_lsu_iw),
        .wm1_i                  (ctrl1_lsu_iw[`REGWRITE]),
        .am1_i                  (rd_addr_1_lsu_iw),

        .ww0_i                  (ctrl0_wb_iw[`REGWRITE]),
        .aw0_i                  (rd_addr_0_wb_iw),
        .ww1_i                  (ctrl1_wb_iw[`REGWRITE]),
        .aw1_i                  (rd_addr_1_wb_iw),

        .bypass_lsu0_i          (alu_0_lsu_iw),
        .bypass_wb0_i           (rd_data0_wb_ow),
        .bypass_lsu1_i          (alu_1_lsu_iw),
        .bypass_wb1_i           (rd_data1_wb_ow),

        .alu0_o                 (alu0_exec_ow),
        .alu1_o                 (alu1_exec_ow)
    );

    wire [31:0]         alu0_exec_ow;
    wire [31:0]         alu1_exec_ow;

    // pipe

    wire [31:0]         alu_0_lsu_iw;
    wire [31:0]         alu_1_lsu_iw;
    wire [`CTRL_BUS]    ctrl0_lsu_iw;
    wire [`CTRL_BUS]    ctrl1_lsu_iw;
    wire [4:0]          rd_addr_0_lsu_iw;
    wire [4:0]          rd_addr_1_lsu_iw;

    lsu LSU(
        .alu0_out_i (alu_0_lsu_iw),
        .alu1_out_i (alu_1_lsu_iw)
    );

    // ow

    // pipe

    wire [31:0]         alu_0_wb_iw;
    wire [31:0]         alu_1_wb_iw;
    wire [`CTRL_BUS]    ctrl0_wb_iw;
    wire [`CTRL_BUS]    ctrl1_wb_iw;
    wire [4:0]          rd_addr_0_wb_iw;
    wire [4:0]          rd_addr_1_wb_iw;

    writeback WRITEBACK(
        .alu0_out_i (alu_0_wb_iw),
        .alu1_out_i (alu_1_wb_iw),
        .rd_data0_o(rd_data0_wb_ow),
        .rd_data1_o(rd_data1_wb_ow)
    );

    wire [31:0] rd_data0_wb_ow;
    wire [31:0] rd_data1_wb_ow;

endmodule
