`include "src/defs.v"

module fetch1
(
    input               clock_i,

    input               pc_we_i,

    input  wire [31:0]  update_pc_i,
    input  wire [31:0]  update_tgt_i,
    input  wire         last_br_i,

    output      [31:0]  pc_o,
    output reg          stall_o = 0
);

    // pc starts one step ahead to account for 
    // pc->imem buffer start state, where both
    // the pc and the buffer are zero at startup
    reg [31:0]      pc = 8;
    reg [31:0]      pc_mux_out = 0;
    reg [`PC_MUX]   pc_mux = `PC_MUX_P8;

    reg             update_pht;
    reg             update_btb;
    wire            btb_hit_0;
    wire            btb_hit_1;
    wire [31:0]     target_0;
    wire [31:0]     target_1;
    wire            pht_pred_0;
    wire            pht_pred_1;
    wire            take_pred_0;
    wire            take_pred_1;

    assign take_pred_0 = btb_hit_0 && pht_pred_0;
    assign take_pred_1 = btb_hit_1 && pht_pred_1;

    assign pc_o = pc;

    always @(posedge clock_i) begin
        if (pc_we_i)
            pc <= pc_mux_out;
    end

    always @(*) begin
        case({take_pred_0, take_pred_1})
            2'b00:      pc_mux_out <= pc + 8;
            2'b01:      pc_mux_out <= target_1;
            2'b10:      pc_mux_out <= target_0;
            2'b11:      pc_mux_out <= target_0;
            default:    pc_mux_out <= 32'bX;
        endcase
    end

    branch_target_buffer BTB(
        .clock_i            (clock_i),
        .pc_i               (pc_mux_out),
        .update_pc_i        (update_pc_i),
        .update_target_i    (update_tgt_i),
        .update_i           (update_btb),
        .hit_0_o            (btb_hit_0),
        .hit_1_o            (btb_hit_1),
        .target_addr_0_o    (target_0),
        .target_addr_1_o    (target_1)
    );

    pattern_history_table PHT(
        .clock_i            (clock_i),
        .pc_i               (pc_mux_out),
        .update_pc_i        (update_pc_i),
        .update_i           (update_pht),
        .last_br_i          (last_br_i),
        .pred_0_o           (pht_pred_0),
        .pred_1_o           (pht_pred_1)
    );

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

    reg  [1:0]          pht [2**ABITS:0];
    reg  [ABITS-1:0]    ghr         = 0;

    reg  [31:0] pc_internal = 0;

    wire [ABITS-1:0] xored_address;

    assign xored_address    = pc_internal[`TAG_RANGE(ABITS)] ^ ghr;
    assign wr_xored_address = update_pc_i[`TAG_RANGE(ABITS)] ^ ghr;

    assign pred_0_o = pht[xored_address  ] > 1;
    assign pred_1_o = pht[xored_address+1] > 1;

    integer i;
    initial begin
        for (i = 0; i < 2**ABITS; i = i + 1) begin
            pht[i]     <= 0;
        end
    end

    always @(posedge clock_i) begin
        pc_internal <= pc_i;
        if (update_i) begin
            ghr <= (ghr << 1) || last_br_i;
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
    input  wire [31:0]  update_pc_i,
    input  wire [31:0]  update_target_i,
    input  wire         update_i,

    output wire         hit_0_o,
    output wire         hit_1_o,
    output wire [31:0]  target_addr_0_o,
    output wire [31:0]  target_addr_1_o
);
    // 32 (XLEN) - 2 (last two uneeded bits) - ABITS = tag width
    localparam tag_width    = 29 - ABITS; // 21 if ABITS = 8
    localparam idx_start = 31 - tag_width - 1; // 9 if ABITS = 8

    reg [tag_width-1:0]   tags    [2**ABITS:0];
    reg [31:0]            targets [2**ABITS:0];

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

    integer i;
    initial begin
        for (i = 0; i < 2**ABITS; i = i + 1) begin
            tags[i]     <= 0;
            targets[i]  <= 0;
        end
    end

    always @(posedge clock_i) begin
        pc_internal <= pc_i;

        if (update_i) begin
            tags[update_pc_i[`IDX_RANGE(ABITS)]]      <= update_pc_i[`TAG_RANGE(ABITS)];
            targets[update_pc_i[`IDX_RANGE(ABITS)]]   <= update_target_i;
        end
    end

endmodule
