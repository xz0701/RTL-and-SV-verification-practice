`timescale 1ns/1ns

module valid_ready(
	input 				clk 		,   
	input 				rst_n		,
	input		[7:0]	data_in		,
	input				valid_a		,
	input	 			ready_b		,
 
 	output		 		ready_a		,
 	output	reg			valid_b		,
	output  reg [9:0] 	data_out
);

	reg [1:0] cnt; 
    assign ready_a = (~valid_b) | ready_b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt     <= 2'd0;
            valid_b <= 1'b0;
            data_out <= 10'd0;
        end 
		else begin
            // if (ready_a && valid_a) begin
			// 	cnt <= cnt + 2'd1;
			// 	if (cnt == 2'd0) begin
			// 		data_out <= data_in;
			// 	end
			// 	else begin
			// 		data_out <= data_out + data_in;
			// 	end
			// 	if (cnt == 2'd3) begin
			// 		cnt <= 2'd0;
			// 		valid_b <= 1'b1;
			// 	end
			// 	else begin
			// 		valid_b <= 1'b0;
			// 	end
			// end
			if (ready_a && valid_a) begin
				cnt <= cnt + 2'd1;
				if (cnt == 2'd0) begin
					data_out <= data_in;
					valid_b <= 1'b0;
				end
				else if (cnt == 2'd3) begin
					cnt <= 2'd0;
					valid_b <= 1'b1;
					data_out <= data_out + data_in;
				end
				else begin
					valid_b <= 1'b0;
					data_out <= data_out + data_in;
				end
			end
        end
    end
endmodule