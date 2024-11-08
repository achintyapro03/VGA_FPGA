`timescale 1ns / 1ps
`default_nettype none

module top (
    input wire i_top_clk,
    input wire i_top_rst,
    
    input wire  i_top_cam_start, 
    output wire o_top_cam_done, 
    
    // I/O to camera
    input wire       i_top_pclk, 
    input wire [7:0] i_top_pix_byte,
    input wire       i_top_pix_vsync,
    input wire       i_top_pix_href,
    output wire      o_top_reset,
    output wire      o_top_pwdn,
    output wire      o_top_xclk,
    output wire      o_top_siod,
    output wire      o_top_sioc,
    
    // I/O to VGA 
    output reg [3:0] o_top_vga_red,
    output reg [3:0] o_top_vga_green,
    output reg [3:0] o_top_vga_blue,
    output wire      o_top_vga_vsync,
    output wire      o_top_vga_hsync
);
    
    // Connect cam_top/vga_top modules to BRAM
    wire [11:0] i_bram_pix_data, o_bram_pix_data;
    wire [16:0] i_bram_pix_addr, my_addr;
    reg [16:0] o_bram_pix_addr; 
    wire o_wr; 

    // Reset synchronizers for all clock domains
    reg r1_rstn_top_clk, r2_rstn_top_clk;
    reg r1_rstn_pclk, r2_rstn_pclk;
    reg r1_rstn_clk25m, r2_rstn_clk25m; 
        
    wire w_clk148m; 
    
    // Generate clocks for camera and VGA
    clk_wiz_148 my_clk (
        .clk_148(w_clk148m),     // output clk_148
        .clk_cam(o_top_xclk),    // output clk_cam
        .clk_in1(i_top_clk)      // input clk_in1
    );

    wire w_rst_btn_db; 
    
    // Debounce top level button - invert reset to have debounced negedge reset
    localparam DELAY_TOP_TB = 240_000; //240_000 when uploading to hardware, 10 when simulating in testbench 
    debouncer #(.DELAY(DELAY_TOP_TB)) top_btn_db (
        .i_clk(i_top_clk),
        .i_btn_in(~i_top_rst),
        .o_btn_db(w_rst_btn_db)
    ); 
    
    // Double FF for negedge reset synchronization 
    always @(posedge i_top_clk or negedge w_rst_btn_db) begin
        if(!w_rst_btn_db) 
            {r2_rstn_top_clk, r1_rstn_top_clk} <= 0; 
        else              
            {r2_rstn_top_clk, r1_rstn_top_clk} <= {r1_rstn_top_clk, 1'b1}; 
    end 

    always @(posedge w_clk148m or negedge w_rst_btn_db) begin
        if(!w_rst_btn_db) 
            {r2_rstn_clk25m, r1_rstn_clk25m} <= 0; 
        else              
            {r2_rstn_clk25m, r1_rstn_clk25m} <= {r1_rstn_clk25m, 1'b1}; 
    end

    always @(posedge i_top_pclk or negedge w_rst_btn_db) begin
        if(!w_rst_btn_db) 
            {r2_rstn_pclk, r1_rstn_pclk} <= 0; 
        else              
            {r2_rstn_pclk, r1_rstn_pclk} <= {r1_rstn_pclk, 1'b1}; 
    end 
    
    // FPGA-camera interface
    cam_top #(.CAM_CONFIG_CLK(100_000_000)) OV7670_cam (
        .i_clk(i_top_clk),
        .i_rstn_clk(r2_rstn_top_clk),
        .i_rstn_pclk(r2_rstn_pclk),
        
        // I/O for camera init
        .i_cam_start(i_top_cam_start),
        .o_cam_done(o_top_cam_done), 
        
        // I/O camera
        .i_pclk(i_top_pclk),
        .i_pix_byte(i_top_pix_byte), 
        .i_vsync(i_top_pix_vsync), 
        .i_href(i_top_pix_href),
        .o_reset(o_top_reset),
        .o_pwdn(o_top_pwdn),
        .o_siod(o_top_siod),
        .o_sioc(o_top_sioc), 
        
        // Outputs from camera to BRAM
        .o_pix_wr(o_wr),
        .o_pix_data(i_bram_pix_data),
        .o_pix_addr(i_bram_pix_addr),
        .my_addr(my_addr)
    );
    
    blk_mem_gen_img mem_img (
      .clka(w_clk148m),           // clock for port A
      .ena(1'b1),                 // enable for port A (always on for writes)
      .wea(1'b1),                 // write enable for port A (always write)
      .addra(my_addr),    // address input for port A
      .dina(i_bram_pix_data),     // data input for port A
      
      .clkb(w_clk148m),           // clock for port B
      .enb(1'b1),                 // enable for port B (always on for reads)
      .addrb(o_bram_pix_addr),    // address input for port B
      .doutb(o_bram_pix_data)     // data output for port B
    );
    
    
    wire [11:0] x_idx, y_idx;
    wire video_enable;
    wire [11:0] temp;
    assign temp = o_bram_pix_data;


    
    ila_0 my_ila (
        .clk(w_clk148m), // input wire clk
    
        .probe0(i_bram_pix_data), // input wire [11:0]  probe0  
        .probe1(o_bram_pix_data), // input wire [11:0]  probe1 
        .probe2(i_bram_pix_addr), // input wire [16:0]  probe2 
        .probe3(o_bram_pix_addr), // input wire [16:0]  probe3 
        .probe4(i_top_pix_vsync), // input wire [0:0]  probe4 
        .probe5(i_top_pix_href) // input wire [0:0]  probe5
    );

    vga_controller vga_cont_inst1 (
        .clk(w_clk148m), 
        .reset(r2_rstn_clk25m),
        .h_sync(o_top_vga_hsync),
        .v_sync(o_top_vga_vsync),
        .x_idx(x_idx),
        .y_idx(y_idx),
        .video_enable(video_enable)
    );
    
    always @(posedge w_clk148m or posedge i_top_rst) begin
        if (i_top_rst) begin
            o_bram_pix_addr <= 17'b0;
            {o_top_vga_red, o_top_vga_green, o_top_vga_blue} <= {3{4'b0000}};
        end else if (video_enable) begin
//            if(x_idx <= 384 && y_idx <= 216) begin
//                o_bram_pix_addr <= y_idx * 384 + x_idx;
//                o_top_vga_red <= o_bram_pix_data[11:8];
//                o_top_vga_green <= o_bram_pix_data[7:4];
//                o_top_vga_blue <= o_bram_pix_data[3:0];
//            end
//            else 
//                {o_top_vga_red, o_top_vga_green, o_top_vga_blue} <= {3{4'b0000}};

            o_bram_pix_addr <= (y_idx / 5) * 384 + (x_idx / 5);
            o_top_vga_red <= o_bram_pix_data[11:8];
            o_top_vga_green <= o_bram_pix_data[7:4];
            o_top_vga_blue <= o_bram_pix_data[3:0];
//            o_top_vga_red <= 4'b1100;
//            o_top_vga_green <= 4'b0000;
//            o_top_vga_blue <= 4'b1100;          

        end else begin
            {o_top_vga_red, o_top_vga_green, o_top_vga_blue} <= {3{4'b0000}};
        end
    end
    
    
endmodule
