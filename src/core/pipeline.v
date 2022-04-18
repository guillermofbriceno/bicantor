`include "src/defs.v"

module pipeline
(
    input  wire        clock_i,
    input  wire        reset_i,
    output wire        frontend_we_o,
    output reg         rst_ready_sync_o = 0,

    // f1
    input  wire [31:0] f1_pc_i,
    input  wire        f1_pred_0_i,
    input  wire        f1_pred_1_i,
    input  wire [31:0] f1_pred_tgt_0_i,
    input  wire [31:0] f1_pred_tgt_1_i,
    input  wire        f1_stall_i,

    // f2 or imem
    output wire [09:0] iaddr_f2_o,
    output wire        f2_pred_0_o,
    output reg         pred_f2_1_o = 0,
    output reg         was_fetched_0_dec_o = 0,
    output reg         was_fetched_1_dec_o = 0,
    input  wire [63:0] idata_f2_i,
    input  wire        f2_stall_i,
    input  wire        pred_f2_1_i,

    // decode
    output wire        pred_taken_0_dec_o,
    output wire        pred_taken_1_dec_o,
    output reg  [31:0] pc_dec0_o = 0,
    output reg  [31:0] pc_dec1_o = 0,
    input  wire [31:0] inst0_dec_i,
    input  wire [31:0] inst1_dec_i,
    input  wire [`CTRL_BUS] ctrl0_dec_i,
    input  wire [`CTRL_BUS] ctrl1_dec_i,
    input  wire        dec_flush_i,
    input  wire        pred_taken_1_dec_i,
    input  wire        dec_stall_i,

    // issue
    output reg  [31:0] inst0_issue_o = 0,
    output reg  [31:0] inst1_issue_o = 0,
    output reg  [`CTRL_BUS] ctrl0_issue_o = 0,
    output reg  [`CTRL_BUS] ctrl1_issue_o = 0,
    output reg         pred_0_issue_o = 0,
    output reg         pred_1_issue_o = 0,
    output reg  [31:0] pred_tgt_0_issue_o = 0,
    output reg  [31:0] pred_tgt_1_issue_o = 0,
    output reg  [31:0] pc_0_issue_o = 0,
    output reg  [31:0] pc_1_issue_o = 0,
    input  wire [31:0] issued_inst0_i,
    input  wire [31:0] issued_inst1_i,
    input  wire [`CTRL_BUS] issued_ctrl0_i,
    input  wire [`CTRL_BUS] issued_ctrl1_i,
    input  wire        issue0_special_stall_i,
    input  wire        issue1_special_stall_i,
    input  wire        issued_pred_0_i,
    input  wire        issued_pred_1_i,
    input  wire [31:0] issued_pred_tgt_0_i,
    input  wire [31:0] issued_pred_tgt_1_i,
    input  wire [31:0] issued_pc_0_i,
    input  wire [31:0] issued_pc_1_i,

    // execute
    output reg  [31:0] inst0_exec_o      = 0,
    output reg  [31:0] inst1_exec_o      = 0,
    output reg  [`CTRL_BUS] ctrl0_exec_o = 0,
    output reg  [`CTRL_BUS] ctrl1_exec_o = 0,
    output reg         pred_exec_o       = 0,
    output reg  [31:0] pred_tgt_exec_o   = 0,
    output reg  [31:0] pc_0_exec_o       = 0,
    output reg  [31:0] pc_1_exec_o       = 0,
    input  wire [31:0] alu_0_exec_i,
    input  wire [31:0] alu_1_exec_i,
    input  wire        exec_wrong_branch_i,
    input  wire        exec_stall_i,
    
    // lsu
    output reg  [31:0]      alu_0_lsu_o = 0,
    output reg  [31:0]      alu_1_lsu_o = 0,
    output reg  [`CTRL_BUS] ctrl0_lsu_o = 0,
    output reg  [`CTRL_BUS] ctrl1_lsu_o = 0,
    output reg  [4:0]       rd_addr_0_lsu_o = 0,
    output reg  [4:0]       rd_addr_1_lsu_o = 0,
    input  wire             mem_stall_i,

    // wb
    output reg  [31:0]      alu_0_wb_o = 0,
    output reg  [31:0]      alu_1_wb_o = 0,
    output reg  [`CTRL_BUS] ctrl0_wb_o = 0,
    output reg  [`CTRL_BUS] ctrl1_wb_o = 0,
    output reg  [4:0]       rd_addr_0_wb_o = 0,
    output reg  [4:0]       rd_addr_1_wb_o = 0,
    output reg  [31:0]      pc_0_wb_o = 0,
    output reg  [31:0]      pc_1_wb_o = 0,
    input  wire             wb_stall_i

`ifdef RISCV_FORMAL
   ,output reg  [`RVFI_BUS] rvfi_issue_0_o = 0
   ,output reg  [`RVFI_BUS] rvfi_issue_1_o = 0
   ,input  wire [`RVFI_BUS] rvfi_issued_0_i
   ,input  wire [`RVFI_BUS] rvfi_issued_1_i

   ,output reg  [63:0] rvfi_order_0_o = 0
   ,output reg  [63:0] rvfi_order_1_o = 0
   ,input  wire [63:0] rvfi_issued_order_0_i
   ,input  wire [63:0] rvfi_issued_order_1_i

   ,input  wire [31:0]      rvfi_pc_wdata_f1_i

   ,input  wire [63:0]      rvfi_order_dec_0_i
   ,input  wire [63:0]      rvfi_order_dec_1_i

   ,input  wire [04:0]      rvfi_rs1_a_exec_0_i
   ,input  wire [04:0]      rvfi_rs2_a_exec_0_i
   ,input  wire [04:0]      rvfi_rs1_a_exec_1_i
   ,input  wire [04:0]      rvfi_rs2_a_exec_1_i

   ,input  wire [31:0]      rvfi_rs1_d_exec_0_i
   ,input  wire [31:0]      rvfi_rs2_d_exec_0_i
   ,input  wire [31:0]      rvfi_rs1_d_exec_1_i
   ,input  wire [31:0]      rvfi_rs2_d_exec_1_i

   ,output reg  [`RVFI_BUS] rvfi_wb_0_o = 0
   ,output reg  [`RVFI_BUS] rvfi_wb_1_o = 0
`endif
);

`ifdef RISCV_FORMAL
    reg [`RVFI_BUS] rvfi_f2_0;
    reg [`RVFI_BUS] rvfi_f2_1;

    reg [`RVFI_BUS] rvfi_dec_0;
    reg [`RVFI_BUS] rvfi_dec_1;

    reg [`RVFI_BUS] rvfi_exec_0     = 0;
    reg [`RVFI_BUS] rvfi_exec_1     = 0;

    reg [`RVFI_BUS] rvfi_lsu_0      = 0;
    reg [`RVFI_BUS] rvfi_lsu_1      = 0;

    // RVFI Instruction Index/Order Generation
    wire rvfi_is_0_valid = !ctrl0_dec_i[`INVALID] && !(ctrl0_dec_i == 0);
    wire rvfi_is_1_valid = !ctrl1_dec_i[`INVALID] && !(ctrl1_dec_i == 0);
    reg [63:0] rvfi_order_counter = 0;

    // This block is synchronous, acting like a dec/issue pipeline buffer. 
    // So, the resulting values generated from decode stage should be
    // connected to issue/exec pipeline buffers.
    always @(posedge clock_i) begin
        if (frontend_we_w) begin
            case ({rvfi_is_1_valid, rvfi_is_0_valid})
                2'b01: begin
                    rvfi_order_0_o      <= rvfi_order_counter;
                    rvfi_order_1_o      <= 0;
                    rvfi_order_counter  <= rvfi_order_counter + 1;
                end
                2'b10: begin
                    rvfi_order_0_o      <= 0;
                    rvfi_order_1_o      <= rvfi_order_counter;
                    rvfi_order_counter  <= rvfi_order_counter + 1;
                end
                2'b11: begin
                    rvfi_order_0_o      <= rvfi_order_counter;
                    rvfi_order_1_o      <= rvfi_order_counter + 1;
                    rvfi_order_counter  <= rvfi_order_counter + 2;
                end default: begin
                    rvfi_order_0_o      <= 0;
                    rvfi_order_1_o      <= 0;
                    rvfi_order_counter  <= rvfi_order_counter;
                end
            endcase
        end
    end

    initial begin
        rvfi_f2_0[`RVFI_PC_WDATA] <= 32'd0;
        rvfi_f2_1[`RVFI_PC_WDATA] <= 32'd0;
        //rvfi_f2_0[`RVFI_PC_WDATA] <= 32'd8;
        //rvfi_f2_1[`RVFI_PC_WDATA] <= 32'd12;
        //rvfi_dec_0[`RVFI_PC_WDATA] <= 8;
        //rvfi_dec_1[`RVFI_PC_WDATA] <= 12;
        rvfi_dec_0 <= 0;
        rvfi_dec_1 <= 0;
    end

`endif

    wire frontend_we_w;
    wire backend_we_w;
    wire issue0_stall_w;
    wire issue1_stall_w;

    /*
    *  Stall Logic
    */
    assign issue0_stall_w = issue0_special_stall_i && backend_we_w && !exec_wrong_branch_i;
    assign issue1_stall_w = issue1_special_stall_i && backend_we_w && !exec_wrong_branch_i;

    assign backend_we_w  = ! ( f1_stall_i || f2_stall_i || dec_stall_i || exec_stall_i || mem_stall_i || wb_stall_i );
    assign frontend_we_w = ( (backend_we_w) && (!issue0_stall_w) && (!issue1_stall_w) );

    assign f1_pc_we_o = frontend_we_w;

    assign frontend_we_o = frontend_we_w;

    // Since FETCH is divided into two stages, the PC is buffered 
    // before imem sees the requested address. After reset, the
    // first inst coming out of imem is invalid, addressed by the
    // buffer before it gets updated with the real PC value. So,
    // we shouldn't allow the pipeline to buffer the first inst 
    // coming out of imem. If we don't do this, the first 
    // instruction will be duplicated after reset. Look at f2/dec.
    always @(posedge clock_i) begin
        if (reset_i)
            rst_ready_sync_o <= 0;
        else
            rst_ready_sync_o <= 1;
    end

    /*
    *  F1 / F2 or MEM Buffer
    */
    reg  [31:0] pc_f2_r = 0;
    reg         pred_f2_0 = 0;
    reg  [31:0] pred_tgt_f2_0 = 0;
    reg  [31:0] pred_tgt_f2_1 = 0;

    always @(posedge clock_i) begin
        if (reset_i) begin
            pred_f2_0     <= 0;
            pred_f2_1_o   <= 0;
            pred_tgt_f2_0 <= 0;
            pred_tgt_f2_1 <= 0;
            pc_f2_r       <= 0;
        `ifdef RISCV_FORMAL
            rvfi_f2_0[`RVFI_PC_RDATA] <= 0;
            rvfi_f2_0[`RVFI_PC_WDATA] <= 0;
            rvfi_f2_1[`RVFI_PC_RDATA] <= 0;
            rvfi_f2_1[`RVFI_PC_WDATA] <= 0;
        `endif
        end else if (frontend_we_w) begin
            pred_f2_0     <= f1_pred_0_i;
            pred_f2_1_o   <= f1_pred_1_i;
            pred_tgt_f2_0 <= f1_pred_tgt_0_i;
            pred_tgt_f2_1 <= f1_pred_tgt_1_i;
            pc_f2_r       <= f1_pc_i;
        `ifdef RISCV_FORMAL
            rvfi_f2_0[`RVFI_PC_RDATA] <= f1_pc_i;
            rvfi_f2_0[`RVFI_PC_WDATA] <= rvfi_pc_wdata_f1_i - 4;
            //rvfi_f2_1[`RVFI_PC_RDATA] <= f1_pc_i + 4;
            //rvfi_f2_1[`RVFI_PC_WDATA] <= rvfi_pc_wdata_f1_i + 4;
            rvfi_f2_1[`RVFI_PC_RDATA] <= f1_pc_i + 4;
            rvfi_f2_1[`RVFI_PC_WDATA] <= rvfi_pc_wdata_f1_i;
        `endif
        end
    end

    assign f2_pred_0_o = pred_f2_0;
    assign iaddr_f2_o = pc_f2_r[09:0];

    /*
    *  F2 / Decode Buffers
    */
    reg         pred_dec_0 = 0;
    reg         pred_dec_1 = 0;
    reg [31:0]  pred_tgt_dec_0 = 0;
    reg [31:0]  pred_tgt_dec_1 = 0;

    always @(posedge clock_i) begin
        // Fetch Slot 0
        if ((dec_flush_i && frontend_we_w) || reset_i) begin
            pred_dec_0          <= 0;
            was_fetched_0_dec_o <= 0;
        `ifdef RISCV_FORMAL
            rvfi_dec_0          <= 0;
        `endif
        end else if (frontend_we_w && rst_ready_sync_o) begin
            pc_dec0_o           <= pc_f2_r;
            pred_dec_0          <= pred_f2_0;
            pred_tgt_dec_0      <= pred_tgt_f2_0;
            was_fetched_0_dec_o <= 1;
        `ifdef RISCV_FORMAL
            rvfi_dec_0[`RVFI_PC_RDATA]  <= rvfi_f2_0[`RVFI_PC_RDATA];
            rvfi_dec_0[`RVFI_PC_WDATA]  <= rvfi_f2_0[`RVFI_PC_WDATA];
        `endif
        end

        // Fetch Slot 1
        if ((dec_flush_i && frontend_we_w) || reset_i) begin
            pred_dec_1          <= 0;
            was_fetched_1_dec_o <= 0;
        `ifdef RISCV_FORMAL
            rvfi_dec_1          <= 0;
        `endif
        end else if (frontend_we_w && rst_ready_sync_o) begin
            pc_dec1_o           <= pc_f2_r + 4;
            pred_dec_1          <= pred_f2_1_o;
            pred_tgt_dec_1      <= pred_tgt_f2_1;
            was_fetched_1_dec_o <= 1;
        `ifdef RISCV_FORMAL
            rvfi_dec_1[`RVFI_PC_RDATA]  <= rvfi_f2_1[`RVFI_PC_RDATA];
            rvfi_dec_1[`RVFI_PC_WDATA]  <= rvfi_f2_1[`RVFI_PC_WDATA];
        `endif
        end
    end

    assign pred_taken_0_dec_o = pred_dec_0;
    assign pred_taken_1_dec_o = pred_dec_1;

    /*
    *  Decode / Issue Buffers
    */
    wire issue_0_sr = issue1_stall_w || exec_wrong_branch_i;
    wire issue_1_sr = issue0_stall_w || exec_wrong_branch_i;
    wire issue_0_we = backend_we_w && !issue0_stall_w;
    wire issue_1_we = backend_we_w && !issue1_stall_w;

    always @(posedge clock_i) begin
        // Issue 0
        if (issue_0_sr || reset_i) begin
            inst0_issue_o      <= 0;
            ctrl0_issue_o      <= 0;
            pred_0_issue_o     <= 0;
            pred_tgt_0_issue_o <= 0;
        `ifdef RISCV_FORMAL
            rvfi_issue_0_o     <= 0;
        `endif
        end else if (issue_0_we) begin
            inst0_issue_o      <= inst0_dec_i;
            ctrl0_issue_o      <= ctrl0_dec_i;
            pc_0_issue_o       <= pc_dec0_o;
            pred_0_issue_o     <= pred_dec_0;
            pred_tgt_0_issue_o <= pred_tgt_dec_0;
        `ifdef RISCV_FORMAL
            //rvfi_issue_0_o     <= rvfi_f2_0;
            rvfi_issue_0_o     <= rvfi_dec_0;
        `endif
        end

        // Issue 1
        if (issue_1_sr || reset_i) begin
            inst1_issue_o      <= 0;
            ctrl1_issue_o      <= 0;
            pred_1_issue_o     <= 0;
            pred_tgt_1_issue_o <= 0;
        `ifdef RISCV_FORMAL
            rvfi_issue_1_o     <= 0;
        `endif
        end else if (issue_1_we) begin
            inst1_issue_o      <= inst1_dec_i;
            ctrl1_issue_o      <= ctrl1_dec_i;
            pc_1_issue_o       <= pc_dec1_o;
            pred_1_issue_o     <= pred_taken_1_dec_i;
            pred_tgt_1_issue_o <= pred_tgt_dec_1;
        `ifdef RISCV_FORMAL
            rvfi_issue_1_o     <= rvfi_dec_1;
        `endif
        end
    end

    /*
    *  Issue / Execute Buffers
    */
    always @(posedge clock_i) begin
        // Exec 0
        if ((issue0_stall_w || exec_wrong_branch_i) || reset_i) begin
            inst0_exec_o        <= 0;
            ctrl0_exec_o        <= 0;
            pred_exec_o         <= 0;
            pred_tgt_exec_o     <= 0;
        `ifdef RISCV_FORMAL
            rvfi_exec_0         <= 0;
        `endif
        end else if (backend_we_w) begin
            inst0_exec_o        <= issued_inst0_i;
            ctrl0_exec_o        <= issued_ctrl0_i;
            pc_0_exec_o         <= issued_pc_0_i;
            pred_exec_o         <= issued_pred_0_i;
            pred_tgt_exec_o     <= issued_pred_tgt_0_i;
        `ifdef RISCV_FORMAL
            rvfi_exec_0[`RVFI_PC_RDATA]  <= rvfi_issued_0_i[`RVFI_PC_RDATA];
            rvfi_exec_0[`RVFI_PC_WDATA]  <= rvfi_issued_0_i[`RVFI_PC_WDATA];
            rvfi_exec_0[`RVFI_ORDER]     <= rvfi_issued_order_0_i;
        `endif
        end

        // Exec 1
        if ((issue1_stall_w || exec_wrong_branch_i) || reset_i) begin
            inst1_exec_o        <= 0;
            ctrl1_exec_o        <= 0;
        `ifdef RISCV_FORMAL
            rvfi_exec_1         <= 0;
        `endif
        end else if (backend_we_w) begin
            inst1_exec_o        <= issued_inst1_i;
            ctrl1_exec_o        <= issued_ctrl1_i;
            pc_1_exec_o         <= issued_pc_1_i;
        `ifdef RISCV_FORMAL
            rvfi_exec_1[`RVFI_PC_RDATA]  <= rvfi_issued_1_i[`RVFI_PC_RDATA];
            rvfi_exec_1[`RVFI_PC_WDATA]  <= rvfi_issued_1_i[`RVFI_PC_WDATA];
            rvfi_exec_1[`RVFI_ORDER]     <= rvfi_issued_order_1_i;
        `endif
        end
   end

    /*
    *  Execute / LSU Buffers
    */
    reg [31:0] pc_0_lsu;
    reg [31:0] pc_1_lsu;
    wire       lsu_1_sr = exec_wrong_branch_i && (pc_0_exec_o < pc_1_exec_o);

    always @(posedge clock_i) begin
        // LSU 0
        if (reset_i) begin
            ctrl0_lsu_o     <= 0;
            alu_0_lsu_o     <= 0;
            rd_addr_0_lsu_o <= 0;
            pc_0_lsu        <= 0;
        `ifdef RISCV_FORMAL
            rvfi_lsu_0      <= 0;
        `endif
        end else if (backend_we_w) begin
            ctrl0_lsu_o     <= ctrl0_exec_o;
            alu_0_lsu_o     <= alu_0_exec_i;
            rd_addr_0_lsu_o <= inst0_exec_o[`RD_ENC];
            pc_0_lsu        <= pc_0_exec_o;
        `ifdef RISCV_FORMAL
            rvfi_lsu_0[`RVFI_PC_RDATA]  <= rvfi_exec_0[`RVFI_PC_RDATA];
            rvfi_lsu_0[`RVFI_PC_WDATA]  <= rvfi_exec_0[`RVFI_PC_WDATA];
            rvfi_lsu_0[`RVFI_ORDER]     <= rvfi_exec_0[`RVFI_ORDER];
            rvfi_lsu_0[`RVFI_RS1_ADDR]  <= rvfi_rs1_a_exec_0_i;
            rvfi_lsu_0[`RVFI_RS2_ADDR]  <= rvfi_rs2_a_exec_0_i;
            rvfi_lsu_0[`RVFI_RS1_DATA]  <= rvfi_rs1_d_exec_0_i;
            rvfi_lsu_0[`RVFI_RS2_DATA]  <= rvfi_rs2_d_exec_0_i;
            rvfi_lsu_0[`RVFI_INSN]      <= inst0_exec_o;
        `endif
        end

        // LSU 1
        if ((lsu_1_sr && backend_we_w) || reset_i) begin
            ctrl1_lsu_o     <= 0;
        `ifdef SIM_TEST
            alu_1_lsu_o     <= 0;
            rd_addr_1_lsu_o <= 0;
            pc_1_lsu        <= 0;
        `endif
        `ifdef RISCV_FORMAL
            rvfi_lsu_1      <= 0;
        `endif
        end else if (backend_we_w) begin
            ctrl1_lsu_o     <= ctrl1_exec_o;
            alu_1_lsu_o     <= alu_1_exec_i;
            rd_addr_1_lsu_o <= inst1_exec_o[`RD_ENC];
            pc_1_lsu        <= pc_1_exec_o;
        `ifdef RISCV_FORMAL
            rvfi_lsu_1[`RVFI_PC_RDATA]  <= rvfi_exec_1[`RVFI_PC_RDATA];
            rvfi_lsu_1[`RVFI_PC_WDATA]  <= rvfi_exec_1[`RVFI_PC_WDATA];
            rvfi_lsu_1[`RVFI_ORDER]     <= rvfi_exec_1[`RVFI_ORDER];
            rvfi_lsu_1[`RVFI_RS1_ADDR]  <= rvfi_rs1_a_exec_1_i;
            rvfi_lsu_1[`RVFI_RS2_ADDR]  <= rvfi_rs2_a_exec_1_i;
            rvfi_lsu_1[`RVFI_RS1_DATA]  <= rvfi_rs1_d_exec_1_i;
            rvfi_lsu_1[`RVFI_RS2_DATA]  <= rvfi_rs2_d_exec_1_i;
            rvfi_lsu_1[`RVFI_INSN]      <= inst1_exec_o;
        `endif
        end
   end

    /*
    *  LSU / Writeback Buffers
    */
    always @(posedge clock_i) begin
        // Exec 0
        if (reset_i) begin
            alu_0_wb_o      <= 0;
            ctrl0_wb_o      <= 0;
            rd_addr_0_wb_o  <= 0;
            pc_0_wb_o       <= 0;
        `ifdef RISCV_FORMAL
            rvfi_wb_0_o     <= 0;
        `endif
        end else if (backend_we_w) begin
            alu_0_wb_o      <= alu_0_lsu_o;
            ctrl0_wb_o      <= ctrl0_lsu_o;
            rd_addr_0_wb_o  <= rd_addr_0_lsu_o;
            pc_0_wb_o       <= pc_0_lsu;
        `ifdef RISCV_FORMAL
            rvfi_wb_0_o     <= rvfi_lsu_0;
        `endif
        end

        // Exec 1
        if (reset_i) begin
            alu_1_wb_o      <= 0;
            ctrl1_wb_o      <= 0;
            rd_addr_1_wb_o  <= 0;
            pc_1_wb_o       <= 0;
        `ifdef RISCV_FORMAL
            rvfi_wb_1_o     <= 0;
        `endif
        end else if (backend_we_w) begin
            alu_1_wb_o      <= alu_1_lsu_o;
            ctrl1_wb_o      <= ctrl1_lsu_o;
            rd_addr_1_wb_o  <= rd_addr_1_lsu_o;
            pc_1_wb_o       <= pc_1_lsu;
        `ifdef RISCV_FORMAL
            rvfi_wb_1_o     <= rvfi_lsu_1;
        `endif
        end
   end

endmodule
