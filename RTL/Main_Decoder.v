`timescale 1ns/1ps

module Main_Decoder(
    input [6:0] Op,
    output RegWrite, ALUSrc, MemWrite, Branch,  Jump, 
    output [1:0] ResultSrc,
    output [1:0] ImmSrc, ALUOp
);

    //Combinational Assignments
   //write on register file 
    assign RegWrite  = ((Op == 7'b0000011) |   // lw
                        (Op == 7'b0110011) |   // R-type
                        (Op == 7'b0010011) |   // I-ALU
                        (Op == 7'b1101111)) ?  // JAL
                        1'b1 : 1'b0;

    // sign extention basd on instruction type 
    assign ImmSrc    = (Op == 7'b0100011) ? 2'b01 : // S-type  (sw)
                       (Op == 7'b1100011) ? 2'b10 : // B-type  (beq)
                       (Op == 7'b1101111) ? 2'b11 : // J-type  (jal)
                       2'b00;                        // I-type / R-type (default)

    assign ALUSrc    = ((Op == 7'b0000011) | (Op == 7'b0100011) | (Op == 7'b0010011)) ? 1'b1 : 1'b0;  // 1 for immediates instead of rs2 

    assign MemWrite  = (Op == 7'b0100011) ? 1'b1 : 1'b0;  //memeory write 

    // ResultSrc: 2'b00 = ALU, 2'b01 = ReadData (lw), 2'b10 = PCPlus4 (jal)
    assign ResultSrc = (Op == 7'b0000011) ? 2'b01 :  // lw  -> read data  , output from data memory 
                       (Op == 7'b1101111) ? 2'b10 :  // jal -> PC+4 (return addr)
                       2'b00;                         // default -> ALU result

    assign Branch    = (Op == 7'b1100011) ? 1'b1 : 1'b0;
    assign Jump = (Op == 7'b1101111) ? 1'b1 : 1'b0;   // JAL
    //
    assign ALUOp     = ((Op == 7'b0110011) || (Op == 7'b0010011)) ? 2'b10 :    //R , I type = 10 , B type = 01 and 00 for everything else ( lw , sw) 
                       (Op == 7'b1100011) ? 2'b01 : 2'b00;

endmodule
