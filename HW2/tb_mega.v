`timescale 1ns/10ps
`define CYCLE		10         	 // Modify your clock period here
`define H_CYCLE		5
`define PAT1		"./pattern1.dat" // Master1 output data   
`define PAT2		"./pattern2.dat" // Master2 output data
`define EXP			"./golden1.dat"   // Memory stored data (ground truth), is used to verified your designed
`define TIME_OUT	6000000

module tb_mega;
	parameter PAT_NUM = 100;

	// Inputs
	reg clk;
	reg rst_n;
	reg [7:0] data1_i, data1_i_d;
	reg [7:0] data2_i, data2_i_d;
	reg valid1_i, valid1_i_d;
	reg valid2_i, valid2_i_d;
	reg gnt_i, gnt_i_d;

	// Outputs
	wire [7:0] data_o;
	wire req_o;
	wire stop1_o;
	wire stop2_o;
	wire valid_o;

	// Instantiate the Unit Under Test (UUT)
	path uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.data1_i(data1_i_d), 
		.data2_i(data2_i_d), 
		.valid1_i(valid1_i_d), 
		.valid2_i(valid2_i_d), 
		.data_o(data_o), 
		.req_o(req_o), 
		.gnt_i(gnt_i_d), 
		.stop1_o(stop1_o), 
		.stop2_o(stop2_o), 
		.valid_o(valid_o)
	);
	integer i, j, k, k1, k2, k3;
	reg [8-1:0] pattern1 [0:99];
	reg [8-1:0] pattern2 [0:99];
	reg [8-1:0] golden [0:199];
	reg [8-1:0] mem [0:199];
	reg [8-1:0] golden_o;
	integer mem_cnt;
	
	always #`H_CYCLE clk = ~clk;	//cycle time is 10ns

	always @(negedge clk) begin
		data1_i <= data1_i_d;
		data2_i <= data2_i_d;
		valid1_i <= valid1_i_d;
		valid2_i <= valid2_i_d;
		gnt_i <= gnt_i_d;
	
		if (valid_o && rst_n) begin
			mem[mem_cnt] <= data_o;
			mem_cnt <= mem_cnt + 1;
		end
	end
	
	initial #(`TIME_OUT) $finish;

	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,tb_mega,"+mda");
		
		$readmemb(`PAT1, pattern1);
		$readmemb(`PAT2, pattern2);
		$readmemb(`EXP, golden);
		
		for (k3=0; k3<1; k3=k3+1) begin
		for (k2=0; k2<1; k2=k2+1) begin
		for (k1=0; k1<1; k1=k1+1) begin
			clk = 1;
			rst_n = 0;
			data1_i = 0; data1_i_d = 0;
			data2_i = 0; data2_i_d = 0;
			valid1_i = 0; valid1_i_d = 0;
			valid2_i = 0; valid2_i_d = 0;
			gnt_i = 0; gnt_i_d = 0;
			mem_cnt = 0;
			i = 0; j = 0; k = 0;
			
			#(`H_CYCLE*5) rst_n = 1; clk = 1;
			
			while (mem_cnt < (PAT_NUM*2)) begin
				// Master1
				if ((i < PAT_NUM) && stop1_o == 0 && (k >= k1)) begin
					valid1_i_d = 1;
					data1_i_d = pattern1[i];
					i = i + 1;
				end
				else begin
					valid1_i_d = 0;
				end
				
				// Master2
				if ((j < PAT_NUM) && stop2_o == 0 && (k > k2)) begin
					valid2_i_d = 1;
					data2_i_d = pattern2[j];
					j = j + 1;
				end
				else begin
					valid2_i_d = 0;
				end
				
				// Memory
				if (req_o && (k > k3))
					gnt_i_d = 1;
				else
					gnt_i_d = 0;
				
				
				if (k < 9)
					k = k + 1;
				else
					k = 0;
				
				
				#(`CYCLE);
			end
			
			for (i=0; i<(PAT_NUM*2); i=i+1) begin
				/*
				if (golden[i] == mem[i])
					$display("[Correct] i=%d, mem=%d, golden=%d",i,mem[i],golden[i]);
				else
					$display("[Error] i=%d, mem=%d, golden=%d",i,mem[i],golden[i]);
				*/
				if (golden[i] !== mem[i]) begin
					$display("[Error] k1:%d, i=%d, mem=%d, golden=%d",k1,i,mem[i],golden[i]);
				end
				
			end
		end
		end
		end
		
		$finish;
	end
      
endmodule
