`timescale 1ns/1ns
`include "../rtl/sequence_detect.v"
module tb_sequence_detect();

    reg clk;
    reg rst_n;
    reg a;
    wire match;

    sequence_detect dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .match(match)
    );

    // 1. Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;  

    // 2. Reset Task
    task reset();
        begin
            rst_n = 0;
            a     = 0;
            repeat(2) @(posedge clk); // ensure at least 2 cycles reset
            rst_n = 1;
        end
    endtask

    // 3. Drive a single bit and wait one cycle
    task drive_bit(input logic bit_value);
        begin
            a = bit_value;
            @(posedge clk);
        end
    endtask

    // 4. Scoreboard (expected match calculation)
    // Simple software model to check correctness
    reg [7:0] shift_reg;  // hold last 8 bits (sequence length = 8)
    reg expected_match;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg      <= 8'b0;
            expected_match <= 0;
        end else begin
            shift_reg <= {shift_reg[6:0], a};

            if (shift_reg == 8'b01110001)
                expected_match <= 1;
            else
                expected_match <= 0;
        end
    end

    // 5. Checker: auto-compare expected vs match
    always @(posedge clk) begin
        if (rst_n) begin
            if (match !== expected_match) begin
                $display("[%0t] ERROR: match=%0b expected=%0b  shift=%b",
                         $time, match, expected_match, shift_reg);
                $stop;
            end
        end
    end

    // 6. VCD dump for waveform debugging
    initial begin
        $dumpfile("sequence_detect.vcd");
        $dumpvars(0, tb_sequence_detect);
    end

    // 7. Test Sequence
    initial begin
        reset();

        // Case 1: Random bits (noise)
        repeat(10) drive_bit($random);

        // Case 2: Correct sequence "011100001"
        drive_bit(0);
        drive_bit(1);
        drive_bit(1);
        drive_bit(1);
        drive_bit(0);
        drive_bit(0);
        drive_bit(0);
        drive_bit(1);

        // Case 3: Overlap check (important for sequence detector)
        // Add bits after final 1 to see if detector recovers correctly
        repeat(20) drive_bit($random);

        $display("=== TEST PASSED ===");
        $finish;
    end

endmodule
