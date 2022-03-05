`include "../defs.v"

module fetch1
(
    input               clock_i,

    input               pc_we_i,

    output      [31:0]  pc_o,
    output reg          stall_o = 0
);

    // pc starts one step ahead to account for 
    // pc->imem buffer start state, where both
    // the pc and the buffer are zero at startup
    reg [31:0]      pc = 8;
    reg [31:0]      pc_mux_out = 0;
    reg [`PC_MUX]   pc_mux = `PC_MUX_P8;

    assign pc_o = pc;

    always @(posedge clock_i) begin
        if (pc_we_i)
            pc <= pc_mux_out;
    end

    always @(*) begin
        case(pc_mux)
            `PC_MUX_P8:     pc_mux_out <= pc + 8;
            default:        pc_mux_out <= 32'bX;
        endcase
    end
endmodule
