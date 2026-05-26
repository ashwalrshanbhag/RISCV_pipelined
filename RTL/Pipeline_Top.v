module Pipeline_top(input clk, rst);

    // Control wires
    wire PCSrcE, RegWriteW, RegWriteE, ALUSrcE, MemWriteE, BranchE;
    wire RegWriteM, MemWriteM;
    wire [1:0] ResultSrcE, ResultSrcM, ResultSrcW;
    wire [2:0] ALUControlE;
    wire [4:0] RD_E, RD_M, RDW;
    // In Pipeline_Top.v - add this wire
    wire JumpE;


    // 32-bit datapath wires
    wire [31:0] PCTargetE, InstrD, PCD, PCPlus4D, ResultW;
    wire [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E;
    wire [31:0] PCPlus4M, WriteDataM, ALU_ResultM;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
    wire [4:0]  RS1_E, RS2_E;
    wire [1:0]  ForwardBE, ForwardAE;

    // Hazard / stall wires
    wire StallF, StallD, FlushD, FlushE;
    // Rs1_D / Rs2_D: source registers of the instruction currently in DECODE
    // These come directly from the instruction word in the IF/ID register
    wire [4:0] Rs1_D, Rs2_D;
    assign Rs1_D = InstrD[19:15];
    assign Rs2_D = InstrD[24:20];
    // ResultSrcE == 2'b01 means the EX-stage instruction is a load
    wire ResultSrcE_is_load;
    assign ResultSrcE_is_load = (ResultSrcE == 2'b01);

    // ==========================================
    // FETCH STAGE
    // ==========================================
    fetch_cycle Fetch (
        .clk(clk),
        .rst(rst),
        .PCSrcE(PCSrcE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .PCTargetE(PCTargetE),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

    // ==========================================
    // DECODE STAGE
    // ==========================================
    decode_cycle Decode (
        .clk(clk),
        .rst(rst),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteW(RegWriteW),
        .RDW(RDW),
        .ResultW(ResultW),
        .FlushE(FlushE),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E),
        .JumpE(JumpE)
    );

    // ==========================================
    // EXECUTE STAGE
    // ==========================================
    execute_cycle Execute (
        .clk(clk),
        .rst(rst),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .ResultW(ResultW),
        .JumpE(JumpE),
        .ForwardA_E(ForwardAE),
        .ForwardB_E(ForwardBE)
    );

    // ==========================================
    // MEMORY STAGE
    // ==========================================
    memory_cycle Memory (
        .clk(clk),
        .rst(rst),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .RD_W(RDW),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW)
    );

    // ==========================================
    // WRITE BACK STAGE
    // ==========================================
    writeback_cycle WriteBack (
        .clk(clk),
        .rst(rst),
        .ResultSrcW(ResultSrcW),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW),
        .ResultW(ResultW)
    );

    // ==========================================
    // HAZARD UNIT (Forwarding + Load-Use Stall)
    // ==========================================
    hazard_unit Hazard (
        .rst(rst),
        // Forwarding
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .RD_M(RD_M),
        .RD_W(RDW),
        .Rs1_E(RS1_E),
        .Rs2_E(RS2_E),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        // Load-use stall
        .ResultSrcE_is_load(ResultSrcE_is_load),
        .RD_E(RD_E),
        .Rs1_D(Rs1_D),
        .Rs2_D(Rs2_D),
        .StallF(StallF),
        .StallD(StallD),
        // Control hazard flush
        .PCSrcE(PCSrcE),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

endmodule