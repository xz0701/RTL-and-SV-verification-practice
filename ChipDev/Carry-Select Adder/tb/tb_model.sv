`timescale 1ns/1ns

module model_tb;

  logic clk;
  logic resetn;

  always #5 clk = ~clk;

  // DUT signals
  logic din;
  logic cen;
  logic doutx;
  logic douty;

  // Instantiate DUT
  model dut (
    .clk    (clk),
    .resetn (resetn),
    .din    (din),
    .cen    (cen),
    .doutx  (doutx),
    .douty  (douty)
  );

  // Reference FSM
  typedef enum int {
    R_S0, R_S1, R_S2, R_S3, R_S4
  } ref_state_t;

  ref_state_t ref_state, ref_next_state;
  logic ref_din_reg, ref_cen_reg;

  // State + input registers
  always_ff @(posedge clk) begin
    if (!resetn) begin
      ref_state   <= R_S0;
      ref_din_reg <= 0;
      ref_cen_reg <= 0;
    end
    else begin
      ref_state   <= ref_next_state;
      ref_din_reg <= din;
      ref_cen_reg <= cen;
    end
  end

  // Reference transition logic (behavioral)
  always_comb begin
    case (ref_state)
      R_S0: ref_next_state = ref_din_reg ? R_S3 : R_S1;
      R_S1: ref_next_state = ref_din_reg ? R_S3 : R_S2;
      R_S2: ref_next_state = ref_din_reg ? R_S3 : R_S2;
      R_S3: ref_next_state = ref_din_reg ? R_S4 : R_S1;
      R_S4: ref_next_state = ref_din_reg ? R_S4 : R_S1;
      default: ref_next_state = R_S0;
    endcase
  end

  // Reference outputs
  function automatic logic ref_doutx();
    if (!ref_cen_reg) return 0;
    return ((ref_state == R_S1 || ref_state == R_S2) && !ref_din_reg) ||
           ((ref_state == R_S3 || ref_state == R_S4) &&  ref_din_reg);
  endfunction

  function automatic logic ref_douty();
    if (!ref_cen_reg) return 0;
    return ((ref_state == R_S2) && !ref_din_reg) ||
           ((ref_state == R_S4) &&  ref_din_reg);
  endfunction

  // Checker
  task automatic check();
    logic exp_x, exp_y;
    begin
      exp_x = ref_doutx();
      exp_y = ref_douty();

      if (doutx !== exp_x || douty !== exp_y) begin
        $display("[%0t] FAIL din=%0b cen=%0b | doutx=%0b exp=%0b | douty=%0b exp=%0b",
                 $time, din, cen, doutx, exp_x, douty, exp_y);
      end
      else begin
        $display("[%0t] PASS din=%0b cen=%0b | doutx=%0b douty=%0b",
                 $time, din, cen, doutx, douty);
      end
    end
  endtask

  // Stimulus
  initial begin
    clk    = 0;
    resetn = 0;
    din    = 0;
    cen    = 0;

    $display("\n=== Reset ===");
    repeat (2) @(posedge clk);
    resetn = 1;

    // cen = 0 -> outputs must stay 0
    $display("\n=== cen = 0 test ===");
    repeat (5) begin
      din = $urandom_range(0,1);
      cen = 0;
      @(posedge clk);
      check();
    end

    // cen = 1, deterministic walk
    $display("\n=== cen = 1 deterministic ===");
    cen = 1;

    din = 0; @(posedge clk); check();
    din = 0; @(posedge clk); check();
    din = 1; @(posedge clk); check();
    din = 1; @(posedge clk); check();
    din = 0; @(posedge clk); check();

    // Random stress
    $display("\n=== Random stress ===");
    repeat (30) begin
      din = $urandom_range(0,1);
      cen = $urandom_range(0,1);
      @(posedge clk);
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
