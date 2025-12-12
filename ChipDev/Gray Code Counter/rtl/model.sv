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
      temp <= '0;
      bin_code <= 1;
    end
    else begin
      bin_code <= bin_code + 1;
      for (int i = 0; i < DATA_WIDTH - 1; i = i + 1) begin
        temp[i] <= bin_code[i] ^ bin_code[i + 1];
      end
      temp[DATA_WIDTH - 1] <= bin_code[DATA_WIDTH - 1];
    end
  end

  assign out = temp;
  
endmodule