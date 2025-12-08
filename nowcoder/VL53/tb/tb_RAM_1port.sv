`timescale 1ns/1ns

module tb_RAM_1port;

  // DUT Interface Signals
  logic        clk;
  logic        rst;
  logic        enb;
  logic [6:0]  addr;
  logic [3:0]  w_data;
  logic [3:0]  r_data;

  logic [3:0] golden_mem [0:127];

  // Instantiate DUT-
  RAM_1port dut (
    .clk    (clk),
    .rst    (rst),
    .enb    (enb),
    .addr   (addr),
    .w_data (w_data),
    .r_data (r_data)
  );

  // Clock Generator
  initial begin
    clk = 0;
    forever #5 clk = ~clk;   // 10ns clock period
  end

  // Reset Task
  task automatic do_reset();
    begin
      rst    = 0;
      enb    = 0;
      addr   = 0;
      w_data = 0;

      // Clear golden model
      foreach (golden_mem[i]) begin
        golden_mem[i] = 4'h0;
      end

      #20;
      rst = 1;
      @(posedge clk);
    end
  endtask

  // Write Task
  task automatic do_write(input logic [6:0] a,
                          input logic [3:0] d);
    begin
      @(posedge clk);
      enb    = 1;
      addr   = a;
      w_data = d;

      golden_mem[a] = d;   // update golden
    end
  endtask

  // Read Task
  task automatic do_read(input logic [6:0] a);
    begin
      @(posedge clk);
      enb  = 0;
      addr = a;

      @(negedge clk);   // data becomes valid here

      if (r_data !== golden_mem[a]) begin
        $display("[%0t] ERROR: addr=%0d expect=%0h got=%0h",
                 $time, a, golden_mem[a], r_data);
        $fatal;
      end
      else begin
        $display("[%0t] READ OK: addr=%0d data=%0h",
                 $time, a, r_data);
      end
    end
  endtask

  // Stimulus
  initial begin
    do_reset();

    // Basic write-read test
    do_write(10, 4'hA);
    do_write(20, 4'h5);
    do_write(30, 4'hF);

    do_read(10);
    do_read(20);
    do_read(30);

    // Random read/write test
    repeat (20) begin
      logic [6:0] rnd_addr = $urandom_range(0,127);
      logic       op       = $urandom_range(0,1);

      if (op) begin
        do_write(rnd_addr, $urandom_range(0,15));
      end
      else begin
        do_read(rnd_addr);
      end
    end

    $display("========== TEST PASSED ==========");
    $finish;
  end

endmodule
