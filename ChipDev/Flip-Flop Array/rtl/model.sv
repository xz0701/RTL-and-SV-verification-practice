module model (
    input [7:0] din,
    input [2:0] addr,
    input wr,
    input rd,
    input clk,
    input resetn,
    output logic [7:0] dout,
    output logic error
);
    typedef struct packed {
        logic [7 : 0] data;
        logic valid;
    } mem_t;

    mem_t mem [0 : 7];
    always_ff @(posedge clk) begin
        if (~resetn) begin
            for (int i = 0; i < 8; i = i + 1) begin
                mem[i].data <= '0;
                mem[i].valid <= '0;
            end
            error <= 1'b0;
            dout <= '0;
        end
        else begin
            if (wr && rd) begin
                error <= 1'b1;
                dout <= '0;
            end
            else if (wr && !rd) begin
                error <= 1'b0;
                dout <= '0;
                mem[addr].data <= din;
                mem[addr].valid <= 1'b1;
            end
            else if (!wr && rd) begin
                error <= 1'b0;
                if (mem[addr].valid == '0)
                    dout <= '0;
                else
                    dout <= mem[addr].data;
            end
            else begin
                error <= 1'b0;
                dout <= '0;
            end
        end
    end
endmodule