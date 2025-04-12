`timescale 1ns/1ps

module unloc_mech_mealy_tb;

    logic clk = 0, rstn = 0;
    localparam CLK_PERIOD = 10;
    initial forever begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    logic ser_val, ser_data;
    logic output_val, output_data;

    unloc_mech_mealy dut(.*);  

    initial begin
        $monitor("Time=%0t: ser_val=%b ser_data=%b | output_val=%b output_data=%b | state=%s", 
                $time, ser_val, ser_data, output_val, output_data, dut.state.name());
    end

    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        
        
        rstn = 0;
        ser_val = 0;
        ser_data = 0;
        @(posedge clk); #1 rstn = 1;
        
        // Let it settle in IDLE
        repeat(2) @(posedge clk);
        
        // Test successful unlock sequence: IDLE -> A -> B -> C -> IDLE with unlock
        $display("\n--- Testing correct unlock sequence ---");
        
        // IDLE to STATE_A: ser_val=1, ser_data=1
        @(posedge clk); #1 ser_val = 1; ser_data = 1;
        @(posedge clk); #1 ser_val = 0; ser_data = 0; // Keep in STATE_A
        
        // STATE_A to STATE_B: ser_val=1, ser_data=0
        @(posedge clk); #1 ser_val = 1; ser_data = 0;
        @(posedge clk); #1 ser_val = 0; ser_data = 0; // Keep in STATE_B
        
        // STATE_B to STATE_C: ser_val=1, ser_data=1
        @(posedge clk); #1 ser_val = 1; ser_data = 1;
        @(posedge clk); #1 ser_val = 0; ser_data = 0; // Keep in STATE_C
        
        // STATE_C to IDLE with unlock: ser_val=1, ser_data=1
        @(posedge clk); #1 ser_val = 1; ser_data = 1; // This should set output_data=1
        @(posedge clk); #1 ser_val = 0; ser_data = 0; // Back to IDLE
        
        // Let it settle in IDLE
        repeat(2) @(posedge clk);
        
        // Test incorrect sequence 1: IDLE -> Try invalid input
        $display("\n--- Testing invalid sequence from IDLE ---");
        @(posedge clk); #1 ser_val = 1; ser_data = 0; // Should stay in IDLE
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        
        // Let it settle
        repeat(2) @(posedge clk);
        
        // Test incorrect sequence 2: IDLE -> A -> invalid input
        $display("\n--- Testing invalid sequence from STATE_A ---");
        // IDLE to STATE_A
        @(posedge clk); #1 ser_val = 1; ser_data = 1;
        @(posedge clk); #1 ser_val = 1; ser_data = 1; // STATE_A to IDLE (invalid input)
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        
        // Let it settle
        repeat(2) @(posedge clk);
        
        // Test partial sequence then reset
        $display("\n--- Testing partial sequence then reset ---");
        // IDLE to STATE_A
        @(posedge clk); #1 ser_val = 1; ser_data = 1;
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        
        // STATE_A to STATE_B
        @(posedge clk); #1 ser_val = 1; ser_data = 0;
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        
        // Reset to IDLE without completing sequence
        rstn = 0;
        @(posedge clk); #1 rstn = 1;
        
        // Let it settle
        repeat(2) @(posedge clk);
        
        if (dut.state != dut.IDLE) 
            $display("ERROR: Should be in IDLE state at end of test");
        else
            $display("Test completed successfully - ended in IDLE state");
            
        repeat(5) @(posedge clk);
        $finish;
    end  

endmodule