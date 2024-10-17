module h_sync_controller #(
    parameter front_porch_h = 88,
    parameter sync_width_h  = 44,
    parameter back_porch_h  = 148,
    parameter pixels_h      = 1920
)(
    input clk,
    input reset,
    output reg h_sync,
    output reg video_enable,
    output reg [11:0] x_idx
);

    reg [11:0] counter;
    wire [11:0] total_pixels;
    
    assign total_pixels = pixels_h + front_porch_h + sync_width_h + back_porch_h;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 12'b0;
            h_sync <= 1'b1;
            video_enable <= 1'b0;
        end else begin
            if (counter == total_pixels - 1) 
                counter <= 0;
            else 
                counter <= counter + 1'b1;
            
            if (counter >= pixels_h + front_porch_h && counter < pixels_h + front_porch_h + sync_width_h)
                h_sync <= 1'b0;
            else
                h_sync <= 1'b1;
            
            if (counter < pixels_h)
                video_enable <= 1'b1;
            else
                video_enable <= 1'b0;
              
            x_idx <= counter; 
        end
    end
endmodule
