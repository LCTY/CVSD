`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:25:58 10/15/2018
// Design Name:   fifo
// Module Name:   D:/CVSD/HW2/fifo_tb.v
// Project Name:  HW2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fifo
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fifo_tb;

	// Inputs
	reg [7:0] data_i;
	reg write_i;
	reg read_i;
	reg clk;
	reg rst_n;

	// Outputs
	wire full_o;
	wire empty_o;
	wire [7:0] data_o;

	// Instantiate the Unit Under Test (UUT)
	fifo uut (
		.data_i(data_i), 
		.write_i(write_i), 
		.read_i(read_i), 
		.full_o(full_o), 
		.empty_o(empty_o), 
		.data_o(data_o), 
		.clk(clk), 
		.rst_n(rst_n)
	);
	
	always #5 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		data_i = 9;
		write_i = 0;
		read_i = 0;
		clk = 1;
		rst_n = 0;

		// Wait 100 ns for global reset to finish
		#5; rst_n = 1; write_i = 1; data_i = 1;
		#10; data_i = 2;
		#10; data_i = 3;
		#10; data_i = 4;
		#10; data_i = 5; read_i = 1;
		#10; data_i = 6;
		#10; data_i = 7;
		#10; data_i = 8;
		#10; write_i = 0; read_i = 1;
		#40; write_i = 1; read_i = 1;
		#10; data_i = 1;
		#10; data_i = 2;
		#10; data_i = 3;
		#10; data_i = 4;
		#10; data_i = 5;
		#10; data_i = 6;
        
		// Add stimulus here

	end
      
endmodule

