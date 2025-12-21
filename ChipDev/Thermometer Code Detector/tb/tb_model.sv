`timescale 1ns/1ns

module model_tb;

  localparam int DATA_WIDTH = 8;

  // DUT signals
  logic [DATA_WIDTH-1:0] codeIn;
  logic isThermometer;

  // Instantiate DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .codeIn        (codeIn),
    .isThermometer (isThermometer)
  );

  // Golden model
  function automatic bit golden_is_thermometer(
    input logic [DATA_WIDTH-1:0] v
  );
    bit seen_zero;
    begin
      seen_zero = 0;

      // Scan from MSB to LSB
      for (int i = DATA_WIDTH-1; i >= 0; i--) begin
        if (v[i] == 0)
          seen_zero = 1;
        else if (seen_zero)
          return 0; // 1 appears after 0 → not thermometer
      end

      // Reject all-0 and all-1
      if (v == '0 || v == {DATA_WIDTH{1'b1}})
        return 0;

      return 1;
    end
  endfunction

  // Checker
  task automatic check();
    bit exp;
    begin
      exp = golden_is_thermometer(codeIn);

      if (isThermometer !== exp) begin
        $display("[%0t] FAIL codeIn=%b isThermometer=%0b exp=%0b",
                 $time, codeIn, isThermometer, exp);
      end
      else begin
        $display("[%0t] PASS codeIn=%b isThermometer=%0b",
                 $time, codeIn, isThermometer);
      end
    end
  endtask

  // Stimulus
  initial begin
    $display("\n=== Directed valid thermometer codes ===");

    // Valid thermometer patterns
    codeIn = 8'b0000_0001; #1; check();
    codeIn = 8'b0000_0011; #1; check();
    codeIn = 8'b0000_0111; #1; check();
    codeIn = 8'b0000_1111; #1; check();
    codeIn = 8'b0011_1111; #1; check();
    codeIn = 8'b0111_1111; #1; check();

    $display("\n=== Directed invalid patterns ===");

    // All zero / all one
    codeIn = 8'b0000_0000; #1; check();
    codeIn = 8'b1111_1111; #1; check();

    // Multiple transitions
    codeIn = 8'b1011_1111; #1; check();
    codeIn = 8'b1101_1110; #1; check();
    codeIn = 8'b0101_0101; #1; check();

    $display("\n=== Random tests ===");

    for (int i = 0; i < 100; i++) begin
      codeIn = $urandom;
      #1;
      check();
    end

    $display("\nSimulation finished.");
    $finish;
  end

endmodule
