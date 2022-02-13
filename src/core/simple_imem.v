module InstructionMemory 
(
    input               clock_i,
    input               stall_i,
    input       [09:0]  address_i,

    output wire [31:0]  data_o
);

    reg [63:0] memory [1023:0];
    reg [9:0]  address1, address2;
    assign data_o = { memory[address1], memory[address2] };

    always @ (posedge clock_i) begin
        if (!stall) begin
            address1 <= address_i+1;
            address2 <= address_i;
        end
    end


    initial begin
        $readmemh("hexfile", memory);
        //$readmemh("/home/guillermo/programming/riscv-zedern/scripts/image.hex", memory);
    end

endmodule

