`timescale 1ns/1ns

module model_tb;

  // Parameters
  localparam int DATA_WIDTH = 16;
  localparam int OUT_WIDTH  = $clog2(DATA_WIDTH) + 1;

  // DUT signals
  logic [DATA_WIDTH-1:0] din;
  logic [OUT_WIDTH-1:0]  dout;

  // DUT instantiation
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .din  (din),
    .dout (dout)
  );

  // Golden reference model
  function automatic int popcount(input logic [DATA_WIDTH-1:0] v);
    int cnt;
    begin
      cnt = 0;
      for (int i = 0; i < DATA_WIDTH; i++)
        cnt += v[i];
      return cnt;
    end
  endfunction

  // Checker
  task automatic check();
    int exp;
    begin
      exp = popcount(din);
      if (dout !== exp[OUT_WIDTH-1:0]) begin
        $display("[%0t] FAIL: din=0x%0h exp=%0d got=%0d",
                 $time, din, exp, dout);
      end else begin
        $display("[%0t] PASS: din=0x%0h popcount=%0d",
                 $time, din, dout);
      end
    end
  endtask

  // Stimulus
  initial begin
    $dumpfile("model.vcd");
    $dumpvars(0, model_tb);

    // Directed tests
    $display("\n=== Directed tests ===");

    din = '0;   #1; check();   // all zeros
    din = '1;   #1; check();   // all ones (should expose bug)
    din = 16'h0001; #1; check();
    din = 16'h8000; #1; check(); // MSB only (very important)
    din = 16'h00FF; #1; check();

    // Random tests
    $display("\n=== Random tests ===");

    for (int i = 0; i < 50; i++) begin
      din = $urandom;
      #1;
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
