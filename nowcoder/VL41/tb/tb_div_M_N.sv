`timescale 1ns/1ns

module tb_div_M_N;

    // DUT inputs & outputs
    reg clk_in;
    reg rst;
    wire clk_out;

    // Instantiate DUT
    div_M_N #(
        .M_N(87),
        .c89(24),
        .div_e(8),
        .div_o(9)
    ) uut (
        .clk_in(clk_in),
        .rst(rst),
        .clk_out(clk_out)
    );

    // Generate clock
    initial begin
        clk_in = 0;
        forever #10 clk_in = ~clk_in;
    end

    // Reset sequence
    initial begin
        rst = 0;
        #50;
        rst = 1;
    end

    // Monitor waveforms
    initial begin
        $display("------ Start Simulation ------");
        $dumpfile("div_M_N_tb.vcd");   // For GTKWave
        $dumpvars(0, tb_div_M_N);
    end

    // Watch key signals for debug
    always @(posedge clk_in) begin
        if (rst) begin
            $display("t=%0t | cnt=%0d sw=%b | cnt8=%0d clk8=%b | cnt9=%0d clk9=%b | clk_out=%b",
                $time,
                uut.cnt,
                uut.switch,
                uut.cnt_8, uut.clk_8,
                uut.cnt_9, uut.clk_9,
                clk_out
            );
        end
    end

    // Auto-stop simulation
    initial begin
        #50000;   // run 50us
        $display("------ Simulation Finished ------");
        $finish;
    end

endmodule
