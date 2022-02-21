module bypass
(
    input           r0_1,
    input           r0_2,
    input [04:0]    a0_1,
    input [04:0]    a0_2,

    input           r1_1,
    input           r1_2,
    input [04:0]    a1_1,
    input [04:0]    a1_2

    input           wm0
    input [04:0]    am0

    input           wm1
    input [04:0]    am1

    input           ww0
    input [04:0]    aw0

    input           ww1
    input [04:0]    aw1


    output [`BYPASS_MUX] mux0_src1;
    output [`BYPASS_MUX] mux0_src2;
    output [`BYPASS_MUX] mux1_src1;
    output [`BYPASS_MUX] mux1_src2;

);

    reg [`BYPASS_MUX] mux0_src1_r;
    reg [`BYPASS_MUX] mux0_src2_r;
    reg [`BYPASS_MUX] mux1_src1_r;
    reg [`BYPASS_MUX] mux1_src2_r;

    assign mux0_src1 = r0_1 ? mux0_src1_r : 0;
    assign mux0_src2 = r0_2 ? mux0_src2_r : 0;
    assign mux1_src1 = r1_1 ? mux1_src1_r : 0;
    assign mux1_src2 = r1_2 ? mux1_src2_r : 0;

    always @(*) begin
        // mux0_src1
        if          (wm0 & (a0_1 == am0) & (am0 != 0))
            mux0_src1_r <= `BYPASS_LSU0;
        end else if (ww0 & (a0_1 == aw0) & (aw0 != 0))
            mux0_src1_r <= `BYPASS_WB0;
        end else if (wm1 & (a0_1 == am1) & (am1 != 0))
            mux0_src1_r <= `BYPASS_LSU1;
        end else if (ww1 & (a0_1 == aw1) & (aw1 != 0))
            mux0_src1_r <= `BYPASS_WB1;
        end else
            mux0_src1_r <= `BYPASS_NONE;
        end

        // mux0_src2
        if          (wm0 & (a0_2 == am0) & (am0 != 0))
            mux0_src2_r <= `BYPASS_LSU0;
        end else if (ww0 & (a0_2 == aw0) & (aw0 != 0))
            mux0_src2_r <= `BYPASS_WB0;
        end else if (wm1 & (a0_2 == am1) & (am1 != 0))
            mux0_src2_r <= `BYPASS_LSU1;
        end else if (ww1 & (a0_2 == aw1) & (aw1 != 0))
            mux0_src2_r <= `BYPASS_WB1;
        end else
            mux0_src2_r <= `BYPASS_NONE;
        end

        // mux1_src1
        if          (wm0 & (a1_1 == am0) & (am0 != 0))
            mux1_src1_r <= `BYPASS_LSU0;
        end else if (ww0 & (a1_1 == aw0) & (aw0 != 0))
            mux1_src1_r <= `BYPASS_WB0;
        end else if (wm1 & (a1_1 == am1) & (am1 != 0))
            mux1_src1_r <= `BYPASS_LSU1;
        end else if (ww1 & (a1_1 == aw1) & (aw1 != 0))
            mux1_src1_r <= `BYPASS_WB1;
        end else
            mux1_src1_r <= `BYPASS_NONE;
        end

        // mux1_src2
        if          (wm0 & (a1_2 == am0) & (am0 != 0))
            mux1_src2_r <= `BYPASS_LSU0;
        end else if (ww0 & (a1_2 == aw0) & (aw0 != 0))
            mux1_src2_r <= `BYPASS_WB0;
        end else if (wm1 & (a1_2 == am1) & (am1 != 0))
            mux1_src2_r <= `BYPASS_LSU1;
        end else if (ww1 & (a1_2 == aw1) & (aw1 != 0))
            mux1_src2_r <= `BYPASS_WB1;
        end else
            mux1_src2_r <= `BYPASS_NONE;
        end
    end

endmodule
