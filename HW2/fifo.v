module fifo (data_i, write_i, read_i, full_o, empty_o, data_o, clk, rst_n);
parameter DWIDTH = 8, FDEPTH = 5;
//parameter CWIDTH = $clog2(FDEPTH);

input [DWIDTH-1:0] data_i;
input write_i, read_i;
output reg full_o, empty_o;
output reg [DWIDTH-1:0] data_o;
input clk, rst_n;


//reg full, empty;
reg [DWIDTH-1:0] mem [FDEPTH-1:0];

reg [3-1:0] counter;
reg [3-1:0] write_add, read_add;


// should consider the condition of (write_i && read_i), (write_i), (read_i) 
always@(*) begin
	if (counter == 0) empty_o = 1'b1;
	else empty_o = 0;
	
	if (counter == 3'd5) full_o = 1'b1;
	else full_o = 0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		data_o <= 0;
		counter <= 0;
		read_add <= 0;
		write_add <= 0;
	end
	else begin
		case ({write_i,read_i})
			2'b00: begin	// IDLE
				counter <= counter;
				
				data_o <= data_o;
				read_add <= read_add;
				write_add <= write_add;
			end
			2'b01: begin	// READ
				if (counter == 0) begin	// EMPTY, CAN'T READ
					data_o <= data_o;
					counter <= counter;
					read_add <= read_add;
				end
				else begin
					data_o <= mem[read_add];
					counter <= counter - 1'b1;
					read_add <= (read_add == 3'd4) ? 3'd0 : read_add + 1'b1;
				end
				
				write_add <= write_add;
			end
			2'b10: begin	// WRITE
				if (counter == 3'd5) begin	// FULL, CAN'T WRITE
					counter <= counter;
					write_add <= write_add;
				end
				else begin
					mem[write_add] <= data_i;
					counter <= counter + 1'b1;
					write_add <= (write_add == 3'd4) ? 3'd0 : write_add + 1'b1;
				end
				
				read_add <= read_add;
			end
			2'b11: begin	// READ & WRITE
				if (counter == 0) begin // EMPTY, READ INPUT
					data_o <= data_i;
					
					counter <= counter;
					read_add <= read_add;
					write_add <= write_add;
				end
				else if (counter == 3'd5) begin // FULL, CAN'T WRITE, ONLY READ
					data_o <= mem[read_add];
					counter <= counter;
					read_add <= (read_add == 3'd4) ? 3'd0 : read_add + 1'b1;
					write_add <= write_add;
				end
				else begin
					mem[write_add] <= data_i;
					data_o <= mem[read_add];
					counter <= counter;
					read_add <= (read_add == 3'd4) ? 3'd0 : read_add + 1'b1;
					write_add <= (write_add == 3'd4) ? 3'd0 : write_add + 1'b1;
				end
			end
		endcase
	end
end

endmodule
