`timescale 1ns/1ns

module pulse_detect(
	input 				clk_fast	, 
	input 				clk_slow	,   
	input 				rst_n		,
	input				data_in		,

	output  		 	dataout
);
	reg  flag_fast_prev; //detect rising edge
	wire flag_fast, flag_slow;
	reg  toggle_fast;
	wire toggle_slow;
	reg  toggle_slow_prev;
	reg  data_out;

	always @(posedge clk_fast or negedge rst_n) begin
		if (~rst_n) begin
			flag_fast_prev <= 1'b0;
		end
		else begin
			flag_fast_prev <= data_in;
		end
	end
	assign flag_fast = data_in & ~flag_fast_prev;

	always @(posedge clk_fast or negedge rst_n) begin
		if (~rst_n) begin
			toggle_fast <= 1'b0;
		end
		else if (flag_fast) begin
			toggle_fast <= ~toggle_fast;
		end
	end

	sync #(
		.WIDTH(1),
		.SYNC_STAGE(2)
	) fast_sync_slow (
		.clk(clk_slow),
		.rstn(rst_n),
		.en(1'b1),
		.data_in(toggle_fast),
		.data_out(toggle_slow)
	);

	always @(posedge clk_slow or negedge rst_n) begin
		if (~rst_n) begin
			data_out <= 1'b0;
			toggle_slow_prev <= 1'b0;

		end
		else begin
			toggle_slow_prev <= toggle_slow;
			data_out <= toggle_slow ^ toggle_slow_prev;
		end
	end
	assign dataout = data_out;
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
