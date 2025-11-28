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
            repeat(2) @(posedge clk);
            rst_n = 1;
        end
    endtask

    // 3. Drive a single bit
    task drive_bit(input logic bit_value);
        begin
            a = bit_value;
            @(posedge clk);
        end
    endtask

    // 4. Reference Model
    //     Detect 011???110  (9 bits)
    reg [8:0] shift_reg; 
    reg expected_match;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg      <= 9'b0;
            expected_match <= 0;
        end else begin
            shift_reg <= {shift_reg[7:0], a};

            if ( shift_reg[8:6] == 3'b011 &&
                 shift_reg[2:0] == 3'b110 )
                expected_match <= 1;
            else
                expected_match <= 0;
        end
    end

    // 5. Checker
    always @(posedge clk) begin
        if (rst_n) begin
            if (match !== expected_match) begin
                $display("[%0t] ERROR: match=%0b expected=%0b shift=%b",
                         $time, match, expected_match, shift_reg);
                $stop;
            end
        end
    end

    // 6. Dump waveform
    initial begin
        $dumpfile("sequence_detect.vcd");
        $dumpvars(0, tb_sequence_detect);
    end

    // 7. Testcases
    initial begin
        reset();

        repeat(10) drive_bit($random);

        // valid sequence: 0 1 1 ? ? ? 1 1 0
        drive_bit(0);
        drive_bit(1);
        drive_bit(1);
        drive_bit(0);   // X
        drive_bit(1);   // X
        drive_bit(1);   // X
        drive_bit(1);   // 1
        drive_bit(1);   // 1
        drive_bit(0);   // 0

        repeat(20) drive_bit($random);

        $display("=== TEST PASSED ===");
        $finish;
    end

endmodule
