module tb;
  localparam N = 4;

  logic        clk;
  logic        rst_n;
  logic        enable;
  logic [N-1:0] count;
  int          p = 0, f = 0;

  initial clk = 0;

  always #5 clk = ~clk;
  sync_counter #(.N(N)) dut (.*);

  initial begin
    rst_n  = 0;
    enable = 0;
    @(posedge clk); @(posedge clk);
    rst_n = 1;
    @(posedge clk); @(negedge clk);

    // TC1 — Count 3 cycles
    @(negedge clk); enable = 1;
    repeat (3) @(posedge clk);
    @(negedge clk);
    if (count == 3) begin p++; $display("PASS: TC1 count=3 after 3 cycles"); end
    else begin f++; $display("FAIL: TC1 count=%0d", count); end

    // Continue to 10
    repeat (7) @(posedge clk);
    @(negedge clk);
    if (count == 10) begin p++; $display("PASS: TC1 count=10 after 10 cycles"); end
    else begin f++; $display("FAIL: TC1 count=%0d", count); end

    // TC2 — Hold on disable
    enable = 0;
    repeat (2) @(posedge clk);
    @(negedge clk);
    if (count == 10) begin p++; $display("PASS: TC2 hold when disabled"); end
    else begin f++; $display("FAIL: TC2 count changed to %0d", count); end
    enable = 1;
    @(posedge clk); @(negedge clk);
    if (count == 11) begin p++; $display("PASS: TC2 increments after re-enable"); end
    else begin f++; $display("FAIL: TC2 expected 11 got %0d", count); end

    // TC3 — Wraparound at 15 → 0
    // Count up to 15
    repeat (4) @(posedge clk);
    @(negedge clk);
    if (count == 15) begin p++; $display("PASS: TC3 at max 15"); end
    else begin f++; $display("FAIL: TC3 expected 15 got %0d", count); end
    @(posedge clk); @(negedge clk);
    if (count == 0) begin p++; $display("PASS: TC3 wraps to 0"); end
    else begin f++; $display("FAIL: TC3 wrap got %0d", count); end

    // TC4 — Reset
    @(posedge clk);
    rst_n = 0; @(posedge clk); @(negedge clk);
    if (count == 0) begin p++; $display("PASS: TC4 reset clears count"); end
    else begin f++; $display("FAIL: TC4 reset"); end
    rst_n = 1;

    $display("=== %0d passed %0d failed ===", p, f);
    $finish;
  end
endmodule