module model (
    input [7:0] din,
    output reg [255:0] dout
);

    parameter WIDTH = 8;

    reg [2 ** WIDTH - 1 : 0] temp [2 ** WIDTH - 1 : 0];

    genvar i;
    generate
        for (i = 0; i < 2 ** WIDTH; i++) begin
            assign temp[i] = (din == i) ? {{2 ** WIDTH - 1 - i{1'b0}}, {i + 1{1'b1}}} : {2**WIDTH{1'b0}};
        end
    endgenerate
    
    assign dout = temp[din];

endmodule