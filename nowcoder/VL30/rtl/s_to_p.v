`timescale 1ns/1ns

module s_to_p(
	input 				clk 		,   
	input 				rst_n		,
	input				valid_a		,
	input	 			data_a		,
 
 	output	reg 		ready_a		,
 	output	reg			valid_b		,
	output  reg [5:0] 	data_b
);
	reg [2:0] cnt;
	reg [5:0] temp;
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n)
			ready_a <= 1'b0;
		else
			ready_a <= 1'b1;
	end

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			data_b <= 6'd0;
			valid_b <= 1'b0;
			cnt <= 3'b0;
			temp <= 6'd0;
		end
		else begin
			if (valid_a) begin
				if (cnt == 3'd5) begin
					cnt <= 3'd0;
					data_b <= {data_a, temp[5:1]}; //very important, include last bit
					valid_b <= 1'b1;
				end
				else begin
					temp <= {data_a, temp[5:1]};
					cnt <= cnt + 1;
					valid_b <= 1'b0;
				end
			end
		end
	end
endmodule