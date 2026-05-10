module model #(parameter
  DATA_WIDTH = 16
) (
  input [DATA_WIDTH-1:0] gray,
  output logic [DATA_WIDTH-1:0] bin
);

  always_comb begin
    bin[DATA_WIDTH - 1] = gray[DATA_WIDTH - 1];
    for(int i = DATA_WIDTH - 2; i >= 0; i = i - 1) begin
        bin[i] = gray[i] ^ bin[i + 1];
    end
  end

endmodule