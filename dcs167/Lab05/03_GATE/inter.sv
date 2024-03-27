module inter(
  // Input signals
  clk,
  rst_n,
  in_valid_1,
  in_valid_2,
  data_in_1,
  data_in_2,
  ready_slave1,
  ready_slave2,
  // Output signals
  valid_slave1,
  valid_slave2,
  addr_out,
  value_out,
  handshake_slave1,
  handshake_slave2
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid_1, in_valid_2;
input [6:0] data_in_1, data_in_2; 
input ready_slave1, ready_slave2;

output logic valid_slave1, valid_slave2;
output logic [2:0] addr_out, value_out;
output logic handshake_slave1, handshake_slave2;

logic handshake_bef1, handshake_bef2;
logic in1, in2;
logic in1_bef, in2_bef;
logic [1:0] cal_add, cal_val;
logic [6:0] data1, data2;
logic [6:0] data1_bef, data2_bef;
parameter S_idle = 2'd0;
parameter S_master1 = 2'd1;
parameter S_master2 = 2'd2;
parameter S_handshake = 2'd3;
logic [1:0] cur_state, next_state;

//---------------------------------------------------------------------
//   YOUR DESIGN
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cur_state <= S_idle;
		in1_bef <= 0;
		in2_bef <= 0;
		data1_bef <= 0;
		data2_bef <= 0;
		handshake_slave1 <= 0;
		handshake_slave2 <= 0;
	end
	else begin
		cur_state <= next_state;
		in1_bef <= in1;
		in2_bef <= in2;
		data1_bef <= data1;
		data2_bef <= data2;
		handshake_slave1 <= handshake_bef1;
		handshake_slave2 <= handshake_bef2;
	end
end


always_comb begin
	in1 = (in_valid_1)? 1 : in1_bef;
	in2 = (in_valid_2)? 1 : in2_bef;
	
	data1 = (in_valid_1)? data_in_1 : data1_bef;
	data2 = (in_valid_2)? data_in_2 : data2_bef;
	
	case(cur_state)
		S_idle : 
			if(in1) begin
				next_state = S_master1;
				in1 = 0;
			end
			else if(in2) begin
				next_state = S_master2;
				in2 = 0;
			end
			else
				next_state = cur_state;
		S_master1:
			if(data1[6]==0) begin
				if(valid_slave1 && ready_slave1) begin
					next_state = S_handshake;
					in1 = 0;
				end	
				else 
					next_state = cur_state;
			end
			else begin	
				if(valid_slave2 && ready_slave2) begin
					next_state = S_handshake;
					in1 = 0;
				end	
				else 
					next_state = cur_state;
			end
		S_master2:
			if(data2[6]==0) begin
				if(valid_slave1 && ready_slave1) begin
					next_state = S_handshake;
					in2 = 0;
				end	
				else 
					next_state = cur_state;
			end
			else begin	
				if(valid_slave2 && ready_slave2) begin
					next_state = S_handshake;
					in2 = 0;
				end	
				else 
					next_state = cur_state;
			end
		S_handshake:
			if(in1) next_state = S_master1;
			else if (in2) next_state = S_master2;
			else next_state = cur_state;
		default: next_state = cur_state;
	endcase
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		value_out <= 0;
		addr_out <= 0;
	end
	else begin
		if(cur_state == S_master1) begin
			value_out <= data1[2:0];
			addr_out <= data1[5:3];
		end
		else if(cur_state == S_master2) begin
			value_out <= data2[2:0];
			addr_out <= data2[5:3];
		end
		else begin
			value_out <= 0;
			addr_out <= 0;
		end
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		valid_slave1 <= 0;
		valid_slave2 <= 0;
	end
	else begin
		if(cur_state == S_master1) begin
			if(data1[6]==0) 
				valid_slave1 <= 1;
			else 
				valid_slave2 <= 1;
		end
		else if(cur_state == S_master2) begin
			if(data2[6]==0) 
				valid_slave1 <= 1;
			else 
				valid_slave2 <= 1;
		end
		else begin
			valid_slave1 <= 0;
			valid_slave2 <= 0;
		end
	end
end

assign handshake_bef1 = (valid_slave1 && ready_slave1)? 1 : 0;
assign handshake_bef2 = (valid_slave2 && ready_slave2)? 1 : 0;

endmodule
