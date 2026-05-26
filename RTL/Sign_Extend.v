module Sign_Extend (
    input [31:0] In,
    input [1:0] ImmSrc,
    output [31:0] Imm_Ext
);

    // RISC-V Immediate Encoding Reconstruction:
    // 2'b00 -> I-Type (addi, lw) -> 12-bit sign-extended constant
    // 2'b01 -> S-Type (sw)       -> 12-bit split across [31:25] and [11:7]
    // 2'b10 -> B-Type (beq)      -> 13-bit branch offset, bit0 hardwired 0
    // 2'b11 -> J-Type (jal)      -> 21-bit jump offset, bit0 hardwired 0
    //
    // J-Type bit scramble (per RISC-V spec):
    //   imm[20]    <- In[31]        sign bit
    //   imm[19:12] <- In[19:12]
    //   imm[11]    <- In[20]
    //   imm[10:1]  <- In[30:21]
    //   imm[0]      = 1'b0          targets always 2-byte aligned
    // Concatenated 21 bits: {In[31], In[19:12], In[20], In[30:21], 1'b0}
    // Sign-extend: {11{In[31]}} prepended to reach 32 bits

    assign Imm_Ext = (ImmSrc == 2'b00) ? {{20{In[31]}}, In[31:20]} :
                     (ImmSrc == 2'b01) ? {{20{In[31]}}, In[31:25], In[11:7]} :
                     (ImmSrc == 2'b10) ? {{20{In[31]}}, In[7], In[30:25], In[11:8], 1'b0} :
                     (ImmSrc == 2'b11) ? {{11{In[31]}}, In[19:12], In[20], In[30:21], 1'b0} :
                                         32'h00000000; // unreachable with 2-bit ImmSrc

endmodule