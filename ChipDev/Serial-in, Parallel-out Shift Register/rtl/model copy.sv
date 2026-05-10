module model #(parameter
  DATA_WIDTH = 16
) (
  input clk,
  input resetn,
  input din,
  output logic [DATA_WIDTH-1:0] dout
);
  logic [DATA_WIDTH - 1 : 0] shift_reg;
  always_ff @(posedge clk) begin
    if (!resetn) begin
      shift_reg <= '0;
    end
    else begin
      shift_reg <= shift_reg << 1 + din;
    end
  end
  assign dout = shift_reg;
endmodule