module model (
  input clk,
  input resetn,
  input din,
  output logic dout
);
  typedef enum logic [3 : 0] {
    IDLE  = 4'b0001,
    S_3N  = 4'b0010,
    S_3N1 = 4'b0100,
    S_3N2 = 4'b1000
  } state_t;
  state_t state, next_state;

  always_ff @(posedge clk) begin
    if (!resetn) 
      state <= IDLE;
    else
      state <= next_state;
  end

  always_comb begin
    case (state)
      IDLE   : next_state = din ? S_3N1 : S_3N; // 0 mod 3 = 1
      S_3N   : next_state = din ? S_3N1 : S_3N;
      S_3N1  : next_state = din ? S_3N  : S_3N2;
      S_3N2  : next_state = din ? S_3N2 : S_3N1;
      default: next_state = IDLE; 
    endcase
  end

  assign dout = (state == S_3N);
endmodule