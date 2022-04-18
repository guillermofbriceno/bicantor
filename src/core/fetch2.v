module fetch2
(
    input  wire         clock_i,
    input  wire         reset_i,
    input  wire [63:0]  idata_i,
    input  wire         branch_mispred_i,
    input  wire         wasnt_branch_i,
    input  wire         zero_1_i,
    input  wire         pred_1_i,

    output reg [31:0]  inst0_o      = 0,
    output reg [31:0]  inst1_o      = 0,
    output reg         pred_1_o     = 0,
    output wire        branch_flush_o
);
    reg  second_flush = 0;

    assign branch_flush_o = second_flush || wasnt_branch_i || branch_mispred_i;

    always @(*) begin
        if (reset_i) begin
            inst0_o <= 0;
        end else begin
            inst0_o <= idata_i[63:32];
        end

        if (zero_1_i || reset_i) begin
            inst1_o  <= 0;
            //pred_1_o <= 0;
        end else begin
            inst1_o  <= idata_i[31:0];
            //pred_1_o <= pred_1_i;
        end
    end

    always @(posedge clock_i) begin
        second_flush <= (wasnt_branch_i || branch_mispred_i);
    end

endmodule
