`timescale 1ns/1ns

module fsm1_tb;

  logic clk;
  logic rst;
  logic data;
  logic flag;

  // DUT instance
  fsm1 dut (
    .clk  (clk),
    .rst  (rst),
    .data (data),
    .flag (flag)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset task
  task automatic reset_dut();
    begin
      rst  = 0;
      data = 0;
      repeat(2) @(posedge clk);
      rst = 1;
      @(posedge clk);
    end
  endtask

  // Drive one bit
  task automatic send_bit(bit d);
    begin
      data = d;
      @(posedge clk);
    end
  endtask

  // Self-check
  task automatic check_flag(bit expected);
    begin
      if (flag !== expected)
        $display("[%0t] FAIL: expected %0b, got %0b",
                 $time, expected, flag);
      else
        $display("[%0t] PASS: flag=%0b",
                 $time, flag);
    end
  endtask


  // Test sequence
  initial begin
    $dumpfile("fsm1.vcd");
    $dumpvars(0, fsm1_tb);

    reset_dut();

    // Case 1: 1111 -> detect once
    $display("\n=== Test 1: 1111 ===");
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(1); // detect

    // Case 2: 11011 -> no detect
    $display("\n=== Test 2: 11011 ===");
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);
    send_bit(0); check_flag(0);
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);

    // Case 3: 11111 -> overlap detect
    $display("\n=== Test 3: 11111 (overlap) ===");
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(0);
    send_bit(1); check_flag(1); // first detect
    send_bit(1); check_flag(1); // second detect (overlap)

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
