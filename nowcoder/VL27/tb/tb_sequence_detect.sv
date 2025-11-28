`timescale 1ns/1ns
`include "../rtl/sequence_detect.v"

module tb_sequence_detect();

    reg clk;
    reg rst_n;
    reg data;
    wire match;
    wire not_match;

    sequence_detect dut (
        .clk(clk),
        .rst_n(rst_n),
        .data(data),      
        .match(match),
        .not_match(not_match)
    );

    // 1. Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    // 2. Reset Task
    task reset();
        begin
            rst_n = 0;
            data  = 0;
            repeat(2) @(posedge clk);
            rst_n = 1;
        end
    endtask

    // 3. Drive one bit
    task drive_bit(input logic bit_value);
        begin
            data = bit_value;
            @(posedge clk);
        end
    endtask

    // 4. Reference Model
    // sequence = 011100
    reg [5:0] shift_reg;  
    reg expected_match;
    reg expected_not_match;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg          <= 6'b0;
            expected_match     <= 0;
            expected_not_match <= 0;
        end else begin
            // shift in 1 bit
            shift_reg <= {shift_reg[4:0], data};

            // exactly at 6th bit = 5
            if (cnt == 3'd5) begin
                expected_match     <= (shift_reg == 6'b011100);
                expected_not_match <= (shift_reg != 6'b011100);
            end else begin
                expected_match     <= 0;
                expected_not_match <= 0;
            end
        end
    end

    // 5. bit counter 
    reg [2:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= 0;
        else if (cnt == 3'd5)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end

    // --------------------------
    // 6. Checker
    // --------------------------
    always @(posedge clk) begin
        if (rst_n) begin
            if (match !== expected_match) begin
                $display("[%0t] MATCH ERROR: match=%0b expected=%0b shift=%b",
                         $time, match, expected_match, shift_reg);
                $stop;
            end
            if (not_match !== expected_not_match) begin
                $display("[%0t] NOT_MATCH ERROR: not_match=%0b expected=%0b shift=%b",
                         $time, not_match, expected_not_match, shift_reg);
                $stop;
            end
        end
    end

    // 7. Waveform dump
    initial begin
        $dumpfile("sequence_detect.vcd");
        $dumpvars(0, tb_sequence_detect);
    end

    // 8. Testcases
    initial begin
        reset();

        repeat(10) drive_bit($random);

        // Directed correct sequence: 011100
        drive_bit(0);
        drive_bit(1);
        drive_bit(1);
        drive_bit(1);
        drive_bit(0);
        drive_bit(0);

        // Random sequence (should trigger both match & not_match over time)
        repeat(50) drive_bit($random);

        $display("=== TEST PASSED ===");
        $finish;
    end

endmodule
