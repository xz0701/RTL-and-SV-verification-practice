`timescale 1ns/1ns

module tb_ram_mod;

  // DUT Interface
  logic clk;
  logic rst_n;

  logic write_en;
  logic [7:0] write_addr;
  logic [3:0] write_data;

  logic read_en;
  logic [7:0] read_addr;
  logic [3:0] read_data;

  // Golden reference memory
  logic [3:0] golden_mem [0:7];

  // Instantiate DUT
  ram_mod dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .write_en   (write_en),
    .write_addr (write_addr),
    .write_data (write_data),
    .read_en    (read_en),
    .read_addr  (read_addr),
    .read_data  (read_data)
  );

  // Clock Generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10 ns clock
  end

  // Reset Task
  task automatic do_reset();
    begin
      rst_n      = 0;
      write_en   = 0;
      read_en    = 0;
      write_addr = 0;
      write_data = 0;
      read_addr  = 0;

      // clear golden model
      foreach (golden_mem[i]) begin
        golden_mem[i] = 4'h0;
      end

      #20;
      rst_n = 1;
      @(posedge clk);
    end
  endtask

  // Write Task
  task automatic do_write(input logic [7:0] addr,
                          input logic [3:0] data);
    begin
      @(posedge clk);
      write_en   = 1;
      write_addr = addr;
      write_data = data;

      golden_mem[addr] = data;   // update golden model
      @(posedge clk);
      write_en = 0;
    end
  endtask

  // Read Task 
  task automatic do_read(input logic [7:0] addr);
    begin
      @(posedge clk);
      read_en  = 1;
      read_addr = addr;

      @(posedge clk); // data available here

      if (read_data !== golden_mem[addr]) begin
        $display("[%0t] ERROR: addr=%0d expect=%0h got=%0h",
                  $time, addr, golden_mem[addr], read_data);
        $fatal;
      end
      else begin
        $display("[%0t] READ OK: addr=%0d data=%0h",
                 $time, addr, read_data);
      end

      read_en = 0;
    end
  endtask

  // Main Stimulus
  initial begin
    do_reset();

    // Basic write and read
    do_write(0, 4'hA);
    do_write(3, 4'h5);
    do_write(6, 4'hF);

    do_read(0);
    do_read(3);
    do_read(6);

    // Random test
    repeat (20) begin
      logic [7:0] a   = $urandom_range(0,7);
      logic [3:0] d   = $urandom_range(0,15);
      logic       op  = $urandom_range(0,1);

      if (op) begin
        do_write(a, d);
      end else begin
        do_read(a);
      end
    end

    $display("========== TEST PASSED ==========");
    $finish;
  end

endmodule
