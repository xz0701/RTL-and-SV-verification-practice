module model (
    input [7:0] din,
    input clk,
    input resetn,
    output reg [17:0] dout,
    output reg run
);

    reg [2 : 0] cnt;
    reg [7 : 0] data [5:0];
    reg [15 : 0] a1b1, a2b2, a3b3;

    always_ff @(posedge clk) begin
        if (!resetn) begin
            cnt <= '0;
        end 
        else if (cnt == 3'd5) begin
            cnt <= '0;
        end
        else begin 
            cnt <= cnt + 3'd1;
        end
    end

    always_ff @(posedge clk) begin
        if (!resetn) begin
            data[0] <= 0;
            data[1] <= 0;
            data[2] <= 0;
            data[3] <= 0;
            data[4] <= 0;
            data[5] <= 0;
        end 
        else begin
            data[cnt] <= din;
        end
    end

    always_comb begin
        run = (cnt == '0);
    end

    always_comb begin
        a1b1 = (run) ? data[0] * data[3] : a1b1;
        a2b2 = (run) ? data[1] * data[4] : a2b2;
        a3b3 = (run) ? data[2] * data[5] : a3b3;
        dout = a1b1 + a2b2 + a3b3;
    end

endmodule