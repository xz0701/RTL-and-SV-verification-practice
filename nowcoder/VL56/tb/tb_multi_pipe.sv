`timescale 1ns/1ns

module multi_pipe_tb;

    parameter SIZE = 4;

    reg                  clk;
    reg                  rst_n;
    reg  [SIZE-1:0]      mul_a;
    reg  [SIZE-1:0]      mul_b;
    wire [SIZE*2-1:0]    mul_out;

    // DUT instantiation
    multi_pipe #(
        .SIZE(SIZE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .mul_a(mul_a),
        .mul_b(mul_b),
        .mul_out(mul_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Store expected output (1-cycle latency)
    reg [SIZE*2-1:0] expected;
    reg [SIZE*2-1:0] expected_pipeline; // delayed version

    integer i;

    initial begin
        // Initial values
        rst_n = 0;
        mul_a = 0;
        mul_b = 0;
        expected = 0;
        expected_pipeline = 0;

        // Apply reset
        repeat(3) @(posedge clk);
        rst_n = 1;

        // Run multiple test iterations
        for (i = 0; i < 20; i = i + 1) begin
            // Random test vectors
            mul_a = $random % (1 << SIZE);
            mul_b = $random % (1 << SIZE);

            expected = mul_a * mul_b;

            // Pipeline delay = 1 cycle
            expected_pipeline <= expected;

            @(posedge clk);

            // Compare DUT output with delayed expected value
            if (mul_out !== expected_pipeline) begin
                $display("ERROR: a=%0d b=%0d  expected=%0d got=%0d  time=%0t",
                          mul_a, mul_b, expected_pipeline, mul_out, $time);
            end else begin
                $display("OK:    a=%0d b=%0d  result=%0d  time=%0t",
                          mul_a, mul_b, mul_out, $time);
            end

        end

        $display("===== TEST FINISHED =====");
        $finish;
    end

endmodule
