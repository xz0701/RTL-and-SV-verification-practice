module model #(parameter
  DATA_WIDTH = 16
) (
  input clk,
  input resetn,
  input din,
  output logic [DATA_WIDTH-1:0] dout
);

  // always_ff @(posedge clk) begin
  //   if (!resetn) begin
  //     dout <= 'b0;
  //   end
  //   else
  //     dout <= {dout[DATA_WIDTH - 2 : 0], din}; // if DATAWIDTH = 1, error!
  // end

  logic [DATA_WIDTH - 1 : 0] shift_reg;
  always_ff @(posedge clk) begin
    if (!resetn)
      shift_reg <= 'b0;
    else
      shift_reg <= (shift_reg << 1) + din;
  end

  assign dout = shift_reg;
  
endmodule