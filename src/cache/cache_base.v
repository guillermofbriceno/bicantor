module cache_base
#(
    parameter           ADDR_WIDTH = 8,
    parameter           BLOCK_SIZE = 16, // In Bytes
    parameter           SETS = 2
)
(
    input                           clk_i,

    input                           rx_we_i,
    input                           rx_re_i,
    output reg                      rx_ready_o = 1,
    input       [31:0]              rx_addr_i,
    input       [1:0]               rx_width_i,
    output reg  [BLOCK_SIZE*8-1:0]  rx_rdata_o = 0,
    input       [BLOCK_SIZE*8-1:0]  rx_wdata_o,

    output reg                      tx_we_o = 0,
    output reg                      tx_re_o = 0,
    input                           tx_ready_i,
    output reg  [31:0]              tx_addr_o = 0,
    input       [BLOCK_SIZE*8-1:0]  tx_rdata_i,
    output      [BLOCK_SIZE*8-1:0]  tx_wdata_o
);

    parameter NUM_BLOCKS   = (1 << ADDR_WIDTH) / BLOCK_SIZE;
    parameter OFFSET_WIDTH = $clog2(BLOCK_SIZE);
    parameter INDEX_WIDTH  = $clog2(NUM_BLOCKS);
    parameter TAG_WIDTH    = 32 - (OFFSET_WIDTH + INDEX_WIDTH);

    parameter CACHE_IDLE_STATE  = 2'b00;
    parameter CACHE_ALLOC_STATE = 2'b01;
    parameter CACHE_WB_STATE    = 2'b10;
    parameter CACHE_RMEM_STATE  = 2'b11;

    reg  [TAG_WIDTH-1:0]    tags        [NUM_BLOCKS-1:0][SETS-1:0];
    reg                     valids      [NUM_BLOCKS-1:0][SETS-1:0];
    reg                     dirtys      [NUM_BLOCKS-1:0][SETS-1:0];
    reg  [$clog2(SETS)-1:0] lru         [NUM_BLOCKS-1:0][SETS-1:0];
    reg  [1:0]              cache_state      = CACHE_IDLE_STATE;
    reg  [1:0]              cache_next_state = CACHE_IDLE_STATE;

    reg  [SETS-1:0]         write_enables = 0;

    wire [SETS-1:0]         hit;
    reg  [$clog2(SETS)-1:0] hit_idx = 0;
    reg  [$clog2(SETS)-1:0] lru_idx = 0;
    wire                    full_width = tx_we_o || tx_re_o;
    wire [1:0]              width = full_width ? 0 : rx_width_i;

    wire [INDEX_WIDTH-1:0] addr_idx = rx_addr_i[31:32 - TAG_WIDTH];
    wire [INDEX_WIDTH-1:0] addr_tag = rx_addr_i[INDEX_WIDTH + OFFSET_WIDTH - 1:OFFSET_WIDTH];

    wire [(BLOCK_SIZE*8*SETS)-1:0]  rdata_w;
    //reg  [BLOCK_SIZE*8-1:0]  rdata_match_r = 0;

    genvar i;
    for (i = 0; i < SETS; i = i + 1) begin
        assign hit[i] = (tags[addr_idx][i] == addr_tag) && valids[addr_idx][i];
    end

    cache_set #(
        .ADDR_WIDTH( ADDR_WIDTH ),
        .DATA_WIDTH( BLOCK_SIZE*8 )
    )
    CACHE_SETS [SETS-1:0] (
        .clk_i(clk_i),
        .we_i(write_enables),
        .addr_i(rx_addr_i[INDEX_WIDTH + OFFSET_WIDTH-1:0]),
        .wdata_i(tx_rdata_i),
        .rdata_o(rdata_w),
        .width_i(width),
        .misaligned_o()
    );

    integer j;
    always @(*) begin
        for (j = 0; j < SETS; j = j + 1) begin
            if (hit[j] == 1) begin
                hit_idx <= j;
            end
            if (lru[addr_idx][j] == SETS-1) begin
                lru_idx <= j;
            end
        end

        for (j = 0; j < (BLOCK_SIZE*8*SETS); j = j + (BLOCK_SIZE*8)) begin
            if (hit[j/(BLOCK_SIZE*8)] == 1)
                rx_rdata_o <= rdata_w[j+:(BLOCK_SIZE*8)];
        end

        case(cache_state)
            CACHE_IDLE_STATE: begin
                // Read state-transition
                if (rx_re_i) begin
                    if (hit) begin
                        cache_next_state <= CACHE_IDLE_STATE;
                        rx_ready_o <= 1;
                    end
                    else begin
                        if (dirtys[addr_idx][hit_idx]) begin
                            cache_next_state <= CACHE_ALLOC_STATE;
                            rx_ready_o <= 0;
                        end
                        else               begin
                            cache_next_state <= CACHE_RMEM_STATE;
                            rx_ready_o <= 0;
                            tx_re_o <= 1;
                            tx_addr_o <= rx_addr_i;
                        end
                    end
                end
                // Write state-transition
                else if (rx_we_i) begin
                    if (hit == 0) begin
                        cache_next_state <= CACHE_IDLE_STATE;
                    end
                    else begin
                        cache_next_state <= CACHE_IDLE_STATE;
                    end
                end
                // No requests
                else begin
                    cache_next_state <= CACHE_IDLE_STATE;
                end
            end

            CACHE_RMEM_STATE: begin
                cache_next_state <= CACHE_WB_STATE;
                write_enables[lru_idx] <= 1;
                tx_re_o <= 0;
            end

            CACHE_WB_STATE: begin
                cache_next_state <= CACHE_IDLE_STATE;
                write_enables[lru_idx] <= 0;
                valids[addr_idx][lru_idx] <= 1;
                tags[addr_idx][lru_idx] <= addr_tag;
                rx_ready_o <= 1;
            end
        endcase
    end

    

    always @(posedge clk_i) begin
        cache_state <= cache_next_state;
        // Update LRU
        if ((rx_re_i || rx_we_i) && (cache_state == CACHE_IDLE_STATE)) begin
            for (j = 0; j < SETS; j = j + 1) begin
                 if (!hit)
                     lru[addr_idx][j] <= lru[addr_idx][j] + 1;
            end
            if (hit)
                lru[addr_idx][hit_idx] <= 0;
            else
                lru[addr_idx][lru_idx] <= 0;
        end
        
    end

    integer k;
    integer l;
    initial begin
        for (k = 0; k < SETS; k = k + 1) begin
            for ( l = 0; l < NUM_BLOCKS; l = l + 1 ) begin
                tags[l][k] <= 0;
                valids[l][k] <= 0;
                dirtys[l][k] <= 0;
                lru[l][k] <= k;
            end
        end
        valids[0][0] <= 0;
    end

endmodule
