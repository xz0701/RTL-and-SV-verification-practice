module model #(parameter
  DATA_WIDTH = 16
) (
  input [DATA_WIDTH-1:0] gray,
  output logic [DATA_WIDTH-1:0] bin
);

  logic [DATA_WIDTH - 1 : 0] temp;

  always @(*) begin
    for(int i = 0; i < DATA_WIDTH; i = i + 1) begin
        temp[i] = ^(gray >> i);
    end
  end

  assign bin = temp;

endmodule