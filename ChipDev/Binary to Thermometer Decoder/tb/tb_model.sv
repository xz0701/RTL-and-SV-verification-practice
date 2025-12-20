`timescale 1ns/1ns

module model_tb;

  // Parameters
  localparam int WIDTH = 8;
  localparam int OUT_W = 1 << WIDTH;   // 256

  // DUT signals
  logic [WIDTH-1:0] din;
  logic [OUT_W-1:0] dout;

  // Instantiate DUT
  model dut (
    .din  (din),
    .dout (dout)
  );

  // Golden model
  function automatic logic [OUT_W-1:0] golden_mask(input logic [WIDTH-1:0] d);
    logic [OUT_W-1:0] mask;
    begin
      // mask = (1 << (d + 1)) - 1
      mask = '0;
      for (int i = 0; i <= d; i++) begin
        mask[i] = 1'b1;
      end
      return mask;
    end
  endfunction

  // Checker
  task automatic check();
    logic [OUT_W-1:0] exp;
    begin
      exp = golden_mask(din);

      if (dout !== exp) begin
        $display("[%0t] FAIL din=%0d", $time, din);
        $display("  dout = %b", dout);
        $display("  exp  = %b", exp);
      end
      else begin
        $display("[%0t] PASS din=%0d", $time, din);
      end
    end
  endtask

  // Stimulus
  initial begin
    $display("\n=== Directed tests ===");

    // Boundary cases
    din = 0;        #1; check();
    din = 1;        #1; check();
    din = 2;        #1; check();
    din = 8'd254;   #1; check();
    din = 8'd255;   #1; check();

    $display("\n=== Random tests ===");

    for (int i = 0; i < 50; i++) begin
      din = $urandom_range(0, 255);
      #1;
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
