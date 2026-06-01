module Instruction_Memory(
    input rst,
    input [31:0] A,
    output [31:0] RD
);

    reg [31:0] mem [1023:0];
    
    
    assign RD = (rst == 1'b0) ? 32'h00000000 : mem[A[31:2]];

    initial begin
       //file containing instructions 
        $readmemh("F:/Downloads/myproject/myproject/RISCV_final/program.hex", mem);
    end

endmodule
