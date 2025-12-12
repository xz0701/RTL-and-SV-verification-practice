module tb;

  localparam DATA_WIDTH = 4;

  logic clk;
  logic resetn;
  logic [DATA_WIDTH-1:0] out;

  // DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk    (clk),
    .resetn (resetn),
    .out    (out)
  );

  // clock
  initial clk = 0;
  always #5 clk = ~clk;

  // -------- Golden Model --------
  logic [DATA_WIDTH-1:0] golden_bin;
  logic [DATA_WIDTH-1:0] golden_out;

  function automatic [DATA_WIDTH-1:0] gray(
    input [DATA_WIDTH-1:0] bin
  );
    gray = bin ^ (bin >> 1);
  endfunction

  // golden model update
  always @(posedge clk) begin
    if (!resetn) begin
      // 必须与你 DUT reset 行为一致
      golden_bin <= 1;
      golden_out <= '0;
    end
    else begin
      golden_out <= gray(golden_bin);
      golden_bin <= golden_bin + 1;
    end
  end

  // -------- Self-check --------
  always @(posedge clk) begin
    if (resetn) begin
      #1;
      if (out !== golden_out) begin
        $error(
          "FAIL @ %0t : out=%0h, expected=%0h (golden_bin=%0d)",
          $time, out, golden_out, golden_bin
        );
      end
      else begin
        $display(
          "PASS @ %0t : out=%0h (golden_bin=%0d)",
          $time, out, golden_bin
        );
      end
    end
  end

  // stimulus
  initial begin
    $display("---- Gray Counter TB with Golden Model ----");

    resetn = 0;
    repeat (2) @(posedge clk);
    resetn = 1;

    repeat (10) @(posedge clk);

    $display("All tests finished.");
    $finish;
  end

endmodule
