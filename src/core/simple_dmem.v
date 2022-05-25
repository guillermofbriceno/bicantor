module simple_imem 
(
    input               clock_i,

    input       [09:0]  load_addr_i,
    input       [09:0]  store_addr_i,

    output reg  [31:0]  data_o = 0
);

    reg  [7:0]  datamemory [0:1023];

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
        if (ssr_i && re_i) begin
            data_o <= 0;
        end else if (re_i) begin
            data_o <= { 
                instmemory[address0], instmemory[address1], instmemory[address2], instmemory[address3],
                instmemory[address4], instmemory[address5], instmemory[address6], instmemory[address7] 
            };
        end
        


    end


endmodule
