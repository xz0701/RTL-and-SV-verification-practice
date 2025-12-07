`timescale 1ns/1ns

module count_module_tb;

    // DUT Signals
    logic clk;
    logic rst_n;
    logic mode;
    logic [3:0] number;
    logic zero;

    // Instantiate DUT
    count_module dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .mode   (mode),
        .number (number),
        .zero   (zero)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset task
    task automatic reset_dut();
        begin
            rst_n = 0;
            mode  = 0;
            repeat(2) @(posedge clk);
            rst_n = 1;
            @(posedge clk);
        end
    endtask

    // Checker task
    task automatic check_output(input int exp_num, input bit exp_zero);
        begin
            if (number !== exp_num[3:0] || zero !== exp_zero) begin
                $display("[%0t] FAIL: expected num=%0d zero=%0b, got num=%0d zero=%0b",
                         $time, exp_num, exp_zero, number, zero);
            end else begin
                $display("[%0t] PASS: num=%0d zero=%0b",
                         $time, number, zero);
            end
        end
    endtask

    // Test sequence
    initial begin
        $dumpfile("count_module.vcd");
        $dumpvars(0, count_module_tb);

        reset_dut();

        int  exp_num;
        bit  exp_zero;

        // Test increment mode (mode=1)
        $display("\n=== TEST: Increment Mode ===");

        mode = 1;
        exp_num  = 0;
        exp_zero = 1;  // since 0 should cause zero=1

        for (int i = 0; i < 20; i++) begin
            @(posedge clk);

            // Expected model
            exp_zero = (exp_num == 0);
            check_output(exp_num, exp_zero);

            // Next expected value
            exp_num = (exp_num == 9) ? 0 : (exp_num + 1);
        end

        // Test decrement mode (mode=0)
        $display("\n=== TEST: Decrement Mode ===");

        mode = 0;
        exp_num = number; // start from current DUT number

        for (int i = 0; i < 20; i++) begin
            @(posedge clk);

            exp_zero = (exp_num == 0);
            check_output(exp_num, exp_zero);

            // Next expected value
            exp_num = (exp_num == 0) ? 9 : (exp_num - 1);
        end

        $display("\nSimulation Finished.");
        $finish;
    end

endmodule
