module core_tb ();
    reg         clock = 0;
    wire        imemstall;
    wire        imem_sr;
    wire [63:0] data;
    wire [9:0]  addr;

    core CORE(
        .clock_i(clock),
        .data_i(data),
        .addr_o(addr),
        .imemstall_o(imemstall),
        .imem_sr_o(imem_sr)
    );

    simple_imem #( .loadfile("build/jupiter_asm.hex") ) 
    INSTMEM(
        .clock_i(clock),
        .re_i(imemstall),
        .address_i(addr),
        .data_o(data),
        .ssr_i(imem_sr)
    );
    
    integer i = 0;
    initial begin
        $dumpfile("./build/uut.vcd");
        $dumpvars(0, core_tb);
        $dumpvars(0, CORE.DECODE);
        for (i = 0; i < 32; i = i + 1) begin
            $dumpvars(0, CORE.ISSUE.REGFILE.registers[i]);
        end

        //for(i=0; i < 1024; i=i+1) begin
        //    $dumpvars(0, CORE.FETCH1.PHT.pht[i]);
        //end

        for (i=0; i < 5000; i=i+1) begin
                #0.5;
                clock = 1;
                #0.5;
                clock = 0;
        end

    end
endmodule
