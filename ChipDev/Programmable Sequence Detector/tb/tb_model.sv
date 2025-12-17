`timescale 1ns/1ps

module tb_model;

  logic clk;
  logic resetn;

  // Clock Generation
  always #5 clk = ~clk;

  // DUT Interface
  // ------------------------------------------------------------------
  logic [4:0] init;
  logic       din;
  logic       seen;

  model dut (
    .clk    (clk),
    .resetn (resetn),
    .init   (init),
    .din    (din),
    .seen   (seen)
  );

  // ------------------------------------------------------------------
  // Reference Model (Scoreboard)
  // ------------------------------------------------------------------
  logic [4:0] ref_shift;
  logic [4:0] ref_target;
  logic [2:0] ref_cnt;
  logic       ref_reset_detect;

  logic       ref_seen;

  // ------------------------------------------------------------------
  // Reset task
  // ------------------------------------------------------------------
  task automatic apply_reset();
    begin
      resetn = 0;
      init   = '0;
      din    = 0;
      repeat (2) @(posedge clk);
      resetn = 1;
      @(posedge clk);
    end
  endtask

  // ------------------------------------------------------------------
  // Drive one cycle of din
  // ------------------------------------------------------------------
  task automatic drive_bit(input logic bit_in);
    begin
      din = bit_in;
      @(posedge clk);
    end
  endtask

  // ------------------------------------------------------------------
  // Reference model update
  // ------------------------------------------------------------------
  always_ff @(posedge clk) begin
    ref_reset_detect <= resetn;

    if (!resetn) begin
      ref_shift  <= '0;
      ref_cnt    <= '0;
      ref_target <= '0;
    end
    else begin
      // Capture init only on reset rising edge
      if (resetn && !ref_reset_detect) begin
        ref_target <= init;
      end

      // Shift register
      ref_shift <= {ref_shift[3:0], din};

      // Counter saturates at 5
      if (ref_cnt < 3'd5)
        ref_cnt <= ref_cnt + 1;
    end
  end

  // Reference seen logic
  always_comb begin
    ref_seen = ref_reset_detect &&
               (ref_shift == ref_target) &&
               (ref_cnt == 3'd5);
  end

  // ------------------------------------------------------------------
  // Checker
  always_ff @(posedge clk) begin
    if (resetn) begin
      assert (seen === ref_seen)
        else $error("[CHECK FAIL] time=%0t seen=%0b ref_seen=%0b",
                    $time, seen, ref_seen);
    end
  end

  // Test Sequence
  initial begin
    // Init
    clk    = 0;
    resetn = 0;
    din    = 0;
    init   = 0;

    // Test 1: Simple match
    apply_reset();
    init = 5'b10110;

    drive_bit(1);
    drive_bit(0);
    drive_bit(1);
    drive_bit(1);
    drive_bit(0);

    repeat (3) drive_bit($urandom_range(0,1));

    // Test 2: Change init after reset (should not affect target)
    init = 5'b00000;
    repeat (5) drive_bit($urandom_range(0,1));

    // Test 3: Second reset
    apply_reset();
    init = 5'b11001;
    repeat (10) drive_bit($urandom_range(0,1));

    $display("All tests completed");
    $finish;
  end

endmodule
