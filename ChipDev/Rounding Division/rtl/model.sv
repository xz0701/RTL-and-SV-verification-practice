module model #(parameter
  DIV_LOG2=3,
  OUT_WIDTH=32,
  IN_WIDTH=OUT_WIDTH+DIV_LOG2
) (
  input [IN_WIDTH-1:0] din,
  output logic [OUT_WIDTH-1:0] dout
);
  logic [DIV_LOG2 - 1  : 0] fractional;
  logic [OUT_WIDTH - 1 : 0] base;
  logic [OUT_WIDTH     : 0] rounded;   // add one extra bit

  assign fractional = din[DIV_LOG2 - 1 : 0];               // fractional bits
  assign base       = din[IN_WIDTH - 1 : DIV_LOG2];        // integer part

  assign rounded    = {1'b0, base} + fractional[DIV_LOG2 - 1];
  assign dout       = rounded[OUT_WIDTH] ? base : rounded[OUT_WIDTH - 1 : 0];
endmodule