`include "mmcm_lookup_params.svh"

module MMCM_clock_gen_7series #(
    parameter int MMCM_OUT_FREQ = 300
) 
(
    input CLKIN1,
    input ASYNC_RESET,
    output CLK_OUT0,
    output CLK_OUT1,
    output LOCKED
);

    // Function to derive Master Divider (D)
    function int DeriveMasterDiv(input int freq);
    // Default to 0 if no match found
    DeriveMasterDiv = 0;

    // Loop through the `desired_freqs` array to find a match
    for (int i = 0; i < $size(desired_freqs); i++) begin
        if (freq == desired_freqs[i]) begin
            // If a match is found, return the corresponding D_value
	    $display ("Dval = %d", D_values[i]);
            return D_values[i];
        end
    end
    endfunction

    // Function to derive Master Multiplier (M)
    function real DeriveMasterMult (input int freq);
    // Default to 0 if no match found
    DeriveMasterMult = 0.0;

    // Loop through the `desired_freqs` array to find a match
    for (int i = 0; i < $size(desired_freqs); i++) begin
        if (freq == desired_freqs[i]) begin
            // If a match is found, return the corresponding M_value
	    $display ("Mval = %f", M_values[i]);
            return M_values[i];
        end
    end
    endfunction

    // Function to derive Output Divider (O)
    function real DeriveOutDiv (input int freq);
    // Default to 0 if no match found
    DeriveOutDiv = 0.0;

    // Loop through the `desired_freqs` array to find a match
    for (int i = 0; i < $size(desired_freqs); i++) begin
        if (freq == desired_freqs[i]) begin
            // If a match is found, return the corresponding O_value
	    $display ("Oval = %f", O_values[i]);
            return O_values[i];
        end
    end
    endfunction


    //localparam int Dval = DeriveMasterDiv(MMCM_OUT_FREQ);
    //localparam real Mval = DeriveMasterMult(MMCM_OUT_FREQ);
    //localparam real Oval = DeriveOutDiv(MMCM_OUT_FREQ);

    localparam int Dval = 1;
    localparam real Mval =10.0;
    //localparam real Oval =3.5;
    localparam real Oval =10.0;
    //localparam real Oval =20.0; //50 Mhz


    wire clkout0;
    wire clkout1;
    wire    clk_in1_clk_wiz_0;
    wire    locked_int;
    wire    clkfbout_clk_wiz_0;
    wire    clkfbout_buf_clk_wiz_0;
    wire    reset_high;

    BUFG clkin1_ibufg(
        .O (clk_in1_clk_wiz_0),
        .I (CLKIN1)
    );

    // Clocking PRIMITIVE
    //------------------------------------
    MMCME2_ADV #(
        .BANDWIDTH            ("OPTIMIZED"),
        .CLKOUT4_CASCADE      ("FALSE"),
        .COMPENSATION         ("ZHOLD"),
        .STARTUP_WAIT         ("FALSE"),
        .DIVCLK_DIVIDE        (Dval),
        .CLKFBOUT_MULT_F      (Mval),
        .CLKFBOUT_PHASE       (0.000),
        .CLKFBOUT_USE_FINE_PS ("FALSE"),
        .CLKOUT0_DIVIDE_F     (Oval),
        //.CLKOUT1_DIVIDE     (20.0), //50MHz
        .CLKOUT1_DIVIDE     (25.0), //40MHz
        //.CLKOUT1_DIVIDE     (40.0), //25MHz
        .CLKOUT0_PHASE        (0.000),
        .CLKOUT0_DUTY_CYCLE   (0.500),
        .CLKOUT0_USE_FINE_PS  ("FALSE"),
        .CLKIN1_PERIOD        (10.000)
    )
  mmcm_adv_inst
   (
        .CLKFBOUT            (clkfbout_clk_wiz_0),
        .CLKFBOUTB           (),
        .CLKOUT0             (clkout0),
        .CLKOUT0B            (),
        .CLKOUT1             (clkout1),
        .CLKOUT1B            (),
        .CLKOUT2             (),
        .CLKOUT2B            (),
        .CLKOUT3             (),
        .CLKOUT3B            (),
        .CLKOUT4             (),
        .CLKOUT5             (),
        .CLKOUT6             (),
         // Input clock control
        .CLKFBIN             (clkfbout_buf_clk_wiz_0),
        .CLKIN1              (clk_in1_clk_wiz_0),
        .CLKIN2              (1'b0),
        // Tied to always select the primary input clock
        .CLKINSEL            (1'b1),
        // Ports for dynamic reconfiguration
        .DADDR               (7'h0),
        .DCLK                (1'b0),
        .DEN                 (1'b0),
        .DI                  (16'h0),
        .DO                  (),
        .DRDY                (),
        .DWE                 (1'b0),
        // Ports for dynamic phase shift
        .PSCLK               (1'b0),
        .PSEN                (1'b0),
        .PSINCDEC            (1'b0),
        .PSDONE              (),
        // Other control and status signals
        .LOCKED              (locked_int),
        .CLKINSTOPPED        (),
        .CLKFBSTOPPED        (),
        .PWRDWN              (1'b0),
        .RST                 (reset_high) 
    );
    
    assign reset_high = ASYNC_RESET; 
    assign LOCKED = locked_int;

    BUFG clkf_buf (
        .O (clkfbout_buf_clk_wiz_0),
        .I (clkfbout_clk_wiz_0)
    );

    BUFG clkout0_buf ( 
        .O (CLK_OUT0),
        .I (clkout0)
    );

    BUFG clkout1_buf ( 
        .O (CLK_OUT1),
        .I (clkout1)
    );
endmodule

