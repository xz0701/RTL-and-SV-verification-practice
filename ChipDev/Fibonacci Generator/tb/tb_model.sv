`timescale 1ns/1ps

module tb_model;

  parameter DATA_WIDTH = 32;

  logic clk;
  logic resetn;
  logic [DATA_WIDTH-1:0] out;

  // DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk    (clk),
    .resetn (resetn),
    .out    (out)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Golden model
  logic [DATA_WIDTH-1:0] ref_out;
  logic [DATA_WIDTH-1:0] ref_prev;
  logic [DATA_WIDTH-1:0] expected_out;

  // Update reference model
  always_ff @(posedge clk) begin
    if (!resetn) begin
      ref_out  <= {{(DATA_WIDTH-1){1'b0}}, 1'b1}; // 1
      ref_prev <= '0;
    end
    else begin
      ref_out  <= ref_out + ref_prev;
      ref_prev <= ref_out;
    end
  end

  assign expected_out = ref_out;

  // Self-check
  always_ff @(posedge clk) begin
    if (resetn) begin
      if (out !== expected_out) begin
        $error("Mismatch @ %0t: out=%0d expected=%0d (bin=%b)",
               $time, out, expected_out, out);
      end
    end
  end

  // Stimulus
  initial begin
    $display("==== TB START ====");

    // Initial values
    resetn = 0;
    repeat (2) @(posedge clk);

    // Release reset
    resetn = 1;

    // Run for several cycles
    repeat (10) @(posedge clk);

    // Assert reset in the middle
    $display("---- Mid-run reset ----");
    resetn = 0;
    @(posedge clk);
    resetn = 1;

    repeat (10) @(posedge clk);

    $display("==== TB PASS ====");
    $finish;
  end

endmodule
