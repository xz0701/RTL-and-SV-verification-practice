`timescale 1ns/1ns

module sequence_test1(
	input wire clk  ,
	input wire rst  ,
	input wire data ,
	output reg flag
);
//*************code***********//
	//reg [2:0] cnt;
	reg temp;
	reg [4:0] data_reg;

	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			//cnt <= 3'd0;
			data_reg <= 5'd0;
			flag <= 1'b0;
			temp <= 1'b0;
		end
		else begin
			data_reg <= {data_reg[3:0], data};
			if ((data_reg == 5'b01011 && data) || (data_reg == 5'b11011 && data)) begin
				if (~temp) begin
					temp <= 1'b1;
					flag <= 1'b1;
				end
				else begin
					flag <= 1'b0;
				end
			end
			else begin
				flag <= 1'b0;
			end
		end
	end

//*************code***********//
endmodule