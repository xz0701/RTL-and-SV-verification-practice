// ============================================================
// ID: mem1 — Single-Port Synchronous RAM (1 port, sync write)
// ============================================================
// Single-port RAM cannot read and write different addresses in the same cycle (one address port).
// Read behavior must be defined: sync (1-cycle latency) or comb (0-cycle latency).
// Read-during-write to same address must be defined: write-first, read-first, or undefined.
//
// TODO: Choose and document:
// - READ_LATENCY: 0 or 1
// - RDW_MODE: WRITE_FIRST / READ_FIRST / NO_CHANGE / UNDEFINED (whatever you support)
// TODO: Decide whether to include chip_enable.
// TODO: Decide reset policy (clear mem vs leave X/undefined for synthesis).

module sp_ram #(
  parameter DEPTH = 256,
  parameter WIDTH = 8
) (
  input  logic                      clk,
  input  logic                      write_en,
  input  logic                      read_en,
  input  logic [$clog2(DEPTH)-1:0] address,
  input  logic [WIDTH-1:0]          write_data,
  output logic [WIDTH-1:0]          read_data
);

  // Memory array
  logic [WIDTH-1:0] mem [0:DEPTH-1];

  // Optional registered output for 1-cycle read latency
  logic [WIDTH-1:0] read_data_q;

  // ----------------------------
  // TODO: Address width / DEPTH edge cases
  // ----------------------------
  // TODO: If DEPTH is not power-of-2, addr width is still clog2(DEPTH); decide if you allow
  // "out of range" addresses (addr >= DEPTH) in simulation, and what to do.

  // ----------------------------
  // TODO: Synchronous write
  // ----------------------------
  // TODO: On posedge clk, if (chip_en && write_en) mem[addr] <= write_data;

  // ----------------------------
  // TODO: Read implementation
  // ----------------------------
  // Option A: READ_LATENCY_1==1 (synchronous read, 1-cycle latency):
  // - On cycle N: if (chip_en && read_en) capture read_data_q <= mem[addr]
  // - read_data = read_data_q
  //
  // Option B: READ_LATENCY_1==0 (combinational read, 0-cycle latency):
  // - read_data = (chip_en && read_en) ? mem[addr] : (hold/0/'x) (document)

  // ----------------------------
  // TODO: Read-during-write (same address)
  // ----------------------------
  // When chip_en && read_en && write_en in same cycle to same addr:
  // - WRITE_FIRST: read returns new data being written.
  // - READ_FIRST:  read returns old stored data.
  // - UNDEFINED:   explicitly document and do not test, or assert error.
  //
  // TODO: Implement forwarding if WRITE_FIRST is required (especially for sync-read mode).

  // ----------------------------
  // TODO: Reset behavior
  // ----------------------------
  // TODO: If HAS_RESET_INIT:
  // - reset read_data_q/read_data to 0
  // - optionally clear mem (expensive); document if you do or not.

endmodule


