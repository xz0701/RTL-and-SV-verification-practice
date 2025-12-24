`timescale 1ns/1ns

module model_tb;

  localparam int DATA_WIDTH = 32;

  // DUT signal
  logic [DATA_WIDTH-1:0] a;
  logic [DATA_WIDTH-1:0] b;

  logic [DATA_WIDTH-1:0] a_plus_b;
  logic [DATA_WIDTH-1:0] a_minus_b;
  logic [DATA_WIDTH-1:0] not_a;
  logic [DATA_WIDTH-1:0] a_and_b;
  logic [DATA_WIDTH-1:0] a_or_b;
  logic [DATA_WIDTH-1:0] a_xor_b;

  // Instantiate DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .a          (a),
    .b          (b),
    .a_plus_b   (a_plus_b),
    .a_minus_b  (a_minus_b),
    .not_a      (not_a),
    .a_and_b    (a_and_b),
    .a_or_b     (a_or_b),
    .a_xor_b    (a_xor_b)
  );

  // Golden model
  function automatic logic [DATA_WIDTH-1:0] golden_plus(
    input logic [DATA_WIDTH-1:0] x,
    input logic [DATA_WIDTH-1:0] y
  );
    return x + y;
  endfunction

  function automatic logic [DATA_WIDTH-1:0] golden_minus(
    input logic [DATA_WIDTH-1:0] x,
    input logic [DATA_WIDTH-1:0] y
  );
    return x - y;
  endfunction

  // Checker
  task automatic check();
    logic [DATA_WIDTH-1:0] exp_plus;
    logic [DATA_WIDTH-1:0] exp_minus;
    logic [DATA_WIDTH-1:0] exp_not;
    logic [DATA_WIDTH-1:0] exp_and;
    logic [DATA_WIDTH-1:0] exp_or;
    logic [DATA_WIDTH-1:0] exp_xor;
    begin
      exp_plus  = golden_plus(a, b);
      exp_minus = golden_minus(a, b);
      exp_not   = ~a;
      exp_and   = a & b;
      exp_or    = a | b;
      exp_xor   = a ^ b;

      if (a_plus_b  !== exp_plus  ||
          a_minus_b !== exp_minus ||
          not_a     !== exp_not   ||
          a_and_b   !== exp_and   ||
          a_or_b    !== exp_or    ||
          a_xor_b   !== exp_xor) begin

        $display("[%0t] FAIL",
                 $time);
        $display("  a        = 0x%08h", a);
        $display("  b        = 0x%08h", b);
        $display("  plus     = 0x%08h exp=0x%08h", a_plus_b,  exp_plus);
        $display("  minus    = 0x%08h exp=0x%08h", a_minus_b, exp_minus);
        $display("  not_a    = 0x%08h exp=0x%08h", not_a,     exp_not);
        $display("  and      = 0x%08h exp=0x%08h", a_and_b,   exp_and);
        $display("  or       = 0x%08h exp=0x%08h", a_or_b,    exp_or);
        $display("  xor      = 0x%08h exp=0x%08h", a_xor_b,   exp_xor);
      end
      else begin
        $display("[%0t] PASS  a=0x%08h b=0x%08h",
                 $time, a, b);
      end
    end
  endtask

  // Stimulus
  initial begin
    $display("\n=== Directed tests ===");

    // Simple directed cases
    a = '0; b = '0; #1; check();
    a = '1; b = '0; #1; check();
    a = '0; b = '1; #1; check();
    a = 32'hFFFF_FFFF; b = 32'h1; #1; check();
    a = 32'h8000_0000; b = 32'h8000_0000; #1; check();

    $display("\n=== Random tests ===");

    for (int i = 0; i < 100; i++) begin
      a = $urandom;
      b = $urandom;
      #1;
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
