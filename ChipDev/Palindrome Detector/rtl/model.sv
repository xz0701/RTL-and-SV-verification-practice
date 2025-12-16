module model #(parameter
  DATA_WIDTH=32
) (
  input [DATA_WIDTH-1:0] din,
  output logic dout
);

  // logic [DATA_WIDTH - 1 : 0] temp;
  // always_comb begin
  //   for (int i = 0; i < DATA_WIDTH; i = i + 1) begin
  //     temp[i] = din[DATA_WIDTH - i - 1];
  //   end
  // end
  // assign dout = (temp == din);

  // a better way
  logic flag;
  always_comb begin
    flag = 1'b1;
    for (int i = 0; i < DATA_WIDTH / 2; i = i + 1) begin
      flag = flag && (din[i] == din[DATA_WIDTH - 1 - i]);
    end
  end
  assign dout = flag;
endmodule