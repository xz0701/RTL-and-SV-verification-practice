`timescale 1ns/1ns

module gray_counter(
   input   clk,
   input   rst_n,

   output  reg [3:0] gray_out
);
	reg  [3 : 0] cnt_bin;
	wire [3 : 0] cnt_gray;
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n)
			cnt_bin <= 4'b0;
		else begin
			cnt_bin <= cnt_bin + 4'd1;
		end	
	end

	bin2gray #(4)u_bin2gray(
		.bin_code(cnt_bin),
		.gray_code(cnt_gray)
	);
	always @(*) begin
		gray_out = cnt_gray;
	end
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