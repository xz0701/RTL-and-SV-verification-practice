// ============================================================
// Overlapping Sequence Detector for 1011
// ============================================================
// Detect pattern "1011" on serial input in (1 bit/cycle).
// Overlapping means the FSM must fall back to the longest suffix that is also a prefix,
// not always to IDLE, after partial or full matches.
//
// TODO: Choose FSM type and document:
// - Mealy: detect can pulse on a transition (state+input).
// - Moore: detect asserted in a dedicated DETECT state (often 1-cycle).
//
// TODO: Clarify pulse vs level for detect.
// TODO: Choose reset type (sync/async) and document it.

module seq_det_1011 #(
  parameter bit MEALY = 1  // TODO: 1=Mealy, 0=Moore
) (
  input  logic clk,
  input  logic rst_n,
  input  logic in,
  output logic detect
);

  // ----------------------------
  // TODO: State definitions
  // ----------------------------
  // Suggested conceptual states (names only):
  // - IDLE: none matched
  // - S1:   seen "1"
  // - S10:  seen "10"
  // - S101: seen "101"
  // - (Moore only) DETECT: complete "1011"
  //
  // TODO: Choose encoding (enum logic [..:0]) and list states clearly.

  typedef enum logic [2:0] {
  // TODO: fill with your states
  ST_IDLE  = 3'd0
  } state_t;

  state_t state_q, state_d;

  // ----------------------------
  // TODO: Next-state logic
  // ----------------------------
  always_comb begin
  // TODO: Default next state = current state (or IDLE) and default detect=0.
  // TODO: Provide complete transitions for every state for in=0 and in=1. (No missing arcs.)
  //
  // TODO: Overlap handling:
  // - After a full match "1011", next state must reflect that "1" can be start of a new match,
  //   not necessarily IDLE.
  // - On mismatch, fall back appropriately (e.g., from having seen "101" and receiving 0,
  //   you may still have matched "10" as suffix).
  //
  // TODO: If MEALY:
  // - detect asserted based on (state_q and in) on the match-completing transition.
  // TODO: If MOORE:
  // - detect asserted only in DETECT state, and DETECT state lasts exactly 1 cycle.
  end

  // ----------------------------
  // State register
  // ----------------------------
  always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
  // TODO: Reset to IDLE, detect=0 (if detect registered).
  state_q <= ST_IDLE;
  end else begin
  // TODO: state_q <= state_d
  end
  end

  // ----------------------------
  // TODO: Output logic (if Moore)
  // ----------------------------
  // TODO: If Moore, make detect a pure function of state_q (combinational decode),
  // or register it carefully so it is a clean 1-cycle pulse.

endmodule


