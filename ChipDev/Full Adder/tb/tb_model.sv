`timescale 1ns/1ns

module model_tb;

  // DUT signals
  logic a;
  logic b;
  logic cin;
  logic sum;
  logic cout;

  // Instantiate DUT
  model dut (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
  );

  // Spec-level golden model
  function automatic logic golden_sum(input logic a, b, cin);
    return (a ^ b ^ cin);
  endfunction

  function automatic logic golden_cout(input logic a, b, cin);
    int tmp;
    begin
      tmp = a + b + cin;
      return (tmp >= 2);
    end
  endfunction

  // Checker
  task automatic check();
    logic exp_sum;
    logic exp_cout;
    begin
      exp_sum  = golden_sum(a, b, cin);
      exp_cout = golden_cout(a, b, cin);

      if (sum !== exp_sum || cout !== exp_cout) begin
        $display("[%0t] FAIL | a=%0b b=%0b cin=%0b | sum=%0b exp=%0b | cout=%0b exp=%0b",
                 $time,
                 a, b, cin,
                 sum, exp_sum,
                 cout, exp_cout);
      end
      else begin
        $display("[%0t] PASS | a=%0b b=%0b cin=%0b | sum=%0b cout=%0b",
                 $time, a, b, cin, sum, cout);
      end
    end
  endtask

  // Stimulus
  initial begin
    $display("\n=== Full Adder Exhaustive Test ===");

    // Exhaustive test: all 8 combinations
    for (int i = 0; i < 8; i++) begin
      {a, b, cin} = i[2:0];
      #1;
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
