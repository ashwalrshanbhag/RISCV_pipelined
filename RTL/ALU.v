`timescale 1ns/1ps

module ALU(
    input [31:0] A, B,
    input [2:0] ALUControl,
    output Carry, OverFlow, Zero, Negative,
    output [31:0] Result
);

    wire Cout;
    wire [31:0] Sum;
    wire slt;

    // Handles Addition (ALUControl[0]=0) or Subtraction (ALUControl[0]=1)
    assign {Cout, Sum} = (ALUControl[0] == 1'b0) ? (A + B) : (A + ((~B) + 1'b1));
                          
    // Multiplexer selecting operations: ADD, SUB, AND, OR, SLT
    assign Result = (ALUControl == 3'b000) ? Sum :
                    (ALUControl == 3'b001) ? Sum :
                    (ALUControl == 3'b010) ? (A & B) :
                    (ALUControl == 3'b011) ? (A | B) :
                    // Cleaned up syntax tracking for your signed SLT operation
                    (ALUControl == 3'b101) ? {31'b0, slt} : 32'h00000000;
    
    // Signed Arithmetic Overflow Flags Check
    assign OverFlow = ((Sum[31] ^ A[31]) & 
                      (~(ALUControl[0] ^ B[31] ^ A[31])) &
                      (~ALUControl[1]));
                      
    assign slt      = Sum[31] ^ OverFlow;
    assign Carry    = ((~ALUControl[1]) & Cout);
    assign Zero     = (Result == 32'h00000000); // Reliable zero reduction match
    assign Negative = Result[31];

endmodule