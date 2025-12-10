`timescale 1ns/1ns

module triffic_light_tb;

  reg clk;
  reg rst_n;
  reg pass_request;

  wire [7:0] clock;
  wire red, yellow, green;

  // DUT
  triffic_light dut(
    .clk(clk),
    .rst_n(rst_n),
    .pass_request(pass_request),
    .clock(clock),
    .red(red),
    .yellow(yellow),
    .green(green)
  );

  // clock generation
  initial clk = 0;
  always #5 clk = ~clk;  

  // task: print current status
  task show;
    $display("[%0t] red=%0b yellow=%0b green=%0b clock=%0d pass_request=%0b",
             $time, red, yellow, green, clock, pass_request);
  endtask

  // task: wait N cycles
  task wait_cycles(input int n);
    repeat(n) @(posedge clk);
  endtask

  // main stimulus
  initial begin
    // Dump waveform
    $dumpfile("triffic_light.vcd");
    $dumpvars(0, triffic_light_tb);

    // Initial values
    rst_n = 0;
    pass_request = 0;

    // Reset sequence
    wait_cycles(5);
    rst_n = 1;
    $display("=== RELEASE RESET ===");

    // Let DUT run normally
    repeat(20) begin
      @(posedge clk);
      show();
    end

    // press the button during green (should shorten to 10 cycles)
    $display("=== PRESS BUTTON ===");
    pass_request = 1;
    wait_cycles(2);
    pass_request = 0;

    // Continue observing behavior
    repeat(100) begin
      @(posedge clk);
      show();
    end

    $display("=== SIM DONE ===");
    $finish;
  end


  // Basic assertions
  always @(posedge clk) begin
    // only one lamp allowed ON at a time
    assert( red + yellow + green <= 1 )
      else $error("Multiple signal lights are ON at time %0t!", $time);

    // clock must match active state remaining count (simple check)
    assert(clock <= 60)
      else $error("Clock value overflow at %0t!", $time);
  end

endmodule
