module bypass
(
    input       [31:0]  rs1_exec0_i,
    input       [31:0]  rs2_exec0_i,
    input       [31:0]  bypass_lsu0_i,
    input       [31:0]  bypass_wb0_i,

    input       [31:0]  rs1_exec1_i,
    input       [31:0]  rs2_exec1_i,
    input       [31:0]  bypass_lsu1_i,
    input       [31:0]  bypass_wb1_i,
    
    input               r0_1_i,
    input               r0_2_i,
    input       [04:0]  a0_1_i,
    input       [04:0]  a0_2_i,

    input               r1_1_i,
    input               r1_2_i,
    input       [04:0]  a1_1_i,
    input       [04:0]  a1_2_i,

    input               wm0_i,
    input       [04:0]  am0_i,

    input               wm1_i,
    input       [04:0]  am1_i,

    input               ww0_i,
    input       [04:0]  aw0_i,

    input               ww1_i,
    input       [04:0]  aw1_i,
    
    output reg  [31:0]  bypassed_in1_0_o = 0,
    output reg  [31:0]  bypassed_in2_0_o = 0,
    output reg  [31:0]  bypassed_in1_1_o = 0,
    output reg  [31:0]  bypassed_in2_1_o = 0

);

    always @(*) begin
        // mux0_src1
        if          (!r0_1_i)
            bypassed_in1_0_o <= rs1_exec0_i;
        else if (wm0_i && (a0_1_i == am0_i) && (am0_i != 0))
            bypassed_in1_0_o <= bypass_lsu0_i;
        else if (ww0_i && (a0_1_i == aw0_i) && (aw0_i != 0))
            bypassed_in1_0_o <= bypass_wb0_i;
        else if (wm1_i && (a0_1_i == am1_i) && (am1_i != 0))
            bypassed_in1_0_o <= bypass_lsu1_i;
        else if (ww1_i && (a0_1_i == aw1_i) && (aw1_i != 0))
            bypassed_in1_0_o <= bypass_wb1_i;
        else
            bypassed_in1_0_o <= rs1_exec0_i;

        // mux0_src2
        if          (!r0_2_i)
            bypassed_in2_0_o <= rs2_exec0_i;
        else if (wm0_i && (a0_2_i == am0_i) && (am0_i != 0))
            bypassed_in2_0_o <= bypass_lsu0_i;
        else if (ww0_i && (a0_2_i == aw0_i) && (aw0_i != 0))
            bypassed_in2_0_o <= bypass_wb0_i;
        else if (wm1_i && (a0_2_i == am1_i) && (am1_i != 0))
            bypassed_in2_0_o <= bypass_lsu1_i;
        else if (ww1_i && (a0_2_i == aw1_i) && (aw1_i != 0))
            bypassed_in2_0_o <= bypass_wb1_i;
        else
            bypassed_in2_0_o <= rs2_exec0_i;

        // mux1_src1
        if          (!r1_1_i)
            bypassed_in1_1_o <= rs1_exec1_i;
        else if (wm0_i && (a1_1_i == am0_i) && (am0_i != 0))
            bypassed_in1_1_o <= bypass_lsu0_i;
        else if (ww0_i && (a1_1_i == aw0_i) && (aw0_i != 0))
            bypassed_in1_1_o <= bypass_wb0_i;
        else if (wm1_i && (a1_1_i == am1_i) && (am1_i != 0))
            bypassed_in1_1_o <= bypass_lsu1_i;
        else if (ww1_i && (a1_1_i == aw1_i) && (aw1_i != 0))
            bypassed_in1_1_o <= bypass_wb1_i;
        else
            bypassed_in1_1_o <= rs1_exec1_i;

        // mux1_src2
        if          (!r1_2_i)
            bypassed_in2_1_o <= rs2_exec1_i;
        else if (wm0_i && (a1_2_i == am0_i) && (am0_i != 0))
            bypassed_in2_1_o <= bypass_lsu0_i;
        else if (ww0_i && (a1_2_i == aw0_i) && (aw0_i != 0))
            bypassed_in2_1_o <= bypass_wb0_i;
        else if (wm1_i && (a1_2_i == am1_i) && (am1_i != 0))
            bypassed_in2_1_o <= bypass_lsu1_i;
        else if (ww1_i && (a1_2_i == aw1_i) && (aw1_i != 0))
            bypassed_in2_1_o <= bypass_wb1_i;
        else
            bypassed_in2_1_o <= rs2_exec1_i;
    end

endmodule
