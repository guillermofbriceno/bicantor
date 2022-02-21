`include "../defs.v"

module issue
(
    input              clock_i,
    input  wire [31:0] inst0_i,
    input  wire [31:0] inst1_i,

    // might not be needed
    input  wire [`CTRL_BUS] ctrl0_i,
    input  wire [`CTRL_BUS] ctrl1_i,

    input  wire [04:0] rd_addr0_i,
    input  wire [31:0] rd_data0_i,
    input  wire        rd_write0_i,

    input  wire [04:0] rd_addr1_i,
    input  wire [31:0] rd_data1_i,
    input  wire        rd_write1_i,

    output wire [31:0] rs1_data0_o,
    output wire [31:0] rs2_data0_o,

    output wire [31:0] rs1_data1_o,
    output wire [31:0] rs2_data1_o
);


    regfile REGFILE (
        .clock_i(clock_i),

        .A_rs1_addr_i(inst0_i[19:15]),
        .A_rs2_addr_i(inst0_i[24:20]),
        .A_rd_addr_i(rd_addr0_i),
        .A_rd_data_i(rd_data0_i),
        .A_rd_write_i(rd_write0_i),

        .B_rs1_addr_i(inst1_i[19:15]),
        .B_rs2_addr_i(inst1_i[24:20]),
        .B_rd_addr_i(rd_addr1_i),
        .B_rd_data_i(rd_data1_i),
        .B_rd_write_i(rd_write1_i),

        .A_rs1_data_o(rs1_data0_o),
        .A_rs2_data_o(rs2_data0_o),

        .B_rs1_data_o(rs1_data1_o),
        .B_rs2_data_o(rs2_data1_o)
    );

endmodule
