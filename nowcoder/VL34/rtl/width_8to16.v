`timescale 1ns/1ns

module width_8to16(
	input 			   clk 		,   
	input 			   rst_n	,
	input			   valid_in	,
	input	[7:0]	   data_in	,
 
 	output  reg		   valid_out,
	output  reg [15:0] data_out
);
	reg cnt;
	reg [7:0] temp;
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			cnt <= 1'b0;
			data_out <= 16'd0;
			temp <= 8'd0;
			valid_out <= 1'b0;
		end
		else begin
			if (valid_in) begin
				temp <= data_in;
				cnt <= cnt + 2'd1;
				if (cnt == 2'd1) begin
					data_out <= {temp, data_in};
					valid_out <= 1'b1; 
					cnt <= 1'b0;
				end
				else begin
					valid_out <= 1'b0;
				end
			end
			else begin
				valid_out <= 1'b0;
			end
		end
	end
endmodule