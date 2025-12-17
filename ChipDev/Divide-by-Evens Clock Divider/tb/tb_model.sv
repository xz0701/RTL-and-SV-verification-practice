`timescale 1ns/1ns

module model_tb;

  // ------------------------------------------------------------------
  // Clock / Reset
  // ------------------------------------------------------------------
  logic clk;
  logic resetn;

  always #5 clk = ~clk;   // 100 MHz clock

  // ------------------------------------------------------------------
  // DUT signals
  // ------------------------------------------------------------------
  logic div2;
  logic div4;
  logic div6;

  // ------------------------------------------------------------------
  // Instantiate DUT
  // ------------------------------------------------------------------
  model dut (
    .clk    (clk),
    .resetn (resetn),
    .div2   (div2),
    .div4   (div4),
    .div6   (div6)
  );

  // ------------------------------------------------------------------
  // Spec-level golden model
  // ------------------------------------------------------------------
  int cycle_cnt;

  always_ff @(posedge clk) begin
    if (!resetn)
      cycle_cnt <= 0;
    else
      cycle_cnt <= cycle_cnt + 1;
  end

  function automatic logic golden_div(input int N);
    int phase;
    begin
      // Align phase so that first cycle after reset is phase 0
      phase = (cycle_cnt - 1) % N;
      if (phase < 0)
        phase = phase + N;

      return (phase < (N/2));
    end
  endfunction


  // ------------------------------------------------------------------
  // Checker
  // ------------------------------------------------------------------
  task automatic check();
    logic exp2, exp4, exp6;
    begin
      exp2 = golden_div(2);
      exp4 = golden_div(4);
      exp6 = golden_div(6);

      if (div2 !== exp2 ||
          div4 !== exp4 ||
          div6 !== exp6) begin
        $display("[%0t] FAIL | div2=%0b exp=%0b | div4=%0b exp=%0b | div6=%0b exp=%0b",
                 $time,
                 div2, exp2,
                 div4, exp4,
                 div6, exp6);
      end
      else begin
        $display("[%0t] PASS | div2=%0b div4=%0b div6=%0b",
                 $time, div2, div4, div6);
      end
    end
  endtask

  // ------------------------------------------------------------------
  // Stimulus
  // ------------------------------------------------------------------
  initial begin
    // Init
    clk    = 0;
    resetn = 0;

    $display("\n=== Apply reset ===");
    repeat (3) @(posedge clk);
    resetn = 1;

    // --------------------------------------------------------------
    // Long-run functional check
    // --------------------------------------------------------------
    $display("\n=== Functional check ===");
    repeat (30) begin
      @(posedge clk);
      check();
    end

    // --------------------------------------------------------------
    // Reset in the middle of operation
    // --------------------------------------------------------------
    $display("\n=== Mid-run reset ===");
    resetn = 0;
    @(posedge clk);
    check();

    resetn = 1;
    repeat (20) begin
      @(posedge clk);
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
