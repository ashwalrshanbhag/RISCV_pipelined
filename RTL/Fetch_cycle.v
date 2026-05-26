module fetch_cycle(
    input clk, rst,
    input PCSrcE,
    input StallF,          // load-use: freeze PC
    input StallD,          // load-use: freeze IF/ID register
    input FlushD,          // control hazard: clear IF/ID register to NOP
    input [31:0] PCTargetE,
    output [31:0] InstrD,
    output [31:0] PCD, PCPlus4D
);

    // Declaring Interim Wires
    wire [31:0] PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;

    // Declaration of Pipeline Registers (F -> D Barrier)
    reg [31:0] InstrF_reg;
    reg [31:0] PCF_reg, PCPlus4F_reg;

    // PC Source Multiplexer
    Mux PC_MUX (
        .a(PCPlus4F),
        .b(PCTargetE),
        .s(PCSrcE),
        .c(PC_F)
    );

    // Program Counter Module
    PC_Module Program_Counter (
        .clk(clk),
        .rst(rst),
        .StallF(StallF),
        .PC(PCF),
        .PC_Next(PC_F)
    );

    // Instruction Memory
    Instruction_Memory IMEM (
        .rst(rst),
        .A(PCF),
        .RD(InstrF)
    );

    // PC Increment Adder
    PC_Adder PC_adder (
        .a(PCF),
        .b(32'h00000004),
        .c(PCPlus4F)
    );

    // IF/ID Pipeline Register
    // Priority: FlushD > StallD
    //   FlushD=1 -> clear to NOP (branch taken, wrong instruction in decode)
    //   StallD=1 -> hold current value (load-use, same instruction re-decoded)
    //   else     -> latch new fetch outputs normally
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0 || FlushD == 1'b1) begin
            InstrF_reg   <= 32'h00000013; // NOP (addi x0, x0, 0)
            PCF_reg      <= 32'h00000000;
            PCPlus4F_reg <= 32'h00000000;
        end
        else if(!StallD) begin
            InstrF_reg   <= InstrF;
            PCF_reg      <= PCF;
            PCPlus4F_reg <= PCPlus4F;
        end
        // StallD=1, FlushD=0: registers keep their current value
    end

    // Direct Output Port Assignments from Pipeline Registers
    assign InstrD    = InstrF_reg;
    assign PCD       = PCF_reg;
    assign PCPlus4D  = PCPlus4F_reg;

endmodule