module model (
    input logic clk,
    input logic resetn,
    input logic din,
    input logic cen,
    output logic doutx,
    output logic douty 
);

    typedef enum logic [4 : 0] {
        S0 = 5'b0_0001, 
        S1 = 5'b0_0010, 
        S2 = 5'b0_0100, 
        S3 = 5'b0_1000, 
        S4 = 5'b1_0000
    } state_t;

    state_t state, next_state;

    logic din_reg, cen_reg;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            state <= S0;
            din_reg <= 0;
            cen_reg <= 0;
        end 
        else begin
            state <= next_state;
            din_reg <= din;
            cen_reg <= cen;
        end
    end

    always_comb begin
        case (state)
            S0:      next_state = din_reg ? S3 : S1;
            S1:      next_state = din_reg ? S3 : S2;
            S2:      next_state = din_reg ? S3 : S2;
            S3:      next_state = din_reg ? S4 : S1;
            S4:      next_state = din_reg ? S4 : S1;
            default: next_state = S0;
        endcase
    end

    // Output Logic
    assign doutx = cen_reg ? ((state == S1 | state == S2) & ~din_reg) | 
                            ((state == S3 | state == S4) & din_reg) : 0;
    assign douty = cen_reg ? (state == S2 & ~din_reg) | 
                             (state == S4 & din_reg) : 0;

endmodule