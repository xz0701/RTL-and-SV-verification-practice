module model (
  input clk,
  input resetn,
  input din,
  output logic dout
);
  typedef enum logic [5 : 0] {
    IDLE  = 6'b00_0001,
    S_5N  = 6'b00_0010,
    S_5N1 = 6'b00_0100,
    S_5N2 = 6'b00_1000,
    S_5N3 = 6'b01_0000,
    S_5N4 = 6'b10_0000
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
      IDLE   : next_state = din ? S_5N1 : S_5N; // 0 mod 5 = 1
      S_5N   : next_state = din ? S_5N1 : S_5N;
      S_5N1  : next_state = din ? S_5N3 : S_5N2;
      S_5N2  : next_state = din ? S_5N  : S_5N4;
      S_5N3  : next_state = din ? S_5N2 : S_5N1;
      S_5N4  : next_state = din ? S_5N4 : S_5N3;
      default: next_state = IDLE; 
    endcase
  end

  assign dout = (state == S_5N);
endmodule