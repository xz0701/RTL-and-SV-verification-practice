module tb;

  localparam DIV_LOG2  = 3;
  localparam OUT_WIDTH = 8;
  localparam IN_WIDTH  = OUT_WIDTH + DIV_LOG2;

  logic [IN_WIDTH-1:0] din;
  logic [OUT_WIDTH-1:0] dout;

  // Golden model
  logic [OUT_WIDTH-1:0] exp_dout;

  // Instantiate DUT
  model #(DIV_LOG2, OUT_WIDTH, IN_WIDTH) dut (
    .din(din),
    .dout(dout)
  );

  // A golden reference function
  function [OUT_WIDTH-1:0] golden (input [IN_WIDTH-1:0] din_f);
    logic [OUT_WIDTH-1:0] base_f;
    logic round_up_f;
    logic [OUT_WIDTH:0] rounded_f;

    begin
      base_f     = din_f[IN_WIDTH-1:DIV_LOG2];     // right shift
      round_up_f = din_f[DIV_LOG2-1];              // fractional MSB

      rounded_f  = {1'b0, base_f} + round_up_f;    // expansion to detect overflow

      golden = rounded_f[OUT_WIDTH] ?
               base_f :                           // overflow -> keep base
               rounded_f[OUT_WIDTH-1:0];          // normal result
    end
  endfunction

  // Task to drive and check values
  task check(input [IN_WIDTH-1:0] val);
    begin
      din = val;
      #1;

      exp_dout = golden(val);

      if (dout !== exp_dout)
        $error("FAIL: din=%0d, dut=%0d, exp=%0d", val, dout, exp_dout);
      else
        $display("PASS: din=%0d, dout=%0d", val, dout);
    end
  endtask

  // Main test sequence
  initial begin
    $display("\n---- Starting Testbench ----\n");

    // Basic cases
    check('d0);
    check('d1);
    check('d7);
    check('d8);

    // Fraction MSB = 0 (no round)
    check(16'h12_00);  // fractional bits = 0

    // Fraction MSB = 1 (round-up)
    check(16'h12_04);  // fractional bits = 100 → round

    // Overflow case: base = max, round_up = 1
    check({8'hFF, 3'b100});  // base=255, round_up=1 → saturate

    // Random coverage
    repeat (20) begin
      check($random);
    end

    $display("\n---- All tests completed ----\n");
    $finish;
  end

endmodule
