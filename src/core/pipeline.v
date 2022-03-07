`include "src/defs.v"

module pipeline
(
    input  wire        clock_i,

    // f1
    output wire        f1_pc_we_o,
    input  wire [31:0] pc_f1_i,
    input  wire        f1_stall_i,

    // f2 or imem
    output wire [09:0] iaddr_f2_o,
    input  wire [63:0] idata_f2_i,
    input  wire        f2_stall_i,

    // decode
    output reg  [31:0] inst0_dec_o     = 0,
    output reg  [31:0] inst1_dec_o     = 0,
    input  wire [31:0] inst0_dec_i,
    input  wire [31:0] inst1_dec_i,
    input  wire [`CTRL_BUS] ctrl0_dec_i,
    input  wire [`CTRL_BUS] ctrl1_dec_i,
    input  wire        dec_stall_i,

    // issue
    output reg  [31:0] inst0_issue_o,
    output reg  [31:0] inst1_issue_o,
    output reg  [`CTRL_BUS] ctrl0_issue_o,
    output reg  [`CTRL_BUS] ctrl1_issue_o,
    input  wire [31:0] issued_inst0_i,
    input  wire [31:0] issued_inst1_i,
    input  wire [`CTRL_BUS] issued_ctrl0_i,
    input  wire [`CTRL_BUS] issued_ctrl1_i,
    input  wire [31:0] rs1_data0_issue_i,
    input  wire [31:0] rs2_data0_issue_i,
    input  wire [31:0] rs1_data1_issue_i,
    input  wire [31:0] rs2_data1_issue_i,
    input  wire        issue0_special_stall_i,
    input  wire        issue1_special_stall_i,

    // execute
    output reg  [31:0] inst0_exec_o,
    output reg  [31:0] inst1_exec_o,
    output reg  [`CTRL_BUS] ctrl0_exec_o,
    output reg  [`CTRL_BUS] ctrl1_exec_o,
    output reg  [31:0] pc_0_exec_o,
    output reg  [31:0] pc_1_exec_o,
    output reg  [31:0] rs1_data0_exec_o,
    output reg  [31:0] rs2_data0_exec_o,
    output reg  [31:0] rs1_data1_exec_o,
    output reg  [31:0] rs2_data1_exec_o,
    input  wire [31:0] alu_0_exec_i,
    input  wire [31:0] alu_1_exec_i,
    input  wire        exec_stall_i,
    
    // lsu
    output reg  [31:0]      alu_0_lsu_o,
    output reg  [31:0]      alu_1_lsu_o,
    output reg  [`CTRL_BUS] ctrl0_lsu_o,
    output reg  [`CTRL_BUS] ctrl1_lsu_o,
    output reg  [4:0]       rd_addr_0_lsu_o,
    output reg  [4:0]       rd_addr_1_lsu_o,

    input  wire        mem_stall_i,

    // wb
    output reg  [31:0] rd_data_0_lsu_o,
    output reg  [31:0] rd_data_1_lsu_o,
    input  wire [31:0] rd_data_0_lsu_i,
    input  wire [31:0] rd_data_1_lsu_i,
    input  wire        wb_stall_i
);
    wire frontend_we_w;
    wire backend_we_w;
    wire issue0_stall_w;
    wire issue1_stall_w;

    /*
    *  Stall Logic
    */
    assign issue0_stall_w = issue0_special_stall_i && backend_we_w;
    assign issue1_stall_w = issue1_special_stall_i && backend_we_w;

    assign backend_we_w  = ! ( f1_stall_i || f2_stall_i || dec_stall_i || exec_stall_i || mem_stall_i || wb_stall_i );
    assign frontend_we_w = ( (backend_we_w) && (!issue0_stall_w) && (!issue1_stall_w) );

    assign f1_pc_we_o = frontend_we_w;

    /*
    *  F1 / F2 or MEM Buffer
    */
    reg  [31:0] pc_f2_r = 0;

    always @(posedge clock_i) begin
        if (frontend_we_w) begin
            pc_f2_r   <= pc_f1_i;
        end
    end

    assign iaddr_f2_o = pc_f2_r[09:0];

    /*
    *  F2 or MEM / Decode Buffers
    */
    reg         dec0_sr = 0;
    reg         dec1_sr = 0;

    always @(*) begin
        // Fetch Slot 0
        if (dec0_sr) begin
            inst0_dec_o <= 0;
        end else if (frontend_we_w) begin
            inst0_dec_o <= idata_f2_i[63:32];
        end

        // Fetch Slot 1
        if (dec0_sr) begin
            inst1_dec_o <= 0;
        end else if (frontend_we_w) begin
            inst1_dec_o <= idata_f2_i[31:0];
        end
    end

    /*
    *  Decode / Issue Buffers
    */
    always @(posedge clock_i) begin
        // Issue 0
        if (issue1_stall_w) begin
            inst0_issue_o    <= 0;
            ctrl0_issue_o    <= 0;
        end else if (backend_we_w && !issue0_stall_w) begin
            inst0_issue_o    <= inst0_dec_i;
            ctrl0_issue_o    <= ctrl0_dec_i;
        end

        // Issue 1
        if (issue0_stall_w) begin
            inst1_issue_o    <= 0;
            ctrl1_issue_o    <= 0;
        end else if (backend_we_w && !issue1_stall_w) begin
            inst1_issue_o    <= inst1_dec_i;
            ctrl1_issue_o    <= ctrl1_dec_i;
        end
    end

    /*
    *  Issue / Execute Buffers
    */
   always @(posedge clock_i) begin
        // Exec 0
        if (issue0_stall_w) begin
            inst0_exec_o        <= 0;
            ctrl0_exec_o        <= 0;
            rs1_data0_exec_o    <= 0;
            rs2_data0_exec_o    <= 0;
        end else if (backend_we_w) begin
            inst0_exec_o        <= issued_inst0_i;
            ctrl0_exec_o        <= issued_ctrl0_i;
            rs1_data0_exec_o    <= rs1_data0_issue_i;
            rs2_data0_exec_o    <= rs2_data0_issue_i;
        end

        // Exec 1
        if (issue1_stall_w) begin
            inst1_exec_o        <= 0;
            ctrl1_exec_o        <= 0;
            rs1_data1_exec_o    <= 0;
            rs2_data1_exec_o    <= 0;
        end else if (backend_we_w) begin
            inst1_exec_o        <= issued_inst1_i;
            ctrl1_exec_o        <= issued_ctrl1_i;
            rs1_data1_exec_o    <= rs1_data1_issue_i;
            rs2_data1_exec_o    <= rs2_data1_issue_i;
        end
   end

    /*
    *  Execute / LSU Buffers
    */
    reg         regwrite_0_lsu;
    reg [4:0]   rd_addr_0_lsu;
    reg         regwrite_1_lsu;
    reg [4:0]   rd_addr_1_lsu;

   always @(posedge clock_i) begin
        // Exec 0
        if (0) begin
        end else if (backend_we_w) begin
            alu_0_lsu_o <= alu_0_exec_i;
            ctrl0_lsu_o <= ctrl0_exec_o;
            rd_addr_0_lsu_o <= inst0_exec_o[`RD_ENC];
        end

        // Exec 1
        if (0) begin
        end else if (backend_we_w) begin
            alu_1_lsu_o <= alu_1_exec_i;
            ctrl1_lsu_o <= ctrl1_exec_o;
            rd_addr_1_lsu_o <= inst1_exec_o[`RD_ENC];
        end
   end

endmodule
