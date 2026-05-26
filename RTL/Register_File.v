module Register_File(
    input clk, rst, WE3,
    input [4:0] A1, A2, A3,
    input [31:0] WD3,
    output [31:0] RD1, RD2
);

    reg [31:0] Register [31:0];
    integer i;

    // Synchronous Write Logic (Enforces x0 cannot be overwritten)
    always @(posedge clk) begin
        if (WE3 && (A3 != 5'h00)) begin
            Register[A3] <= WD3;
        end
    end

    // Combinational Read Logic 
    // Always returns 0 if address is 0, or if the system is in reset.
    assign RD1 = (rst == 1'b0) ? 32'h00000000 : ((A1 == 5'h00) ? 32'h00000000 : Register[A1]);
    assign RD2 = (rst == 1'b0) ? 32'h00000000 : ((A2 == 5'h00) ? 32'h00000000 : Register[A2]);

    // Initial Block to Zero out ALL Registers for clean simulation
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            Register[i] = 32'h00000000;
        end
    end

endmodule