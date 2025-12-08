`timescale 1ns/1ns

module RAM_1port(
    input clk,
    input rst,
    input enb,
    input [6:0]addr,
    input [3:0]w_data,
    output wire [3:0]r_data
);
    reg [3 : 0] RAM [0 : 127];
    reg [3:0] data_out;
    assign r_data = data_out;

    integer i;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (i = 0; i < 127; i = i + 1) begin
                RAM[i] <= 4'b0;
            end
        end
        else begin
            if (enb) begin
                RAM[addr] <= w_data;
            end
        end
    end

    always @(negedge clk or negedge rst) begin
        if (~rst) begin
            data_out <= 4'b0;
        end
        else begin
            if (~enb) begin
                data_out <= RAM[addr];
            end
        end
    end
endmodule