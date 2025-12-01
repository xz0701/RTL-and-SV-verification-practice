`timescale 1ns/1ns

module width_24to128(
	input 				clk 		,   
	input 				rst_n		,
	input				valid_in	,
	input	[23:0]		data_in		,
 
 	output	reg			valid_out	,
	output  reg [127:0]	data_out
);

	reg [3:0] cnt;
	reg [143:0] temp;
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			data_out <= 128'b0;
			temp <= 144'd0;
			valid_out <= 1'b0;
			cnt <= 4'b0;
		end
		else begin
			if (valid_in) begin
				temp <= {temp[119:0], data_in};
				cnt <= cnt + 4'd1;
				if (cnt == 4'd5) begin
					data_out <= {temp[119:0], data_in[23:16]};
					valid_out <= 1'b1;
				end
				else if (cnt == 4'd10) begin
					data_out <= {temp[111:0], data_in[23:8]};
					valid_out <= 1'b1;
				end
				else if (cnt == 4'd15) begin
					data_out <= {temp[103:0], data_in};
					valid_out <= 1'b1;
					cnt <= 4'd0;
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