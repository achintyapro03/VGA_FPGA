module vga_controller (
    input wire clk,
    input wire reset, 
    output wire h_sync,       
    output wire v_sync,      
    output wire [11:0] x_idx, 
    output wire [11:0] y_idx, 
    output wire video_enable
);

    wire reset_inv;
    assign reset_inv = ~reset;
    parameter pixels_h      = 1920;
    parameter front_porch_h = 88;
    parameter sync_width_h  = 44;
    parameter back_porch_h  = 148;

    parameter pixels_v      = 1080; 
    parameter front_porch_v = 4;
    parameter sync_width_v  = 5;
    parameter back_porch_v  = 36;

    wire video_enable_h, video_enable_v;

    assign video_enable = video_enable_h && video_enable_v;
    localparam h_total = pixels_h + front_porch_h + sync_width_h + back_porch_h;

    h_sync_controller #(
        .front_porch_h(front_porch_h), 
        .sync_width_h(sync_width_h), 
        .back_porch_h(back_porch_h), 
        .pixels_h(pixels_h)
    ) h_cont (
        .clk(clk),
        .reset(reset_inv), 
        .h_sync(h_sync),           
        .video_enable(video_enable_h),
        .x_idx(x_idx)             
    );

    v_sync_controller #(
        .front_porch_v(front_porch_v), 
        .sync_width_v(sync_width_v), 
        .back_porch_v(back_porch_v), 
        .pixels_v(pixels_v),
        .h_total(h_total)
    ) v_cont (
        .clk(clk),
        .reset(reset_inv), 
        .v_sync(v_sync),            
        .video_enable(video_enable_v),
        .x_idx(x_idx),            
        .y_idx(y_idx)               
    );
endmodule
