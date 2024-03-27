module DCT(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_data,
	// Output signals
	out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input        clk, rst_n, in_valid;
input signed [7:0]in_data;
output logic out_valid;
output logic signed[9:0]out_data;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------
integer i,j;
// parameter IDLE = 0;
// parameter INPUT = 1;
// parameter OUTPUT = 4;
logic signed [7:0]dctmtx[0:3][0:3];

logic [2:0]STATE,NS;
logic [3:0]input_cnt;
logic signed [7:0]inbuffer[0:3][0:3];
logic [3:0]output_cnt;
logic signed [9:0]outbuffer[0:3][0:3];
//finish your declaration

logic [4:0] counter, counter_nxt;

logic signed [9:0] mul1 [3:0];
logic signed [9:0] mul2 [3:0];
logic signed [31:0] result [3:0];
logic signed [9:0] outbuffer_nxt [0:3][0:3];

logic out_valid_nxt;
logic signed [9:0] out_data_nxt;

logic signed [9:0] outbuffer_1 [0:3][0:3];
logic signed [9:0] outbuffer_1_nxt [0:3][0:3];


parameter [1:0] IDLE = 0, INPUT = 1, OUTPUT = 2, CALC = 3;


//---------------------------------------------------------------------
//   YOUR DESIGN                         
//---------------------------------------------------------------------
assign dctmtx[0][0] = 8'b01000000;
assign dctmtx[0][1] = 8'b01000000;
assign dctmtx[0][2] = 8'b01000000;
assign dctmtx[0][3] = 8'b01000000;
assign dctmtx[1][0] = 8'b01010011;
assign dctmtx[1][1] = 8'b00100010;
assign dctmtx[1][2] = 8'b11011110;
assign dctmtx[1][3] = 8'b10101101;
assign dctmtx[2][0] = 8'b01000000;
assign dctmtx[2][1] = 8'b11000000;
assign dctmtx[2][2] = 8'b11000000;
assign dctmtx[2][3] = 8'b01000000;
assign dctmtx[3][0] = 8'b00100010;
assign dctmtx[3][1] = 8'b10101101;
assign dctmtx[3][2] = 8'b01010011;
assign dctmtx[3][3] = 8'b11011110;


always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		STATE<=0;
		out_valid<=0;
		out_data<=0;
	end
	else begin
		STATE<=NS;
		out_valid<= (STATE==OUTPUT);
		out_data<= (STATE==OUTPUT ? outbuffer[output_cnt[3:2]][output_cnt[1:0]] : 0);
	end
end

always_comb begin
	outbuffer_nxt[0][0] = outbuffer[0][0];
	outbuffer_nxt[0][1] = outbuffer[0][1];
	outbuffer_nxt[0][2] = outbuffer[0][2];
	outbuffer_nxt[0][3] = outbuffer[0][3];
	outbuffer_nxt[1][0] = outbuffer[1][0];
	outbuffer_nxt[1][1] = outbuffer[1][1];
	outbuffer_nxt[1][2] = outbuffer[1][2];
	outbuffer_nxt[1][3] = outbuffer[1][3];
	outbuffer_nxt[2][0] = outbuffer[2][0];
	outbuffer_nxt[2][1] = outbuffer[2][1];
	outbuffer_nxt[2][2] = outbuffer[2][2];
	outbuffer_nxt[2][3] = outbuffer[2][3];
	outbuffer_nxt[3][0] = outbuffer[3][0];
	outbuffer_nxt[3][1] = outbuffer[3][1];
	outbuffer_nxt[3][2] = outbuffer[3][2];
	outbuffer_nxt[3][3] = outbuffer[3][3];

	outbuffer_1_nxt[0][0] = outbuffer_1[0][0];
	outbuffer_1_nxt[0][1] = outbuffer_1[0][1];
	outbuffer_1_nxt[0][2] = outbuffer_1[0][2];
	outbuffer_1_nxt[0][3] = outbuffer_1[0][3];
	outbuffer_1_nxt[1][0] = outbuffer_1[1][0];
	outbuffer_1_nxt[1][1] = outbuffer_1[1][1];
	outbuffer_1_nxt[1][2] = outbuffer_1[1][2];
	outbuffer_1_nxt[1][3] = outbuffer_1[1][3];
	outbuffer_1_nxt[2][0] = outbuffer_1[2][0];
	outbuffer_1_nxt[2][1] = outbuffer_1[2][1];
	outbuffer_1_nxt[2][2] = outbuffer_1[2][2];
	outbuffer_1_nxt[2][3] = outbuffer_1[2][3];
	outbuffer_1_nxt[3][0] = outbuffer_1[3][0];
	outbuffer_1_nxt[3][1] = outbuffer_1[3][1];
	outbuffer_1_nxt[3][2] = outbuffer_1[3][2];
	outbuffer_1_nxt[3][3] = outbuffer_1[3][3];

	mul1[0] = 0; mul2[0] = 0; result[0] = 0;
	mul1[1] = 0; mul2[1] = 0; result[1] = 0;
	mul1[2] = 0; mul2[2] = 0; result[2] = 0;
	mul1[3] = 0; mul2[3] = 0; result[3] = 0;

	counter_nxt = counter + 1;

	NS = STATE;

	out_valid_nxt = 0;
	out_data_nxt  = 0;
	case(STATE)
		IDLE:begin
			if(in_valid) NS = INPUT;
		end
		INPUT:begin
			if(~in_valid) begin
				NS = CALC;
				counter_nxt = 0;
			end
		end
		//next state start matrix multiplication
		//finish your FSM
		CALC: begin
			case (counter[4]) 
				0: begin
					mul1[0] = dctmtx[counter[3:2]][0];
					mul1[1] = dctmtx[counter[3:2]][1];
					mul1[2] = dctmtx[counter[3:2]][2];
					mul1[3] = dctmtx[counter[3:2]][3];

					mul2[0] = inbuffer[0][counter[1:0]];
					mul2[1] = inbuffer[1][counter[1:0]];
					mul2[2] = inbuffer[2][counter[1:0]];
					mul2[3] = inbuffer[3][counter[1:0]];
				end
				1: begin
					mul1[0] = outbuffer_1[counter[3:2]][0];
					mul1[1] = outbuffer_1[counter[3:2]][1];
					mul1[2] = outbuffer_1[counter[3:2]][2];
					mul1[3] = outbuffer_1[counter[3:2]][3];

					mul2[0] = dctmtx[counter[1:0]][0];
					mul2[1] = dctmtx[counter[1:0]][1];
					mul2[2] = dctmtx[counter[1:0]][2];
					mul2[3] = dctmtx[counter[1:0]][3];
				end
			endcase

			result[0] = mul1[0] * mul2[0];
			result[1] = mul1[1] * mul2[1];
			result[2] = mul1[2] * mul2[2];
			result[3] = mul1[3] * mul2[3];

			case (counter[4]) 
				0: begin
					outbuffer_1_nxt[counter[3:2]][counter[1:0]] = (result[0] + result[1] + result[2] + result[3]) / 128;
				end
				1: begin
					outbuffer_nxt[counter[3:2]][counter[1:0]] = (result[0] + result[1] + result[2] + result[3]) / 128;
				end
			endcase
			
			if (counter == 31) begin
				NS = OUTPUT;
			end
		end
	
		OUTPUT:begin
			if(output_cnt==15) NS = IDLE;
		end
	endcase
end

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		input_cnt<=0;
	end
	else begin
		if(in_valid)begin
			input_cnt<=input_cnt+1;
		end
		else begin
			input_cnt<=0;
		end
	end
end

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		for(i=0;i<4;i=i+1)begin
			for(j=0;j<4;j=j+1)begin
				inbuffer[i][j]<=0;
			end
		end
	end
	else begin
		if(in_valid)begin
			inbuffer[input_cnt[3:2]][input_cnt[1:0]]<=in_data;
		end
	end
end

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		output_cnt<=0;
	end
	else begin
		if(STATE==OUTPUT)begin
			output_cnt<=output_cnt+1;
		end
		else begin
			output_cnt<=0;
		end
	end
end

always_ff @(posedge clk) begin
	counter <= counter_nxt;
	outbuffer[0][0] <= outbuffer_nxt[0][0];
	outbuffer[0][1] <= outbuffer_nxt[0][1];
	outbuffer[0][2] <= outbuffer_nxt[0][2];
	outbuffer[0][3] <= outbuffer_nxt[0][3];

	outbuffer[1][0] <= outbuffer_nxt[1][0];
	outbuffer[1][1] <= outbuffer_nxt[1][1];
	outbuffer[1][2] <= outbuffer_nxt[1][2];
	outbuffer[1][3] <= outbuffer_nxt[1][3];

	outbuffer[2][0] <= outbuffer_nxt[2][0];
	outbuffer[2][1] <= outbuffer_nxt[2][1];
	outbuffer[2][2] <= outbuffer_nxt[2][2];
	outbuffer[2][3] <= outbuffer_nxt[2][3];

	outbuffer[3][0] <= outbuffer_nxt[3][0];
	outbuffer[3][1] <= outbuffer_nxt[3][1];
	outbuffer[3][2] <= outbuffer_nxt[3][2];
	outbuffer[3][3] <= outbuffer_nxt[3][3];

	outbuffer_1[0][0] <= outbuffer_1_nxt[0][0];
	outbuffer_1[0][1] <= outbuffer_1_nxt[0][1];
	outbuffer_1[0][2] <= outbuffer_1_nxt[0][2];
	outbuffer_1[0][3] <= outbuffer_1_nxt[0][3];

	outbuffer_1[1][0] <= outbuffer_1_nxt[1][0];
	outbuffer_1[1][1] <= outbuffer_1_nxt[1][1];
	outbuffer_1[1][2] <= outbuffer_1_nxt[1][2];
	outbuffer_1[1][3] <= outbuffer_1_nxt[1][3];

	outbuffer_1[2][0] <= outbuffer_1_nxt[2][0];
	outbuffer_1[2][1] <= outbuffer_1_nxt[2][1];
	outbuffer_1[2][2] <= outbuffer_1_nxt[2][2];
	outbuffer_1[2][3] <= outbuffer_1_nxt[2][3];
	
	outbuffer_1[3][0] <= outbuffer_1_nxt[3][0];
	outbuffer_1[3][1] <= outbuffer_1_nxt[3][1];
	outbuffer_1[3][2] <= outbuffer_1_nxt[3][2];
	outbuffer_1[3][3] <= outbuffer_1_nxt[3][3];
end
//input matrix stored in inbuffer
//output matrix should store in outbuffer
//finish your matrix multiplier











endmodule