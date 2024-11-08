`timescale 1ns / 1ps
`default_nettype none

/*
 *  Synchronous ROM that contains OV7670 reg addr, OV7670 reg data;
 *  End of ROM is marked by o_dout = 16'hFF_FF
 *
 *  NOTE:  
 *  - One clock cycle delay
 *  - Must reset SCCB registers first then include 10 ms delay after
 *    to allow the change to settle
 *  
 */

module cam_rom
    (   input wire        i_clk,
        input wire        i_rstn,
        input wire  [7:0] i_addr,
        output reg [15:0] o_dout
    );
    
    // Registers for OV7670 for configuration of RGB 565 
    always @(posedge i_clk or negedge i_rstn) begin
        if(!i_rstn) o_dout <= 0; 
        else begin 
            case(i_addr)
            0:  o_dout <= 16'h12_80; // Reset all registers to default
            1:  o_dout <= 16'h12_04; // Set output format to RGB
            2:  o_dout <= 16'h15_20; // PCLK will not toggle during horizontal blank
            3:  o_dout <= 16'h40_d0; // RGB565 mode
            
            // Configuration values
            4:  o_dout <= 16'h12_04; // COM7, set RGB color output
            5:  o_dout <= 16'h11_80; // CLKRC, internal PLL matches input clock
            6:  o_dout <= 16'h0C_00; // COM3, default settings
            7:  o_dout <= 16'h3E_00; // COM14, no scaling, normal pclock
            8:  o_dout <= 16'h04_00; // COM1, disable CCIR656
            9:  o_dout <= 16'h8C_02; // COM15, RGB565, full output range
            10: o_dout <= 16'h3a_04; // TSLB, correct output data sequence (magic)
            11: o_dout <= 16'h14_18; // COM9, MAX AGC value x4
            12: o_dout <= 16'h4F_B3; // MTX1, magical matrix coefficient
            13: o_dout <= 16'h50_B3; // MTX2
            14: o_dout <= 16'h51_00; // MTX3
            15: o_dout <= 16'h52_3d; // MTX4
            16: o_dout <= 16'h53_A7; // MTX5
            17: o_dout <= 16'h54_E4; // MTX6
            18: o_dout <= 16'h58_9E; // MTXS
            19: o_dout <= 16'h3D_C0; // COM13, sets gamma enable
            20: o_dout <= 16'h17_14; // HSTART, start high 8 bits
            21: o_dout <= 16'h18_02; // HSTOP, stop high 8 bits
            22: o_dout <= 16'h32_80; // HREF, edge offset
            23: o_dout <= 16'h19_03; // VSTART, start high 8 bits
            24: o_dout <= 16'h1A_7B; // VSTOP, stop high 8 bits
            25: o_dout <= 16'h03_0A; // VREF, vsync edge offset
            26: o_dout <= 16'h0F_41; // COM6, reset timings
            27: o_dout <= 16'h1E_00; // MVFP, disable mirror/flip
            28: o_dout <= 16'h33_0B; // CHLF, magic value
            29: o_dout <= 16'h3C_78; // COM12, no HREF when VSYNC low
            30: o_dout <= 16'h69_00; // GFIX, fix gain control
            31: o_dout <= 16'h74_00; // REG74, digital gain control
            32: o_dout <= 16'hB0_84; // RSVD, required for good color
            33: o_dout <= 16'hB1_0c; // ABLC1
            34: o_dout <= 16'hB2_0e; // RSVD, more values
            35: o_dout <= 16'hB3_80; // THL_ST
            36: o_dout <= 16'h70_3a; // SCALING_XSC
            37: o_dout <= 16'h71_35; // SCALING_YSC
            38: o_dout <= 16'h72_11; // SCALING DCWCTR
            39: o_dout <= 16'h73_f0; // SCALING PCLK_DIV
            40: o_dout <= 16'ha2_02; // SCALING PCLK DELAY
            
            // Gamma curve values
            41: o_dout <= 16'h7a_20; // SLOP
            42: o_dout <= 16'h7b_10; // GAM1
            43: o_dout <= 16'h7c_1e; // GAM2
            44: o_dout <= 16'h7d_35; // GAM3
            45: o_dout <= 16'h7e_5a; // GAM4
            46: o_dout <= 16'h7f_69; // GAM5
            47: o_dout <= 16'h80_76; // GAM6
            48: o_dout <= 16'h81_80; // GAM7
            49: o_dout <= 16'h82_88; // GAM8
            50: o_dout <= 16'h83_8f; // GAM9
            51: o_dout <= 16'h84_96; // GAM10
            52: o_dout <= 16'h85_a3; // GAM11
            53: o_dout <= 16'h86_af; // GAM12
            54: o_dout <= 16'h87_c4; // GAM13
            55: o_dout <= 16'h88_d7; // GAM14
            56: o_dout <= 16'h89_e8; // GAM15
            
            // AGC and AEC
            57: o_dout <= 16'h13_e0; // COM8, disable AGC/AEC
            58: o_dout <= 16'h00_00; // Set gain reg to 0 for AGC
            59: o_dout <= 16'h10_00; // Set ARCJ reg to 0
            60: o_dout <= 16'h0d_40; // Reserved bit for COM4
            61: o_dout <= 16'h14_18; // COM9, 4x gain + magic bit
            62: o_dout <= 16'ha5_05; // BD50MAX
            63: o_dout <= 16'hab_07; // DB60MAX
            64: o_dout <= 16'h24_95; // AGC upper limit
            65: o_dout <= 16'h25_33; // AGC lower limit
            66: o_dout <= 16'h26_e3; // AGC/AEC fast mode op region
            67: o_dout <= 16'h9f_78; // HAECC1
            68: o_dout <= 16'ha0_68; // HAECC2
            69: o_dout <= 16'ha1_03; // Magic value
            70: o_dout <= 16'ha6_d8; // HAECC3
            71: o_dout <= 16'ha7_d8; // HAECC4
            72: o_dout <= 16'ha8_f0; // HAECC5
            73: o_dout <= 16'ha9_90; // HAECC6
            74: o_dout <= 16'haa_94; // HAECC7
            75: o_dout <= 16'h13_e5; // COM8, enable AGC/AEC
            76: o_dout <= 16'h1E_23; // Mirror Image
            77: o_dout <= 16'h69_06; // Gain of RGB (manually adjusted)
            default: o_dout <= 16'hFF_FF; // End of ROM marker
            endcase
        end
    end
endmodule
