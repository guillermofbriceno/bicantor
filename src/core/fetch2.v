module fetch2
(
    input  wire         clock_i,
    input  wire [63:0]  idata_i,
    input  wire         branch_mispred_i,
    input  wire         wasnt_branch_i,
    input  wire         bubble_1_i,
    input  wire         pred_0_i,
    input  wire         pred_1_i,

    output reg [31:0]  inst0_o,
    output reg [31:0]  inst1_o,
    output wire        zero_0_data_o,
    output wire        zero_1_data_o
    //output wire        pred_0_o,
    //output wire        pred_1_o
);
    
    wire initial_flush;
    wire branch_flush;
    reg  second_flush = 0;
    reg  third_flush = 0;

    assign branch_flush = wasnt_branch_i || branch_mispred_i;
    assign zero_0_data_o = branch_flush || second_flush || third_flush;
    assign zero_1_data_o = branch_flush || second_flush || third_flush || bubble_1_i;

    always @(*) begin
        if (zero_0_data_o) begin
            inst0_o     <= 0;
        end else begin
            inst0_o     <= idata_i[63:32];
        end

        if (zero_1_data_o) begin
            inst1_o <= 0;
        end else begin
            inst1_o     <= idata_i[31:0];
        end
    end

    always @(posedge clock_i) begin
        second_flush <= branch_flush;
        third_flush <= second_flush;
    end

endmodule
