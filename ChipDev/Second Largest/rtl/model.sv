module model #(parameter
  DATA_WIDTH = 32
) (
  input clk,
  input resetn,
  input [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
);
  logic [DATA_WIDTH - 1 : 0] second, first;
  always_ff @(posedge clk) begin
    if (~resetn) begin
        second <= '0;
        first  <= '0;
        dout   <= '0;
    end
    else begin
        if (din >= first) begin
            first  <= din;
            second <= first;
            dout   <= first;
        end
        else if ((din > second) && (din < first)) begin // cannot write second < din < first
            second <= din;
            dout   <= din;
        end
        else if (din < second) begin
            dout   <= second;
        end
    end
  end

endmodule