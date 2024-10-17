module tb_vga_controller();

    // Inputs
    reg clk;
    reg reset;

    // Instantiate the VGA Controller
    vga_controller uut (
        .clk(clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .video_enable(video_enable)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock -> 10ns period
    end

    // Test Procedure
    initial begin
        // Initial reset
        reset = 1;
        #20;  // Hold reset for a few cycles
        
        reset = 0;
        #30000000;  // Let the simulation run for a while after reset is released

        $finish;
    end

    // initial begin
    //     $monitor("Time=%0t | h_sync=%b | v_sync=%b | video_enable=%b", 
    //              $time, h_sync, v_sync, video_enable);
    // end

    initial begin
        $dumpfile("vga_controller_tb.vcd");
        $dumpvars(0, tb_vga_controller);
    end

endmodule
