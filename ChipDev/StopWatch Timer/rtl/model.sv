module model #(parameter
  DATA_WIDTH = 16,
  MAX = 99
) (
    input clk,
    input reset, start, stop,
    output logic [DATA_WIDTH-1:0] count
);
  logic flag;

  always_ff @(posedge clk) begin
    if (reset) begin
      count <= '0;
      flag <= 1'b0;
    end
    else begin
      if (stop) begin
        flag <= 1'b0;
      end
      else if (start || flag) begin
        flag <= 1'b1;
        count <= count + 1;
        if (count == MAX) begin
          count <= '0;
        end
      end
    end
  end
endmodule