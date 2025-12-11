module tb;

  localparam DATA_WIDTH = 32;

  logic [DATA_WIDTH-1:0] din;
  logic din_en;
  logic [1:0] addr;

  logic [DATA_WIDTH-1:0] dout0, dout1, dout2, dout3;

  model #(DATA_WIDTH) dut (
    .din(din),
    .din_en(din_en),
    .addr(addr),
    .dout0(dout0),
    .dout1(dout1),
    .dout2(dout2),
    .dout3(dout3)
  );

  task check(
    input [1:0] addr_t,
    input [DATA_WIDTH-1:0] data_t
  );
    begin
      din    = data_t;
      din_en = 1;
      addr   = addr_t;
      #1;

      // Expect only the selected output to have data_t
      if (addr_t == 0 && dout0 !== data_t) $error("FAIL: dout0 != data");
      if (addr_t == 1 && dout1 !== data_t) $error("FAIL: dout1 != data");
      if (addr_t == 2 && dout2 !== data_t) $error("FAIL: dout2 != data");
      if (addr_t == 3 && dout3 !== data_t) $error("FAIL: dout3 != data");

      // All other outputs must be zero
      if (addr_t != 0 && dout0 !== '0) $error("FAIL: dout0 not zero");
      if (addr_t != 1 && dout1 !== '0) $error("FAIL: dout1 not zero");
      if (addr_t != 2 && dout2 !== '0) $error("FAIL: dout2 not zero");
      if (addr_t != 3 && dout3 !== '0) $error("FAIL: dout3 not zero");
    end
  endtask

  initial begin
    $display("---- Self-Checking Router TB ----");

    check(0, 32'hAAAA0001);
    check(1, 32'hBBBB0002);
    check(2, 32'hCCCC0003);
    check(3, 32'hDDDD0004);

    din_en = 0;
    #1;

    if (dout0 !== '0 || dout1 !== '0 || dout2 !== '0 || dout3 !== '0)
      $error("FAIL: outputs not zero when din_en=0");
    
    $display("All tests passed!");
    $finish;
  end

endmodule
