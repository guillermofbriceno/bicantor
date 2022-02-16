`include "simple_imem.v"
`include "core.v"

module core_tb ();
    reg         clock = 0;
    reg         mem_stall = 0;
    wire [63:0] data;
    wire [9:0]  addr;

    core CORE(
        .clock_i(clock),
        .data_i(data),
        .addr_o(addr)
    );

    inst_mem #( .loadfile("build/jupiter_asm.hex") ) 
    INSTMEM(
        .clock_i(clock),
        .stall_i(mem_stall),
        .address_i(addr),
        .data_o(data)
    );
    
    integer i = 0;
    initial begin
        $dumpfile("./build/uut.vcd");
        $dumpvars(0, core_tb);
        //$dumpvars(0, INSTMEM.instmemory);
        //for(i=0; i < 1024; i=i+1) begin
        //    $dumpvars(0, INSTMEM.instmemory[i]);
        //end

        for (i=0; i < 5000; i=i+1) begin
                #41.665;
                clock = 1;
                #41.665;
                clock = 0;
        end

    end
endmodule
