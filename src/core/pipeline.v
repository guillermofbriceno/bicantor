module pipeline
(
    input  wire        clock_i,
    input  wire [31:0] pc_i,
    output wire [09:0] inst_addr_o,

    input  wire [63:0] imem_i,
    output reg  [31:0] inst_0_o     = 0,
    output reg  [31:0] inst_1_o     = 0
);

    /*
    *  PC / MEM Buffer
    */
    reg         fetch_we = 1;
    reg  [31:0] pc_fetch1_out = 0;

    always @(posedge clock_i) begin
        if (fetch_we) begin
            pc_fetch1_out   <= pc_i;
        end
    end

    assign inst_addr_o = pc_fetch1_out[09:0];

    /*
    *  MEM / D1 Buffers
    */
    reg         fetch2_0_we = 1;
    reg         fetch2_1_we = 1;
    reg         fetch2_0_sr = 0;
    reg         fetch2_1_sr = 0;

    always @(*) begin
        // Fetch Slot 0
        if (fetch2_0_sr) begin
            inst_0_o    <= 32'b0;
        end else if (fetch2_0_we) begin
            inst_0_o    <= imem_i[63:32];
        end

        // Fetch Slot 1
        if (fetch2_0_sr) begin
            inst_1_o    <= 32'b0;
        end else if (fetch2_1_we) begin
            inst_1_o    <= imem_i[31:0];
        end
    end

endmodule
