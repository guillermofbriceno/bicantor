`include "../defs.v"

module fetch1
(
    input clock_i,

    output [31:0] pc_o
);

    reg [31:0]      pc = 0;
    reg [31:0]      pc_mux_out;
    reg [`PC_MUX]   pc_mux = `PC_MUX_P8;

    assign pc_o = pc;

    always @(posedge clock_i) begin
        pc <= pc_mux_out;
    end

    always @(*) begin
        case(pc_mux)
            `PC_MUX_P8:     pc_mux_out <= pc + 8;
            default:        pc_mux_out <= 32'bX;
        endcase
    end
endmodule
