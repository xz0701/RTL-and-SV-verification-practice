`timescale 1ns/1ps

module tb_gray_counter;

    // DUT signals
    logic        clk;
    logic        rst_n;
    logic [3:0]  gray_out;

    // Reference model
    logic [3:0]  prev_gray;

    // Instantiate DUT
    gray_counter dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .gray_out(gray_out)
    );

    // Clock Generation
    initial clk = 0;
    always  #5 clk = ~clk;

    // Reset
    initial begin
        rst_n = 0;
        prev_gray = '0;

        #20 rst_n = 1;

        #200;
        $display("===== SIMULATION FINISHED =====");
        $finish;
    end

    // Monitor + Gray-code checker
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            prev_gray <= '0;
        end
        else begin
            $display("[TIME=%0t] Gray Out = %b", $time, gray_out);

            // Gray code must change only 1 bit every step
            int diff_bits = $countones(prev_gray ^ gray_out);

            assert (diff_bits == 1)
                else begin
                    $error("[GRAY CHECK FAIL] prev=%b curr=%b diff_bits=%0d",
                           prev_gray, gray_out, diff_bits);
                    $fatal;
                end

            prev_gray <= gray_out;
        end
    end

endmodule
