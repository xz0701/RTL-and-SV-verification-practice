`timescale 1ns/1ps

// FIFO Interface
interface fifo_if #(parameter WIDTH = 8);

    logic              clk;
    logic              rst_n;
    logic              winc, rinc;
    logic [WIDTH-1:0]  wdata;
    logic [WIDTH-1:0]  rdata;
    logic              wfull, rempty;

endinterface : fifo_if

// Testbench
module tb_sfifo;

    localparam WIDTH = 8;
    localparam DEPTH = 16;

    fifo_if #(WIDTH) fifo();

    // Reference model using SystemVerilog queue
    bit [WIDTH-1:0] ref_q[$];

    // DUT instantiation
    sfifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk    (fifo.clk),
        .rst_n  (fifo.rst_n),
        .winc   (fifo.winc),
        .rinc   (fifo.rinc),
        .wdata  (fifo.wdata),
        .wfull  (fifo.wfull),
        .rempty (fifo.rempty),
        .rdata  (fifo.rdata)
    );

    // Clock generation
    initial fifo.clk = 0;
    always  #5 fifo.clk = ~fifo.clk;

    // Reset + fork test processes
    initial begin
        fifo.rst_n = 0;
        fifo.winc  = 0;
        fifo.rinc  = 0;
        fifo.wdata = '0;
        ref_q      = {};

        #40 fifo.rst_n = 1;
        #20;

        fork
            drive_write();
            drive_read();
        join_none

        #2000;
        $display("=== TEST FINISHED ===");
        $finish;
    end

    // Write Driver
    task automatic drive_write();
        forever begin
            @(posedge fifo.clk);

            if (!fifo.wfull && $urandom_range(0,1)) begin
                fifo.winc  <= 1;
                fifo.wdata <= $urandom;

                // REF model update
                ref_q.push_back(fifo.wdata);

                $display("[%0t] WRITE  data=%0d  qsize=%0d",
                         $time, fifo.wdata, ref_q.size());
            end
            else begin
                fifo.winc <= 0;
            end
        end
    endtask

    // Read Driver + scoreboard
    task automatic drive_read();
        forever begin
            @(posedge fifo.clk);

            if (!fifo.rempty && $urandom_range(0,2) == 0) begin
                fifo.rinc <= 1;

                // wait next cycle for rdata
                @(posedge fifo.clk);

                // reference check
                if (ref_q.size() == 0) begin
                    $error("[%0t] ERROR: Read when queue empty!", $time);
                    assert(0) else $fatal;
                end
                else begin
                    bit [WIDTH-1:0] exp = ref_q.pop_front();

                    if (fifo.rdata !== exp) begin
                        $error("[%0t] MISMATCH exp=%0d got=%0d",
                               $time, exp, fifo.rdata);
                        assert(fifo.rdata === exp) else $fatal;
                    end
                    else begin
                        $display("[%0t] READ   data=%0d (OK)",
                                 $time, fifo.rdata);
                    end
                end
            end
            else begin
                fifo.rinc <= 0;
            end
        end
    endtask

endmodule
