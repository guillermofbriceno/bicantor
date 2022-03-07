module alu
(
    input      [31:0] A_i,
    input      [31:0] B_i,
    input      [09:0] func_i,

    output reg [31:0] out
);
    always @(*) begin
        case(func_i)
            10'b0000000_000: out <= A_i +   B_i;        // ADD
            10'b0100000_000: out <= A_i -   B_i;        // SUB
            10'b0000000_001: out <= A_i <<  B_i[4:0];   // SL Logical
            10'b0000000_100: out <= A_i ^   B_i;        // XOR
            10'b0000000_101: out <= A_i >>  B_i[4:0];   // SR Logical
            10'b0100000_101: out <= A_i >>> B_i[4:0];   // SR Arith
            10'b0000000_110: out <= A_i |   B_i;        // OR
            10'b0000000_111: out <= A_i &   B_i;        // AND
            default        : out <= 0;
        endcase
    end


endmodule
