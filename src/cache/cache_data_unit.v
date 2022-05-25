module cache_data_unit
#(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 128
)
(
    input                       clk_i,
    input                       we_i,
    input  [ADDR_WIDTH - 1:0]   addr_i,
    input  [DATA_WIDTH - 1:0]   wdata_i,
    output [DATA_WIDTH - 1:0]   rdata_o,
    input  [1:0]                width_i, // 0: line, 1: byte, 2: halfword, 3: word
    output                      misaligned_o
);
    wire [($clog2(DATA_WIDTH / 8)) + 3 - 1:0]     shamt;
    wire [(DATA_WIDTH / 8)-1:0]                 addr_ebr;
    reg  [(DATA_WIDTH / 8)-1:0]                 line_enables = 0;
    wire [DATA_WIDTH / 8:0]                     shft_line_enables; // One extra bit for misalignment detection
    wire [DATA_WIDTH-1:0]                       shft_wdata = 0;
    reg  [(DATA_WIDTH / 8)-1:0]                 write_enables;
    wire [(DATA_WIDTH / 8)-1:0]                 read_enables;
    wire [DATA_WIDTH-1:0]                       preshft_rdata;
    wire [DATA_WIDTH-1:0]                       shft_rdata;
    wire [DATA_WIDTH-1:0]                       unmasked_rdata;

    assign shamt                = {addr_i[$clog2(DATA_WIDTH/8)-1:0], 3'b0};
    assign addr_ebr             = addr_i[ADDR_WIDTH-1:$clog2(DATA_WIDTH / 8)];
    assign shft_line_enables    = {1'b0, line_enables} << addr_i[$clog2(DATA_WIDTH/8)-1:0];
    assign misaligned_o         = shft_line_enables[DATA_WIDTH / 8];
    assign shft_wdata           = wdata_i << shamt;
    assign shft_rdata           = preshft_rdata >> shamt;

    ram_Nx8 #( 
        .ADDR_WIDTH(ADDR_WIDTH - $clog2(DATA_WIDTH / 8)) 
    )
    CACHE_DATA_EBRS [(DATA_WIDTH / 8) - 1:0] (
        .clk_i(clk_i),
        .we_i(write_enables), // need to change to the corrected write enables
        .addr_i(addr_ebr),
        .wdata_i(shft_wdata),
        .rdata_o(preshft_rdata)
    );

    integer i;
    integer j;
    always @(*) begin
        case (width_i)
            0:          line_enables <= {DATA_WIDTH/8{1}};  // line      (all 1)
            1:          line_enables <= 1;                  // byte      (0001)
            2:          line_enables <= 3;                  // halfword  (0011)
            3:          line_enables <= 15;                 // word      (1111)
            default:    line_enables <= 0;
        endcase

        for (i = 0; i < (DATA_WIDTH / 8); i = i + 1) begin
            write_enables[i] <= (((width_i == 0) || shft_line_enables[i]) && we_i);
        end

        for (i = 0; i < DATA_WIDTH; i = i + 8) begin
            if (i == 0)
                rdata_o[i-1:i-8] <= line_enables[0]   ? shft_rdata[i-1:i-8] : 0;
            else
                rdata_o[i-1:i-8] <= line_enables[i/8] ? shft_rdata[i-1:i-8] : 0;

        end

    end

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
    output reg [DATA_WIDTH-1:0] rdata_o
);

    reg [DATA_WIDTH-1:0] mem [(1 << ADDR_WIDTH) - 1: 0];

    always @(posedge clk_i) begin
        rdata_o <= mem[addr_i];
        if (we_i)
            mem[addr_i] <= wdata_i;
    end

endmodule
