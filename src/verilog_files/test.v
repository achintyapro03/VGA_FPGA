`timescale 1ns / 1ps

module main(
    input clk,
    input reset,
    input ov7670_pclk,                  // Camera pixel clock
    input ov7670_vsync,                 // Camera vertical sync
    input ov7670_href,                  // Camera horizontal reference
    input [7:0] ov7670_data,            // Camera pixel data
    output wire h_sync,
    output wire v_sync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue,
    output wire ov7670_xclk,            // Camera system clock
    output wire ov7670_pwdn,            // Camera power down
    output wire ov7670_reset            // Camera reset
    );

    wire [16:0] address;
    wire [11:0] pixel_data;
    wire clk_wiz_out;
    
    wire [11:0] x_idx, y_idx;
    wire video_enable;

    // Set up the camera clock and control signals
    assign ov7670_xclk = clk_wiz_out;   // Provide the system clock to the camera
    assign ov7670_pwdn = 0;             // Keep the camera powered on
    assign ov7670_reset = ~reset;       // Reset signal for the camera

    // Clock wizard to create the necessary camera and VGA clock signals
    clk_wiz_0 clk_wiz_inst1 (
        .clk_out1(clk_wiz_out),         // Output clock for camera
        .clk_in1(clk)                   // Input clock
    );

    // VGA Controller to generate sync signals and pixel coordinates
    vga_controller vga_cont_inst1 (
        .clk(clk_wiz_out),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .x_idx(x_idx),
        .y_idx(y_idx),
        .video_enable(video_enable)
    );

    // OV7670 Capture to get pixel data from the camera
    ov7670_capture capture_inst (
        .pclk(ov7670_pclk),
        .vsync(ov7670_vsync),
        .href(ov7670_href),
        .d(ov7670_data),
        .addr(address),
        .dout(pixel_data)
    );

    always @(posedge clk_wiz_out or posedge reset) begin
        if (reset) begin
            {red, green, blue} <= {3{4'b0000}};
        end else if (video_enable) begin
            // Scale down the input frame (if needed) and assign camera data to RGB
            red <= pixel_data[11:8];
            green <= pixel_data[7:4];
            blue <= pixel_data[3:0];
        end else begin
            {red, green, blue} <= {3{4'b0000}};
        end
    end

endmodule
