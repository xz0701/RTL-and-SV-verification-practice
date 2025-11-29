`timescale 1ns/1ns
module signal_generator(
	input clk,
	input rst_n,
	input [1:0] wave_choise,
	output reg [4:0]wave
);
	reg [4:0] cnt;
	reg option;

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			cnt <= 5'd0;
			wave <= 5'b0;
			option <= 1'b0;
		end
		else begin
			case (wave_choise)
				2'b00: begin;
					cnt <= cnt + 1;
					if (cnt == 5'd9) begin
						wave <= 5'd20;
						option <= 1'b1;
					end
					else if (cnt == 5'd19) begin
						wave <= 5'b0;
						option <= 1'b0;
						cnt <= 5'd0;
					end	
				end
				2'b01: begin
					if (option) begin
						wave <= 5'b0;
						option <= 1'b0;
					end
					else begin
						if (wave == 5'd20) begin
							wave <= 5'b0;
						end
						else 
							wave <= wave + 1;
					end
				end
				2'b10: begin
					if (~option) begin
						wave <= wave - 1;
						if (wave == 5'b0) begin
							option <= 1'b1;
							wave <= 5'd1;
						end
					end
					else begin
						wave <= wave + 1;
						if (wave == 5'd20) begin
							option <= 1'b0;
							wave <= 5'd19;
						end
					end
				end
				default: begin
					wave <= 5'b0;
					option <= 1'b0;
					cnt <= 5'd0;
				end		
			endcase
		end
	end
endmodule