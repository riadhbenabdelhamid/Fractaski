module manycore_wrapper #(
    parameter int N = 8, // Rows
    parameter int M = 8 // Columns
)(
    input logic clk,
    input logic clkvga,
    input logic reset,
    input logic [17:0] global_addr,
    output logic [7:0] global_rd_data
);

    logic [7:0] core_rd_data [N][M];
    logic [11:0] local_addr;                 
    logic [2:0] core_select_row;    
    logic [2:0] core_select_col;    

    // Intermediate multiplexer signals
    logic [7:0] row_mux [M-1:0];

    logic [M*N-1:0] reqs ;
    logic grant ;

    always_ff @(posedge clk) begin
	    if (reset) begin  
		    grant <= 0;
	    end else begin
		    // grant transition from 1 to 0 when all reqs are set to 0 again
		    if (grant) begin
			    grant <= |reqs;
		    // grant transition from 0 to 1 when all reqs are set to 1
		    end else begin
			    grant <= &reqs;
		    end
	    end
    end

    always_ff @(posedge clkvga) begin
      core_select_row <= global_addr[17:15];    // block_row
      core_select_col <= global_addr[14:12];    // block_col
    end
    
    assign local_addr      = global_addr[11:0];     // pixel_row[5:0], pixel_col[5:0]
    //
    genvar i, j;
    generate
        for(i = 0; i < N; i++) begin : row_gen
            for(j = 0; j < M; j++) begin : col_gen
                RISCV_core_top_extended_fractaski #(
                  .IDcluster(j),      
                  .IDrow(0),
                  .IDminirow(0),
                  .IDposx(i)
                ) core_inst(
                    .clk(clk),
                    .clkvga(clkvga),
                    .reset(reset),
                    .i_VRAM_addr(local_addr),
                    .o_VRAM_rd_data(core_rd_data[i][j]),
		    .o_core_req(reqs[j*N+i]),
		    .i_core_grant(grant)
                );
            end
        end
    endgenerate

    always_comb begin
        for (int  row= 0; row < N; row++) begin
            row_mux[row] = core_rd_data[row][core_select_col];
        end
        // Second multiplexer stage (selecting row)
        global_rd_data = row_mux[core_select_row];
    end

endmodule

