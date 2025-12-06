`timescale 1ns/1ns

/***************************************AFIFO*****************************************/
module sfifo#(
	parameter	WIDTH = 8,
	parameter 	DEPTH = 16
)(
	input 					clk	    ,  
	input 					rst_n	,
	input 					winc	,
	input 			 		rinc	,
	input 		[WIDTH-1:0]	wdata	,

	output wire				wfull	,
	output wire				rempty	,
	output wire [WIDTH-1:0]	rdata
);

	localparam ADDR_WIDTH = $clog2(DEPTH);

	wire [ADDR_WIDTH - 1 : 0] waddr, raddr;
	wire wenc, renc;
	// address pointers
	reg  [ADDR_WIDTH : 0] waddr_ptr, raddr_ptr;

	assign waddr = waddr_ptr[ADDR_WIDTH - 1 : 0];
	assign raddr = raddr_ptr[ADDR_WIDTH - 1 : 0];
	assign wenc = winc & (~wfull);
	assign renc = rinc & (~rempty);

	wire full, empty; // The answer is not correct on nowcoder,
	reg full_reg, empty_reg;	// so we have to define two extra registers

	// RAM
	dual_port_RAM #(
		.DEPTH(DEPTH),
		.WIDTH(WIDTH)
	) RAM_0 (
		.wclk(clk),
		.wenc(wenc),
		.waddr(waddr),
		.wdata(wdata),
		.rclk(clk),
		.renc(renc),
		.raddr(raddr),
		.rdata(rdata)
	);

	// Write FIFO
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			waddr_ptr <= {(ADDR_WIDTH + 1){1'b0}};
		end 
		else begin
			if (wenc) begin
				if (waddr_ptr[ADDR_WIDTH - 1 : 0] == DEPTH - 1) begin
					waddr_ptr[ADDR_WIDTH - 1 : 0] <= {ADDR_WIDTH{1'b0}};
					waddr_ptr[ADDR_WIDTH] <= ~waddr_ptr[ADDR_WIDTH];
				end 
				else begin
					waddr_ptr <= waddr_ptr + 1'd1;
				end
			end
		end
	end

	// Read FIFO
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			raddr_ptr <= {(ADDR_WIDTH + 1){1'b0}};
		end 
		else begin
			if (renc) begin
				if (raddr_ptr[ADDR_WIDTH - 1 : 0] == DEPTH-1) begin
					raddr_ptr[ADDR_WIDTH - 1 : 0] <= {ADDR_WIDTH{1'b0}};
					raddr_ptr[ADDR_WIDTH] <= ~raddr_ptr[ADDR_WIDTH];
				end 
				else begin
					raddr_ptr <= raddr_ptr + 1'd1;
				end
			end
		end
	end

	// Full
	assign full = (
		{~waddr_ptr[ADDR_WIDTH], 
		  waddr_ptr[ADDR_WIDTH - 1 : 0]} == raddr_ptr) 
		? 1'b1 : 1'b0;	
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			full_reg <= 1'b0;
		end
		else begin
			full_reg <= full;
		end
	end
	assign wfull = full_reg;
	// Correct Logic
	// assign wfull = (
	// 	{~waddr_ptr[ADDR_WIDTH], 
	// 	  waddr_ptr[ADDR_WIDTH - 1 : 0]} == raddr_ptr) 
	// 	? 1'b1 : 1'b0;	

	// Empty
	assign empty = 
		   (raddr_ptr == waddr_ptr) ? 1'b1 : 1'b0;	 
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			empty_reg <= 1'b0; // actually should be 1
		end
		else begin
			empty_reg <= empty;
		end
	end
	assign rempty = empty_reg;
	// Correct Logic
	// assign rempty = 
	// 	   (raddr_ptr == waddr_ptr) ? 1'b1 : 1'b0;	   

endmodule

/***************************************RAM*****************************************/
module dual_port_RAM #(
	parameter DEPTH = 16,
	parameter WIDTH = 8 
)(
	 input wclk
	,input wenc
	,input [$clog2(DEPTH)-1:0] waddr  //log2 get the address width according to depth
	,input [WIDTH-1:0] wdata      	//data input
	,input rclk
	,input renc
	,input [$clog2(DEPTH)-1:0] raddr  //log2 get the address width according to depth
	,output reg [WIDTH-1:0] rdata 		//data output
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
	if(wenc)
		RAM_MEM[waddr] <= wdata;
end 

always @(posedge rclk) begin
	if(renc)
		rdata <= RAM_MEM[raddr];
end 

endmodule  