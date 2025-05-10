// ------------------------------------------------------------
// Mandelbrot color mapper: 8-bit escape counter ➜ 4-bit RGB
// ------------------------------------------------------------
module mandelbrot_color
(
    input  logic [7:0]  escape_count,   // 0 … 255 
    output logic [3:0]  r,        //
    output logic [3:0]  g,
    output logic [3:0]  b
);
    // Local wires to hold the results
    logic [3:0] r_i, g_i, b_i;

    always_comb begin
        // Break the byte into “band” (hue) and “step” (interpolation)
        automatic logic [2:0] band  = escape_count[7:5]; // 0…7   (32-pixel stripes)
        automatic logic [4:0] step5 = escape_count[4:0]; // 0…31  (interpolation in band)
        automatic logic [3:0] t     = step5 >> 1;      // 0…15 (cheap /2 gives us 4 bits)

        unique case (band)
            3'd0 : begin // black → blue
                r_i = 4'd0;
                g_i = 4'd0;
                b_i = t;
            end
            3'd1 : begin // blue → cyan
                r_i = 4'd0;
                g_i = t;
                b_i = 4'd15;
            end
            3'd2 : begin // cyan → green
                r_i = 4'd0;
                g_i = 4'd15;
                b_i = 4'd15 - t;
            end
            3'd3 : begin // green → yellow
                r_i = t;
                g_i = 4'd15;
                b_i = 4'd0;
            end
            3'd4 : begin // yellow → red
                r_i = 4'd15;
                g_i = 4'd15 - t;
                b_i = 4'd0;
            end
            3'd5 : begin // red → magenta
                r_i = 4'd15;
                g_i = 4'd0;
                b_i = t;
            end
            3'd6 : begin // magenta → white
                r_i = 4'd15;
                g_i = t;
                b_i = 4'd15;
            end
            default : begin // 3'd7, escape_count 224-255 ⇒ inside set ⇒ black
                r_i = 4'd0;
                g_i = 4'd0;
                b_i = 4'd0;
            end
        endcase
    end

    // Drive the VGA DAC
    assign r = r_i;
    assign g = g_i;
    assign b = b_i;
endmodule

