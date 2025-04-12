// Test bench for full digital safe lock
`include "p2s.sv"
`include "unloc_mech_moore.sv"
`timescale 1ns/1ns

module full_digital_safe_lock_tb;

    localparam CLK_PERIOD = 10,
               N          = 4;

    logic clk = 0, rstn = 0;

    initial forever begin
        #(CLK_PERIOD/2) 
        clk <= ~clk;
    end
    
    logic par_valid = 0;
    logic [N-1 : 0] par_data;
    logic output_val, output_data;

    full_digital_safe_lock #(
        .N(N)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .par_valid(par_valid),
        .par_data(par_data),
        .output_val(output_val),
        .output_data(output_data)
    );

    initial begin
        
        $dumpfile("dump.vcd");
        $dumpvars;

        @(posedge clk); #1 rstn = 0;
        @(posedge clk); #1 rstn = 1;

        // Test Input 1
        @(posedge clk); #1 par_data = 4'b0101; par_valid = 0;
        #(CLK_PERIOD*3)
        @(posedge clk); #1 par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;

        // Test input 2
        #(CLK_PERIOD*10)
        @(posedge clk); #1 par_data <= 4'b1100; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;

        // Test input 3
        #(CLK_PERIOD*10)
        @(posedge clk); #1 par_data <= 4'b1110; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;

        // Test input 4 - (input 1011 which should be correct)
        #(CLK_PERIOD*10)
      @(posedge clk); #1 par_data <= 4'b1011; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;
        
        // Test input 5
        #(CLK_PERIOD*10)
        @(posedge clk); #1 par_data <= 4'b0001; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;

        // Test input 6
        #(CLK_PERIOD*5)
        @(posedge clk); #1 par_data <= 4'b0010; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;

        // Test input 7
        #(CLK_PERIOD*5)
        @(posedge clk); #1 par_data <= 4'b0100; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;

        // Test input 8
        #(CLK_PERIOD*5)
        @(posedge clk); #1 par_data <= 4'b1000; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;

        // Test input 9
        #(CLK_PERIOD*5)
        @(posedge clk); #1 par_data <= 4'b0110; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;

        // Test input 10
        #(CLK_PERIOD*5)
        @(posedge clk); #1 par_data <= 4'b0011; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;

        #(CLK_PERIOD*10)
        $finish();        
        
    end

endmodule