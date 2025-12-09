`timescale 1ns/1ns

module jc_tb;

    // Clock & Reset
    logic clk = 0;
    logic rst_n = 0;
    logic [3:0] Q;

    // DUT
    JC_counter dut (
        .clk   (clk),
        .rst_n (rst_n),
        .Q     (Q)
    );

    // Clock generation
    always #5 clk = ~clk;  

    // Expected value storage
    logic [3:0] exp_Q;

    // Function to compute next Johnson counter value
    function logic [3:0] jc_next(input logic [3:0] x);
        return { ~x[0], x[3:1] };
    endfunction

    initial begin
        // Reset sequence
        rst_n = 0;
        repeat(3) @(posedge clk);
        rst_n = 1;

        exp_Q = 4'b0000; // initial expected value

        // Run simulation and verify
        repeat(30) begin
            @(posedge clk);

            if (Q !== exp_Q) begin
                $error("Mismatch! expected=%b got=%b at time=%0t", exp_Q, Q, $time);
            end
            else begin
                $display("OK: %b -> %b", exp_Q, Q);
            end

            // update expected value
            exp_Q = jc_next(exp_Q);
        end

        $display("=== Test Completed ===");
        $finish;
    end

endmodule
