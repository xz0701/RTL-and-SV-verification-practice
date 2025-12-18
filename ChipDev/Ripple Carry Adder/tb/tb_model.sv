`timescale 1ns/1ns

module model_tb;

  localparam int DATA_WIDTH = 8;

  // DUT signals
  logic [DATA_WIDTH-1:0] a;
  logic [DATA_WIDTH-1:0] b;

  logic [DATA_WIDTH:0]   sum;
  logic [DATA_WIDTH-1:0] cout_int;

  // Instantiate DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .a        (a),
    .b        (b),
    .sum      (sum),
    .cout_int (cout_int)
  );

  // Golden model
  function automatic logic [DATA_WIDTH:0] golden_sum(
    input logic [DATA_WIDTH-1:0] x,
    input logic [DATA_WIDTH-1:0] y
  );
    return x + y;
  endfunction

  // Checker
  task automatic check();
    logic [DATA_WIDTH:0] exp_sum;
    begin
      exp_sum = golden_sum(a, b);

      if (sum !== exp_sum) begin
        $display("[%0t] FAIL", $time);
        $display("  a        = 0x%0h", a);
        $display("  b        = 0x%0h", b);
        $display("  sum      = 0x%0h", sum);
        $display("  exp_sum  = 0x%0h", exp_sum);
      end
      else begin
        $display("[%0t] PASS  a=0x%0h b=0x%0h sum=0x%0h",
                 $time, a, b, sum);
      end
    end
  endtask

  // Optional internal consistency check
  task automatic check_internal_carry();
    logic [DATA_WIDTH:0] tmp;
    begin
      tmp = {cout_int[DATA_WIDTH-1], sum[DATA_WIDTH-1:0]};
      if (tmp !== sum) begin
        $display("[%0t] INTERNAL CARRY MISMATCH", $time);
        $display("  cout_int = %b", cout_int);
        $display("  sum      = %b", sum);
      end
    end
  endtask

  // Stimulus
  initial begin
    $display("\n=== Directed tests ===");

    // Corner cases
    a = '0;           b = '0;           #1; check();
    a = '1;           b = '0;           #1; check();
    a = '0;           b = '1;           #1; check();
    a = '1;           b = '1;           #1; check();
    a = '1;           b = '1;           #1; check();
    a = {DATA_WIDTH{1'b1}}; b = 1;       #1; check();
    a = {DATA_WIDTH{1'b1}}; b = {DATA_WIDTH{1'b1}}; #1; check();

    $display("\n=== Random tests ===");

    for (int i = 0; i < 200; i++) begin
      a = $urandom;
      b = $urandom;
      #1;
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
