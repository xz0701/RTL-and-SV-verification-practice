module model (
  input clk,
  input resetn,
  output logic div2,
  output logic div4,
  output logic div6
);
  logic [2 : 0] cnt_2, cnt_4, cnt_6;

  always_ff @(posedge clk) begin
    if (!resetn)
      cnt_2 <= '0;
    else if (cnt_2 == 3'd1)
      cnt_2 <= '0;
    else
      cnt_2 <= cnt_2 + 1;
  end

  always_ff @(posedge clk) begin
    if (!resetn)
      cnt_4 <= '0;
    else if (cnt_4 == 3'd3)
      cnt_4 <= '0;
    else
      cnt_4 <= cnt_4 + 1;
  end

  always_ff @(posedge clk) begin
    if (!resetn)
      cnt_6 <= '0;
    else if (cnt_6 == 3'd5)
      cnt_6 <= '0;
    else
      cnt_6 <= cnt_6 + 1;
  end

  always_ff @(posedge clk) begin
    if (!resetn)
      div2 <= '0;
    else if (cnt_2 == 3'd0)
      div2 <= 1;
    else if (cnt_2 == 3'd1)
      div2 <= '0;
  end

  always_ff @(posedge clk) begin
    if (!resetn)
      div4 <= '0;
    else if (cnt_4 == 3'd0)
      div4 <= 1;
    else if (cnt_4 == 3'd2)
      div4 <= '0;
  end

  always_ff @(posedge clk) begin
    if (!resetn)
      div6 <= '0;
    else if (cnt_6 == 3'd0)
      div6 <= 1;
    else if (cnt_6 == 3'd3)
      div6 <= '0;
  end

endmodule