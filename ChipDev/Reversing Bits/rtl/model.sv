module model #(parameter
  DATA_WIDTH=32
) (
  input  [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
);
  logic [DATA_WIDTH - 1 : 0] temp;
  always_comb begin
    // has to be DATAWIDTH, not DATAWIDTH - 1
    for (int i = 0; i < DATA_WIDTH; i = i + 1) begin 
      
      temp[i] = din[DATA_WIDTH - 1 - i];
    end
  end
  assign dout = temp;
endmodule