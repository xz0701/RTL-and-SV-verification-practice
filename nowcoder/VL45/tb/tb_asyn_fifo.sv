`timescale 1ns/1ns

module tb_asyn_fifo;

    // Parameters
    localparam WIDTH = 8;
    localparam DEPTH = 16;
    localparam ADDR_WIDTH = $clog2(DEPTH);

    // DUT signals
    reg              wclk, rclk;
    reg              wrstn, rrstn;
    reg              winc, rinc;
    reg  [WIDTH-1:0] wdata;
    wire [WIDTH-1:0] rdata;
    wire             wfull, rempty;

    // Instantiate DUT
    asyn_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .wclk   (wclk),
        .rclk   (rclk),
        .wrstn  (wrstn),
        .rrstn  (rrstn),
        .winc   (winc),
        .rinc   (rinc),
        .wdata  (wdata),
        .wfull  (wfull),
        .rempty (rempty),
        .rdata  (rdata)
    );

    // Clocks: async clocks with different periods
    initial wclk = 0;
    always #5  wclk = ~wclk;     // 100MHz

    initial rclk = 0;
    always #7  rclk = ~rclk;     // ~71MHz (asynchronous)

    // Reference model: SystemVerilog queue
    bit [WIDTH-1:0] ref_queue[$];

    // Apply reset
    initial begin
        wrstn = 0;
        rrstn = 0;
        winc  = 0;
        rinc  = 0;
        wdata = 0;

        #50;
        wrstn = 1;
        rrstn = 1;

        #50;
        fork
            drive_write();
            drive_read();
        join_any

        #2000;
        $display("TEST FINISHED");
        $finish;
    end

    // Write driver
    task drive_write();
        forever begin
            @(posedge wclk);
            if (!wfull && ($urandom%2)) begin
                winc  <= 1;
                wdata <= $urandom;
                ref_queue.push_back(wdata);
                $display("[WRITE] %0t  Data = %0d  queue_size = %0d",
                         $time, wdata, ref_queue.size());
            end else begin
                winc <= 0;
            end
        end
    endtask

    // Read driver
    task drive_read();
        forever begin
            @(posedge rclk);
            if (!rempty && ($urandom%3==0)) begin
                rinc <= 1;

                // Compare with reference queue on next cycle
                @(posedge rclk);
                if (ref_queue.size() == 0) begin
                    $display("[ERROR] empty but read triggered!");
                end else begin
                    bit [WIDTH-1:0] exp = ref_queue.pop_front();
                    if (exp !== rdata) begin
                        $display("[MISMATCH] %0t  Expected=%0d  Got=%0d",
                                 $time, exp, rdata);
                        $stop;
                    end else begin
                        $display("[READ ] %0t  Data=%0d (OK)", 
                                 $time, rdata);
                    end
                end

            end else begin
                rinc <= 0;
            end
        end
    endtask

endmodule
