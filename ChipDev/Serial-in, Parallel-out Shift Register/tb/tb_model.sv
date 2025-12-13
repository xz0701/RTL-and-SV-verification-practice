`timescale 1ns/1ps

module tb_model;

  parameter DATA_WIDTH = 16;

  logic clk;
  logic resetn;
  logic din;
  logic [DATA_WIDTH-1:0] dout;

  // DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk    (clk),
    .resetn (resetn),
    .din    (din),
    .dout   (dout)
  );

  // Clock
  initial clk = 0;
  always #5 clk = ~clk;

  // Golden model
  bit golden_q[$];   // stores din history, oldest at index 0
  logic [DATA_WIDTH-1:0] expected_dout;

  // Update golden model
  always_ff @(posedge clk) begin
    if (!resetn) begin
      golden_q.delete();
    end
    else begin
      golden_q.push_back(din);
      if (golden_q.size() > DATA_WIDTH)
        golden_q.pop_front();
    end
  end

  // Build expected dout from golden queue
  always_comb begin
    expected_dout = '0;
    for (int i = 0; i < golden_q.size(); i++) begin
      expected_dout[golden_q.size()-1-i] = golden_q[i];
    end
  end

  // Self-check
  always_ff @(posedge clk) begin
    if (resetn) begin
      if (dout !== expected_dout) begin
        $error("Mismatch @ %0t: dout=%b expected=%b",
               $time, dout, expected_dout);
      end
    end
  end

  // Stimulus
  initial begin
    $display("==== TB START ====");

    resetn = 0;
    din    = 0;
    repeat (2) @(posedge clk);
    resetn = 1;

    // Random shifting
    repeat (30) begin
      din = $urandom_range(0, 1);
      @(posedge clk);
    end

    // Reset in the middle
    resetn = 0;
    @(posedge clk);
    resetn = 1;

    repeat (10) begin
      din = $urandom_range(0, 1);
      @(posedge clk);
    end

    $display("==== TB PASS ====");
    $finish;
  end

endmodule
