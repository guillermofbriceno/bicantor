module regfile
(
    input  wire        clock_i,
    input  wire [ 4:0] A_rs1_addr_i,
    input  wire [ 4:0] A_rs2_addr_i,
    input  wire [ 4:0] A_rd_addr_i,
    input  wire [31:0] A_rd_data_i,
    input  wire        A_rd_write_i,

    input  wire [ 4:0] B_rs1_addr_i,
    input  wire [ 4:0] B_rs2_addr_i,
    input  wire [ 4:0] B_rd_addr_i,
    input  wire [31:0] B_rd_data_i,
    input  wire        B_rd_write_i,

    output wire [31:0] A_rs1_data_o,
    output wire [31:0] A_rs2_data_o,

    output wire [31:0] B_rs1_data_o,
    output wire [31:0] B_rs2_data_o
);

    reg [31:0] registers  [31:0];

    reg [04:0] A_rs1_address_internal;
    reg [04:0] A_rs2_address_internal;
    reg [04:0] B_rs1_address_internal;
    reg [04:0] B_rs2_address_internal;

    assign A_rs1_data_o = ( A_rs1_address_internal != 0 ) ? registers[A_rs1_address_internal] : 0;
    assign A_rs2_data_o = ( A_rs2_address_internal != 0 ) ? registers[A_rs2_address_internal] : 0;
    assign B_rs1_data_o = ( B_rs1_address_internal != 0 ) ? registers[B_rs1_address_internal] : 0;
    assign B_rs2_data_o = ( B_rs2_address_internal != 0 ) ? registers[B_rs2_address_internal] : 0;

    /*
    *  Initialize registers at zero and dump states
    */
    integer i;
    initial begin
        //$dumpfile("./build/uut.vcd");
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'b0;
            //$dumpvars(0, registers[i]);
        end
    end

    /*
    *  Write
    */
    always @(posedge clock_i) begin
        if (A_rd_addr_i != 5'b0 && A_rd_write_i) begin
            registers[A_rd_addr_i] <= A_rd_data_i;
        end

        if (B_rd_addr_i != 5'b0 && B_rd_write_i) begin
            registers[B_rd_addr_i] <= B_rd_data_i;
        end
    end

    /*
    *  Read
    */
    always @(posedge clock_i) begin
        A_rs1_address_internal <= A_rs1_addr_i;
        A_rs2_address_internal <= A_rs2_addr_i;

        B_rs1_address_internal <= B_rs1_addr_i;
        B_rs2_address_internal <= B_rs2_addr_i;
    end

endmodule
