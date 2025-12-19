`timescale 1ns/1ns

module model_tb;

  logic clk;
  logic resetn;

  always #5 clk = ~clk; 

  // DUT signals
  logic [7:0] din;
  logic [2:0] addr;
  logic wr;
  logic rd;

  logic [7:0] dout;
  logic error;

  // Instantiate DUT
  model dut (
    .din    (din),
    .addr   (addr),
    .wr     (wr),
    .rd     (rd),
    .clk    (clk),
    .resetn (resetn),
    .dout   (dout),
    .error  (error)
  );

  // Golden model
  logic [7:0] golden_mem [0:7];
  logic       golden_valid [0:7];

  // Reset golden model
  task automatic golden_reset();
    begin
      for (int i = 0; i < 8; i++) begin
        golden_mem[i]   = '0;
        golden_valid[i] = 1'b0;
      end
    end
  endtask

  // Golden model update
  task automatic golden_update();
    begin
      if (wr && rd) begin
        // no state change
      end
      else if (wr && !rd) begin
        golden_mem[addr]   = din;
        golden_valid[addr] = 1'b1;
      end
    end
  endtask

  // Checker
  task automatic check();
    logic [7:0] exp_dout;
    logic exp_error;
    begin
      // Expected error
      exp_error = (wr && rd);

      // Expected dout
      if (wr || !rd)
        exp_dout = '0;
      else if (!golden_valid[addr])
        exp_dout = '0;
      else
        exp_dout = golden_mem[addr];

      if (dout !== exp_dout || error !== exp_error) begin
        $display("[%0t] FAIL", $time);
        $display("  addr=%0d din=0x%02h wr=%0b rd=%0b",
                 addr, din, wr, rd);
        $display("  dout=%0h exp=%0h error=%0b exp=%0b",
                 dout, exp_dout, error, exp_error);
      end
      else begin
        $display("[%0t] PASS addr=%0d wr=%0b rd=%0b dout=0x%02h",
                 $time, addr, wr, rd, dout);
      end
    end
  endtask

  // Drive helpers
  task automatic do_write(input [2:0] a, input [7:0] d);
    begin
      addr = a;
      din  = d;
      wr   = 1;
      rd   = 0;
      @(posedge clk);
      golden_update();
      check();
      wr = 0;
    end
  endtask

  task automatic do_read(input [2:0] a);
    begin
      addr = a;
      wr   = 0;
      rd   = 1;
      @(posedge clk);
      check();
      rd = 0;
    end
  endtask

  task automatic do_illegal(input [2:0] a);
    begin
      addr = a;
      wr   = 1;
      rd   = 1;
      @(posedge clk);
      check();
      wr = 0;
      rd = 0;
    end
  endtask

  // Stimulus
  initial begin
    // Init
    clk    = 0;
    resetn = 0;
    wr     = 0;
    rd     = 0;
    din    = 0;
    addr   = 0;

    $display("\n=== Reset ===");
    golden_reset();
    repeat (2) @(posedge clk);
    resetn = 1;

    // Read invalid locations
    $display("\n=== Read invalid ===");
    for (int i = 0; i < 4; i++) begin
      do_read(i[2:0]);
    end

    // Writes
    $display("\n=== Writes ===");
    for (int i = 0; i < 4; i++) begin
      do_write(i[2:0], $urandom);
    end

    // Reads after write
    $display("\n=== Reads after write ===");
    for (int i = 0; i < 4; i++) begin
      do_read(i[2:0]);
    end

    // Illegal access
    $display("\n=== Illegal access (wr & rd) ===");
    do_illegal(3'd2);

    // Random tests
    $display("\n=== Random stress ===");
    for (int i = 0; i < 50; i++) begin
      addr = $urandom_range(0,7);
      din  = $urandom;
      wr   = $urandom_range(0,1);
      rd   = $urandom_range(0,1);
      @(posedge clk);
      golden_update();
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
