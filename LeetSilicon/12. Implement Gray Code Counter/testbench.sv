module tb;
  localparam N = 4;

  logic        clk;
  logic        rst_n;
  logic        enable;
  logic [N-1:0] gray_count;
  logic [N-1:0] prev_gray;
  int          p = 0, f = 0;

  initial clk = 0;

  always #5 clk = ~clk;
  gray_counter #(.N(N)) dut (.*);

  function automatic int hamming(logic [N-1:0] a, logic [N-1:0] b);
    return $countones(a ^ b);
  endfunction

  initial begin
    rst_n  = 0;
    enable = 0;
    @(posedge clk); @(posedge clk);
    rst_n = 1; @(posedge clk); #1;

    // TC5 — Reset gives gray=0
    if (gray_count == 0) begin p++; $display("PASS: TC5 reset gray=0"); end
    else begin f++; $display("FAIL: TC5 gray=%b", gray_count); end

    // TC1 — Verify first few Gray values
    enable = 1;
    begin
      logic [3:0] expected [8];
      logic ok;
      expected = '{4'b0001, 4'b0011, 4'b0010, 4'b0110,
                   4'b0111, 4'b0101, 4'b0100, 4'b1100};
      ok = 1;
      for (int i = 0; i < 8; i++) begin
        @(posedge clk); #1;
        if (gray_count != expected[i]) ok = 0;
      end
      if (ok) begin p++; $display("PASS: TC1 Gray sequence correct"); end
      else begin f++; $display("FAIL: TC1 Gray sequence"); end
    end

    // TC2 — Hamming distance = 1 for all transitions (full cycle)
    enable = 0;
    rst_n  = 0; @(posedge clk); @(posedge clk); rst_n = 1; enable = 1;
    @(posedge clk); #1;
    begin
      logic hd_ok = 1;
      logic [N-1:0] prev;
      prev = gray_count;
      repeat (15) begin
        @(posedge clk); #1;
        if (hamming(prev, gray_count) != 1) hd_ok = 0;
        prev = gray_count;
      end
      // Wrap: check last→first
      @(posedge clk); #1;
      if (hamming(prev, gray_count) != 1) hd_ok = 0;
      if (hd_ok) begin p++; $display("PASS: TC2 Hamming distance=1 always"); end
      else begin f++; $display("FAIL: TC2 Hamming distance violation"); end
    end

    // TC4 — Enable hold
    begin
      logic [N-1:0] held;
      held   = gray_count;
      enable = 0;
      repeat (3) @(posedge clk);
      #1;
      if (gray_count == held) begin p++; $display("PASS: TC4 hold when disabled"); end
      else begin f++; $display("FAIL: TC4 hold"); end
    end

    $display("=== %0d passed %0d failed ===", p, f);
    $finish;
  end
endmodule