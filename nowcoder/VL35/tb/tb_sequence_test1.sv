`timescale 1ns/1ns

module sequence_test1_tb;

  // DUT signals
  reg  clk;
  reg  rst;
  reg  data;
  wire flag;

  // Instantiate DUT
  sequence_test1 dut (
    .clk  (clk),
    .rst  (rst),
    .data (data),
    .flag (flag)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  // Task to send one bit
  task send_bit(input bit d);
    begin
      data = d;
      @(posedge clk);
    end
  endtask

  // Reset task
  task reset_dut();
    begin
      rst = 0;
      data = 0;
      repeat(2) @(posedge clk);
      rst = 1;
      @(posedge clk);
    end
  endtask

  // Test sequence
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, sequence_test1_tb);

    reset_dut();

    // Case 1: send the target sequence "01011"
    $display("\n--- Test: Detect 01011 ---");
    send_bit(0);
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(1);

    // Wait 3 clocks
    repeat(3) @(posedge clk);

    // Case 2: send the second pattern "11011"
    $display("\n--- Test: Detect 11011 ---");
    send_bit(1);
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(1);

    // Wait 3 clocks
    repeat(3) @(posedge clk);

    // Case 3: random noise then embed pattern
    $display("\n--- Test: Random + pattern ---");

    send_bit(0);
    send_bit(1);
    send_bit(1);
    send_bit(0);

    // Insert 01011 again
    send_bit(0);
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(1);

    repeat(5) @(posedge clk);

    $display("\n--- Simulation finished ---");
    $finish;
  end

endmodule
