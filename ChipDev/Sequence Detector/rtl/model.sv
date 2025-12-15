module model (
  input clk,
  input resetn,
  input din,
  output logic dout
);
  typedef enum logic [4:0] {
    IDLE  = 5'b0_0001,
    S1    = 5'b0_0010,
    S10   = 5'b0_0100,
    S101  = 5'b0_1000,
    S1010 = 5'b1_0000
  } state_t;
  state_t state, next_state;

  always_ff @ (posedge clk) begin
    if (!resetn) begin
      state <= IDLE;
    end
    else
      state <= next_state;
  end

  always_comb begin
    case (state)
      IDLE   : next_state =  din ? S1    : IDLE;
      S1     : next_state = !din ? S10   : S1;
      S10    : next_state =  din ? S101  : IDLE;
      S101   : next_state = !din ? S1010 : S1;
      S1010  : next_state =  din ? S101  : IDLE;
      default: next_state =  IDLE;
    endcase
  end
  
  assign dout = (state == S1010);
endmodule
