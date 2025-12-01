`timescale 1ns/1ns

module sequence_test2_tb;

  // DUT signals
  reg  clk;
  reg  rst;
  reg  data;
  wire flag;

  // Instantiate DUT
  sequence_test2 dut (
    .clk  (clk),
    .rst  (rst),
    .data (data),
    .flag (flag)
  );

  // Clock
  always #5 clk = ~clk;

  // Task: drive one bit-
  task send_bit(input bit d);
    begin
      data = d;
      @(posedge clk);
    end
  endtask

  // Task: reset DUT
  task reset_dut();
    begin
      rst = 0;
      data = 0;
      repeat(2) @(posedge clk);
      rst = 1;
      @(posedge clk);
    end
  endtask

  // Main stimulus
  initial begin
    // Dump wave
    $dumpfile("sequence_test2.vcd");
    $dumpvars(0, sequence_test2_tb);

    reset_dut();

    // Test 1: send exactly "1011"
    // Should assert flag for one cycle
    $display("\n--- Test 1: single 1011 ---");
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(1);   // <-- flag should be 1 here
    repeat(3) @(posedge clk);

    // Test 2: overlapping pattern "10111"
    // Should detect 1011 twice:
    //   - bits: 1 0 1 1 1
    //   detection at pos 4 and pos 5
    $display("\n--- Test 2: overlapping 10111 ---");
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(1);   // first detection
    send_bit(1);   // overlap detection (1011 shifting)
    repeat(3) @(posedge clk);

    // Test 3: random noise then embedded 1011
    $display("\n--- Test 3: random + 1011 ---");
    send_bit(0);
    send_bit(1);
    send_bit(1);
    send_bit(0);

    // Now embed 1011
    send_bit(1);
    send_bit(0);
    send_bit(1);
    send_bit(1);  // detect here

    repeat(5) @(posedge clk);

    // Test 4: long stream with multiple “1011”
    $display("\n--- Test 4: multiple 1011 in long stream ---");
    bit stream [0:19] = '{1,0,1,1,   // detect
                         0,1,1,0,
                         1,0,1,1,   // detect
                         1,0,1,1};  // detect + overlap

    foreach (stream[i]) begin
      send_bit(stream[i]);
    end

    repeat(5) @(posedge clk);

    $display("\n--- Simulation finished ---");
    $finish;
  end

endmodule
