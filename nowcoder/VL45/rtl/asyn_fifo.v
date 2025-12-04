`timescale 1ns/1ns

/***************************************AFIFO*****************************************/
module asyn_fifo#(
	parameter	WIDTH = 8,
	parameter 	DEPTH = 16
)(
	input 					wclk	, 
	input 					rclk	,   
	input 					wrstn	,
	input					rrstn	,
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
	wire [ADDR_WIDTH : 0] waddr_ptr_gray, raddr_ptr_gray;
	// sync registers
	wire [ADDR_WIDTH : 0] waddr_gray_wsync, raddr_gray_wsync;
	wire [ADDR_WIDTH : 0] waddr_gray_rsync, raddr_gray_rsync;

	assign waddr = waddr_ptr[ADDR_WIDTH - 1 : 0];
	assign raddr = raddr_ptr[ADDR_WIDTH - 1 : 0];
	assign wenc = winc & (~wfull);
	assign renc = rinc & (~rempty);

	// RAM
	dual_port_RAM #(
		.DEPTH(DEPTH),
		.WIDTH(WIDTH)
	) RAM (
		.wclk(wclk),
		.wenc(wenc),
		.waddr(waddr),
		.wdata(wdata),
		.rclk(rclk),
		.renc(renc),
		.raddr(raddr),
		.rdata(rdata)
	);

	// Write FIFO
	always @(posedge wclk or negedge wrstn) begin
		if (~wrstn) begin
			waddr_ptr <= {(ADDR_WIDTH+1){1'b0}};
		end 
		else begin
			if (wenc) begin
				if (waddr_ptr == DEPTH-1) begin
					waddr_ptr[ADDR_WIDTH - 1 : 0] <= {ADDR_WIDTH{1'b0}};
					waddr_ptr[ADDR_WIDTH] <= ~waddr_ptr[ADDR_WIDTH];
				end 
				else begin
					waddr_ptr <= waddr_ptr + 1'd1;
				end
			end
		end
	end

	bin2gray #(
		.WIDTH(ADDR_WIDTH+1)
	) bin2gray_waddr (
		.bin_code(waddr_ptr),
		.gray_code(waddr_ptr_gray)
	);

	sync_data #(
		.WIDTH(ADDR_WIDTH+1),
		.SYNC_STAGE(1)
	) waddr_gray_wclk_sync (
		.clk(wclk),
		.rstn(wrstn),
		.data_in(waddr_ptr_gray),
		.data_out(waddr_gray_wsync)
	);

	sync_data #(
		.WIDTH(ADDR_WIDTH+1),
		.SYNC_STAGE(2)
	) waddr_gray_rclk_sync (
		.clk(rclk),
		.rstn(rrstn),
		.data_in(waddr_gray_wsync),
		.data_out(waddr_gray_rsync)
	);

	// Read FIFO
	always @(posedge rclk or negedge rrstn) begin
		if (~rrstn) begin
			raddr_ptr <= {(ADDR_WIDTH+1){1'b0}};
		end 
		else begin
			if (renc) begin
				if (raddr_ptr == DEPTH-1) begin
					raddr_ptr[ADDR_WIDTH - 1 : 0] <= {ADDR_WIDTH{1'b0}};
					raddr_ptr[ADDR_WIDTH] <= ~raddr_ptr[ADDR_WIDTH];
				end 
				else begin
					raddr_ptr <= raddr_ptr + 1'd1;
				end
			end
		end
	end

	bin2gray #(
		.WIDTH(ADDR_WIDTH+1)
	) bin2gray_raddr (
		.bin_code(raddr_ptr),
		.gray_code(raddr_ptr_gray)
	);

	sync_data #(
		.WIDTH(ADDR_WIDTH+1),
		.SYNC_STAGE(1)
	) raddr_gray_wclk_sync (
		.clk(wclk),
		.rstn(wrstn),
		.data_in(raddr_ptr_gray),
		.data_out(raddr_gray_wsync)
	);

	sync_data #(
		.WIDTH(ADDR_WIDTH+1),
		.SYNC_STAGE(2)
	) raddr_gray_rclk_sync (
		.clk(rclk),
		.rstn(rrstn),
		.data_in(raddr_gray_wsync),
		.data_out(raddr_gray_rsync)
	);

	// Full
	// assign wfull = (
	// 	{~waddr_gray_wsync[ADDR_WIDTH : ADDR_WIDTH - 1], 
	// 	  waddr_gray_wsync[ADDR_WIDTH-2:0]} == raddr_gray_wsync) 
	// 	? 1'b1 : 1'b0;
	// Correct Logic
	assign wfull = (
		{~waddr_ptr_gray[ADDR_WIDTH : ADDR_WIDTH - 1], 
		  waddr_ptr_gray[ADDR_WIDTH-2:0]} == raddr_gray_wsync) 
		  ? 1'b1 : 1'b0;

	// Empty
	// assign rempty = 
	// 	   (raddr_gray_rsync == waddr_gray_rsync) ? 1'b1 : 1'b0;
	// Correct Logic
	assign rempty = 
	       (raddr_ptr_gray == waddr_gray_rsync) ? 1'b1 : 1'b0;

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

/*************************************BIN2GRAY***************************************/
module bin2gray #(
	parameter WIDTH = 8 
)(
	input  [WIDTH - 1 : 0] bin_code,
	output [WIDTH - 1 : 0] gray_code
	
);
	generate
		genvar i;
		for (i = 0; i < WIDTH - 1; i = i + 1) begin: bin_to_gray
			assign gray_code[i] = bin_code[i] ^ bin_code[i+1];
		end
	endgenerate

	assign gray_code[WIDTH-1] = bin_code[WIDTH-1];

endmodule 

/*************************************GRAY2BIN***************************************/
module gray2bin #(
	parameter WIDTH = 8 
)(
	input  [WIDTH - 1 : 0] gray_code,
	output [WIDTH - 1 : 0] bin_code
);

	generate
		genvar i;
		for (i = 0; i < WIDTH - 1; i = i + 1) begin : gray_to_bin
			assign bin_code[i] = gray_code[i] ^ gray_code[i+1];
		end
	endgenerate

	assign bin_code[WIDTH-1] = gray_code[WIDTH-1];

endmodule 

/***********************************SYNCHRONIZE**************************************/
module sync_data #(
	parameter WIDTH = 8,
  	parameter SYNC_STAGE = 2
)(
  	input                  clk,
  	input                  rstn,
  	input  [WIDTH - 1 : 0] data_in,
  	output [WIDTH - 1 : 0] data_out
);
  
  	generate
		if (SYNC_STAGE == 1) begin : sync_stage_one
      		reg [WIDTH - 1 : 0] data_sync;
      		always @(posedge clk or negedge rstn) begin
        		if (~rstn) begin
          			data_sync <= {WIDTH{1'b0}};
				end 
				else begin
					data_sync <= data_in;
				end
      		end
      assign data_out = data_sync;
    	end
		else begin : sync_stage_more
			integer i;
			reg [SYNC_STAGE - 1 : 0][WIDTH - 1 : 0] data_sync;
			always @(posedge clk or negedge rstn) begin
				if (~rstn) begin
					data_sync <= {WIDTH{1'b0}};
				end 
				else begin
					data_sync[0] <= data_in;
					for (i = 1; i < SYNC_STAGE; i = i + 1) begin
						data_sync[i] <= data_sync[i-1];
					end
				end
			end
			assign data_out = data_sync[SYNC_STAGE-1];
		end
	endgenerate

endmodule
