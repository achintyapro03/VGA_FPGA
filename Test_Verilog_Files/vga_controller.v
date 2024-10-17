module vga_controller (
    input clk,
    input reset, 
    output h_sync,
    output v_sync, 
    output video_enable
);

    parameter front_porch_h = 88;
    parameter sync_width_h  = 44;
    parameter back_porch_h  = 148;
    parameter pixels_h      = 1920;

    parameter front_porch_v = 4;
    parameter sync_width_v  = 5;
    parameter back_porch_v  = 36;
    parameter pixels_v      = 1080; 

    wire h_sync, v_sync;
    wire video_enable_h, video_enable_v;
    wire video_enable;

    wire next_line;

    assign video_enable = video_enable_h & video_enable_v;

    h_sync_controller #(
        .front_porch_h(front_porch_h), 
        .sync_width_h(sync_width_h), 
        .back_porch_h(back_porch_h), 
        .pixels_h(pixels_h)
    ) h_cont (
        .clk(clk),
        .reset(reset), 
        .h_sync(h_sync), 
        .video_enable(video_enable_h),
        .next_line(next_line)
    );

    v_sync_controller #(
        .front_porch_v(front_porch_v), 
        .sync_width_v(sync_width_v), 
        .back_porch_v(back_porch_v), 
        .pixels_v(pixels_v)
    ) v_cont (
        .clk(clk),
        .reset(reset), 
        .next_line(next_line),
        .v_sync(v_sync), 
        .video_enable(video_enable_v)
    );

endmodule
