`timescale 1ns/1ps

module unloc_mech_moore_tb;

    
    logic clk = 0, rstn = 0;
    localparam CLK_PERIOD = 10;
    initial forever begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    
    logic ser_val, ser_data;
    logic output_val, output;

    
    unloc_mech_moore dut(.*);  

    
    initial begin
        $monitor("Time=%0t: ser_val=%b ser_data=%b | output_val=%b output=%b | state=%s", 
                $time, ser_val, ser_data, output_val, output, dut.state.name());
    end

    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        
        
        rstn = 0;
        ser_val = 0;
        ser_data = 0;
        @(posedge clk); #1 rstn = 1;
        
        
        repeat(2) @(posedge clk);
        
        
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
        
        // Let it settle in IDLE
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        repeat(2) @(posedge clk);
        
        // Test path to INCORRECT state: IDLE -> INCORRECT -> IDLE
        @(posedge clk); #1 ser_val = 1; ser_data = 0; // IDLE to INCORRECT
        // INCORRECT automatically returns to IDLE after one clock cycle
        
        
        // Let it settle in IDLE
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        repeat(2) @(posedge clk);
        
        // Test another incorrect path: IDLE -> STATE_A -> INCORRECT -> IDLE
        @(posedge clk); #1 ser_val = 1; ser_data = 1; // IDLE to STATE_A
        @(posedge clk); #1 ser_val = 1; ser_data = 1; // STATE_A to INCORRECT (wrong input)
        
        @(posedge clk);
        
        
        @(posedge clk); #1 ser_val = 0; ser_data = 0;
        repeat(2) @(posedge clk);
        
        
        if (dut.state != dut.IDLE) 
            $display("ERROR: Should be in IDLE state at end of test");
        else
            $display("Test completed successfully - ended in IDLE state");
            
        
        repeat(5) @(posedge clk);
        $finish;
    end
endmodule