module Mux (
    input [31:0] a,
    input [31:0] b,
    input s,
    output [31:0] c
);

    // Standard condition: if s is 1, choose b. If s is 0, choose a.
    assign c = (s) ? b : a;

endmodule


module Mux_3_by_1 (a,b,c,s,d);
    input [31:0] a,b,c;
    input [1:0] s;
    output [31:0] d;

    assign d = (s == 2'b00) ? a : (s == 2'b01) ? b : (s == 2'b10) ? c : 32'h00000000;
    
endmodule