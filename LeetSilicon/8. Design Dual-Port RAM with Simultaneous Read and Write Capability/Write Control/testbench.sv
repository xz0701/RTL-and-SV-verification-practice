module tb;
  localparam DEPTH=16, WIDTH=8;
  logic clk, write_en_a, read_en_b;
  logic [3:0] addr_a, addr_b;
  logic [7:0] write_data_a, read_data_b;
  int p=0, f=0;
  initial clk=0; always #5 clk=~clk;
  dp_ram #(.DEPTH(DEPTH), .WIDTH(WIDTH)) dut(.*);
  initial begin
    write_en_a=0; read_en_b=0; addr_a=0; addr_b=0; write_data_a=0;
    @(posedge clk); @(posedge clk);
    // TC1: Write portA, read portB
    @(negedge clk); addr_a=5; write_data_a=8'hBB; write_en_a=1;
    @(posedge clk); @(negedge clk); write_en_a=0;
    @(negedge clk); addr_b=5; read_en_b=1;
    @(posedge clk); @(negedge clk); read_en_b=0;
    @(posedge clk); @(negedge clk);
    if (read_data_b==8'hBB) begin p++; $display("PASS: TC1"); end
    else begin f++; $display("FAIL: TC1 got %h", read_data_b); end
    // TC5: read same addr
    @(negedge clk); addr_b=5; read_en_b=1;
    @(posedge clk); @(negedge clk); read_en_b=0;
    @(posedge clk); @(negedge clk);
    if (read_data_b==8'hBB) begin p++; $display("PASS: TC5"); end
    else begin f++; $display("FAIL: TC5 got %h", read_data_b); end
    // TC4: Simultaneous write A / read B same addr
    @(negedge clk); addr_a=2; write_data_a=8'hCC; write_en_a=1; addr_b=2; read_en_b=1;
    @(posedge clk); @(negedge clk); write_en_a=0; read_en_b=0;
    @(posedge clk); @(negedge clk);
    if (read_data_b==8'hCC || read_data_b==8'h00) begin p++; $display("PASS: TC4"); end
    else begin f++; $display("FAIL: TC4 got %h", read_data_b); end
    $display("=== %0d passed %0d failed ===", p, f);
    $finish;
  end
endmodule
