module model #(parameter
  DATA_WIDTH = 32
) (
  input  [DATA_WIDTH-1:0] din,
  output logic [$clog2(DATA_WIDTH):0] dout
);
  logic [$clog2(DATA_WIDTH) : 0] num_zero;
  logic [DATA_WIDTH - 1 : 0] temp;
  assign temp = din & (~din + 1);
  always_comb begin
    if (temp == '0) begin
      num_zero = DATA_WIDTH;
    end
    else begin
      num_zero = '0;
      for (int i = 0; i < DATA_WIDTH; i = i + 1) begin
        num_zero = temp[i] ? i : num_zero;
      end
    end
  end
  assign dout = num_zero;
endmodule