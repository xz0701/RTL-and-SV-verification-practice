`timescale 1ns/1ns

module JC_counter(
   input                clk ,
   input                rst_n,
 
   output reg [3:0]     Q  
);
   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         Q <= 4'b0;
      end
      else begin
         Q <= {~Q[0], Q[3 : 1]};
      end
   end
endmodule