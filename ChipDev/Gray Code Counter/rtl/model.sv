module model #(parameter
  DATA_WIDTH = 4
) (
  input clk,
  input resetn,
  output logic [DATA_WIDTH-1:0] out
);
  logic [DATA_WIDTH - 1 : 0] bin_code, temp;

  always_ff @(posedge clk) begin
    if (~resetn) begin
      out <= '0;
      bin_code <= '0;
    end
    else begin
      bin_code <= bin_code + 1'b1;
      out <= (bin_code + 1'b1) ^ ((bin_code + 1'b1) >> 1'b1);
    end
  end
  
endmodule