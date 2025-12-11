module tb;

  localparam DATA_WIDTH = 32;

  logic clk;
  logic resetn;
  logic [DATA_WIDTH-1:0] din;
  logic [DATA_WIDTH-1:0] dout;

  // golden model
  logic [DATA_WIDTH-1:0] exp_first, exp_second, exp_dout;

  // Instantiate DUT
  model #(DATA_WIDTH) dut (
    .clk(clk),
    .resetn(resetn),
    .din(din),
    .dout(dout)
  );

  // Clock
  initial clk = 0;
  always #5 clk = ~clk;

  // Task: drive one sample and check result
  task drive(input [DATA_WIDTH-1:0] x);
    begin
      din = x;
      @(posedge clk); #1;

      // Golden model logic (same as DUT)
      if (x >= exp_first) begin
        exp_dout   = exp_first;
        exp_second = exp_first;
        exp_first  = x;
      end
      else if ((x > exp_second) && (x < exp_first)) begin
        exp_second = x;
        exp_dout   = x;
      end
      else if (x < exp_second) begin
        exp_dout = exp_second;
      end

      // Compare
      if (dout !== exp_dout) begin
        $error("FAIL: din=%0d, expected dout=%0d, got dout=%0d",
               x, exp_dout, dout);
      end
      else begin
        $display("PASS: din=%0d, dout=%0d", x, dout);
      end
    end
  endtask

  // TB main
  initial begin
    // reset
    exp_first  = 0;
    exp_second = 0;
    exp_dout   = 0;

    resetn = 0;
    din = 0;
    repeat(2) @(posedge clk);
    resetn = 1;

    // Test different patterns
    drive(10);
    drive(20);
    drive(15);
    drive(8);
    drive(16);
    drive(30);
    drive(25);
    drive(5);
    drive(28);

    $display("---- All tests finished ----");
    $finish;
  end

endmodule
