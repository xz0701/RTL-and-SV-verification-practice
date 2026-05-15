// ============================================================
// ID: counter1 — N-bit Synchronous Up Counter (enable + reset)
// ============================================================
// Wraparound is natural with N-bit arithmetic (mod 2^N).
//
// TODO: Choose reset type:
// - synchronous reset (reset sampled on clk edge), or
// - asynchronous reset (in sensitivity list).
// TODO: Optionally add RESET_VALUE parameter (default 0).

module sync_counter #(
  parameter int unsigned N = 8,
  parameter logic [N-1:0] RESET_VALUE = '0
) (
  input  logic         clk,
  input  logic         rst_n,    // TODO: define active-low vs active-high reset
  input  logic         enable,
  output logic [N-1:0] count
);

  // TODO: Decide reset polarity usage (rst_n vs rst).
  // TODO: Implement always_ff with priority:
  // - if reset: count <= RESET_VALUE
  // - else if enable: count <= count + 1'b1
  // - else hold
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        count <= RESET_VALUE;
    else if (enable)
        count <= count + 1'b1;
  end
  // TODO: Confirm behavior for N=1.
  // TODO: Optional terminal_count output (count == {N{1'b1}}).

endmodule


