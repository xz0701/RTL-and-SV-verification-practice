`timescale 1ns/1ns

module tb_valid_ready;

    reg         clk;
    reg         rst_n;
    reg  [7:0]  data_in;
    reg         valid_a;
    wire        ready_a;
    wire [9:0]  data_out;
    wire        valid_b;
    reg         ready_b;

    // DUT instance
    valid_ready dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_in  (data_in),
        .valid_a  (valid_a),
        .ready_b  (ready_b),
        .ready_a  (ready_a),
        .valid_b  (valid_b),
        .data_out (data_out)
    );

    // clock gen
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz

    // task: send one data with handshake
    task send(input [7:0] din);
        begin
            @(posedge clk);
            valid_a <= 1;
            data_in <= din;
            // wait until DUT ready
            while (!ready_a) begin
                @(posedge clk);
            end
            @(posedge clk);
            valid_a <= 0;
            data_in <= 0;
        end
    endtask

    // task: random stall on ready_b
    task random_stall_b();
        begin
            ready_b <= $random % 2;
        end
    endtask

    // Test sequence
    initial begin
        $dumpfile("wave.vcd"); 
        $dumpvars(0, tb_valid_ready);

        // init
        valid_a = 0;
        data_in = 0;
        ready_b = 1;
        rst_n   = 0;

        repeat(5) @(posedge clk);
        rst_n = 1;

        // Test 1: normal input, ready_b always 1
        $display("\n--- Test 1: Normal full-speed input ---");
        send(8'd1);
        send(8'd2);
        send(8'd3);
        send(8'd4);   // expect valid_b=1 here, data_out = 1+2+3+4 = 10

        // Test 2: continuous stream, multiple groups
        $display("\n--- Test 2: Continuous input stream ---");
        repeat (8) begin
            send($random % 10);
        end

        // Test 3: downstream stalls
        $display("\n--- Test 3: Downstream backpressure ---");
        repeat (10) begin
            random_stall_b();
            send($random % 20);
        end

        // -------------------------------------
        // end
        $display("\nSimulation finished.");
        #100 $finish;
    end


endmodule
