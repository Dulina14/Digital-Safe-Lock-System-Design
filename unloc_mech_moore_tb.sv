`timescale 1ns/1ps

module unloc_mech_moore_tb;

    // Clock and reset
    logic clk = 0, rstn = 0;
    localparam CLK_PERIOD = 10;
    initial forever begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    // DUT interface signals
    logic ser_val, ser_data;
    logic output_val, output_data, ser_ready;

    // DUT instantiation - assuming the module name was updated to match the implementation
    unloc_mech_moore dut(.*);

        

    // Test stimulus
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        
        // Reset sequence
        rstn = 0;
        ser_val = 0;
        ser_data = 0;
        @(posedge clk); #1 rstn = 1;
        
        // Wait a few cycles after reset
        repeat(2) @(posedge clk);
        
        // Test path through all states correctly: IDLE -> STATE_A -> STATE_B -> STATE_C -> STATE_D -> IDLE
        // IDLE to STATE_A: ser_val=1, ser_data=1
        @(posedge clk); #1 ser_val = 1; ser_data = 1;
        @(posedge clk); #1 ser_val = 0; // Keep in STATE_A for one cycle
        
        // STATE_A to STATE_B: ser_val=1, ser_data=0
        @(posedge clk); #1 ser_val = 1; ser_data = 0;
        @(posedge clk); #1 ser_val = 0; // Keep in STATE_B for one cycle
        
        // STATE_B to STATE_C: ser_val=1, ser_data=1
        @(posedge clk); #1 ser_val = 1; ser_data = 1;
        @(posedge clk); #1 ser_val = 0; // Keep in STATE_C for one cycle
        
        // STATE_C to STATE_D: ser_val=1, ser_data=1
        @(posedge clk); #1 ser_val = 1; ser_data = 1;
        @(posedge clk); #1 ser_val = 0; // Keep in STATE_D for one cycle
        
        // STATE_D automatically returns to IDLE after one clock cycle
        // No need to change inputs
        
        // Let it settle in IDLE
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        repeat(2) @(posedge clk);
        
        // Test path to INCORRECT state: IDLE -> INCORRECT -> IDLE
        @(posedge clk); #1 ser_val = 1; ser_data = 0; // IDLE to INCORRECT
        // INCORRECT automatically returns to IDLE after one clock cycle
        // No need to set inputs to trigger return to IDLE
        
        // Let it settle in IDLE
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        repeat(2) @(posedge clk);
        
        // Test another incorrect path: IDLE -> STATE_A -> INCORRECT -> IDLE
        @(posedge clk); #1 ser_val = 1; ser_data = 1; // IDLE to STATE_A
        @(posedge clk); #1 ser_val = 1; ser_data = 1; // STATE_A to INCORRECT (wrong input)
        // Wait for INCORRECT to automatically return to IDLE
        @(posedge clk);
        
        // Let it settle in IDLE
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        repeat(2) @(posedge clk);
        
        // Add assertions to verify expected behavior
        if (dut.state != dut.IDLE) 
            $display("ERROR: Should be in IDLE state at end of test");
        else
            $display("Test completed successfully - ended in IDLE state");
            
        // Run for a few more cycles and finish
        repeat(5) @(posedge clk);
        $finish;
    end

    // Optional: Add some assertions to check expected behavior
    property correct_sequence_property;
        @(posedge clk) disable iff (!rstn)
        ($rose(ser_val) && ser_data) |=> (dut.state == dut.STATE_A);
    endproperty
    
   
endmodule