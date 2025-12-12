module model (
  input clk,
  input resetn,
  input din,
  output dout
);
  logic prev, temp;
  always_ff @(posedge clk) begin
    if (~resetn) begin
      prev <= 1'b0;
      temp <= 1'b0;
    end
    else begin
      prev <= din;
      temp <= ~prev & din;
    end
  end
  assign dout = temp;
  //assign dout = ~prev & din; //same cycle
endmodule