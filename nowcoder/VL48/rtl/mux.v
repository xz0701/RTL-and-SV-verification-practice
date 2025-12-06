`timescale 1ns/1ns

module mux(
	input 				clk_a	, 
	input 				clk_b	,   
	input 				arstn	,
	input				brstn   ,
	input		[3:0]	data_in	,
	input               data_en ,

	output      [3:0] 	dataout
);
	wire data_en_a, data_en_b;
	wire [3 : 0] data_in_gray, data_out_gray;

	sync #(
		.WIDTH(1),
		.SYNC_STAGE(2)
	) en_sync_a (
		.clk(clk_a),
		.rstn(arstn),
		.en(1'b1),
		.data_in(data_en),
		.data_out(data_en_a)
	);

	sync #(
		.WIDTH(1),
		.SYNC_STAGE(2)
	) en_a_sync_b (
		.clk(clk_b),
		.rstn(brstn),
		.en(1'b1),
		.data_in(data_en_a),
		.data_out(data_en_b)
	);

	bin2gray #(
		.WIDTH(4)
	) bin2gray_in (
		.bin_code(data_in),
		.gray_code(data_in_gray)
	);

	sync #(
		.WIDTH(4),
		.SYNC_STAGE(2)
	) a_sync_b (
		.clk(clk_b),
		.rstn(brstn),
		.en(data_en_b),
		.data_in(data_in_gray),
		.data_out(data_out_gray)
	);

	gray2bin #(
		.WIDTH(4)
	) gray2bin_out (
		.gray_code(data_out_gray),
		.bin_code(dataout)
	);

endmodule

/*************************************BIN2GRAY***************************************/
module bin2gray #(
	parameter WIDTH = 8
)(
	input  [WIDTH - 1 : 0] bin_code,
	output [WIDTH - 1 : 0] gray_code
);
	assign gray_code = bin_code ^ (bin_code >> 1);

endmodule

/*************************************GRAY2BIN***************************************/
module gray2bin #(
	parameter WIDTH = 8 
)(
	input  [WIDTH - 1 : 0] gray_code,
	output [WIDTH - 1 : 0] bin_code
);

	genvar i;
	assign bin_code[WIDTH-1] = gray_code[WIDTH-1];

	generate
		for (i = WIDTH-2; i >= 0; i = i - 1) begin
			assign bin_code[i] = bin_code[i+1] ^ gray_code[i];
		end
	endgenerate

endmodule 

/***************************************SYNC****************************************/
module sync #(
    parameter WIDTH = 8,
    parameter SYNC_STAGE = 2
)(
    input              clk,
    input              rstn,
	input              en,
    input  [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out
);

    reg [WIDTH - 1 : 0] sync_reg [0 : SYNC_STAGE - 1];

    integer i;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < SYNC_STAGE; i = i + 1)
                sync_reg[i] <= {WIDTH{1'b0}};
        end
        else if (en) begin
            sync_reg[0] <= data_in;
            for (i = 1; i < SYNC_STAGE; i = i + 1)
                sync_reg[i] <= sync_reg[i - 1];
        end
    end

    assign data_out = sync_reg[SYNC_STAGE - 1];

endmodule
