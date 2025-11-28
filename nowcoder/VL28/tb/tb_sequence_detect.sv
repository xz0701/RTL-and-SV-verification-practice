`timescale 1ns/1ns
`include "../rtl/sequence_detect.v"

module tb_sequence_detect_0110();

    reg clk;
    reg rst_n;
    reg data;
    reg data_valid;
    wire match;

    sequence_detect_0110 dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .data      (data),
        .data_valid(data_valid),
        .match     (match)
    );

    // 1. Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    // 2. Reset Task
    task reset();
        begin
            rst_n      = 0;
            data       = 0;
            data_valid = 0;
            repeat(2) @(posedge clk);
            rst_n      = 1;
        end
    endtask

    // 3. Drive: one bit with valid control
    task drive_bit(input logic bit_value, input logic valid_value);
        begin
            data       = bit_value;
            data_valid = valid_value;
            @(posedge clk);
        end
    endtask

    // 4. Reference Model
    //     sequence = 0110 (overlapping)
    reg [3:0] shift_reg;  
    reg expected_match;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg      <= 4'b0;
            expected_match <= 0;
        end else begin
            if (data_valid) begin
                // shift in valid bit
                shift_reg <= {shift_reg[2:0], data};
            end

            // Overlap match detection: look for 0110
            if (data_valid && shift_reg == 4'b0110)
                expected_match <= 1;
            else
                expected_match <= 0;
        end
    end

    // 5. Checker
    always @(posedge clk) begin
        if (rst_n) begin
            if (match !== expected_match) begin
                $display("[%0t] ERROR: match=%0b expected=%0b shift=%b valid=%b",
                          $time, match, expected_match, shift_reg, data_valid);
                $stop;
            end
        end
    end

    // 6. Waveform dump
    initial begin
        $dumpfile("sequence_detect_0110.vcd");
        $dumpvars(0, tb_sequence_detect_0110);
    end

    // 7. Testcases
    initial begin
        reset();

        // random invalid cycles
        repeat(5)  drive_bit($random, 0);

        // directed test: 0110 (valid every cycle)
        drive_bit(0, 1);
        drive_bit(1, 1);
        drive_bit(1, 1);
        drive_bit(0, 1);   // expect match=1 here

        // random with valid=1 or 0
        repeat(30) drive_bit($random, $random);

        // overlapping test: 0110110
        drive_bit(0, 1);
        drive_bit(1, 1);
        drive_bit(1, 1);
        drive_bit(0, 1);   // match
        drive_bit(1, 1);
        drive_bit(1, 1);
        drive_bit(0, 1);   // match again

        $display("=== TEST PASSED ===");
        $finish;
    end

endmodule
