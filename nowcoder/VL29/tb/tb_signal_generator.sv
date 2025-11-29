`include "../rtl/signal_generator.v"
`timescale 1ns/1ns

module tb_signal_generator;

    logic clk;
    logic rst_n;
    logic [1:0] wave_choise;
    logic [4:0] wave;

    // Instantiate DUT
    signal_generator dut (
        .clk(clk),
        .rst_n(rst_n),
        .wave_choise(wave_choise),
        .wave(wave)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Golden model state
    logic [4:0] gold_wave;
    logic [4:0] gold_cnt;
    logic       gold_opt;

    // Golden model: behavioral reference
    task golden_step();
        case (wave_choise)

        // mode 00
        2'b00: begin
            gold_cnt = gold_cnt + 1;
            if (gold_cnt == 5'd9) begin
                gold_wave = 5'd20;
                gold_opt  = 1;
            end
            else if (gold_cnt == 5'd19) begin
                gold_wave = 5'd0;
                gold_opt  = 0;
                gold_cnt  = 5'd0;
            end
        end

        // mode 01: sawtooth
        2'b01: begin
            if (gold_wave == 5'd20)
                gold_wave = 0;
            else
                gold_wave++;
        end

        // mode 02: triangle
        2'b10: begin
            if (gold_opt) begin
                if (gold_wave == 20) begin
                    gold_opt = 0;
                    gold_wave = 19;
                end else gold_wave++;
            end else begin
                if (gold_wave == 0) begin
                    gold_opt = 1;
                    gold_wave = 1;
                end else gold_wave--;
            end
        end

        // illegal
        default: begin
            gold_wave = 0;
            gold_cnt  = 0;
            gold_opt  = 0;
        end
        endcase
    endtask

    // Checker
    task check_output();
        assert(wave == gold_wave)
        else $error("Mismatch at %0t: DUT=%0d GOLD=%0d",
                    $time, wave, gold_wave);
    endtask

    // Stimulus
    initial begin
        clk = 0;
        rst_n = 0;

        gold_wave = 0;
        gold_cnt  = 0;
        gold_opt  = 0;

        #20 rst_n = 1;

        // Directed tests
        wave_choise = 2'b00;
        repeat (50) begin @(posedge clk); golden_step(); check_output(); end

        wave_choise = 2'b01;
        repeat (50) begin @(posedge clk); golden_step(); check_output(); end

        wave_choise = 2'b10;
        repeat (80) begin @(posedge clk); golden_step(); check_output(); end

        // Random test
        repeat (200) begin
            @(posedge clk);
            wave_choise = $urandom_range(0,3);
            golden_step();
            check_output();
        end

        $display("All tests completed.");
        $finish;
    end

    // Coverage (functional coverage)
    covergroup cg @(posedge clk);
        coverpoint wave_choise;
        coverpoint wave;
        coverpoint gold_opt;
        wave: coverpoint wave {
            bins zero  = {0};
            bins mid   = {1,10,19};
            bins maxv  = {20};
        }
        trans: coverpoint gold_opt {
            bins up    = {1};
            bins down  = {0};
        }
    endgroup

    cg coverage = new();

    // Dump waveform
    initial begin
        $dumpfile("tb_wave.vcd");
        $dumpvars(0, tb_signal_generator);
    end
endmodule
