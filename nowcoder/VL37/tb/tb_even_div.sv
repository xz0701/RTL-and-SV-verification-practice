`timescale 1ns/1ns

module even_div_tb;

  // DUT signals
  reg  clk_in;
  reg  rst;
  wire clk_out2;
  wire clk_out4;
  wire clk_out8;

  // Instantiate DUT
  even_div dut (
    .rst      (rst),
    .clk_in   (clk_in),
    .clk_out2 (clk_out2),
    .clk_out4 (clk_out4),
    .clk_out8 (clk_out8)
  );

  // Clock generation
  initial clk_in = 0;
  always #5 clk_in = ~clk_in;

  // Reset procedure
  task reset_dut();
    begin
      rst = 0;
      repeat(3) @(posedge clk_in);
      rst = 1;
      @(posedge clk_in);
    end
  endtask

  // Main simulation
  initial begin
    $dumpfile("even_div.vcd");
    $dumpvars(0, even_div_tb);

    reset_dut();

    // Run for several cycles to observe clk_out2/4/8
    repeat(200) @(posedge clk_in);

    $display("Simulation finished.");
    $finish;
  end

endmodule
