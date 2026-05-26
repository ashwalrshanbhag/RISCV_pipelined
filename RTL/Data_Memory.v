`timescale 1ns/1ps

module Data_Memory(
    input clk,
    input rst, // Added to match the instantiation port list in memory_cycle.v
    input WE,
    input [31:0] A, 
    input [31:0] WD,
    output [31:0] RD
);

    reg [31:0] mem [1023:0];
    integer i;

    // Zero out data memory on startup to avoid 'X' states
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
    end
    
    // Combinational Read (Word-aligned indexing)
    assign RD = mem[A[31:2]]; 

    // Synchronous Write
    always @(posedge clk) begin
        if (WE) begin
            mem[A[31:2]] <= WD;
        end
    end

endmodule