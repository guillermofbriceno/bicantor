module inst_mem 
#(
    parameter loadfile = "build/jupiter_asm.hex"
)
(
    input               clock_i,
    input               stall_i,
    input       [09:0]  address_i,

    output reg  [63:0]  data_o = 0
);

    reg  [7:0]  instmemory [0:1023];

    wire [9:0]  address0, address1, address2, address3;
    wire [9:0]  address4, address5, address6, address7;

    assign address0 = address_i;
    assign address1 = address_i+1;
    assign address2 = address_i+2;
    assign address3 = address_i+3;
    assign address4 = address_i+4;
    assign address5 = address_i+5;
    assign address6 = address_i+6;
    assign address7 = address_i+7;


    always @ (posedge clock_i) begin
        if (!stall_i) begin
            data_o <= { 
                instmemory[address0], instmemory[address1], instmemory[address2], instmemory[address3],
                instmemory[address4], instmemory[address5], instmemory[address6], instmemory[address7] 
            };
        end
    end

    initial begin
        $readmemh(loadfile, instmemory);
    end

endmodule

