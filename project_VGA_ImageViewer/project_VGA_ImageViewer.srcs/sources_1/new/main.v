`timescale 1ns / 1ps

module main(
    input clk,
    input reset, 
    output wire h_sync,
    output wire v_sync, 
    output reg [3:0] red, 
    output reg [3:0] green, 
    output reg [3:0] blue
    );
    
    reg [16:0] address;
    reg wea, ena;
    wire [11:0] pixel_in, pixel_out;
    wire clk_wiz_out;
    
    wire [11:0] x_idx, y_idx;
    wire video_enable;
        
    clk_wiz_0 clk_wiz_inst1 (
        .clk_out1(clk_wiz_out),     // output clk_out1
        .clk_in1(clk)               // input clk_in1
    );
    
    blk_mem_gen_0 blk_mem_inst1 (
        .clka(clk_wiz_out),         // input wire clka
        .ena(ena),                  // input wire ena
        .wea(wea),                  // input wire [0 : 0] wea
        .addra(address),            // input wire [16 : 0] addra
        .dina(pixel_in),            // input wire [11 : 0] dina
        .douta(pixel_out)           // output wire [11 : 0] douta
    );
    
    initial begin
        address = 17'b0;
        wea = 0;
        ena = 1;
    end
    
    vga_controller vga_cont_inst1 (
        .clk(clk_wiz_out), 
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .x_idx(x_idx),
        .y_idx(y_idx),
        .video_enable(video_enable)
    );
    
    always @(posedge clk_wiz_out or posedge reset) begin
        if (reset) begin
            address <= 17'b0;
            {red, green, blue} <= {3{4'b0000}};
        end else if (video_enable) begin
//            if(x_idx <= 384 && y_idx <= 216) begin
//                address <= y_idx * 384 + x_idx;
//                red <= pixel_out[11:8];
//                green <= pixel_out[7:4];
//                blue <= pixel_out[3:0];
//            end
            address <= (y_idx / 5) * 384 + (x_idx / 5);
            red <= pixel_out[11:8];
            green <= pixel_out[7:4];
            blue <= pixel_out[3:0];
        end else begin
            {red, green, blue} <= {3{4'b0000}};
        end
    end
    
endmodule
