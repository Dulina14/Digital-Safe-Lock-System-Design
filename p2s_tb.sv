`timescale 1ns/1ps

module p2s_tb;

    logic clk = 0, rstn = 0;
    localparam CLK_PERIOD = 10;
    initial forever begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    parameter N = 4;
    logic [N-1:0] par_data;
    logic par_valid = 0, par_ready;
    logic ser_data, ser_valid, ser_ready;

    p2s #(.N(N)) dut (.*);

    initial begin 
        $dumpfile("p2s_tb.vcd");
        $dumpvars(0, p2s_tb);

        @(posedge clk); #1 rstn <= 0;
        @(posedge clk); #1 rstn <= 1;

        // Test input 1
        @(posedge clk); #1 par_data <= 4'b1010; par_valid <= 0; ser_ready <= 1;
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

        // Test input 4
        #(CLK_PERIOD*10)
        @(posedge clk); #1 par_data <= 4'b1111; par_valid <= 1;
        @(posedge clk); #1 par_valid <= 0;
        @(posedge clk); #1 ser_ready <= 0;
        #(CLK_PERIOD*2)
        @(posedge clk); #1 ser_ready <= 1;

        // Test input 5
        #(CLK_PERIOD*5)
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
