`timescale 1ns/1ns

module model_tb;

  // DUT signals
  logic clk;
  logic resetn;
  logic din;
  logic dout;

  // Instantiate DUT
  model dut (
    .clk    (clk),
    .resetn (resetn),
    .din    (din),
    .dout   (dout)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Golden reference model (arithmetic mod-5)
  int   ref_mod5;    // valid range: 0..4
  logic ref_dout;

  task automatic ref_model(input logic din_i);
    if (!resetn) begin
      ref_mod5 = 0;
      ref_dout = 1'b1;   // 0 mod 5 after reset
    end
    else begin
      ref_mod5 = (ref_mod5 * 2 + din_i) % 5;
      ref_dout = (ref_mod5 == 0);
    end
  endtask

  // Checker
  task automatic check();
    if (dout !== ref_dout) begin
      $display("[%0t] FAIL: din=%0b dout=%0b exp=%0b mod5=%0d",
               $time, din, dout, ref_dout, ref_mod5);
    end
    else begin
      $display("[%0t] PASS: din=%0b dout=%0b mod5=%0d",
               $time, din, dout, ref_mod5);
    end
  endtask

  // One-cycle step
  task automatic step(input logic din_i);
    din = din_i;
    @(posedge clk);
    #1;                 // allow DUT state update to settle
    ref_model(din_i);
    check();
  endtask

  // Stimulus
  initial begin

    resetn   = 0;
    din      = 0;
    ref_mod5 = 0;
    ref_dout = 1'b1;

    // Reset
    $display("\n=== Reset ===");
    repeat (2) @(posedge clk);
    resetn = 1;
    step(0);

    // Directed tests
    $display("\n=== Directed tests ===");

    // Binary 101 = 5 -> divisible
    step(1);
    step(0);
    step(1);   // dout should be 1

    // Binary 1010 = 10 -> divisible
    step(1);
    step(0);
    step(1);
    step(0);   // dout should be 1

    // Binary 111 = 7 -> not divisible
    step(1);
    step(1);
    step(1);

    // All-zero stream
    $display("\n=== All zeros ===");
    repeat (5) step(0);

    // Random tests
    $display("\n=== Random tests ===");
    for (int i = 0; i < 20; i++) begin
      step($urandom_range(0,1));
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
