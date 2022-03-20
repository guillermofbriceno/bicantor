module fetch2
(
    input  wire         clock_i,
    input  wire [63:0]  idata_i,
    input  wire         branch_mispred_i,
    input  wire         wasnt_branch_i,
    input  wire         bubble_1_i,

    output reg [31:0]  inst0_o,
    output reg [31:0]  inst1_o
);
    
    wire zero_0_data;
    wire zero_1_data;
    wire initial_flush;
    wire branch_flush;
    reg  second_flush = 0;

    assign branch_flush = wasnt_branch_i || branch_mispred_i;
    assign zero_0_data = branch_flush || second_flush;
    assign zero_1_data = branch_flush || second_flush || bubble_1_i;

    always @(*) begin
        if (zero_0_data)
            inst0_o <= 0;
        else
            inst0_o <= idata_i[63:32];

        if (zero_1_data)
            inst1_o <= 0;
        else
            inst1_o <= idata_i[31:0];
    end

    always @(posedge clock_i) begin
        second_flush <= branch_flush;
    end

endmodule
