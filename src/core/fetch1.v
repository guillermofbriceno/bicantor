`include "src/defs.v"

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

module pattern_history_table
#(
    parameter ABITS = 10
)
(
    input  wire         clock_i,
    input  wire [31:0]  pc_i,
    input  wire [31:0]  update_pc_i,
    input  wire         update_i,
    input  wire         last_br_i,

    output wire         pred_0_o,
    output wire         pred_1_o

);
    // 32 (XLEN) - 2 (last two uneeded bits) - ABITS = tag width
    localparam tag_width    = 29 - ABITS; // 21 if ABITS = 8
    localparam idx_start = 31 - tag_width - 1; // 9 if ABITS = 8

    reg  [1:0] pht [ABITS-1:0];
    reg        ghr [ABITS-1:0] = 0;

    reg  [31:0] pc_internal = 0;

    wire [ABITS-1:0] xored_address;

    assign xored_address    = pc_internal[`TAG_RANGE(ABITS)] ^ ghr;
    assign wr_xored_address = update_pc_i[`TAG_RANGE(ABITS)] ^ ghr;

    assign pred_0_o = pht[xored_address  ] > 1;
    assign pred_1_o = pht[xored_address+1] > 1;

    always @(posedge clock_i) begin
        pc_internal <= pc_i;
        if (update_i) begin
            pht <= (pht << 1) || {{ABITS{0}}, last_br_i};
            if      (  last_br_i && ( (pht[wr_xored_address] + 1) <= 2 ) )
                pht[wr_xored_address] <= pht[wr_xored_address] + 1;
            else if ( !last_br_i && ( (pht[wr_xored_address] - 1) >= 0 ) )
                pht[wr_xored_address] <= pht[wr_xored_address] - 1;
        end
    end
    
endmodule

module branch_target_buffer
#(
    parameter ABITS = 10
)
(
    input  wire         clock_i,

    input  wire [31:0]  pc_i,
    input  wire [31:0]  new_pc_i,
    input  wire [31:0]  new_target_i,
    input  wire         update_i,

    output wire         hit_0_o,
    output wire         hit_1_o,
    output wire [31:0]  target_addr_0_o,
    output wire [31:0]  target_addr_1_o
);
    // 32 (XLEN) - 2 (last two uneeded bits) - ABITS = tag width
    localparam tag_width    = 29 - ABITS; // 21 if ABITS = 8
    localparam idx_start = 31 - tag_width - 1; // 9 if ABITS = 8

    reg [tag_width-1:0]   tags    [ABITS-1:0];
    reg [31:0]            targets [ABITS-1:0];

    reg [31:0]   pc_internal = 0;

    wire [tag_width-1:0] tag_out_0;
    wire [tag_width-1:0] tag_out_1;

    // Read tags and targets
    assign target_addr_0_o  = targets[pc_internal[`IDX_RANGE(ABITS)]];
    assign target_addr_1_o  = targets[pc_internal[`IDX_RANGE(ABITS)] + 1];
    assign tag_out_0        = tags[pc_internal[`IDX_RANGE(ABITS)]];
    assign tag_out_1        = tags[pc_internal[`IDX_RANGE(ABITS)] + 1];

    // Internal Logic
    assign hit_0_o = tag_out_0 == pc_i[`TAG_RANGE(ABITS)];
    assign hit_1_o = tag_out_1 == pc_i[`TAG_RANGE(ABITS)];

    always @(posedge clock_i) begin
        pc_internal <= pc_i;

        if (update_i) begin
            tags[new_pc_i[`IDX_RANGE(ABITS)]]      <= new_pc_i[`TAG_RANGE(ABITS)];
            targets[new_pc_i[`IDX_RANGE(ABITS)]]   <= new_target_i;
        end
    end

endmodule
