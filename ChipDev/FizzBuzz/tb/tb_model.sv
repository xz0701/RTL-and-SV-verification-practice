`timescale 1ns/1ns

module model_tb;

  // Parameters
  localparam int FIZZ       = 3;
  localparam int BUZZ       = 5;
  localparam int MAX_CYCLES = 20;

  // Clock Generation
  logic clk;
  logic resetn;

  always #5 clk = ~clk;   

  // DUT outputs
  logic fizz;
  logic buzz;
  logic fizzbuzz;

  // Instantiate DUT
  model #(
    .FIZZ(FIZZ),
    .BUZZ(BUZZ),
    .MAX_CYCLES(MAX_CYCLES)
  ) dut (
    .clk       (clk),
    .resetn    (resetn),
    .fizz      (fizz),
    .buzz      (buzz),
    .fizzbuzz  (fizzbuzz)
  );

  // golden model
  int cycle;  // logical cycle count since last reset / wrap

  always_ff @(posedge clk) begin
    if (!resetn)
      cycle <= 0;
    else if (cycle == MAX_CYCLES)
      cycle <= 1;
    else
      cycle <= cycle + 1;
  end

  function automatic logic golden_fizz(input int c);
    return (c % FIZZ == 0);
  endfunction

  function automatic logic golden_buzz(input int c);
    return (c % BUZZ == 0);
  endfunction

  // Checker
  task automatic check();
    logic exp_fizz, exp_buzz, exp_fizzbuzz;
    begin
      exp_fizz     = golden_fizz(cycle);
      exp_buzz     = golden_buzz(cycle);
      exp_fizzbuzz = exp_fizz && exp_buzz;

      if (fizz      !== exp_fizz     ||
          buzz      !== exp_buzz     ||
          fizzbuzz !== exp_fizzbuzz) begin
        $display("[%0t] FAIL  cycle=%0d | fizz=%0b exp=%0b | buzz=%0b exp=%0b | fizzbuzz=%0b exp=%0b",
                 $time, cycle,
                 fizz, exp_fizz,
                 buzz, exp_buzz,
                 fizzbuzz, exp_fizzbuzz);
      end
      else begin
        $display("[%0t] PASS  cycle=%0d | fizz=%0b buzz=%0b fizzbuzz=%0b",
                 $time, cycle, fizz, buzz, fizzbuzz);
      end
    end
  endtask

  // Stimulus
  initial begin
    // Init
    clk    = 0;
    resetn = 0;

    $display("\n=== Apply reset ===");
    repeat (2) @(posedge clk);
    resetn = 1;

    // Normal operation
    $display("\n=== Functional check ===");
    repeat (MAX_CYCLES * 2) begin
      @(posedge clk);
      check();
    end

    // Mid-run reset
    $display("\n=== Mid-run reset ===");
    resetn = 0;
    @(posedge clk);
    check();

    resetn = 1;
    repeat (10) begin
      @(posedge clk);
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
