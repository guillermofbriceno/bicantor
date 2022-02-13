module blink 
(
    input      clk_i,
    output wire led_o
);
    reg  [25:0] counter;
    
    assign led_o = counter[25];

    always @(posedge clk_i) begin
        counter <= counter + 1;
    end

    initial begin
        $dumpfile("./build/uut.vcd");
        $dumpvars(0, blink);
    end
endmodule
