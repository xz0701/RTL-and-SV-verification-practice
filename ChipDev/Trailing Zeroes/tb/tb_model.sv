`timescale 1ns/1ns

module model_tb;

  // Parameters
  localparam int DATA_WIDTH = 32;
  localparam int OUT_WIDTH  = $clog2(DATA_WIDTH) + 1;

  // DUT signals
  logic [DATA_WIDTH-1:0] din;
  logic [OUT_WIDTH-1:0]  dout;

  // Instantiate DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .din  (din),
    .dout (dout)
  );

  // Golden reference model: CTZ
  function automatic int ctz(input logic [DATA_WIDTH-1:0] v);
    int cnt;
    begin
      if (v == 0) begin
        return DATA_WIDTH;
      end
      cnt = 0;
      while ((v[cnt] == 1'b0) && (cnt < DATA_WIDTH)) begin
        cnt++;
      end
      return cnt;
    end
  endfunction

  // Checker
  task automatic check();
    int exp;
    begin
      exp = ctz(din);
      if (dout !== exp[OUT_WIDTH-1:0]) begin
        $display("[%0t] FAIL: din=0x%08h exp_ctz=%0d got=%0d",
                 $time, din, exp, dout);
      end
      else begin
        $display("[%0t] PASS: din=0x%08h ctz=%0d",
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

    din = '0;              #1; check(); // all zeros
    din = 32'h0000_0001;   #1; check(); // ctz = 0
    din = 32'h0000_0002;   #1; check(); // ctz = 1
    din = 32'h0000_0008;   #1; check(); // ctz = 3
    din = 32'h8000_0000;   #1; check(); // ctz = 31
    din = 32'h0000_00F0;   #1; check(); // ctz = 4
    din = 32'hFFFF_FFFF;   #1; check(); // ctz = 0

    // Random tests
    $display("\n=== Random tests ===");

    for (int i = 0; i < 100; i++) begin
      din = $urandom;
      #1;
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
