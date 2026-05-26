module writeback_cycle(clk, rst, ResultSrcW, PCPlus4W, ALU_ResultW, ReadDataW, ResultW);

// Declaration of IOs
input clk, rst;
input [1:0] ResultSrcW;
input [31:0] PCPlus4W, ALU_ResultW, ReadDataW;

output [31:0] ResultW;

// 3-to-1 result MUX
// 2'b00 -> ALU result   (R-type, I-ALU, S-type address)
// 2'b01 -> Read data    (lw)
// 2'b10 -> PC + 4       (JAL / JALR return address)
Mux_3_by_1 result_mux (
                .a(ALU_ResultW),
                .b(ReadDataW),
                .c(PCPlus4W),
                .s(ResultSrcW),
                .d(ResultW)
                );
endmodule