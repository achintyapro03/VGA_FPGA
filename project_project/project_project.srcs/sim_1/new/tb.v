`timescale 1ns / 1ps

module tb_vga_controller;

    // Inputs
    reg clk;
    reg reset;
    reg [3:0] red_in;
    reg [3:0] green_in;
    reg [3:0] blue_in;

    // Outputs
    wire h_sync;
    wire v_sync;
    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;

    // Clock period definition (for 247.5 MHz clock)
    localparam CLK_PERIOD = 4.04; // 4.04 ns for 247.5 MHz

    // Instantiate the Unit Under Test (UUT)
    vga_controller uut (
        .clk(clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .red(red),
        .green(green),
        .blue(blue),
        .red_in(red_in),
        .green_in(green_in),
        .blue_in(blue_in)
    );

    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2);
        clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    // Test stimulus
    initial begin
        // Initialize Inputs
        reset = 1'b1;
        red_in = 4'b0000;
        green_in = 4'b0000;
        blue_in = 4'b0000;

        #(CLK_PERIOD * 10);
        reset = 1'b0;

        #(CLK_PERIOD * 10);
        red_in = 4'b1010;
        green_in = 4'b1100;
        blue_in = 4'b0011;

        #(CLK_PERIOD * 10000);
        $stop;
    end

endmodule
