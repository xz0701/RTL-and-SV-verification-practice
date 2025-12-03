`timescale 1ns/1ns

module odo_div_or_tb;

  // DUT signals
  reg  clk_in;
  reg  rst;
  wire clk_out7;

  // Instantiate DUT
  odo_div_or dut (
    .rst      (rst),
    .clk_in   (clk_in),
    .clk_out7 (clk_out7)
  );

  // Clock generation
  initial clk_in = 0;
  always #5 clk_in = ~clk_in;

  // Reset
  task reset_dut();
    begin
      rst = 0;
      repeat(3) @(posedge clk_in);
      rst = 1;
      @(posedge clk_in);
    end
  endtask

  // Main stimulus
  initial begin
    // Dump wave file
    $dumpfile("odo_div_or.vcd");
    $dumpvars(0, odo_div_or_tb);

    reset_dut();

    // Run long enough
    repeat(300) @(posedge clk_in);

    $display("Simulation finished.");
    $finish;
  end

endmodule
