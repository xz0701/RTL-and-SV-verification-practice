`timescale 1ns/1ns

module model_tb;

  localparam int DATA_WIDTH = 16;
  localparam int TB_MAX     = 5;   // small MAX for fast wrap-around

  // DUT signals
  logic clk;
  logic reset;
  logic start;
  logic stop;
  logic [DATA_WIDTH-1:0] count;

  // Instantiate DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH),
    .MAX(TB_MAX)
  ) dut (
    .clk   (clk),
    .reset (reset),
    .start (start),
    .stop  (stop),
    .count (count)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  

  // Golden reference model state
  logic [DATA_WIDTH-1:0] ref_count;
  logic ref_flag;

  // Golden reference model
  task automatic ref_model();
    if (reset) begin
      ref_count = '0;
      ref_flag  = 1'b0;
    end
    else begin
      if (stop) begin
        ref_flag = 1'b0;
      end
      else if (start || ref_flag) begin
        ref_flag = 1'b1;
        if (ref_count == TB_MAX)
          ref_count = '0;
        else
          ref_count = ref_count + 1;
      end
    end
  endtask

  // Checker
  task automatic check();
    if (count !== ref_count) begin
      $display("[%0t] FAIL: count=%0d exp=%0d start=%0b stop=%0b",
               $time, count, ref_count, start, stop);
    end
    else begin
      $display("[%0t] PASS: count=%0d start=%0b stop=%0b",
               $time, count, start, stop);
    end
  endtask

  // One-cycle ste
  task automatic step_and_check();
    @(posedge clk);
    #1;              // allow non-blocking updates to settle
    ref_model();
    check();
  endtask

  // Stimulus
  initial begin

    reset = 1;
    start = 0;
    stop  = 0;

    ref_count = '0;
    ref_flag  = 1'b0;

    // Reset
    $display("\n=== Reset ===");
    repeat (2) @(posedge clk);
    reset = 0;
    step_and_check();

    // Directed: start -> run -> stop
    $display("\n=== Directed: start / hold / stop ===");

    start = 1;
    step_and_check();

    start = 0;
    repeat (2) step_and_check();   // keep counting via flag

    stop = 1;
    step_and_check();

    stop = 0;
    repeat (2) step_and_check();   // must stay idle

    // Directed: restart
    $display("\n=== Directed: restart ===");

    start = 1;
    step_and_check();
    start = 0;
    repeat (2) step_and_check();

    // Directed: wrap-around
    $display("\n=== Directed: wrap-around ===");

    start = 1;
    repeat (TB_MAX + 2) step_and_check(); 
    start = 0;

    // Random tests
    $display("\n=== Random tests ===");

    for (int i = 0; i < 10; i++) begin
      start = $urandom_range(0, 1);
      stop  = $urandom_range(0, 1);
      step_and_check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
