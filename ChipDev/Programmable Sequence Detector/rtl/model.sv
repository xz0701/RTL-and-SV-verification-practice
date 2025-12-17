module model (
  input clk,
  input resetn,
  input [4:0] init,
  input din,
  output logic seen
);

    logic [4 : 0] shift_reg, target;
    logic [2 : 0] cnt;
    logic reset_detect;

    always_ff @(posedge clk) begin
      if (!resetn) begin
          shift_reg <= '0;
          cnt <= '0;
      end 
      else begin
        shift_reg <= {shift_reg[3 : 0], din};
        if (cnt == 3'd5) begin
          cnt <= cnt;
        end
        else
          cnt <= cnt + 1;
      end
    end
// The answer from ChipDev will cause latch in synthesization, I don't like that answer
    always_ff @(posedge clk) begin
      reset_detect <= resetn;
      if (!resetn) begin
        target <= '0;
      end 
      else begin
        if (resetn && ~reset_detect)
          target <= init;
      end
    end

    assign seen = reset_detect && (shift_reg == target) && (cnt == 5);

endmodule