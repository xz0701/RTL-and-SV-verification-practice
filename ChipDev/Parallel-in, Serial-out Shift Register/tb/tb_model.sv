`timescale 1ns/1ps

module tb_model;

  parameter DATA_WIDTH = 16;

  logic clk;
  logic resetn;
  logic [DATA_WIDTH-1:0] din;
  logic din_en;
  logic dout;

  // DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk    (clk),
    .resetn (resetn),
    .din    (din),
    .din_en (din_en),
    .dout   (dout)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Gold model
  int unsigned bit_idx;
  logic [DATA_WIDTH-1:0] latched_din;
  logic expected_dout;

  always_ff @(posedge clk) begin
    if (!resetn) begin
      bit_idx      <= DATA_WIDTH;   // means no valid bits
      latched_din  <= '0;
    end
    else if (din_en) begin
      latched_din <= din;
      bit_idx     <= 0;
    end
    else if (bit_idx < DATA_WIDTH) begin
      bit_idx <= bit_idx + 1;
    end
  end

  always_comb begin
    if (bit_idx < DATA_WIDTH)
      expected_dout = latched_din[bit_idx];
    else
      expected_dout = 1'b0;
  end

  // Self-check
  always_ff @(posedge clk) begin
    if (resetn) begin
      if (dout !== expected_dout) begin
        $error("Mismatch @ time=%0t: expected=%b, got=%b",
               $time, expected_dout, dout);
      end
    end
  end

  // Tasks
  task apply_reset();
    begin
      resetn = 0;
      din_en = 0;
      din    = '0;
      repeat (2) @(posedge clk);
      resetn = 1;
      @(posedge clk);
    end
  endtask

  task load_and_shift(input [DATA_WIDTH-1:0] value);
    begin
      din    = value;
      din_en = 1;
      @(posedge clk);
      din_en = 0;
    end
  endtask

  // Main stimulus
  initial begin
    $display("==== SELF-CHECKING TB START ====");

    resetn = 1;
    din_en = 0;
    din    = '0;

    // Reset
    apply_reset();

    // Test 1: basic shifting
    load_and_shift(16'b1011_0101_0000_1111);
    repeat (20) @(posedge clk);

    // Test 2: reload during shift
    load_and_shift(16'b1111_0000_1111_0000);
    repeat (4) @(posedge clk);
    load_and_shift(16'b0000_0000_0000_0011);
    repeat (10) @(posedge clk);

    // Test 3: reset during shift
    load_and_shift(16'b1111_1111_1111_1111);
    repeat (3) @(posedge clk);
    resetn = 0;
    @(posedge clk);
    resetn = 1;
    repeat (6) @(posedge clk);

    $display("==== SELF-CHECKING TB PASS ====");
    $finish;
  end

endmodule
