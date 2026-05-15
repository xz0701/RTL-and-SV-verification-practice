module tb;
  logic clk;
  logic rst_n;
  logic in;
  logic detect;
  int   p = 0, f = 0;

  initial clk = 0;

  always #5 clk = ~clk;
  seq_det_1011 dut (.*);

  task automatic drive_bit(input logic b, output logic det_sample);
    in = b;
    #1;                 // sample Mealy output before the state update edge
    det_sample = detect;
    @(posedge clk);
    #1;
  endtask

  logic det;

  initial begin
    rst_n = 0; in = 0;
    @(posedge clk); @(posedge clk);
    rst_n = 1;
    @(posedge clk); @(negedge clk);

    // TC1 — Single match: 0 1 0 1 1 0
    drive_bit(0, det);
    drive_bit(1, det);
    drive_bit(0, det);
    drive_bit(1, det);
    drive_bit(1, det);
    if (det) begin p++; $display("PASS: TC1 single match"); end
    else begin f++; $display("FAIL: TC1 single match"); end
    drive_bit(0, det);

    // TC2 — Overlap/fallback behavior on 1 0 1 0 should not falsely match
    rst_n = 0; @(posedge clk); @(posedge clk); rst_n = 1;
    drive_bit(1, det); if (det) begin f++; $display("FAIL: TC2 spurious detect"); end
    drive_bit(0, det); if (det) begin f++; $display("FAIL: TC2 spurious detect"); end
    drive_bit(1, det); if (det) begin f++; $display("FAIL: TC2 spurious detect"); end
    drive_bit(0, det);
    if (!det) begin p++; $display("PASS: TC2 fallback without false match"); end
    else begin f++; $display("FAIL: TC2 false detect"); end

    // TC3 — Two matches in 1 0 1 1 0 1 0 1 1
    rst_n = 0; @(posedge clk); @(posedge clk); rst_n = 1;
    drive_bit(1, det);
    drive_bit(0, det);
    drive_bit(1, det);
    drive_bit(1, det);
    if (det) begin p++; $display("PASS: TC3 first match"); end
    else begin f++; $display("FAIL: TC3 first match"); end
    drive_bit(0, det);
    drive_bit(1, det);
    drive_bit(0, det);
    drive_bit(1, det);
    drive_bit(1, det);
    if (det) begin p++; $display("PASS: TC3 second match"); end
    else begin f++; $display("FAIL: TC3 second match"); end

    // TC4 — No match
    rst_n = 0; @(posedge clk); @(posedge clk); rst_n = 1;
    begin
      logic any_det;
      any_det = 0;
      drive_bit(0, det); any_det |= det;
      drive_bit(0, det); any_det |= det;
      drive_bit(0, det); any_det |= det;
      drive_bit(1, det); any_det |= det;
      drive_bit(1, det); any_det |= det;
      drive_bit(0, det); any_det |= det;
      drive_bit(0, det); any_det |= det;
      if (!any_det) begin p++; $display("PASS: TC4 no match"); end
      else begin f++; $display("FAIL: TC4 spurious detect"); end
    end

    // TC5 — Reset during partial sequence
    rst_n = 0; @(posedge clk); @(posedge clk); rst_n = 1;
    drive_bit(1, det);
    drive_bit(0, det);
    drive_bit(1, det);
    rst_n = 0; @(posedge clk); @(posedge clk); rst_n = 1;
    drive_bit(1, det);
    drive_bit(0, det);
    drive_bit(1, det);
    drive_bit(1, det);
    if (det) begin p++; $display("PASS: TC5 reset recovery"); end
    else begin f++; $display("FAIL: TC5 reset recovery"); end

    $display("=== %0d passed %0d failed ===", p, f);
    $finish;
  end
endmodule