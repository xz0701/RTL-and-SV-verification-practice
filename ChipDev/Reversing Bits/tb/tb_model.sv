module tb;

  localparam DATA_WIDTH = 32;

  logic [DATA_WIDTH-1:0] din;
  logic [DATA_WIDTH-1:0] dout;

  // DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .din  (din),
    .dout (dout)
  );

  // -------- Golden Model --------
  logic [DATA_WIDTH-1:0] golden_dout;

  task compute_golden(
    input  [DATA_WIDTH-1:0] din_t,
    output [DATA_WIDTH-1:0] dout_t
  );
    begin
      for (int i = 0; i < DATA_WIDTH; i = i + 1) begin
        dout_t[i] = din_t[DATA_WIDTH-1-i];
      end
    end
  endtask

  // -------- Self Check --------
  task check(input [DATA_WIDTH-1:0] din_t);
    begin
      din = din_t;
      #1;

      compute_golden(din_t, golden_dout);

      if (dout !== golden_dout) begin
        $error("FAIL: din=%0h  dout=%0h  expected=%0h",
               din_t, dout, golden_dout);
      end
      else begin
        $display("PASS: din=%0h  dout=%0h",
                 din_t, dout);
      end
    end
  endtask

  // -------- Stimulus --------
  initial begin
    $display("---- Self-Checking Reverse TB ----");

    check(32'h0000_0001);
    check(32'h8000_0000);
    check(32'hA5A5_5A5A);
    check(32'hFFFF_0000);
    check(32'h1234_5678);

    $display("All tests finished.");
    $finish;
  end

endmodule
