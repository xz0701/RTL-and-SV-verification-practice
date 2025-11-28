`timescale 1ns/1ns
module sequence_detect(
	input clk,
	input rst_n,
	input a,
	output reg match
	);

	parameter IDLE       = 10'b00_0000_0001,
			  S0         = 10'b00_0000_0010,
			  S01        = 10'b00_0000_0100,
			  S011       = 10'b00_0000_1000,
			  S011X      = 10'b00_0001_0000,
			  S011XX     = 10'b00_0010_0000,
			  S011XXX    = 10'b00_0100_0000,
			  S011XXX1   = 10'b00_1000_0000,
			  S011XXX11  = 10'b01_0000_0000,
			  S011XXX110 = 10'b10_0000_0000;

	reg [9:0] state, next_state;
	
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) 
			state <= IDLE;
		else
			state <= next_state;
	end

	always @(*) begin
		case (state)
			IDLE:       next_state = ~a ? S0         : IDLE;
			S0:         next_state =  a ? S01        : S0;
			S01:        next_state =  a ? S011       : S0;
			S011:       next_state =  S011X;
			S011X:      next_state =  S011XX;
			S011XX:     next_state =  S011XXX;
			S011XXX:    next_state =  S011XXX1;			
			S011XXX1:   next_state =  S011XXX11;
			S011XXX11:  next_state =  S011XXX110;
			S011XXX110: next_state =  a ? S01        : S0;
			default :   next_state = IDLE;
		endcase
	end

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n)
			match <= 1'b0;
		else if (state == S011XXX110)
			match <= 1'b1;
		else
			match <= 1'b0;
	end
endmodule