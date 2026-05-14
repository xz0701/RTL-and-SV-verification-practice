// ============================================================
// Synchronous FIFO with Full/Empty/Almost flags
// ============================================================
// Single clock domain FIFO; typical implementation uses memory + rd/wr pointers and/or
// an occupancy counter to generate full/empty and threshold flags.


module sync_fifo #(
  parameter int unsigned DEPTH = 8,    // TODO: power-of-2 recommended
  parameter int unsigned WIDTH = 8,

  // Thresholds in "entries" (0..DEPTH)
  parameter int unsigned ALMOST_FULL_THRESH  = DEPTH-1,
  parameter int unsigned ALMOST_EMPTY_THRESH = 1
) (
  input  logic               clk,
  input  logic               rst_n,

  input  logic               write_en,
  input  logic [WIDTH-1:0]   write_data,

  input  logic               read_en,
  output logic [WIDTH-1:0]   read_data,

  output logic               full,
  output logic               empty,
  output logic               almost_full,
  output logic               almost_empty
);

  localparam int unsigned ADDR_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH);

  // Storage
  logic [WIDTH-1:0] mem [0:DEPTH-1];

  // Pointers and occupancy
  logic [ADDR_W-1:0] rd_ptr, wr_ptr;
  logic [ADDR_W:0]   count; // extra bit to represent DEPTH

  logic write_fire;
  logic read_fire;

  // ----------------------------
  // TODO: Parameter/legal checks
  // ----------------------------
  // TODO: Ensure thresholds satisfy:
  // 0 <= ALMOST_EMPTY_THRESHOLD < ALMOST_FULL_THRESHOLD <= DEPTH
  // TODO: Decide behavior if DEPTH is not power-of-2 (pointer wrap logic still must work).
  // TODO: Decide what to do if DEPTH==1 (ADDR_W may be 0 tool-dependent).
  initial begin
    if (DEPTH == 0) begin
      $fatal(1, "DEPTH must be greater than 0");
    end

    if ((DEPTH & (DEPTH - 1)) != 0) begin
      $fatal(1, "DEPTH must be power of 2");
    end

    if (WIDTH < 1) begin
      $fatal(1, "WIDTH must be >= 1");
    end

    if (!(ALMOST_EMPTY_THRESH < ALMOST_FULL_THRESH)) begin
      $fatal(1, "Require ALMOST_EMPTY_THRESH < ALMOST_FULL_THRESH");
    end

    if (ALMOST_FULL_THRESH > DEPTH) begin
      $fatal(1, "ALMOST_FULL_THRESH must be <= DEPTH");
    end
  end

  // ----------------------------
  // TODO: Derived handshakes
  // ----------------------------
  // TODO: write_fire = write_en && !full
  assign write_fire = write_en && !full;

  // TODO: read_fire  = read_en  && !empty
  assign read_fire  = read_en && !empty;

  // ----------------------------
  // TODO: Flag generation from count
  // ----------------------------
  // full  = (count == DEPTH)
  // empty = (count == 0)
  // almost_full  = (count >= ALMOST_FULL_THRESHOLD)
  // almost_empty = (count <= ALMOST_EMPTY_THRESHOLD)
  assign full         = (count == DEPTH);
  assign empty        = (count == 0);
  assign almost_full  = (count >= ALMOST_FULL_THRESH);
  assign almost_empty = (count <= ALMOST_EMPTY_THRESH);

  // ----------------------------
  // Sequential logic
  // ----------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // TODO: Reset:
      // rd_ptr=0; wr_ptr=0; count=0; empty=1; full=0; read_data defined.
      // almost flags depend on thresholds.
      rd_ptr    <= '0;
      wr_ptr    <= '0;
      count     <= '0;
      read_data <= '0;
    end else begin
      // TODO: Write operation:
      // - If write_fire: mem[wr_ptr] <= write_data; wr_ptr++ (wrap); count++ if no read_fire.
      // - If write_en && full: ignore write (optionally record an overflow event internally).
      if (write_fire) begin
        mem[wr_ptr] <= write_data;
        wr_ptr      <= wr_ptr + 1'b1;
      end

      // TODO: Read operation:
      // - If read_fire: read_data <= mem[rd_ptr] (if registered); rd_ptr++ (wrap); count-- if no write_fire.
      // - If read_en && empty: ignore read (optionally record an underflow event internally).
      if (read_fire) begin
        read_data <= mem[rd_ptr];
        rd_ptr    <= rd_ptr + 1'b1;
      end

      // TODO: Simultaneous read+write:
      // - If both fire: do both pointer updates; count unchanged.
      // - TODO: Define if reading and writing same address can occur (depends on full/empty boundaries).
      unique case ({write_fire, read_fire})
        2'b10: begin
          count <= count + 1'b1;
        end

        2'b01: begin
          count <= count - 1'b1;
        end

        2'b11: begin
          count <= count;
        end

        default: begin
          count <= count;
        end
      endcase
    end
  end

endmodule