`timescale 1ns/1ns

module game_count_tb;

    // DUT ports
    reg         clk;
    reg         rst_n;
    reg  [9:0]  money;
    reg         set;
    reg         boost;
    wire [9:0]  remain;
    wire        yellow;
    wire        red;

    // DUT
    game_count dut (
        .clk(clk),
        .rst_n(rst_n),
        .money(money),
        .set(set),
        .boost(boost),
        .remain(remain),
        .yellow(yellow),
        .red(red)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Simple display task
    task show;
        $display("[%0t] set=%0b boost=%0b money=%0d | remain=%0d yellow=%0b red=%0b",
                 $time, set, boost, money, remain, yellow, red);
    endtask

    // Test sequence
    initial begin
        // enable waveform dump
        $dumpfile("game_count.vcd");
        $dumpvars(0, game_count_tb);

        // Step 1: reset
        rst_n = 0;
        set   = 0;
        boost = 0;
        money = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        $display("=== Release Reset ===");

        // Step 2: Add money (set=1)
        money = 10'd50;
        set   = 1;
        @(posedge clk);
        show();

        // Disable set
        set = 0;

        // Step 3: Normal decrement (boost=0, -1 per cycle)
        boost = 0;
        repeat(10) begin
            @(posedge clk);
            show();
        end

        // Step 4: Fast decrement (boost=1, -2 per cycle)
        boost = 1;
        repeat(10) begin
            @(posedge clk);
            show();
        end

        // Step 5: Observe yellow zone (< 10)
        repeat(10) begin
            @(posedge clk);
            show();
        end

        // Step 6: Observe red zone (remain == 0)
        repeat(10) begin
            @(posedge clk);
            show();
        end

        $display("=== SIM END ===");
        $finish;
    end

    // Assertions to verify correct behavior
    always @(posedge clk) begin
        if (rst_n) begin
            // remain must never overflow 10 bits
            assert(remain <= 10'd1023)
                else $error("ERROR: remain overflow at %0t!", $time);

            // remain should never go negative in simulation (two's complement wrap check)
            assert(remain >= 0)
                else $error("ERROR: remain underflow at %0t!", $time);

            // yellow/red and remain rules
            if (remain == 0)
                assert(red == 1 && yellow == 0)
                    else $error("ERROR: remain==0 but red/yellow wrong at %0t!", $time);

            if (remain < 10 && remain > 0)
                assert(yellow == 1 && red == 0)
                    else $error("ERROR: remain<10 but wrong lights at %0t!", $time);
        end
    end

endmodule
