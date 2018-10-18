`timescale 1ns/10ps
`define CYCLE      5.00         	 // Modify your clock period here
`define PAT1        "./pattern1.dat" // Master1 output data   
`define PAT2        "./pattern2.dat" // Master2 output data
`define EXP        "./golden1.dat"   // Memory stored data (ground truth), is used to verified your designed

module tb;

	// Inputs
	reg clk;
	reg rst_n;
	reg [7:0] data1_i;
	reg [7:0] data2_i;
	reg valid1_i;
	reg valid2_i;
	reg gnt_i;

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
		.data1_i(data1_i), 
		.data2_i(data2_i), 
		.valid1_i(valid1_i), 
		.valid2_i(valid2_i), 
		.data_o(data_o), 
		.req_o(req_o), 
		.gnt_i(gnt_i), 
		.stop1_o(stop1_o), 
		.stop2_o(stop2_o), 
		.valid_o(valid_o)
	);
	integer i, j, k;
	reg [8-1:0] pattern1 [0:99];
	reg [8-1:0] pattern2 [0:99];
	reg [8-1:0] golden [0:199];
	reg [8-1:0] mem [0:199];
	reg [8-1:0] golden_o;
	integer mem_cnt;
	
	always #`CYCLE clk = ~clk;	//cycle time is 10ns

	always @(negedge clk) begin
		if (valid_o) begin
			mem[mem_cnt] <= data_o;
			mem_cnt <= mem_cnt + 1;
		end
	end
	
	always @(*) begin
		if (req_o) begin
			//#(`CYCLE*15); gnt_i = 1;
			//#`CYCLE; gnt_i = 1;
			
			if (k>3) begin
				#`CYCLE; gnt_i = 1;
			end
			else begin
				#`CYCLE; gnt_i = 0;
			end
			
		end
		else begin
			#`CYCLE; gnt_i = 0;
		end
		
		golden_o = golden[mem_cnt];
	end
	
	

	initial begin
		//$sdf_annotate("tb_s.sdf",my_tb);
		//$fsdbDumpfile("tb.fsdb");
		//$fsdbDumpvars;
		$dumpfile("tb.vcd");
		$dumpvars;
		
		$readmemb(`PAT1, pattern1);
		$readmemb(`PAT2, pattern2);
		$readmemb(`EXP, golden);
		
		clk = 1;
		rst_n = 0;
		data1_i = 0;
		data2_i = 0;
		valid1_i = 0;
		valid2_i = 0;
		gnt_i = 0;
		mem_cnt = 0;
		
		#`CYCLE; rst_n = 1;
		
		i = 0; j = 0; k = 2;
		while ((i < 100) || (j < 101)) begin
			#(`CYCLE*2);
			// Master1
			if (!stop1_o && (k > 5)) begin
				valid1_i = 1;
				data1_i = pattern1[i];
				i = i + 1;
			end
			else begin
				valid1_i = 0;
			end
			
			// Master2
			if (!stop2_o && (k > 3)) begin
			//if (!stop2_o) begin
				valid2_i = 1;
				data2_i = pattern2[j];
				j = j + 1;
			end
			else begin
				valid2_i = 0;
			end
			
			if (k < 10)
				k = k + 1;
			else
				k = 0;
		end
		
		while (mem_cnt < 200) begin
			#`CYCLE;
		end
		
		for (i=0; i<200; i=i+1) begin
			if (golden[i] == mem[i])
				$display("Correct - i=%d, mem=%d, golden=%d",i,mem[i],golden[i]);
			else
				$display("Error - i=%d, mem=%d, golden=%d",i,mem[i],golden[i]);
		end
		$finish;
	end
      
endmodule
