module I2S(
	// Input signals
	clk,
	rst_n,
	in_valid,
	SD,
	WS,
	// Output signals
	out_valid,
	out_left,
	out_right
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input SD, WS;

output logic        out_valid;
output logic [31:0] out_left, out_right;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

parameter [1:0] IDLE = 2, L_RCV = 1, R_RCV = 0;
logic [1:0]  state, state_nxt;
logic [1:0]  sel, sel_nxt;
logic [32:0] buffer, buffer_nxt;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

// Transition Logic
always_comb begin
	buffer_nxt = out_valid ? {buffer[0], SD & in_valid} : {buffer[31:0], SD & in_valid};

	sel_nxt = 0;
	state_nxt = state;
	case(state) 
		IDLE: begin
			if (in_valid) state_nxt = WS ? R_RCV : L_RCV;
		end
		L_RCV: begin
			if (!in_valid)	begin 
				state_nxt = IDLE;  sel_nxt = 2'b10;
			end 
			else if (WS)	begin 
				state_nxt = R_RCV; sel_nxt = 2'b10;
			end
		end
		R_RCV: begin
			if (!in_valid) 	begin 
				state_nxt = IDLE;  sel_nxt = 2'b01;
			end 
			else if (!WS) 	begin 
				state_nxt = L_RCV; sel_nxt = 2'b01;
			end  
		end
	endcase
end

// Registers
always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else 		state <= state_nxt;
end

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) buffer <= 0;
	else 		buffer <= buffer_nxt;
end

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) sel <= 0;
	else 		sel <= sel_nxt;
end

// Output logic
always_comb begin
	out_valid = |sel;
	out_left = 0;
	out_right = 0;

	if 		(sel[0]) out_right = buffer[32:1];
	else if (sel[1]) out_left  = buffer[32:1]; 
end

endmodule