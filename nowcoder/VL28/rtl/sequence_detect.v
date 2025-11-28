`timescale 1ns/1ns
module sequence_detect(
	input clk,
	input rst_n,
	input data,
	input data_valid,
	output reg match
	);

	parameter IDLE    = 5'b0_0001,

			  S0      = 5'b0_0010,
			  S01     = 5'b0_0100,
			  S011    = 5'b0_1000,
			  S0110   = 5'b1_0000;
			  
	reg [4:0] state, next_state;
	
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) 
			state <= IDLE;
		else 
			state <= next_state;
	end

	always @(*) begin
		if (data_valid) begin
			case (state)
				IDLE:       next_state = ~data ? S0    : IDLE;

				S0:         next_state =  data ? S01   : S0;
				S01:        next_state =  data ? S011  : S0;
				S011:       next_state =  data ? S0110 : S0;
				S0110:      next_state = ~data ? S01   : S0;

				default :   next_state = IDLE;
		endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n)
			match <= 1'b0;
		else if (state == S011 && ~data && data_valid)
			match <= 1'b1;
		else
			match <= 1'b0;
	end

endmodule