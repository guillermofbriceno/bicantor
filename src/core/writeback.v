module writeback
(
    input [31:0] alu0_out_i,
    input [31:0] alu1_out_i,

    output [31:0] rd_data0_o,
    output [31:0] rd_data1_o

);

    assign rd_data0_o = alu0_out_i;
    assign rd_data1_o = alu1_out_i;

endmodule
