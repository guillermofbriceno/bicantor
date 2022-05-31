module cache_set
#(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 128 // In bits
)
(
    input                       clk_i,
    input                       we_i,
    input  [ADDR_WIDTH - 1:0]   addr_i,
    input  [DATA_WIDTH - 1:0]   wdata_i,
    output reg [DATA_WIDTH - 1:0]   rdata_o = 0,
    input  [1:0]                width_i, // 0: line, 1: byte, 2: halfword, 3: word
    output                      misaligned_o
);
    parameter NUM_BLOCKS = DATA_WIDTH / 8;

    wire [($clog2(NUM_BLOCKS)) + 3 - 1:0]           shamt;
    wire [(ADDR_WIDTH - $clog2(NUM_BLOCKS))-1:0]    addr_ebr;
    reg  [NUM_BLOCKS-1:0]                           line_enables = 0;
    wire [NUM_BLOCKS:0]                             shft_line_enables; // One extra bit for misalignment detection
    wire [DATA_WIDTH-1:0]                           shft_wdata;
    reg  [NUM_BLOCKS-1:0]                           write_enables = 0;
    wire [NUM_BLOCKS-1:0]                           read_enables;
    wire [DATA_WIDTH-1:0]                           preshft_rdata;
    wire [DATA_WIDTH-1:0]                           shft_rdata;
    wire [DATA_WIDTH-1:0]                           unmasked_rdata;

    assign shamt                = {addr_i[$clog2(DATA_WIDTH/8)-1:0], 3'b0};
    assign addr_ebr             = addr_i[ADDR_WIDTH-1:$clog2(NUM_BLOCKS)];
    assign shft_line_enables    = {1'b0, line_enables} << addr_i[$clog2(DATA_WIDTH/8)-1:0];
    assign misaligned_o         = shft_line_enables[NUM_BLOCKS];
    assign shft_wdata           = wdata_i << shamt;
    assign shft_rdata           = preshft_rdata >> shamt;

    ram_Nx8 #( 
        .ADDR_WIDTH(ADDR_WIDTH - $clog2(NUM_BLOCKS)) 
    )
    CACHE_DATA_EBRS [(NUM_BLOCKS) - 1:0] (
        .clk_i(clk_i),
        .we_i(write_enables), // need to change to the corrected write enables
        .addr_i(addr_ebr),
        .wdata_i(shft_wdata),
        .rdata_o(preshft_rdata)
    );

    integer i;
    always @(*) begin
        case (width_i)
            0:          line_enables <= {(DATA_WIDTH/8){1'b1}};// line      (all 1)
            1:          line_enables <= 1;                  // byte      (0001)
            2:          line_enables <= 3;                  // halfword  (0011)
            3:          line_enables <= 15;                 // word      (1111)
            default:    line_enables <= 0;
        endcase

        for (i = 0; i < NUM_BLOCKS; i = i + 1) begin
            write_enables[i] <= (((width_i == 0) || shft_line_enables[i]) && we_i);
        end

        for (i = 0; i < DATA_WIDTH; i = i + 8) begin
            rdata_o[i+:8] <= line_enables[i/8] ? shft_rdata[i+:8] : 0;
        end

    end

    //initial begin
    //    CACHE_DATA_EBRS[0].mem[0] <= 8'hEF;
    //    CACHE_DATA_EBRS[1].mem[0] <= 8'hBE;
    //    CACHE_DATA_EBRS[2].mem[0] <= 8'hAD;
    //    CACHE_DATA_EBRS[3].mem[0] <= 8'hDE;
    //end

endmodule


module ram_Nx8
#(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)
(
    input                       clk_i,
    input                       we_i,
    input      [ADDR_WIDTH-1:0] addr_i, 
    input      [DATA_WIDTH-1:0] wdata_i,
    output reg [DATA_WIDTH-1:0] rdata_o = 0
);

    reg [DATA_WIDTH-1:0] mem [(1 << ADDR_WIDTH) - 1: 0];

    always @(posedge clk_i) begin
        rdata_o <= mem[addr_i];
        if (we_i)
            mem[addr_i] <= wdata_i;
    end

    integer i;
    initial begin
        for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
            mem[i] <= 0;
        end
    end

endmodule
