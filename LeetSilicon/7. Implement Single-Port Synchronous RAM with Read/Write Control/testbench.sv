module tb;
  localparam DEPTH = 16, WIDTH = 8;
  logic clk, write_en, read_en;
  logic [3:0] address;
  logic [7:0] write_data, read_data;
  int p=0, f=0;
  initial clk=0; always #5 clk=~clk;
  sp_ram #(.DEPTH(DEPTH), .WIDTH(WIDTH)) dut(.*);
  initial begin
    write_en=0; read_en=0; address=0; write_data=0;
    @(posedge clk); @(posedge clk);

    // TC1
    @(negedge clk); address=3; write_data=8'hAA; write_en=1;
    @(posedge clk); @(negedge clk); write_en=0;
    @(negedge clk); read_en=1;
    @(posedge clk); @(negedge clk); read_en=0;
    @(posedge clk); @(negedge clk);
    if (read_data==8'hAA) begin p++; $display("PASS: TC1"); end
    else begin f++; $display("FAIL: TC1 got %h", read_data); end

    // TC4
    for (int i=0; i<4; i++) begin
      @(negedge clk); address=i; write_data=i*8'h11; write_en=1;
      @(posedge clk); @(negedge clk); write_en=0;
    end
    begin
      logic ok=1;
      for (int i=0; i<4; i++) begin
        @(negedge clk); address=i; read_en=1;
        @(posedge clk); @(negedge clk); read_en=0;
        @(posedge clk); @(negedge clk);
        if (read_data != i*8'h11) ok=0;
      end
      if (ok) begin p++; $display("PASS: TC4"); end
      else begin f++; $display("FAIL: TC4"); end
    end

    // TC5
    @(negedge clk); address=0; write_data=8'hFF; write_en=1;
    @(posedge clk); @(negedge clk); write_en=0;
    @(negedge clk); address=DEPTH-1; write_data=8'hEE; write_en=1;
    @(posedge clk); @(negedge clk); write_en=0;
    @(negedge clk); address=0; read_en=1;
    @(posedge clk); @(negedge clk); read_en=0;
    @(posedge clk); @(negedge clk);
    if (read_data==8'hFF) begin p++; $display("PASS: TC5"); end
    else begin f++; $display("FAIL: TC5 got %h", read_data); end

    $display("=== %0d passed %0d failed ===", p, f);
    $finish;
  end
endmodule
