`timescale 1ns/1ns

module model_tb;

  logic clk;
  logic resetn;

  always #5 clk = ~clk;

  // DUT signals
  logic [7:0]  din;
  logic [17:0] dout;
  logic        run;

  // Instantiate DUT
  model dut (
    .din    (din),
    .clk    (clk),
    .resetn (resetn),
    .dout   (dout),
    .run    (run)
  );

  // Golden model
  int g_cnt;
  logic [7:0] g_data [0:5];

  always_ff @(posedge clk) begin
    if (!resetn) begin
      g_cnt <= 0;
      for (int i = 0; i < 6; i++) g_data[i] <= '0;
    end
    else begin
      g_data[g_cnt] <= din;
      if (g_cnt == 5) g_cnt <= 0;
      else            g_cnt <= g_cnt + 1;
    end
  end

  function automatic logic [17:0] golden_dot();
    logic [15:0] p0, p1, p2;
    logic [17:0] s;
    begin
      p0 = g_data[0] * g_data[3];
      p1 = g_data[1] * g_data[4];
      p2 = g_data[2] * g_data[5];
      s  = p0 + p1 + p2;
      return s;
    end
  endfunction

  // Checker
  task automatic check_on_run();
    logic [17:0] exp;
    begin
      exp = golden_dot();
      if (dout !== exp) begin
        $display("[%0t] FAIL (run) dout=0x%0h exp=0x%0h", $time, dout, exp);
        $display("  g_data: [%0d %0d %0d %0d %0d %0d]",
                 g_data[0], g_data[1], g_data[2], g_data[3], g_data[4], g_data[5]);
      end
      else begin
        $display("[%0t] PASS (run) dout=0x%0h", $time, dout);
      end
    end
  endtask

  // Drive helper
  task automatic drive_sample(input logic [7:0] v);
    begin
      din = v;
      @(posedge clk);
    end
  endtask

  // Stimulus
  initial begin
    clk    = 0;
    resetn = 0;
    din    = 0;

    $display("\n=== Reset ===");
    repeat (2) @(posedge clk);
    resetn = 1;

    // Directed test
    $display("\n=== Directed test ===");

    // Fill 6 samples: d0..d5
    drive_sample(8'd1);   // -> data[0]
    drive_sample(8'd2);   // -> data[1]
    drive_sample(8'd3);   // -> data[2]
    drive_sample(8'd4);   // -> data[3]
    drive_sample(8'd5);   // -> data[4]
    drive_sample(8'd6);   // -> data[5]

    // Next cycle is run==1 (cnt wraps to 0 inside DUT logic)
    // We check only when run is high
    if (run) check_on_run();
    else begin
      @(posedge clk);
      if (run) check_on_run();
    end

    // Random tests: multiple frames
    $display("\n=== Random tests ===");
    for (int frame = 0; frame < 20; frame++) begin
      // Provide 6 samples
      for (int i = 0; i < 6; i++) begin
        drive_sample($urandom_range(0, 255));
      end

      // Wait until run asserts and check
      // (run is expected once per 6 cycles)
      for (int k = 0; k < 3; k++) begin
        if (run) begin
          check_on_run();
          break;
        end
        @(posedge clk);
      end
    end

    // Mid-run reset
    $display("\n=== Mid-run reset ===");
    drive_sample(8'd9);
    drive_sample(8'd10);
    resetn = 0;
    @(posedge clk);
    resetn = 1;

    // After reset, first run will not be meaningful until 6 new samples loaded,
    // but DUT will still compute something. We only check after one full frame.
    for (int i = 0; i < 6; i++) drive_sample($urandom_range(0, 255));
    // Find run and check
    for (int k = 0; k < 3; k++) begin
      if (run) begin
        check_on_run();
        break;
      end
      @(posedge clk);
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
