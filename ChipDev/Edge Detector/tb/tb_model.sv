module tb;

  logic clk;
  logic resetn;
  logic din;
  logic dout;

  // DUT
  model dut (
    .clk    (clk),
    .resetn (resetn),
    .din    (din),
    .dout   (dout)
  );

  // clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // -------- Golden Model --------
  logic golden_prev;
  logic golden_dout;

  // golden update
  always @(posedge clk) begin
    if (!resetn) begin
      golden_prev <= 1'b0;
      golden_dout <= 1'b0;
    end
    else begin
      golden_dout <= ~golden_prev & din;
      golden_prev <= din;
    end
  end

  // -------- Self Check --------
  always @(posedge clk) begin
    if (resetn) begin
      #1; // wait for NBA update
      if (dout !== golden_dout) begin
        $error(
          "FAIL @ %0t : din=%b prev=%b dout=%b expected=%b",
          $time, din, golden_prev, dout, golden_dout
        );
      end
      else begin
        $display(
          "PASS @ %0t : din=%b dout=%b",
          $time, din, dout
        );
      end
    end
  end

  // -------- Stimulus --------
  initial begin
    $display("---- Rising Edge Detector TB ----");

    // init
    resetn = 0;
    din    = 0;

    repeat (2) @(posedge clk);
    resetn = 1;

    // stimulus pattern
    @(posedge clk) din = 0;
    @(posedge clk) din = 1; // rising edge -> pulse expected next cycle
    @(posedge clk) din = 1;
    @(posedge clk) din = 0;
    @(posedge clk) din = 1; // another rising edge
    @(posedge clk) din = 0;
    @(posedge clk) din = 1;

    repeat (3) @(posedge clk);

    $display("All tests finished.");
    $finish;
  end

endmodule
