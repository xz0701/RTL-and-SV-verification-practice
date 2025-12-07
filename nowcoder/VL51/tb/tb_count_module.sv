`timescale 1ns/1ns

module count_module_tb;

    // DUT 
    logic clk;
    logic rst_n;
    logic set;
    logic [3:0] set_num;
    logic [3:0] number;
    logic zero;

    // Instantiate DUT
    count_module dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .set    (set),
        .set_num(set_num),
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
            set   = 0;
            set_num = 0;
            repeat(2) @(posedge clk);
            rst_n = 1;
            @(posedge clk);
        end
    endtask

    // Reference model
    int exp_num;
    bit exp_zero;
    bit load_pending;   // indicates a set operation is pending

    task automatic update_expected();
        begin
            if (load_pending) begin
                exp_num = set_num;
                load_pending = 0;
            end
            else begin
                exp_num = (exp_num == 15) ? 0 : (exp_num + 1);
            end

            exp_zero = (exp_num == 0);
        end
    endtask

    // Checker
    task automatic check_output();
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

    // Main stimulus
    initial begin
        $dumpfile("count_module.vcd");
        $dumpvars(0, count_module_tb);

        reset_dut();

        exp_num = 0;
        exp_zero = 1;
        load_pending = 0;

        // Phase 1: Normal counting
        $display("\n=== Test 1: Normal Continuous Counting ===");
        for (int i = 0; i < 20; i++) begin
            @(posedge clk);

            update_expected();
            check_output();
        end

        // Phase 2: Test set operation
        $display("\n=== Test 2: Set Operation Tests ===");

        repeat(5) begin
            @(posedge clk);

            // randomly choose a number to set
            set <= 1;
            set_num <= $urandom_range(0, 15);

            // mark load to be executed in the next cycle
            load_pending = 1;

            @(posedge clk);
            set <= 0;

            update_expected();
            check_output();

            // 
            repeat(3) begin
                @(posedge clk);
                update_expected();
                check_output();
            end
        end

        $display("\nSimulation Finished.");
        $finish;
    end

endmodule
