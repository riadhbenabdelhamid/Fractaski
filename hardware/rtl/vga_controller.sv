module vga_controller (
    input  logic        clk,           // pixel clock
    input  logic        reset,        
    output logic [17:0] VRAM_addr,     // 18-bit global address
    input  logic [7:0]  VRAM_data, // read rom BRAMs
    output logic        VGA_hsync,
    output logic        VGA_vsync,
    output logic [3:0]  VGA_R,
    output logic [3:0]  VGA_G,
    output logic [3:0]  VGA_B
);

    // 800 by 600 pixel screen (40 MHz pixel clock / 60 Hz)
    localparam H_ACTIVE = 800;
    localparam H_FRONT  = 40;
    localparam H_SYNC   = 128;
    localparam H_BACK   = 88;

    localparam V_ACTIVE = 600;
    localparam V_FRONT  = 1;
    localparam V_SYNC   = 4;
    localparam V_BACK   = 23;

    parameter H_TOTAL    = H_ACTIVE + H_FRONT + H_SYNC + H_BACK; // total horizontal pixels
    parameter V_TOTAL    = V_ACTIVE + V_FRONT + V_SYNC + V_BACK; // total vertical lines

    // Horizontal and vertical counters
    logic [$clog2(H_TOTAL)-1:0] h_count;
    logic [$clog2(V_TOTAL)-1:0] v_count;

    // Pixel data buffer (due to BRAM read latency)
    logic [7:0] pixel_data;
    logic       pixel_valid; // for latency

    // Internal signals
    logic [8:0] pixel_x; // 0-511
    logic [8:0] pixel_y; // 0-511

    // Address generation
    logic [17:0] addr_next;
    logic        active_area;

    // Horizontal counter
    always_ff @(posedge clk) begin
        if (reset)
            h_count <= 0;
        else if (h_count == H_TOTAL-1)
            h_count <= 0;
        else
            h_count <= h_count + 1;
    end

    // Vertical counter
    always_ff @(posedge clk) begin
        if (reset)
            v_count <= 0;
        else if (h_count == H_TOTAL-1) begin
            if (v_count == V_TOTAL-1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end
    end

    // Generate sync signals (active low)
    assign VGA_hsync = ~((h_count >= (H_ACTIVE + H_FRONT)) && (h_count < (H_ACTIVE + H_FRONT + H_SYNC)));
    assign VGA_vsync = ~((v_count >= (V_ACTIVE + V_FRONT)) && (v_count < (V_ACTIVE + V_FRONT + V_SYNC)));

    logic [2:0] block_row ; 
    logic [2:0] block_col ; 
    logic [5:0] local_row ; 
    logic [5:0] local_col ; 

    // Address calculation
    always_comb begin
        // Determine if in active display area
        active_area = (h_count < 512) && (v_count < 512);
        // Current pixel position in active area
        pixel_x = h_count;
        pixel_y = v_count;
        if (active_area) begin
            // Determine which BRAM slice
            block_row = pixel_y[8:6]; // divide by 64
            block_col = pixel_x[8:6]; // divide by 64
            local_row = pixel_y[5:0]; // inside 64 rows
            local_col = pixel_x[5:0]; // inside 64 cols

            addr_next = {block_row, block_col, local_row, local_col};
        end else begin
            addr_next = 18'd0;
        end
    end

    
    // Pipelining for 1 cycle read latency
    always_ff @(posedge clk) begin
        if (reset) begin
            pixel_data <= 0;
            pixel_valid <= 0;
        end else begin
            pixel_data <= VRAM_data; 
            pixel_valid <= active_area;
        end
    end

    logic [3:0] R_LUT, G_LUT, B_LUT;
    mandelbrot_color mandelbrot_color_inst (
       .escape_count(pixel_data), 
       .r(R_LUT),
       .g(G_LUT),
       .b(B_LUT)
   );

    // Output RGB aligned properly with data availability
    always_comb begin
      if (pixel_valid) begin
          VGA_R = R_LUT;
          VGA_G = G_LUT;
          VGA_B = B_LUT;
      end else begin
          VGA_R = 4'b0;
          VGA_G = 4'b0;
          VGA_B = 4'b0;
      end
    end


    assign VRAM_addr = addr_next;

endmodule

