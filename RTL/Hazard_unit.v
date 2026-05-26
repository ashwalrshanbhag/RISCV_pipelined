module hazard_unit(
    rst,
    // Forwarding inputs
    RegWriteM, RegWriteW,
    RD_M, RD_W,
    Rs1_E, Rs2_E,
    // Load-use stall inputs
    ResultSrcE_is_load,   // high when instruction in EX is a load (ResultSrcE == 2'b01)
    RD_E,
    Rs1_D, Rs2_D,
    // Control hazard input
    PCSrcE,               // high when a branch is taken
    // Forwarding outputs
    ForwardAE, ForwardBE,
    // Stall / flush outputs
    StallF, StallD, FlushD, FlushE
);

    // --- I/O Declaration ---
    input rst;
    input RegWriteM, RegWriteW;
    input [4:0] RD_M, RD_W, Rs1_E, Rs2_E;

    // Load-use detection
    input ResultSrcE_is_load;
    input [4:0] RD_E;
    input [4:0] Rs1_D, Rs2_D;

    // Control hazard
    input PCSrcE;

    output [1:0] ForwardAE, ForwardBE;
    output StallF, StallD, FlushD, FlushE;

    // -------------------------------------------------------
    // EX/MEM and MEM/WB Forwarding (unchanged from before)
    // Priority: MEM forwarding (2'b10) beats WB forwarding (2'b01)
    // -------------------------------------------------------
    assign ForwardAE = (rst == 1'b0) ? 2'b00 :
                       ((RegWriteM) & (RD_M != 5'h00) & (RD_M == Rs1_E)) ? 2'b10 :
                       ((RegWriteW) & (RD_W != 5'h00) & (RD_W == Rs1_E)) ? 2'b01 :
                       2'b00;

    assign ForwardBE = (rst == 1'b0) ? 2'b00 :
                       ((RegWriteM) & (RD_M != 5'h00) & (RD_M == Rs2_E)) ? 2'b10 :
                       ((RegWriteW) & (RD_W != 5'h00) & (RD_W == Rs2_E)) ? 2'b01 :
                       2'b00;

    // -------------------------------------------------------
    // Load-Use Hazard Detection
    //
    // Condition: the instruction currently in EX is a load (lw),
    // AND its destination register matches either source register
    // of the instruction currently in ID/D.
    //
    // When detected:
    //   StallF = 1  -> PC register holds (does not advance)
    //   StallD = 1  -> IF/ID register holds (same instruction stays in decode)
    //   FlushE = 1  -> ID/EX register is cleared to NOP (bubble inserted)
    // -------------------------------------------------------
    wire load_use_hazard;
    assign load_use_hazard = (rst == 1'b1)          &
                              ResultSrcE_is_load     &
                              (RD_E != 5'h00)        &
                              ((RD_E == Rs1_D) | (RD_E == Rs2_D));

    assign StallF = load_use_hazard;
    assign StallD = load_use_hazard;

    // -------------------------------------------------------
    // Control Hazard Flush (Branch Taken)
    //
    // When PCSrcE=1, the branch is taken. Two wrong instructions
    // have already entered the pipeline behind the branch:
    //   instr+1 is sitting in ID  (IF/ID register) -> FlushD
    //   instr+2 is being fetched in IF this cycle   -> will enter IF/ID
    //                                                  next cycle -> FlushE
    // Both must be turned into NOPs.
    // PC redirect (PCSrcE -> PCTargetE mux) ensures correct fetch from cycle N+1.
    //
    //   FlushD = 1  -> IF/ID register cleared to NOP  (kills instr+1)
    //   FlushE = 1  -> ID/EX register cleared to NOP  (kills instr+2)
    // -------------------------------------------------------
    assign FlushD = PCSrcE;

    // FlushE fires on load-use hazard OR branch taken
    assign FlushE = load_use_hazard | PCSrcE;

endmodule