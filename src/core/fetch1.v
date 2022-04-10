`include "src/defs.v"

module fetch1
(
    input               clock_i,

    input               pc_we_i,
    input  wire [31:0]  update_pc_i,
    input  wire [31:0]  update_tgt_i,
    input  wire         last_br_i,
    input  wire         update_pht_i,
    input  wire         update_btb_i,
    input  wire         wrong_pred_i,
    input  wire [31:0]  fixed_pc_i,

    input  wire         wasnt_branch_i,
    input  wire [31:0]  wasnt_br_pc_i,

    output wire         pred_0_o,
    output wire         pred_1_o,
    output      [31:0]  pred_tgt_0_o,
    output      [31:0]  pred_tgt_1_o,
    output      [31:0]  pc_o,
    output reg          stall_o = 0

`ifdef RISCV_FORMAL
   ,output wire [31:0]  rvfi_pc_wdata_o
`endif
);
`ifdef RISCV_FORMAL
    assign rvfi_pc_wdata_o = pc_mux_out;
`endif

    // pc starts one step ahead to account for 
    // pc->imem buffer start state, where both
    // the pc and the buffer are zero at startup
    reg [31:0]      pc = 8;
    reg [31:0]      pc_mux_out = 0;
    reg [`PC_MUX]   pc_mux = `PC_MUX_P8;

    wire            btb_hit_0;
    wire            btb_hit_1;
    wire            pht_pred_0;
    wire            pht_pred_1;
    wire  [31:0]    update_pc;
    wire            update_pht;
    wire            do_fix_wasnt_branch;

    assign pred_0_o = btb_hit_0 && pht_pred_0;
    assign pred_1_o = btb_hit_1 && pht_pred_1;
    //assign update_pc = ( !wasnt_branch_i && wrong_pred_i ) ? update_pc_i : wasnt_br_pc_i;
    assign update_pc = wasnt_branch_i ? wasnt_br_pc_i : update_pc_i;
    assign do_fix_wasnt_branch = wasnt_branch_i && !wrong_pred_i;

    assign pc_o = pc;

    always @(posedge clock_i) begin
        if (pc_we_i)
            pc <= pc_mux_out;
    end

    always @(*) begin
        case({pred_0_o, pred_1_o, wrong_pred_i, wasnt_branch_i})
            4'b0000: pc_mux_out <= pc + 8;

            4'b0100: pc_mux_out <= pred_tgt_1_o;
            4'b1000: pc_mux_out <= pred_tgt_0_o;
            4'b1100: pc_mux_out <= pred_tgt_0_o;

            4'b0010: pc_mux_out <= fixed_pc_i;
            4'b0110: pc_mux_out <= fixed_pc_i;
            4'b1010: pc_mux_out <= fixed_pc_i;
            4'b1110: pc_mux_out <= fixed_pc_i;

            4'b0001: pc_mux_out <= wasnt_br_pc_i + 4;
            4'b0011: pc_mux_out <= fixed_pc_i;
            4'b0101: pc_mux_out <= wasnt_br_pc_i + 4;
            4'b0111: pc_mux_out <= fixed_pc_i;
            4'b1001: pc_mux_out <= wasnt_br_pc_i + 4;
            4'b1011: pc_mux_out <= fixed_pc_i;
            4'b1101: pc_mux_out <= wasnt_br_pc_i + 4;
            4'b1111: pc_mux_out <= fixed_pc_i;
            default: pc_mux_out <= 32'bX;
        endcase
    end

    branch_target_buffer BTB(
        .clock_i            (clock_i),
        .we_i               (pc_we_i),
        .pc_i               (pc_mux_out),
        .update_pc_i        (update_pc_i),
        .update_target_i    (update_tgt_i),
        .update_i           (update_btb_i),
        .hit_0_o            (btb_hit_0),
        .hit_1_o            (btb_hit_1),
        .target_addr_0_o    (pred_tgt_0_o),
        .target_addr_1_o    (pred_tgt_1_o)
    );

    pattern_history_table PHT(
        .clock_i            (clock_i),
        .we_i               (pc_we_i),
        .pc_i               (pc_mux_out),
        .update_pc_i        (update_pc),
        .update_i           (update_pht_i || do_fix_wasnt_branch),
        .last_br_i          (last_br_i),
        .wasnt_branch_i     (do_fix_wasnt_branch),
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
    input  wire         we_i,
    input  wire [31:0]  pc_i,
    input  wire [31:0]  update_pc_i,
    input  wire         update_i,
    input  wire         last_br_i,
    input  wire         wasnt_branch_i,

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
    wire [ABITS-1:0] wr_xored_address;
    wire             last_br;

    //assign xored_address    = pc_internal[`IDX_RANGE(ABITS)] ^ ghr;
    //assign wr_xored_address = update_pc_i[`IDX_RANGE(ABITS)] ^ ghr;
    assign xored_address    = pc_internal[`IDX_RANGE(ABITS)];
    assign wr_xored_address = update_pc_i[`IDX_RANGE(ABITS)];

    assign pred_0_o = pht[xored_address  ] > 1;
    assign pred_1_o = pht[xored_address+1] > 1;

    assign last_br = wasnt_branch_i ? 0 : last_br_i;

    integer i;
    initial begin
        for (i = 0; i < 2**ABITS; i = i + 1) begin
            pht[i]     <= 0;
        end
        // for testing
        //pht[4]     <= 3;
    end

    always @(posedge clock_i) begin
        if (we_i)
            pc_internal <= pc_i;

        if (update_i && we_i) begin
            if      (  last_br && ( $signed( (pht[wr_xored_address] + 1) ) <= 2 ) )
                pht[wr_xored_address] <= pht[wr_xored_address] + 1;
            else if ( !last_br && ( $signed( (pht[wr_xored_address] - 1) ) >= 0 ) )
                pht[wr_xored_address] <= pht[wr_xored_address] - 1;
        end

        if (update_i && !wasnt_branch_i && we_i) begin
            ghr <= {ghr[ABITS-1:0], last_br_i};
        end
    end

//    always @(posedge clock_i) begin
//        //xored_address <= pc_internal[`TAG_RANGE(ABITS)] ^ ghr;
//        xored_address <= pc_i[`IDX_RANGE(ABITS)];
//    end
    
endmodule

module branch_target_buffer
#(
    parameter ABITS = 10
)
(
    input  wire         clock_i,
    input  wire         we_i,

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
    assign hit_0_o = tag_out_0 == pc_internal[`TAG_RANGE(ABITS)];
    assign hit_1_o = tag_out_1 == pc_internal[`TAG_RANGE(ABITS)];

    integer i;
    initial begin
        for (i = 0; i < 2**ABITS; i = i + 1) begin
            tags[i]     <= 0;
            targets[i]  <= 0;
        end
        // for tesing
        //tags[4]     <= 0;
        //targets[4]  <= 100;
    end

    always @(posedge clock_i) begin
        if (we_i)
            pc_internal <= pc_i;

        if (update_i && we_i) begin
            tags[update_pc_i[`IDX_RANGE(ABITS)]]      <= update_pc_i[`TAG_RANGE(ABITS)];
            targets[update_pc_i[`IDX_RANGE(ABITS)]]   <= update_target_i;
        end
    end

endmodule
