`timescale 1ns/1ns

module tb_s_to_p;

    // DUT signals
    logic clk;
    logic rst_n;
    logic valid_a;
    logic data_a;
    logic ready_a;
    logic valid_b;
    logic [5:0] data_b;

    // Instantiate DUT
    s_to_p dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .valid_a (valid_a),
        .data_a  (data_a),
        .ready_a (ready_a),
        .valid_b (valid_b),
        .data_b  (data_b)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //  Golden Model: shift register + bit counter
    logic [5:0] gold_shift;
    int         bit_cnt;

    task golden_step(input logic vld, input logic din);
        if (!rst_n) begin
            gold_shift = 6'd0;
            bit_cnt    = 0;
        end 
        else if (vld) begin
            gold_shift = {din, gold_shift[5:1]};
            bit_cnt++;
            if (bit_cnt == 6)
                bit_cnt = 0;
        end
    endtask

    //  Checker: compare DUT output with golden model
    task check_output();
        if (valid_b) begin
            if (bit_cnt != 0)
                $error("[TB] ERROR: valid_b asserted at wrong time! bit_cnt=%0d", bit_cnt);

            if (data_b !== gold_shift)
                $error("[TB] DATA MISMATCH: DUT=%b  GOLD=%b", data_b, gold_shift);
        end
    endtask

    //  Reset Task
    task do_reset();
        $display("\n=== APPLY RESET ===");

        rst_n   = 0;
        valid_a = 0;
        data_a  = 0;

        // Hold reset for 3 cycles
        repeat (3) @(posedge clk);

        // Check DUT reset values
        assert (ready_a == 0)
          else $error("[TB] Reset check failed: ready_a != 0");

        assert (valid_b == 0)
          else $error("[TB] Reset check failed: valid_b != 0");

        assert (data_b == 6'd0)
          else $error("[TB] Reset check failed: data_b != 0");

        // Release reset
        rst_n = 1;
        repeat (2) @(posedge clk);

        $display("=== RESET DONE ===\n");
    endtask

    //  Stimulus
    initial begin
        // VCD dump
        $dumpfile("s_to_p_tb.vcd");
        $dumpvars(0, tb_s_to_p);

        rst_n = 1;   // start with deasserted
        do_reset();  // perform full reset

        //   1. Directed Test: send known pattern 110011
        $display("=== Directed Test (110011) ===");

        logic [5:0] pattern = 6'b110011;

        repeat (6) begin
            @(posedge clk);
            valid_a <= 1;
            data_a  <= pattern[0];
            pattern = pattern >> 1;

            golden_step(valid_a, data_a);
            check_output();
        end

        @(posedge clk);
        valid_a <= 0;

        //   2. Random Test: random valid_a & data_a
        $display("=== Random Test (50 cycles) ===");

        repeat (50) begin
            @(posedge clk);
            valid_a <= $urandom_range(0,1);
            data_a  <= $urandom_range(0,1);

            golden_step(valid_a, data_a);
            check_output();
        end

        $display("\n=== ALL TESTS PASSED (if no error printed) ===");
        #20;
        $finish;
    end

endmodule
