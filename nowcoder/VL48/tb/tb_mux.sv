`timescale 1ns/1ps

module tb_mux;

    localparam WIDTH = 4;

    // DUT signals
    logic              clk_a, clk_b;
    logic              arstn, brstn;
    logic              data_en;
    logic [WIDTH-1:0]  data_in;
    logic [WIDTH-1:0]  dataout;

    // Reference queue for data passing
    logic [WIDTH-1:0] ref_bin, ref_gray, ref_gray_sync, ref_back_bin;

    // Instantiate DUT
    mux dut (
        .clk_a   (clk_a),
        .clk_b   (clk_b),
        .arstn   (arstn),
        .brstn   (brstn),
        .data_in (data_in),
        .data_en (data_en),
        .dataout (dataout)
    );

    // Clock Generation
    initial clk_a = 0;
    always  #5 clk_a = ~clk_a;    

    initial clk_b = 0;
    always  #7 clk_b = ~clk_b;     

    // Reset sequence
    initial begin
        arstn = 0;
        brstn = 0;
        data_en = 0;
        data_in = 0;
        #40;

        arstn = 1;
        brstn = 1;

        $display("[TB] Reset released");

        fork
            drive_a_domain();
            monitor_b_domain();
        join_any

        #2000;
        $display("===== SIMULATION FINISHED =====");
        $finish;
    end

    // Driver in clk_a domain (stimulus)
    task automatic drive_a_domain();
        forever begin
            @(posedge clk_a);

            // Random enable
            data_en <= $urandom_range(0,1);

            // Random data generation
            data_in <= $urandom_range(0, 15);

            $display("[A] %0t  data_in=%0d  en=%0d",
                     $time, data_in, data_en);

            // Build reference model (bin → gray)
            ref_bin  = data_in;
            ref_gray = ref_bin ^ (ref_bin >> 1);
        end
    endtask

    // Monitor / Scoreboard in clk_b domain
    task automatic monitor_b_domain();
        forever begin
            @(posedge clk_b);

            // Only when enable reaches clk_b domain
            if (data_en) begin
                // Simulate gray sync behavior (2 FF stages)
                ref_gray_sync = ref_gray;

                // Convert back gray → bin
                ref_back_bin = gray2bin_func(ref_gray_sync);

                $display("[B] %0t  DUT_OUT=%0d  REF=%0d",
                         $time, dataout, ref_back_bin);

                // Assertion
                assert(dataout === ref_back_bin)
                    else begin
                        $error("[MISMATCH] %0t  DUT=%0d REF=%0d",
                               $time, dataout, ref_back_bin);
                        $fatal;
                    end
            end
        end
    endtask

    // Gray -> Binary conversion function (reference model)
    function automatic [WIDTH-1:0] gray2bin_func(input [WIDTH-1:0] g);
        automatic int i;
        gray2bin_func[WIDTH-1] = g[WIDTH-1];
        for (i = WIDTH-2; i >= 0; i--) begin
            gray2bin_func[i] = gray2bin_func[i+1] ^ g[i];
        end
    endfunction

endmodule
