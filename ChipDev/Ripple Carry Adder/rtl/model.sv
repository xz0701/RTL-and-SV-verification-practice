`include "full_adder.sv"
module model #(parameter
    DATA_WIDTH=8
) (
    input [DATA_WIDTH-1:0] a,
    input [DATA_WIDTH-1:0] b,
    output logic [DATA_WIDTH-0:0] sum,
    output logic [DATA_WIDTH-1:0] cout_int
);
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            if (i == '0) begin
                full_adder adder0(
                    .a(a[i]),
                    .b(b[i]),
                    .cin(1'b0),
                    .sum(sum[i]),
                    .cout(cout_int[i])
                );
            end
            else begin
                full_adder adder(
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cout_int[i - 1]),
                    .sum(sum[i]),
                    .cout(cout_int[i])
                );
            end
        end
    endgenerate
    assign sum[DATA_WIDTH] = cout_int[DATA_WIDTH - 1];
endmodule