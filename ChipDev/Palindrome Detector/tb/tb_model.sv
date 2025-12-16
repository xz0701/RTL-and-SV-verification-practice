`timescale 1ns/1ns

module model_tb;

  // Parameters
  localparam int DATA_WIDTH = 32;

  // DUT signals
  logic [DATA_WIDTH-1:0] din;
  logic dout;

  // Instantiate DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .din  (din),
    .dout (dout)
  );

  // Golden reference model
  function automatic bit is_palindrome(input logic [DATA_WIDTH-1:0] v);
    begin
      for (int i = 0; i < DATA_WIDTH/2; i++) begin
        if (v[i] !== v[DATA_WIDTH-1-i])
          return 0;
      end
      return 1;
    end
  endfunction

  // Checker
  task automatic check();
    bit exp;
    begin
      exp = is_palindrome(din);
      if (dout !== exp) begin
        $display("[%0t] FAIL: din=0x%08h exp=%0b got=%0b",
                 $time, din, exp, dout);
      end
      else begin
        $display("[%0t] PASS: din=0x%08h dout=%0b",
                 $time, din, dout);
      end
    end
  endtask

  // Stimulus
  initial begin

    // Directed tests
    $display("\n=== Directed tests ===");

    // All zeros (palindrome)
    din = '0;
    #1; check();

    // All ones (palindrome)
    din = '1;
    #1; check();

    // Simple palindrome pattern
    din = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
    #1; check();

    // Another palindrome
    din = 32'b0110_1001_1001_0110_0110_1001_1001_0110;
    #1; check();

    // Not a palindrome
    din = 32'h8000_0000;
    #1; check();

    din = 32'h1234_5678;
    #1; check();

    // Random tests
    $display("\n=== Random tests ===");

    for (int i = 0; i < 100; i++) begin
      din = $urandom;
      #1;
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
