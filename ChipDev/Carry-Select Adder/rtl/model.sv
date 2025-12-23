`include "full_adder.sv"
`include "rca.sv"

module model (
    input [23:0] a,
    input [23:0] b,
    output logic [24:0] result
);

    localparam DATA_WIDTH = 24;  // Word bitwidth
    localparam STAGE_WIDTH = 8;  // RCA stage bitwidth
    localparam NSTAGE = DATA_WIDTH / STAGE_WIDTH;

    logic [STAGE_WIDTH-1:0] psum_0 [NSTAGE-1:0];
    logic [STAGE_WIDTH-1:0] psum_1 [NSTAGE-1:0];
    logic cout_0 [NSTAGE-1:0];
    logic cout_1 [NSTAGE-1:0];
    logic cout [NSTAGE-1:0];

    // RCA instances
    genvar i;
    generate
        for (i = 0; i < NSTAGE; i++) begin
            if (i == 0) begin
                rca #(.DATA_WIDTH(STAGE_WIDTH)) rca_8b_cin0 (.a(a[7:0]), .b(b[7:0]), .sum({cout_0[0], psum_0[0]}), .cin(1'b0));
            end else begin
                rca #(.DATA_WIDTH(STAGE_WIDTH)) rca_8b_cin0 (.a(a[STAGE_WIDTH*(i+1)-1:(STAGE_WIDTH*i)]), .b(b[STAGE_WIDTH*(i+1)-1:(STAGE_WIDTH*i)]), .sum({cout_0[i], psum_0[i]}), .cin(1'b0));
                rca #(.DATA_WIDTH(STAGE_WIDTH)) rca_8b_cin1 (.a(a[STAGE_WIDTH*(i+1)-1:(STAGE_WIDTH*i)]), .b(b[STAGE_WIDTH*(i+1)-1:(STAGE_WIDTH*i)]), .sum({cout_1[i], psum_1[i]}), .cin(1'b1));
            end
        end
    endgenerate

    // Select between partial sum (cin = 0), and partial sum (cin = 1)
    generate
        for (i = 0; i < NSTAGE; i++) begin
            if (i == 0) begin
                assign result[7:0] = psum_0[0];
            end else begin
                assign result[STAGE_WIDTH*(i+1)-1:(STAGE_WIDTH*i)] = cout[i-1] ? psum_1[i] : psum_0[i];
            end
        end
    endgenerate

    // Muxes for selecting the carry-out bit of the parallel RCAs
    // The cout bit propagates from stage i to stage i+1
    generate
        for (i = 0; i < NSTAGE; i++) begin
            if (i == 0) begin
                assign cout[0] = cout_0[0];
            end else begin
                assign cout[i] = cout[i-1] ? cout_1[i] : cout_0[i];
            end
        end
    endgenerate

    assign result[DATA_WIDTH] = cout[NSTAGE-1];

endmodule