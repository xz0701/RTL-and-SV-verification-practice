`timescale 1ns/1ns

module count_module_tb;

    logic clk;
    logic rst_n;
    logic [5:0] second;
    logic [5:0] minute;

    // DUT
    count_module dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .second (second),
        .minute (minute)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset task
    task automatic reset_dut();
        begin
            rst_n = 0;
            repeat(2) @(posedge clk);
            rst_n = 1;
            @(posedge clk);
        end
    endtask

    // Self-checking task
    task automatic check_value(input int expected_sec, input int expected_min);
        begin
            if (second !== expected_sec[5:0] || minute !== expected_min[5:0]) begin
                $display("[%0t] FAIL: expected second=%0d minute=%0d, got %0d / %0d",
                         $time, expected_sec, expected_min, second, minute);
            end
            else begin
                $display("[%0t] PASS: second=%0d minute=%0d",
                         $time, second, minute);
            end
        end
    endtask

    // Test sequence
    initial begin
        $dumpfile("count_module.vcd");
        $dumpvars(0, count_module_tb);

        reset_dut();

        int exp_sec = 0;
        int exp_min = 0;

        // ---------------------------
        // Run for 3700 cycles
        // Automatically verify values
        // ---------------------------
        for (int cycle = 1; cycle <= 3700; cycle++) begin
            @(posedge clk);

            // Model expected behavior
            if (exp_min < 60) begin
                exp_sec++;
                if (exp_sec == 60) begin
                    exp_sec = 1;
                    exp_min++;
                end
            end
            // after exp_min==60, counters stop changing

            check_value(exp_sec, exp_min);
        end

        $display("Simulation Finished.");
        $finish;
    end

endmodule
