`include "fetch1.v"

module core
(
    input  wire         clock_i,
    input  wire [63:0]  data_i,

    output wire [09:0]  addr_o
);

    wire [31:0] pc_w;

    assign addr_o = pc_w[09:0];

    fetch1 FETCH1 (
        .clock_i(clock_i),
        .pc_o(pc_w)
    );

endmodule
