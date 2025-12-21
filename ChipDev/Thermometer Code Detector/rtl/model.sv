module model #(parameter
    DATA_WIDTH = 8
) (
    input [DATA_WIDTH-1:0] codeIn,
    output reg isThermometer
);

    reg [$clog2(DATA_WIDTH) - 1 : 0] temp;

    always_comb begin
        temp = 0;
        for (int i = 1; i < DATA_WIDTH; i++) begin
            temp = temp + (codeIn[i - 1] ^ codeIn[i]); 
        end

    end 

    assign isThermometer = (temp == 1) ? 1'b1 : 1'b0;

endmodule