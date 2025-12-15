`timescale 1ns/1ns

module model_tb;

  // Parameters
  localparam int DATA_WIDTH = 32;

  // DUT signals
  logic [DATA_WIDTH-1:0] din;
  logic onehot;

  // Instantiate DUT
  model #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .din    (din),
    .onehot (onehot)
  );

  // Golden reference model
  function automatic bit is_onehot(input logic [DATA_WIDTH-1:0] v);
    int cnt;
    begin
      cnt = 0;
      for (int i = 0; i < DATA_WIDTH; i++)
        cnt += v[i];
      return (cnt == 1);
    end
  endfunction

  // Checker
  task automatic check();
    bit exp;
    begin
      exp = is_onehot(din);
      if (onehot !== exp) begin
        $display("[%0t] FAIL: din=0x%08h exp_onehot=%0b got=%0b",
                 $time, din, exp, onehot);
      end
      else begin
        $display("[%0t] PASS: din=0x%08h onehot=%0b",
                 $time, din, onehot);
      end
    end
  endtask

  // Stimulus
  initial begin
    $dumpfile("model.vcd");
    $dumpvars(0, model_tb);

    // Directed tests
    $display("\n=== Directed tests ===");

    din = '0;                #1; check(); // all zeros
    din = 32'h0000_0001;     #1; check(); // LSB one-hot
    din = 32'h8000_0000;     #1; check(); // MSB one-hot
    din = 32'h0000_0010;     #1; check(); // middle one-hot
    din = 32'h0000_0003;     #1; check(); // two bits set
    din = 32'h0000_00F0;     #1; check(); // multiple bits
    din = 32'hFFFF_FFFF;     #1; check(); // all bits set

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
