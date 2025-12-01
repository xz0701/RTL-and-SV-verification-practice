`timescale 1ns/1ps

module tb_width_24to128;

    // DUT ports
    reg         clk;
    reg         rst_n;
    reg         valid_in;
    reg  [23:0] data_in;
    wire        valid_out;
    wire [127:0] data_out;

    // Instantiate DUT
    width_24to128 dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .data_in   (data_in),
        .valid_out (valid_out),
        .data_out  (data_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    integer i;
    reg [23:0] data_mem [0:63];  // store 64 inputs for debugging
    reg [9:0]  out_cnt = 0;

    initial begin
        // Reset
        rst_n = 0;
        valid_in = 0;
        data_in = 24'h0;
        #20;
        rst_n = 1;

        // Generate 64 random 24-bit data
        for (i=0; i<64; i=i+1) begin
            @(posedge clk);
            valid_in = 1;
            data_in  = $random;
            data_mem[i] = data_in;
        end

        // Stop driving valid_in
        @(posedge clk);
        valid_in = 0;

        // Let pipeline flush
        #200;

        $finish;
    end

    // Output Monitor
    always @(posedge clk) begin
        if (valid_out) begin
            $display("Time=%0t | OUT[%0d] = %032x",
                     $time, out_cnt, data_out);
            out_cnt = out_cnt + 1;
        end
    end

endmodule
