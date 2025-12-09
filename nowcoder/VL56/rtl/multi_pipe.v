`timescale 1ns/1ns

module multi_pipe#(
	parameter SIZE = 4
)(
	input 						clk 		,   
	input 						rst_n		,
	input	[SIZE - 1 : 0]			mul_a		,
	input	[SIZE - 1 : 0]			mul_b		,
 
 	output	reg	[SIZE * 2 - 1 : 0]	mul_out		
);
	//typical wallace adder
	wire [SIZE - 1 : 0] [SIZE * 2 - 1 : 0] mulb_shift;
	reg  [SIZE * 2 - 1 : 0]            adder_0;
	reg  [SIZE * 2 - 1 : 0]            adder_1;

	generate
		genvar i;
		for (i = 0; i < SIZE; i = i + 1) begin : gen_mulb_shift
		assign mulb_shift[i] = mul_a[i] ? (mul_b << i) : {(SIZE * 2){1'b0}};
		end
	endgenerate

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
		adder_0 <= {(SIZE * 2){1'b0}};
		adder_1 <= {(SIZE * 2){1'b0}};
		mul_out <= {(SIZE * 2){1'b0}};
		end else begin
		adder_0 <= mulb_shift[0] + mulb_shift[1];
		adder_1 <= mulb_shift[2] + mulb_shift[3];
		mul_out <= adder_0 + adder_1;
		end
	end
endmodule