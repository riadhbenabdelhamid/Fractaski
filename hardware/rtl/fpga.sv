module fpga #(
    parameter int MMCM_OUT_FREQ = `MMCM_OUT_FREQ_MHZ,
    parameter int N = 8,
    parameter int M = 8
) (
    input logic switch,
    input  logic clk,
    output logic res_status,
    output logic VGA_HS,
    output logic VGA_VS,
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B
);


  logic [17:0] vga_global_addr;
  logic [7:0] vga_global_data;

  logic clkout0;//MMCM main generated clock
  logic clkout1;  // vga clock
  logic ibuf_reset;  // buffered external input reset
  logic sync_reset;  // synchronized reset
  logic locked;  // MMCM locked signal
  logic ibuf_reset_or_not_locked;  // synchronized reset

  //temporary VGA signals
  logic VGA_HS_TMP;
  logic VGA_VS_TMP;
  logic [3:0] VGA_R_TMP;
  logic [3:0] VGA_G_TMP;
  logic [3:0] VGA_B_TMP;
  //=======================================================
  //=========       CLK generate   ========================
  //=======================================================
  MMCM_clock_gen_7series #(
      .MMCM_OUT_FREQ(MMCM_OUT_FREQ)
  ) MMCM_clock_gen_inst (
      .CLKIN1(clk),
      .ASYNC_RESET(ibuf_reset),
      .CLK_OUT0(clkout0),
      .CLK_OUT1(clkout1),
      .LOCKED(locked)
  );

  //=======================================================
  //=========      ASYNC RESET synchronizer    ===========
  //=======================================================
  async_reset_synchronizer#(0) sync_reset_gen_inst (
      .clk(clkout0),
      .async_reset(ibuf_reset_or_not_locked),
      .sync_reset(sync_reset)
  );

  assign res_status = sync_reset;

  IBUF input_buf_async_reset (
      .O(ibuf_reset),
      .I(switch)
  );

  assign ibuf_reset_or_not_locked = ibuf_reset | ~locked;

  //=======================================================
  //=========      MANYCORE wrapper             ===========
  //=======================================================
    manycore_wrapper #(
        .N(N),
        .M(M)
    ) cores_wrapper (
        .clk(clkout0),
        .clkvga(clkout1),
        .reset(sync_reset),
        .global_addr(vga_global_addr),
        .global_rd_data(vga_global_data)
    );

  //=======================================================
  //=========      VGA controller               ===========
  //=======================================================
    always_ff @(posedge clkout1) begin
	    if (sync_reset) begin
		    VGA_HS <= 0;
		    VGA_VS <= 0;
		    VGA_R <= 0;
		    VGA_G <= 0;
		    VGA_B <= 0;
            end else begin
		    VGA_HS <= VGA_HS_TMP;
		    VGA_VS <= VGA_VS_TMP;
		    VGA_R <= VGA_R_TMP;
		    VGA_G <= VGA_G_TMP;
		    VGA_B <= VGA_B_TMP;
	    end
    end

    vga_controller vga_controller_inst (
        .clk(clkout1),
        .reset(sync_reset),
        .VRAM_data(vga_global_data),
        .VRAM_addr(vga_global_addr),
        .VGA_hsync(VGA_HS_TMP),
        .VGA_vsync(VGA_VS_TMP),
        .VGA_R(VGA_R_TMP),
        .VGA_G(VGA_G_TMP),
        .VGA_B(VGA_B_TMP)
    );


endmodule
