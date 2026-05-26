`timescale 1ns/1ps

module Pipeline_top_tb();

    // Inputs to the DUT
    reg clk;
    reg rst;

    // Instantiate the Device Under Test (DUT)
    Pipeline_top uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock Generation (100MHz Clock -> 10ns period)
    always begin
        #5 clk = ~clk;
    end

    // Test Stimulus Setup
    initial begin
        // Initialize signals
        clk = 1'b0;
        rst = 1'b0; // Assert reset

        // Hold reset for slightly over one full clock cycle to capture the edge cleanly
        #15; 
        rst = 1'b1; // Release reset to kickstart the pipeline execution

        // Let the simulation run for 30 clock cycles (300ns)
        #300; 

        // =====================================================
        // OPTIONAL REGISTER FILE CHECK: Let's see what's in x2, x3, x5
        // (Adjust the inner path 'Decode.Register_File.rf' to match your actual module names)
        // =====================================================
        $display("\n================ FINAL REGISTER SNAPSHOT ================");
        //$display("Register x2: %d", uut.Decode.Register_File.rf[2]);
        //$display("Register x3: %d", uut.Decode.Register_File.rf[3]);
        //$display("Register x5: %d", uut.Decode.Register_File.rf[5]);
        $display("=========================================================\n");

        // Display a message in the Tcl Console when finished
        $display("===== Simulation Complete =====");
        $finish; 
    end
    
    initial begin
        // Print a nice header in the console
        $display("-----------------------------------------------------");
        $display("TIME     | PC       | WRITE REG | WRITE DATA");
        $display("-----------------------------------------------------");
    end

    always @(posedge clk) begin
        // Only print when a real register update is happening 
        // and skip the hardwired zero register (x0)
        if (uut.RegWriteW && (uut.RDW != 5'b00000)) begin
            $display("%8d ps | 0x%h | x%0d       | 0x%h (%0d)", 
                     $time, 
                     uut.PCPlus4W - 4,      // Reconstructs current instruction PC
                     uut.RDW,               // Destination register number from top file
                     uut.ResultW,           // Data bus going into the Register File
                     $signed(uut.ResultW)   // Decimal representation
            );
        end
    end

endmodule