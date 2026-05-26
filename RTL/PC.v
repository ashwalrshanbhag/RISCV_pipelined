`timescale 1ns/1ps

module PC_Module(
    input clk,
    input rst,
    input StallF,          // load-use: freeze PC when high
    input [31:0] PC_Next,
    output reg [31:0] PC
);

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0)
            PC <= 32'h00000000;
        else if (!StallF)  // only advance when not stalled
            PC <= PC_Next;
        // StallF=1: PC keeps current value
    end

endmodule