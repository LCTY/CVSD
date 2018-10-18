module path(clk, rst_n, data1_i, data2_i, valid1_i, valid2_i, data_o, req_o, gnt_i, stop1_o, stop2_o, valid_o);

parameter DWIDTH = 8;
parameter FDEPTH = 5;
input clk;
input rst_n;
input [DWIDTH-1:0] data1_i;
input [DWIDTH-1:0] data2_i;
input valid1_i;
input valid2_i;
input gnt_i;
output reg req_o;
output reg stop1_o;
output reg stop2_o;
output [DWIDTH-1:0] data_o;
output reg valid_o;


wire [DWIDTH-1:0] fifo_o;
wire full, empty, almost_full, valid_i;
wire bypass;
wire read_i;
wire write_i;
reg [DWIDTH-1:0] data_i, data_i_bypass;

reg select;
reg [4-1:0] counter;

assign write_i = (bypass || (valid1_i && !stop1_o) || (valid2_i && !stop2_o)) ? 1'b1 : 1'b0;
assign valid_i = (valid1_i || valid2_i) ? 1'b1 : 1'b0;
assign bypass = (empty && gnt_i && valid_i) ? 1'b1 : 1'b0;
assign read_i = (bypass || (gnt_i && !empty)) ? 1'b1 : 1'b0;	// TODO: read_i == 1 when empty == 1 <-- this situation should not exist
//assign valid_o = (read_i) ? 1'b1 : 1'b0;
//assign data_o = (bypass) ? data_i_bypass : fifo_o;
assign data_o = fifo_o;

always@(*) begin
	if (select == 1'b0) begin	// Master 1
		if (full && !gnt_i) stop1_o = 1'b1;
		else stop1_o = 0;
		
		stop2_o = 1'b1;
	end
	else begin	 // Master 2
		stop1_o = 1'b1;
		
		if (full && !gnt_i) stop2_o = 1'b1;
		else stop2_o = 0;
	end
	
	if (select == 1'b0) data_i = data1_i;
	else data_i = data2_i;
end

always @(posedge clk, negedge rst_n)	begin
    if (!rst_n) begin
		counter <= 0;
		select <= 0;
		req_o <= 0;
		valid_o <= 0;
		data_i_bypass <= 0;
	end
	else begin
		if (valid_i) begin
			if (counter < 4'd9) begin
				counter <= counter + 1'b1;
				select <= select;
			end
			else begin
				counter <= 0;
				select <= ~select;
			end
			end
		else begin
			counter <= counter;
			select <= select;
		end
		
		if (valid_i || !empty || bypass) req_o <= 1'b1;
		else req_o <= 0;
		
		if (read_i || bypass) valid_o <= 1'b1;
		else valid_o <= 0;
		
		data_i_bypass <= data_i;
		
		//if (bypass) data_o <= data_i;
		//else data_o <= fifo_o;
		
		//if (((valid1_i && !stop1_o) || (valid2_i && !stop2_o)) && !bypass) write_i <= 1'b1;
		//else write_i <= 0;
		
		//if (gnt_i && !empty) read_i <= 1'b1;
		//else read_i <= 0;
		
		//if (valid1_i || valid2_i) valid_i <= 1'b1;
		//else valid_i <= 0;
		
		//if (empty && gnt_i && valid_i) bypass <= 1'b1;
		//else bypass <= 0;
	end
end

fifo fifo_inst (.data_i(data_i), .write_i(write_i), .read_i(read_i),
                .full_o(full), .empty_o(empty),
                .data_o(fifo_o), .clk(clk), .rst_n(rst_n));

endmodule