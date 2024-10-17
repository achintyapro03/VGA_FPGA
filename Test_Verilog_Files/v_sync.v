module v_sync_controller #(
    parameter front_porch_v = 4,
    parameter sync_width_v = 5,
    parameter back_porch_v = 36,
    parameter pixels_v = 1080  
)(
    input clk,
    input reset,
    input next_line,  // Ensure this is driven from the horizontal sync controller
    output reg v_sync,
    output reg video_enable
);

    reg [11:0] counter;
    wire [11:0] total_pixels;

    assign total_pixels = pixels_v + front_porch_v + sync_width_v + back_porch_v;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 12'b0;
            v_sync <= 1'b1;
            video_enable <= 1'b0;
        end else if (next_line) begin  // Increment counter on next_line signal
            if (counter == total_pixels - 1) begin
                counter <= 12'b0;
            end else begin
                counter <= counter + 1'b1;
            end

            if (counter < pixels_v) begin
                video_enable <= 1'b1;  
            end else begin
                video_enable <= 1'b0;  
            end

            if (counter >= (pixels_v + front_porch_v) && counter < (pixels_v + front_porch_v + sync_width_v)) begin
                v_sync <= 1'b0;  
            end else begin
                v_sync <= 1'b1;  
            end
        end
    end
endmodule
