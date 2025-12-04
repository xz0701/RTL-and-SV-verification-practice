`timescale 1ns/1ns

module fsm2_tb;

  logic clk;
  logic rst;
  logic data;
  logic flag;

  // DUT
  fsm2 dut (
    .clk  (clk),
    .rst  (rst),
    .data (data),
    .flag (flag)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset
  task automatic reset_dut();
    begin
      rst  = 0;
      data = 0;
      repeat(2) @(posedge clk);
      rst = 1;
      @(posedge clk);
    end
  endtask

  // Drive 1 bit
  task automatic send_bit(bit d);
    begin
      data = d;
      @(posedge clk);
    end
  endtask

  // Check expected flag
  task automatic check_flag(bit expected);
    begin
      if (flag !== expected)
        $display("[%0t] FAIL: expect flag=%0b, got %0b",
                 $time, expected, flag);
      else
        $display("[%0t] PASS: flag=%0b",
                 $time, flag);
    end
  endtask

  // Main stimulus
  initial begin
    $dumpfile("fsm2.vcd");
    $dumpvars(0, fsm2_tb);

    reset_dut();

    // Test Case 1: 1111 → expect 1 detect
    $display("\n=== Test 1: 1111 ===");
    send_bit(1); check_flag(0); // S1
    send_bit(1); check_flag(0); // S2
    send_bit(1); check_flag(0); // S3
    send_bit(1); check_flag(1); // S4 -> flag = 1

    // Test Case 2: 11011 -> no detect
    $display("\n=== Test 2: 11011 ===");
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);
    send_bit(0); check_flag(0); // break
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);

    // Test Case 3: 11111 -> overlapping detect
    $display("\n=== Test 3: 11111 (overlap) ===");
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(1); // first detection
    send_bit(1); check_flag(1); // second detection (overlap)

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
