module Instruction_Memory(
    input rst,
    input [31:0] A,
    output [31:0] RD
);

    reg [31:0] mem [1023:0];
    
    // Using a clear 32-bit hex literal prevents replication syntax errors
    assign RD = (rst == 1'b0) ? 32'h00000000 : mem[A[31:2]];

    initial begin
        // Using full directory path with forward slashes for Vivado compatibility
        $readmemh("F:/Downloads/myproject/myproject/RISCV_final/program.hex", mem);
    end

endmodule