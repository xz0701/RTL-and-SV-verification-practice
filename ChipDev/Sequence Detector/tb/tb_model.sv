`timescale 1ns/1ns

module model_tb;

  logic clk;
  logic resetn;
  logic din;
  logic dout;

  // Instantiate DUT
  model dut (
    .clk    (clk),
    .resetn (resetn),
    .din    (din),
    .dout   (dout)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Reference model state encoding
  typedef enum logic [2:0] {
    R_IDLE,
    R_S1,
    R_S10,
    R_S101,
    R_S1010
  } ref_state_t;

  ref_state_t ref_state;
  logic ref_dout;

  // Golden model
  task automatic ref_model(input logic din_i);
    if (!resetn) begin
      ref_state = R_IDLE;
      ref_dout  = 1'b0;
    end
    else begin
      case (ref_state)
        R_IDLE  : ref_state =  din_i ? R_S1    : R_IDLE;
        R_S1    : ref_state = !din_i ? R_S10   : R_S1;
        R_S10   : ref_state =  din_i ? R_S101  : R_IDLE;
        R_S101  : ref_state = !din_i ? R_S1010 : R_S1;
        R_S1010 : ref_state =  din_i ? R_S101  : R_IDLE;
        default : ref_state =  R_IDLE;
      endcase
      ref_dout = (ref_state == R_S1010);
    end
  endtask

  // Checker
  task automatic check();
    if (dout !== ref_dout) begin
      $display("[%0t] FAIL: din=%0b dout=%0b exp=%0b state=%0d",
               $time, din, dout, ref_dout, ref_state);
    end
    else begin
      $display("[%0t] PASS: din=%0b dout=%0b",
               $time, din, dout);
    end
  endtask

  // One-cycle step
  task automatic step(input logic din_i);
    din = din_i;
    @(posedge clk);
    #1;                 // allow DUT state update to settle
    ref_model(din_i);
    check();
  endtask

  // Stimulus
  initial begin
    $dumpfile("model.vcd");
    $dumpvars(0, model_tb);

    // Init
    resetn    = 0;
    din       = 0;
    ref_state = R_IDLE;
    ref_dout  = 0;

    // Reset
    $display("\n=== Reset ===");
    repeat (2) @(posedge clk);
    resetn = 1;
    step(0);

    // Directed tests
    $display("\n=== Directed tests ===");

    // 1010 -> should assert dout
    step(1);
    step(0);
    step(1);
    step(0);   // dout expected = 1

    // Overlapping sequence: 101010
    step(1);
    step(0);
    step(1);
    step(0);   // dout = 1 again

    // Break sequence
    step(0);
    step(0);
    step(1);

    // Random tests
    $display("\n=== Random tests ===");
    for (int i = 0; i < 20; i++) begin
      step($urandom_range(0,1));
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
