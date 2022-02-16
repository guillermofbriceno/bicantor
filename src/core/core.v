`include "pipeline.v"
`include "fetch1.v"
`include "fetch2.v"

module core
(
    input  wire         clock_i,
    input  wire [63:0]  data_i,

    output wire [09:0]  addr_o
);

    wire [31:0] pc_w;

    wire [31:0] inst_0_w;
    wire [31:0] inst_1_w;


    pipeline PIPELINE(
        .clock_i    (clock_i),
        .pc_i       (pc_w),
        .inst_addr_o(addr_o),
        .imem_i     (data_i),
        .inst_0_o   (inst_0_w),
        .inst_1_o   (inst_1_w)
    );

    fetch1 FETCH1(
        .clock_i    (clock_i),
        .pc_o       (pc_w)
    );

    fetch2 FETCH2(
        .inst_0_i   (inst_0_w),
        .inst_1_i   (inst_1_w)
    );


endmodule
