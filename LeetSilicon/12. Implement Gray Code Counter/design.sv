// ============================================================
// ID: counter2 — Gray-Code Counter (enable + reset)
// ============================================================
// Recommended approach: keep internal binary counter, output Gray code as:
// gray = (bin >> 1) ^ bin.
//
// TODO: Decide whether to output only gray_count or also binary_count for debug.

module gray_counter #(
  parameter int unsigned N = 4
) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic         enable,
  output logic [N-1:0] gray_count
);

  logic [N-1:0] bin_q, bin_d;

  function automatic logic [N-1:0] bin2gray(input logic [N-1:0] b);
  // TODO: Implement gray conversion: (b >> 1) ^ b.
  bin2gray = (b >> 1) ^ b;
  endfunction

  // TODO: Next binary count logic:
  // - if enable: bin_d = bin_q + 1
  // - else: bin_d = bin_q
  always_comb begin
    if (enable)
      bin_d = bin_q + 1'b1;
    else
      bin_d = bin_q;
  end

  // TODO: gray_count combinational from bin_q (or from bin_d if you want gray to advance same cycle as bin updates).
  bin_q = bin2gray[bin_d];
  // TODO: Reset: bin_q=0, gray_count=0.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bin_q <= '0;
    end
    else
      bin_q <= bin_d;
  end

  // TODO: Testbench-only checks:
  // - Hamming distance between gray_count and $past(gray_count) is 1 when enable=1.
  // - Wraparound transition is also 1-bit (cyclic property).

endmodule


