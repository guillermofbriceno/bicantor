`include "../defs.v"

module pipeline
(
    input  wire        clock_i,

    // f1
    input  wire [31:0] pc_f1_i,

    // f2 or imem
    output wire [09:0] iaddr_f2_o,
    input  wire [63:0] idata_f2_i,

    // decode
    output reg  [31:0] inst0_dec_o     = 0,
    output reg  [31:0] inst1_dec_o     = 0,
    input  wire [31:0] inst0_dec_i,
    input  wire [31:0] inst1_dec_i,
    input  wire [`CTRL_BUS] ctrl0_dec_i,
    input  wire [`CTRL_BUS] ctrl1_dec_i,

    // issue
    output reg  [31:0] inst0_issue_o,
    output reg  [31:0] inst1_issue_o,
    output reg  [`CTRL_BUS] ctrl0_issue_o,
    output reg  [`CTRL_BUS] ctrl1_issue_o

    // execute

    // dmem

    // wb
);

    /*
    *  F1 / F2 or MEM Buffer
    */
    reg         fetch_we = 1;
    reg  [31:0] pc_f1_r = 0;

    always @(posedge clock_i) begin
        if (fetch_we) begin
            pc_f1_r   <= pc_f1_i;
        end
    end

    assign iaddr_f2_o = pc_f1_r[09:0];

    /*
    *  F2 or MEM / Decode Buffers
    */
    reg         dec2_0_we = 1;
    reg         dec2_1_we = 1;
    reg         dec2_0_sr = 0;
    reg         dec2_1_sr = 0;

    always @(*) begin
        // Fetch Slot 0
        if (dec2_0_sr) begin
            inst0_dec_o <= 0;
        end else if (dec2_0_we) begin
            inst0_dec_o <= idata_f2_i[63:32];
        end

        // Fetch Slot 1
        if (dec2_0_sr) begin
            inst1_dec_o <= 0;
        end else if (dec2_1_we) begin
            inst1_dec_o <= idata_f2_i[31:0];
        end
    end

    /*
    *  Decode / Issue Buffers
    */
    reg         issue0_we = 1;
    reg         issue1_we = 1;
    reg         issue0_sr = 0;
    reg         issue1_sr = 0;

    always @(posedge clock_i) begin
        // Issue 0
        if (issue0_sr) begin
            inst0_issue_o    <= 0;
            ctrl0_issue_o    <= 0;
        end else if (issue0_we) begin
            inst0_issue_o    <= inst0_dec_i;
            ctrl0_issue_o    <= ctrl0_dec_i;
        end

        // Issue 1
        if (issue1_sr) begin
            inst1_issue_o    <= 0;
            ctrl1_issue_o    <= 0;
        end else if (issue1_we) begin
            inst1_issue_o    <= inst1_dec_i;
            ctrl1_issue_o    <= ctrl1_dec_i;
        end
    end

endmodule
