module v_sync_controller #(
    parameter front_porch_v = 4,
    parameter sync_width_v = 5,
    parameter back_porch_v = 36,
    parameter pixels_v = 1080, 
    parameter h_total = 2200
)(
    input wire clk,
    input wire reset,
    output reg v_sync,
    output reg video_enable,
    input wire [11:0] x_idx,    
    output reg [11:0] y_idx 
);

    reg [11:0] counter;
    wire [11:0] total_pixels;

    assign total_pixels = pixels_v + front_porch_v + sync_width_v + back_porch_v;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 12'b0;
            v_sync <= 1'b1;
            video_enable <= 1'b0;
        end else if (x_idx == h_total - 1) begin
            if (counter == total_pixels - 1) 
                counter <= 0;
            else
                counter <= counter + 1'b1;

            if (counter >= pixels_v + front_porch_v && counter < pixels_v + front_porch_v + sync_width_v)
                v_sync <= 1'b0;
            else
                v_sync <= 1'b1;
            
            if (counter < pixels_v)
                video_enable <= 1'b1;
            else
                video_enable <= 1'b0;

            y_idx <= counter; 
        end
    end
endmodule
