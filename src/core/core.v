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


    pipeline PIPELINE(
        .clock_i    (clock_i),

        // f1
        .pc_f1_i (pc_f1_ow),

        // f2 or imem
        .iaddr_f2_o(addr_o),

        .idata_f2_i(data_i),

        // decode
        .inst0_dec_o   (inst0_dec_iw),
        .inst1_dec_o   (inst1_dec_iw),

        .inst0_dec_i(inst0_dec_ow),
        .inst1_dec_i(inst1_dec_ow),
        .ctrl0_dec_i(ctrl0_dec_ow),
        .ctrl1_dec_i(ctrl1_dec_ow),

        // issue
        .inst0_issue_o(inst0_issue_iw),
        .inst1_issue_o(inst1_issue_iw),
        .ctrl0_issue_o(ctrl0_issue_iw),
        .ctrl1_issue_o(ctrl1_issue_iw)

        // execute

        // dmem

        // wb

    );

    wire [31:0] pc_f1_ow;

    fetch1 FETCH1(
        .clock_i    (clock_i),
        .pc_o       (pc_f1_ow)
    );

    // pipe

    wire [31:0] inst0_dec_iw;
    wire [31:0] inst1_dec_iw;

    decode DECODE(
        .inst0_i    (inst0_dec_iw),
        .inst1_i    (inst1_dec_iw),

        .inst0_o    (inst0_dec_ow),
        .inst1_o    (inst1_dec_ow),
        .ctrl0_o    (ctrl0_dec_ow),
        .ctrl1_o    (ctrl1_dec_ow)
    );

    wire [31:0]      inst0_dec_ow;
    wire [31:0]      inst1_dec_ow;
    wire [`CTRL_BUS] ctrl0_dec_ow;
    wire [`CTRL_BUS] ctrl1_dec_ow;

    // pipe
    
    wire [31:0] inst0_issue_iw;
    wire [31:0] inst1_issue_iw;

    wire [`CTRL_BUS] ctrl0_issue_iw;
    wire [`CTRL_BUS] ctrl1_issue_iw;
    
    wire [31:0] rs1_data0_iw;
    wire [31:0] rs2_data0_iw;
    wire [31:0] rs1_data1_iw;
    wire [31:0] rs2_data1_iw;

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
        .rs2_data1_o(rs2_data1_ow)
    );

    wire [31:0] rs1_data0_ow;
    wire [31:0] rs2_data0_ow;
    wire [31:0] rs1_data1_ow;
    wire [31:0] rs2_data1_ow;

    // pipe
    


endmodule
