`timescale 1ns/1ps

module tb_width_8to12;

    // DUT signals
    reg         clk;
    reg         rst_n;
    reg         valid_in;
    reg  [7:0]  data_in;
    wire        valid_out;
    wire [11:0] data_out;

    // Instantiate DUT
    width_8to12 dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .data_in   (data_in),
        .valid_out (valid_out),
        .data_out  (data_out)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;     // 100MHz clock

    // Reference Model (golden model)
    int cnt_ref = 0;
    byte temp_ref;
    bit [11:0] golden_q[$];

    task ref_push(input [7:0] din);
        begin
            cnt_ref++;
            if (cnt_ref == 1) begin
                golden_q.push_back({temp_ref, din[7:4]});
            end
            else if (cnt_ref == 2) begin
                golden_q.push_back({temp_ref[3:0], din});
                cnt_ref = 0;
            end
            temp_ref = din;
        end
    endtask

    // Driver
    task drive_byte(input [7:0] din);
        begin
            @(posedge clk);
            valid_in <= 1;
            data_in  <= din;
            ref_push(din);    // feed into golden model
        end
    endtask

    // Monitor + Scoreboard
    always @(posedge clk) begin
        if (valid_out) begin
            if (golden_q.size() == 0) begin
                $display("[ERROR] DUT output but golden empty!");
                $finish;
            end

            bit [11:0] exp = golden_q.pop_front();

            if (exp !== data_out) begin
                $display("[FAIL @%0t]", $time);
                $display("  Expected = %03x", exp);
                $display("  Got      = %03x", data_out);
                $finish;
            end else begin
                $display("[PASS] Matched output = %03x", data_out);
            end
        end
    end


    // Main Test Sequence
    initial begin
        rst_n     = 0;
        valid_in  = 0;
        data_in   = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;

        // Send 20 random bytes
        for (i=0; i<20; i++) begin
            drive_byte($urandom);
        end

        // Stop driving
        @(posedge clk);
        valid_in = 0;

        // Let outputs drain
        repeat (20) @(posedge clk);

        $display("============ ALL TESTS PASSED ============");
        $finish;
    end

endmodule
