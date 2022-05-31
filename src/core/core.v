`include "src/defs.v"
`include "src/core/riscv-formal.v"

module core
(
    input  wire         clock_i,
    input  wire [63:0]  data_i,
    input  wire         reset_i,

    output wire [09:0]  addr_o,
    output wire         imemstall_o,
    output wire         imem_sr_o,

    output wire [09:0]  data_addr0_o,
    output wire [09:0]  data_addr_o

`ifdef RISCV_FORMAL
    `BICANTOR_RVFI_IO
`endif
);
`ifdef RISCV_FORMAL
    wire [`RVFI_BUS] rvfi_issue_0_iw;
    wire [`RVFI_BUS] rvfi_issue_1_iw;
    wire [`RVFI_BUS] rvfi_issued_0_ow;
    wire [`RVFI_BUS] rvfi_issued_1_ow;

    wire [63:0] rvfi_order_0_iw;
    wire [63:0] rvfi_order_1_iw;
    wire [63:0] rvfi_issued_order_0_ow;
    wire [63:0] rvfi_issued_order_1_ow;

    wire [31:0] rvfi_pc_wdata_f1_ow;

    wire [04:0] rvfi_rs1_a_exec_0_ow;
    wire [04:0] rvfi_rs2_a_exec_0_ow;
    wire [04:0] rvfi_rs1_a_exec_1_ow;
    wire [04:0] rvfi_rs2_a_exec_1_ow;

    wire [31:0] rvfi_rs1_d_exec_0_ow;
    wire [31:0] rvfi_rs2_d_exec_0_ow;
    wire [31:0] rvfi_rs1_d_exec_1_ow;
    wire [31:0] rvfi_rs2_d_exec_1_ow;

    wire [`RVFI_BUS] rvfi_wb_0;
    wire [`RVFI_BUS] rvfi_wb_1;
    
    `BICANTOR_RVFI_DRIVER
`endif


    reg exec_stall_ow = 0; //temp
    reg f2_stall_ow   = 0; //temp
    reg mem_stall_ow  = 0; //temp
    reg wb_stall_ow   = 0; //temp

    wire frontend_we;
    wire rst_ready_sync;
    assign imemstall_o = frontend_we;
    assign imem_sr_o = f2_flush_ow || !rst_ready_sync || reset_i;
    
    pipeline PIPELINE(
        .clock_i                (clock_i),
        .reset_i                (reset_i),
        .frontend_we_o          (frontend_we),
        .rst_ready_sync_o       (rst_ready_sync),

        // f1
        .f1_pc_i                (f1_pc_ow),
        .f1_pred_0_i            (f1_pred_0_ow),
        .f1_pred_1_i            (f1_pred_1_ow),
        .f1_pred_tgt_0_i        (f1_pred_tgt_0_ow),
        .f1_pred_tgt_1_i        (f1_pred_tgt_1_ow),
        .f1_stall_i             (f1_stall_ow),

        // f2 or imem
        .iaddr_f2_o             (addr_o),
        .f2_pred_0_o            (f2_pred_0_iw),
        .pred_f2_1_o            (f2_pred_1_iw),
        .idata_f2_i             (data_i),
        .pred_f2_1_i            (f2_pred_1_ow),
        .f2_stall_i             (f2_stall_ow),

        // decode
        .pred_taken_0_dec_o     (pred_taken_0_dec_iw),
        .pred_taken_1_dec_o     (pred_taken_1_dec_iw),
        .pc_dec0_o              (pc_dec_0_iw),
        .pc_dec1_o              (pc_dec_1_iw),
        .was_fetched_0_dec_o    (was_fetched_0_dec_iw),
        .was_fetched_1_dec_o    (was_fetched_1_dec_iw),
        .inst0_dec_i            (inst0_dec_ow),
        .inst1_dec_i            (inst1_dec_ow),
        .ctrl0_dec_i            (ctrl0_dec_ow),
        .ctrl1_dec_i            (ctrl1_dec_ow),
        .wasnt_branch_dec_i     (wasnt_branch_ow),
        .dec_flush_i            (f2_flush_ow),
        .dec_stall_i            (dec_stall_ow),
        .pred_taken_1_dec_i     (pred_taken_1_dec_ow),
        .misaligned_branch_exec_i(misaligned_branch_exec_ow),

        // issue
        .inst0_issue_o          (inst0_issue_iw),
        .inst1_issue_o          (inst1_issue_iw),
        .ctrl0_issue_o          (ctrl0_issue_iw),
        .ctrl1_issue_o          (ctrl1_issue_iw),
        .pred_0_issue_o         (pred_0_issue_iw),
        .pred_1_issue_o         (pred_1_issue_iw),
        .pred_tgt_0_issue_o     (pred_tgt_0_issue_iw),
        .pred_tgt_1_issue_o     (pred_tgt_1_issue_iw),
        .pc_0_issue_o           (pc_0_issue_iw),
        .pc_1_issue_o           (pc_1_issue_iw),
        .issued_inst0_i         (issued_inst0_ow),
        .issued_inst1_i         (issued_inst1_ow),
        .issued_ctrl0_i         (issued_ctrl0_ow),
        .issued_ctrl1_i         (issued_ctrl1_ow),
        .issue0_special_stall_i (issue0_special_stall_ow),
        .issue1_special_stall_i (issue1_special_stall_ow),
        .issued_pred_0_i        (issued_pred_0_ow),
        .issued_pred_1_i        (issued_pred_1_ow),
        .issued_pred_tgt_0_i    (issued_pred_tgt_0_ow),
        .issued_pred_tgt_1_i    (issued_pred_tgt_1_ow),
        .issued_pc_0_i          (issued_pc_0_ow),
        .issued_pc_1_i          (issued_pc_1_ow),

        // execute
        .inst0_exec_o           (inst0_exec_iw),
        .inst1_exec_o           (inst1_exec_iw),
        .ctrl0_exec_o           (ctrl0_exec_iw),
        .ctrl1_exec_o           (ctrl1_exec_iw),
        .pred_tgt_exec_o        (pred_tgt_exec_iw),
        .pred_exec_o            (pred_taken_exec_iw),
        .pc_0_exec_o            (pc_0_exec_iw),
        .pc_1_exec_o            (pc_1_exec_iw),
        .alu_0_exec_i           (alu0_exec_ow),
        .alu_1_exec_i           (alu1_exec_ow),
        .exec_wrong_branch_i    (wrong_pred_exec_ow),
        .exec_stall_i           (exec_stall_ow),

        // lsu
        .alu_0_lsu_o            (alu_0_lsu_iw),
        .alu_1_lsu_o            (alu_1_lsu_iw),
        .ctrl0_lsu_o            (ctrl0_lsu_iw),
        .ctrl1_lsu_o            (ctrl1_lsu_iw),
        .rd_addr_0_lsu_o        (rd_addr_0_lsu_iw),
        .rd_addr_1_lsu_o        (rd_addr_1_lsu_iw),
        .misaligned_branch_lsu_o(misaligned_branch_lsu_iw),
        .mem_stall_i            (mem_stall_ow),

        // wb
        .alu_0_wb_o             (alu_0_wb_iw),
        .alu_1_wb_o             (alu_1_wb_iw),
        .ctrl0_wb_o             (ctrl0_wb_iw),
        .ctrl1_wb_o             (ctrl1_wb_iw),
        .rd_addr_0_wb_o         (rd_addr_0_wb_iw),
        .rd_addr_1_wb_o         (rd_addr_1_wb_iw),
        .pc_0_wb_o              (pc_0_wb_iw),
        .pc_1_wb_o              (pc_1_wb_iw),
        .misaligned_branch_wb_o (misaligned_branch_wb_iw),
        .wb_stall_i             (wb_stall_ow)

    `ifdef RISCV_FORMAL
        ,.rvfi_issue_0_o        (rvfi_issue_0_iw)
        ,.rvfi_issue_1_o        (rvfi_issue_1_iw)
        ,.rvfi_issued_0_i       (rvfi_issued_0_ow)
        ,.rvfi_issued_1_i       (rvfi_issued_1_ow)

        ,.rvfi_order_0_o        (rvfi_order_0_iw)
        ,.rvfi_order_1_o        (rvfi_order_1_iw)
        ,.rvfi_issued_order_0_i (rvfi_issued_order_0_ow)
        ,.rvfi_issued_order_1_i (rvfi_issued_order_1_ow)

        ,.rvfi_pc_wdata_f1_i    (rvfi_pc_wdata_f1_ow)

        ,.rvfi_rs1_a_exec_0_i   (rvfi_rs1_a_exec_0_ow)
        ,.rvfi_rs2_a_exec_0_i   (rvfi_rs2_a_exec_0_ow)
        ,.rvfi_rs1_a_exec_1_i   (rvfi_rs1_a_exec_1_ow)
        ,.rvfi_rs2_a_exec_1_i   (rvfi_rs2_a_exec_1_ow)

        ,.rvfi_rs1_d_exec_0_i   (rvfi_rs1_d_exec_0_ow)
        ,.rvfi_rs2_d_exec_0_i   (rvfi_rs2_d_exec_0_ow)
        ,.rvfi_rs1_d_exec_1_i   (rvfi_rs1_d_exec_1_ow)
        ,.rvfi_rs2_d_exec_1_i   (rvfi_rs2_d_exec_1_ow)

        ,.rvfi_wb_0_o           (rvfi_wb_0)
        ,.rvfi_wb_1_o           (rvfi_wb_1)
    `endif

    );



    fetch1 FETCH1(
        .clock_i                (clock_i),
        .reset_i                (reset_i),
        .pc_we_i                (frontend_we),
        .update_pc_i            (pc_0_exec_iw),
        .update_tgt_i           (corr_tgt_exec_ow),
        .last_br_i              (corr_taken_exec_ow),
        .update_pht_i           (update_pht_exec_ow),
        .update_btb_i           (update_btb_exec_ow),
        .wrong_pred_i           (wrong_pred_exec_ow),
        .fixed_pc_i             (fixed_pc_ow),
        .wasnt_branch_i         (wasnt_branch_ow),
        .wasnt_br_pc_i          (fixed_pc_dec_ow),

        .pred_0_o               (f1_pred_0_ow),
        .pred_1_o               (f1_pred_1_ow),
        .pred_tgt_0_o           (f1_pred_tgt_0_ow),
        .pred_tgt_1_o           (f1_pred_tgt_1_ow),
        .pc_o                   (f1_pc_ow),
        .stall_o                (f1_stall_ow)
`ifdef RISCV_FORMAL
       ,.rvfi_pc_wdata_o        (rvfi_pc_wdata_f1_ow)
`endif
    );

    wire [31:0] f1_pc_ow;
    wire        f1_stall_ow;
    wire [31:0] f1_pred_tgt_0_ow;
    wire [31:0] f1_pred_tgt_1_ow;
    wire        f1_pred_0_ow;
    wire        f1_pred_1_ow;


    // pipe

    wire        f2_pred_0_iw;
    wire        f2_pred_1_iw;

    fetch2 FETCH2(
        .clock_i                (clock_i),
        .reset_i                (reset_i || !rst_ready_sync),
        .frontend_we_i          (frontend_we),
        .idata_i                (data_i),
        .branch_mispred_i       (wrong_pred_exec_ow),
        .wasnt_branch_i         (wasnt_branch_ow),
        .zero_1_i               (pred_taken_0_dec_iw),
        .pred_1_i               (f2_pred_1_iw),

        .inst0_o                (f2_inst0_ow),
        .inst1_o                (f2_inst1_ow),
        .pred_1_o               (f2_pred_1_ow),
        .branch_flush_o         (f2_flush_ow)
    );

    wire [31:0] f2_inst0_ow;
    wire [31:0] f2_inst1_ow;
    wire        f2_pred_1_ow;
    wire        f2_flush_ow;

    // pipe

    // inst-ins not pipelined because imemory is read synchronous
    wire        pred_taken_0_dec_iw;
    wire        pred_taken_1_dec_iw;
    wire [31:0] pc_dec_0_iw;
    wire [31:0] pc_dec_1_iw;
    wire        was_fetched_0_dec_iw;
    wire        was_fetched_1_dec_iw;

    decode DECODE(
        .clock_i                (clock_i),
        .we_i                   (frontend_we),
        .inst0_i                (f2_inst0_ow),
        .inst1_i                (f2_inst1_ow),
        .pred_taken_0_i         (pred_taken_0_dec_iw),
        .pred_taken_1_i         (pred_taken_1_dec_iw),
        .pc_0_i                 (pc_dec_0_iw),
        .pc_1_i                 (pc_dec_1_iw),
        .was_fetched_0_i        (was_fetched_0_dec_iw),
        .was_fetched_1_i        (was_fetched_1_dec_iw),

        .inst0_o                (inst0_dec_ow),
        .inst1_o                (inst1_dec_ow),
        .ctrl0_o                (ctrl0_dec_ow),
        .ctrl1_o                (ctrl1_dec_ow),
        .wasnt_branch_o         (wasnt_branch_ow),
        .fixed_pc_o             (fixed_pc_dec_ow),
        .pred_taken_1_o         (pred_taken_1_dec_ow),
        .stall_o                (dec_stall_ow)
    );

    wire [31:0]      inst0_dec_ow;
    wire [31:0]      inst1_dec_ow;
    wire [`CTRL_BUS] ctrl0_dec_ow;
    wire [`CTRL_BUS] ctrl1_dec_ow;
    wire             dec_stall_ow;
    wire             wasnt_branch_ow;
    wire [31:0]      fixed_pc_dec_ow;
    wire             pred_taken_1_dec_ow;

    // pipe
    
    wire [31:0] inst0_issue_iw;
    wire [31:0] inst1_issue_iw;
    wire [`CTRL_BUS] ctrl0_issue_iw;
    wire [`CTRL_BUS] ctrl1_issue_iw;
    wire        pred_0_issue_iw;
    wire        pred_1_issue_iw;
    wire [31:0] pred_tgt_0_issue_iw;
    wire [31:0] pred_tgt_1_issue_iw;
    wire [31:0] pc_0_issue_iw;
    wire [31:0] pc_1_issue_iw;

    issue ISSUE(
        .clock_i                (clock_i),

        .inst0_i                (inst0_issue_iw),
        .inst1_i                (inst1_issue_iw),
        .pred_0_i               (pred_0_issue_iw),
        .pred_1_i               (pred_1_issue_iw),
        .pred_tgt_0_i           (pred_tgt_0_issue_iw),
        .pred_tgt_1_i           (pred_tgt_1_issue_iw),
        
        .ctrl0_i                (ctrl0_issue_iw),
        .ctrl1_i                (ctrl1_issue_iw),

        .rd_addr0_i             (rd_addr_0_wb_iw),
        .rd_data0_i             (rd_data0_wb_ow),
        .rd_write0_i            (ctrl0_wb_iw[`REGWRITE] && !misaligned_branch_wb_iw),

        .rd_addr1_i             (rd_addr_1_wb_iw),
        .rd_data1_i             (rd_data1_wb_ow),
        .rd_write1_i            (ctrl1_wb_iw[`REGWRITE]),

        .pc_0_i                 (pc_0_issue_iw),
        .pc_1_i                 (pc_1_issue_iw),

        .rs1_data0_o            (rs1_data0_exec_iw),
        .rs2_data0_o            (rs2_data0_exec_iw),
        .rs1_data1_o            (rs1_data1_exec_iw),
        .rs2_data1_o            (rs2_data1_exec_iw),

        .issue0_special_stall_o (issue0_special_stall_ow),
        .issue1_special_stall_o (issue1_special_stall_ow),
        .issued_ctrl0_o         (issued_ctrl0_ow),
        .issued_ctrl1_o         (issued_ctrl1_ow),
        .issued_inst0_o         (issued_inst0_ow),
        .issued_inst1_o         (issued_inst1_ow),
        .issued_pred_0_o        (issued_pred_0_ow),
        .issued_pred_1_o        (issued_pred_1_ow),
        .issued_pred_tgt_0_o    (issued_pred_tgt_0_ow),
        .issued_pred_tgt_1_o    (issued_pred_tgt_1_ow),
        .issued_pc_0_o          (issued_pc_0_ow),
        .issued_pc_1_o          (issued_pc_1_ow)
    `ifdef RISCV_FORMAL
       ,.rvfi_0_i               (rvfi_issue_0_iw)
       ,.rvfi_1_i               (rvfi_issue_1_iw)
       ,.rvfi_issued_0_o        (rvfi_issued_0_ow)
       ,.rvfi_issued_1_o        (rvfi_issued_1_ow)

       ,.rvfi_order_0_i         (rvfi_order_0_iw)
       ,.rvfi_order_1_i         (rvfi_order_1_iw)
       ,.rvfi_issued_order_0_o  (rvfi_issued_order_0_ow)
       ,.rvfi_issued_order_1_o  (rvfi_issued_order_1_ow)
    `endif
    );

    wire                issue0_special_stall_ow;
    wire                issue1_special_stall_ow;
    wire [`CTRL_BUS]    issued_ctrl0_ow;
    wire [`CTRL_BUS]    issued_ctrl1_ow;
    wire [31:0]         issued_inst0_ow;
    wire [31:0]         issued_inst1_ow;
    wire                issued_pred_0_ow;
    wire                issued_pred_1_ow;
    wire [31:0]         issued_pred_tgt_0_ow;
    wire [31:0]         issued_pred_tgt_1_ow;
    wire [31:0]         issued_pc_0_ow;
    wire [31:0]         issued_pc_1_ow;

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
    wire [31:0] pred_tgt_exec_iw;
    wire        pred_taken_exec_iw;

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

        .wm0_i                  (ctrl0_lsu_iw[`REGWRITE] && !misaligned_branch_lsu_iw),
        .am0_i                  (rd_addr_0_lsu_iw),
        .wm1_i                  (ctrl1_lsu_iw[`REGWRITE]),
        .am1_i                  (rd_addr_1_lsu_iw),

        .ww0_i                  (ctrl0_wb_iw[`REGWRITE] && !misaligned_branch_wb_iw),
        .aw0_i                  (rd_addr_0_wb_iw),
        .ww1_i                  (ctrl1_wb_iw[`REGWRITE]),
        .aw1_i                  (rd_addr_1_wb_iw),

        .bypass_lsu0_i          (alu_0_lsu_iw),
        .bypass_wb0_i           (rd_data0_wb_ow),
        .bypass_lsu1_i          (alu_1_lsu_iw),
        .bypass_wb1_i           (rd_data1_wb_ow),

        .pred_tgt_i             (pred_tgt_exec_iw),
        .pred_taken_i           (pred_taken_exec_iw),

        .alu0_o                 (alu0_exec_ow),
        .alu1_o                 (alu1_exec_ow),

        .update_pht_o           (update_pht_exec_ow),
        .update_btb_o           (update_btb_exec_ow),
        .corr_tgt_o             (corr_tgt_exec_ow),
        .corr_taken_o           (corr_taken_exec_ow),
        .wrong_pred_o           (wrong_pred_exec_ow),
        .fixed_pc_o             (fixed_pc_ow),
        .misaligned_branch_o    (misaligned_branch_exec_ow)

    `ifdef RISCV_FORMAL
        ,.rvfi_rs1_addr_0_o     (rvfi_rs1_a_exec_0_ow)
        ,.rvfi_rs2_addr_0_o     (rvfi_rs2_a_exec_0_ow)
        ,.rvfi_rs1_addr_1_o     (rvfi_rs1_a_exec_1_ow)
        ,.rvfi_rs2_addr_1_o     (rvfi_rs2_a_exec_1_ow)
        
        ,.rvfi_rs1_data_0_o     (rvfi_rs1_d_exec_0_ow)
        ,.rvfi_rs2_data_0_o     (rvfi_rs2_d_exec_0_ow)
        ,.rvfi_rs1_data_1_o     (rvfi_rs1_d_exec_1_ow)
        ,.rvfi_rs2_data_1_o     (rvfi_rs2_d_exec_1_ow)
    `endif
    );

    wire [31:0]         alu0_exec_ow;
    wire [31:0]         alu1_exec_ow;
    wire [31:0]         corr_tgt_exec_ow;
    wire                corr_taken_exec_ow;
    wire                wrong_pred_exec_ow;
    wire [31:0]         fixed_pc_ow;
    wire                update_pht_exec_ow;
    wire                update_btb_exec_ow;
    wire                misaligned_branch_exec_ow;

    // pipe

    wire [31:0]         alu_0_lsu_iw;
    wire [31:0]         alu_1_lsu_iw;
    wire [`CTRL_BUS]    ctrl0_lsu_iw;
    wire [`CTRL_BUS]    ctrl1_lsu_iw;
    wire [4:0]          rd_addr_0_lsu_iw;
    wire [4:0]          rd_addr_1_lsu_iw;
    wire                misaligned_branch_lsu_iw;

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
    wire [31:0]         pc_0_wb_iw;
    wire [31:0]         pc_1_wb_iw;
    wire                misaligned_branch_wb_iw;

    writeback WRITEBACK(
        .alu0_out_i (alu_0_wb_iw),
        .alu1_out_i (alu_1_wb_iw),
        .pc_0_i     (pc_0_wb_iw),
        .pc_1_i     (pc_1_wb_iw),
        .ctrl_0_i   (ctrl0_wb_iw),
        .ctrl_1_i   (ctrl1_wb_iw),
        .misaligned_branch_i (misaligned_branch_wb_iw),
        .rd_data0_o (rd_data0_wb_ow),
        .rd_data1_o (rd_data1_wb_ow),
        .trap0_o    (trap0_wb_ow),
        .trap1_o    (trap1_wb_ow)
    );

    wire [31:0] rd_data0_wb_ow;
    wire [31:0] rd_data1_wb_ow;
    wire        trap0_wb_ow;
    wire        trap1_wb_ow;

endmodule
