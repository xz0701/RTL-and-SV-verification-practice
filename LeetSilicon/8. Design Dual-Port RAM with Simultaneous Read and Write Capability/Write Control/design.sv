// ============================================================
// ID: mem2 — Dual-Port RAM (Simple DP or True DP)
// ============================================================
// Two independent ports, same clock in this template.
// Must define collision behavior:
// - read/write same address same cycle (read-first vs write-first vs undefined)
// - write/write same address (true dual-port only): define priority or flag error.
//
// TODO: Choose type:
// - SIMPLE_DP: Port A write-only, Port B read-only
// - TRUE_DP: both ports can read/write

module dp_ram #(
  parameter DEPTH = 256,
  parameter WIDTH = 8
) (
  input  logic                      clk,
  input  logic                      write_en_a,
  input  logic [$clog2(DEPTH)-1:0] addr_a,
  input  logic [WIDTH-1:0]          write_data_a,
  input  logic                      read_en_b,
  input  logic [$clog2(DEPTH)-1:0] addr_b,
  output logic [WIDTH-1:0]          read_data_b
);

  logic [WIDTH-1:0] mem [0:DEPTH-1];

  // TODO: Registered read outputs if you want 1-cycle latency per port (recommended).
  logic [WIDTH-1:0] rdata_a_q, rdata_b_q;

  // ----------------------------
  // TODO: Collision detection
  // ----------------------------
  // TODO: ww_collision = TRUE_DUAL_PORT && en_a && en_b && we_a && we_b && (addr_a == addr_b).
  // TODO: Define what happens on ww_collision:
  // - Port A priority, or Port B priority, or error/undefined.

  // ----------------------------
  // TODO: Write logic
  // ----------------------------
  // TODO: In always_ff:
  // - If SIMPLE_DP: only allow writes on Port A.
  // - If TRUE_DP: allow writes on both ports; handle ww_collision per spec.

  // ----------------------------
  // TODO: Read logic + RW collision behavior
  // ----------------------------
  // TODO: Read latency: 1-cycle sync read suggested:
  // if (en_a && re_a) rdata_a_q <= mem[addr_a];
  // if (en_b && re_b) rdata_b_q <= mem[addr_b];
  // rdata_* = rdata_*_q;
  //
  // TODO: Same-address RW collision: one port writes, other reads same address same cycle:
  // - If WRITE_FIRST_RW: read returns new write data.
  // - Else READ_FIRST_RW: read returns old mem value.
  // TODO: Implement forwarding mux(es) if choosing write-first.

  // ----------------------------
  // TODO: Reset
  // ----------------------------
  // TODO: Reset read data regs (optional); memory init optional.

endmodule


