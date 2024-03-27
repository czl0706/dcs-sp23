module Conv(
	// Input signals
	clk,
	rst_n,
	filter_valid,
	image_valid,
	filter_size,
	image_size,
	pad_mode,
	act_mode,
	in_data,
	// Output signals
	out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, image_valid, filter_valid, filter_size, pad_mode, act_mode;
input [3:0] image_size;
input signed [7:0] in_data;
output logic out_valid;
output logic signed [15:0] out_data;

//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------

parameter [1:0] {PARAMS};
logic [1:0] state, state_nxt;
logic [2:0] counter, counter_nxt;
logic [3:0] conv_counter, conv_counter_nxt;
logic [3:0] v_cnt, v_cnt_nxt;

logic signed [7:0] filter [0:4][0:4];
logic signed [7:0] filter_nxt [0:4][0:4];

logic signed [7:0] image_in [0:4][0:4];
logic signed [7:0] image_in_nxt [0:4][0:4];

logic signed [15:0] conv_result_A [0:4][0:4];
logic signed [15:0] conv_result_A_nxt [0:4][0:4];

logic signed [3+15:0] conv_result [0:4];
logic signed [3+15:0] conv_result_nxt [0:4];

logic signed [5+15:0] conv_result_B;
logic signed [5+15:0] conv_result_B_nxt;

logic signed [7:0] image_buffer [0:4][0:11];
logic signed [7:0] image_buffer_nxt [0:4][0:11];

logic conv_enable, conv_enable_nxt;
logic sum_enable1, sum_enable1_nxt;
logic sum_enable, sum_enable_nxt;
logic out_enable, out_enable_nxt;
 
logic signed [5+15:0] conv_sum;
logic signed [5+15:0] conv_sum_nxt;

logic out_valid_nxt;
logic signed [15:0] out_data_nxt;
 
logic filter_size_reg, pad_mode_reg, act_mode_reg;
logic filter_size_reg_nxt, pad_mode_reg_nxt, act_mode_reg_nxt;
logic [3:0] image_size_reg, image_size_reg_nxt;

task reset_task;
	state_nxt = state;
	filter_size_reg_nxt = filter_size_reg;
	pad_mode_reg_nxt 	= pad_mode_reg;
	act_mode_reg_nxt 	= act_mode_reg;
	image_size_reg_nxt 	= image_size_reg;

	conv_enable_nxt = conv_enable;
	conv_result_nxt[0] = 0;
	conv_result_nxt[1] = 0;
	conv_result_nxt[2] = 0;
	conv_result_nxt[3] = 0;
	conv_result_nxt[4] = 0;

	conv_result_B_nxt = conv_result_B;

	// pipeline chain
	sum_enable1_nxt = sum_enable1;
	sum_enable_nxt = sum_enable1;
	out_enable_nxt = sum_enable;

	out_valid_nxt = 0;
	out_data_nxt = 0;

	conv_sum_nxt = 0;

	for (integer i = 0; i < 5; i = i + 1) begin
		for (integer j = 0; j < 12; j = j + 1) begin
			image_buffer_nxt[i][j] = image_buffer[i][j];
		end
	end

	for (integer i = 0; i < 5; i = i + 1) begin
		for (integer j = 0; j < 5; j = j + 1) begin
			filter_nxt[i][j] = filter[i][j];
		end
	end

	for (integer i = 0; i < 5; i = i + 1) begin
		for (integer j = 0; j < 5; j = j + 1) begin
			image_in_nxt[i][j] = 0;
		end
	end

	for (integer i = 0; i < 5; i = i + 1) begin
		for (integer j = 0; j < 5; j = j + 1) begin
			conv_result_A_nxt[i][j] = conv_result_A[i][j];
		end
	end
endtask

always_comb begin
	counter_nxt = counter + 1;
	conv_counter_nxt = conv_counter + 1;
	v_cnt_nxt = v_cnt;
	reset_task;

	case (state)
		IDLE: begin
			counter_nxt = 1;
			v_cnt_nxt	= 0;
			conv_enable_nxt = 0;
			if (image_valid) begin
				for (integer i = 0; i < 5; i = i + 1) begin
					for (integer j = 0; j < 12; j = j + 1) begin
						image_buffer_nxt[i][j] = 0;
					end
				end
				if (filter_size_reg) begin
					state_nxt = PROC5;
					image_buffer_nxt[2][0] = pad_mode_reg ? in_data : 0;
					image_buffer_nxt[3][0] = pad_mode_reg ? in_data : 0;
					image_buffer_nxt[4][0] = pad_mode_reg ? in_data : 0;

					image_buffer_nxt[2][1] = pad_mode_reg ? in_data : 0;
					image_buffer_nxt[3][1] = pad_mode_reg ? in_data : 0;
					image_buffer_nxt[4][1] = pad_mode_reg ? in_data : 0;

					image_buffer_nxt[2][2] = pad_mode_reg ? in_data : 0;
					image_buffer_nxt[3][2] = pad_mode_reg ? in_data : 0;

					image_buffer_nxt[4][2] = in_data;
				end
				else begin
					state_nxt = PROC3;
					image_buffer_nxt[2][2] = pad_mode_reg ? in_data : 0;
					image_buffer_nxt[3][2] = in_data;

					image_buffer_nxt[2][1] = pad_mode_reg ? in_data : 0;
					image_buffer_nxt[3][1] = pad_mode_reg ? in_data : 0;
				end
			end
			else if (filter_valid) begin
				filter_size_reg_nxt = filter_size;
				pad_mode_reg_nxt 	= pad_mode;
				act_mode_reg_nxt 	= act_mode;
				image_size_reg_nxt 	= image_size;
				
				if (filter_size) begin // 5x5
					filter_nxt[0][0] = in_data;
				end
				else begin // 3x3
					filter_nxt[1][1] = in_data;
					
					filter_nxt[0][0] = 0;
					filter_nxt[0][1] = 0;
					filter_nxt[0][2] = 0;
					filter_nxt[0][3] = 0;
					filter_nxt[0][4] = 0;
					filter_nxt[1][0] = 0;
					filter_nxt[1][4] = 0;
					filter_nxt[2][0] = 0;
					filter_nxt[2][4] = 0;
					filter_nxt[3][0] = 0;
					filter_nxt[3][4] = 0;
					filter_nxt[4][0] = 0;
					filter_nxt[4][1] = 0;
					filter_nxt[4][2] = 0;
					filter_nxt[4][3] = 0;
					filter_nxt[4][4] = 0;
				end
				state_nxt = CONF;
			end
		end
		CONF: begin
			if (filter_size_reg) begin // 5x5
				case (counter) inside
					[0:4]: 
					case (v_cnt) inside
						[0:4]: filter_nxt[v_cnt][counter] = in_data;
					endcase
				endcase
				
				if (counter == 4) begin
					counter_nxt = 0;
					v_cnt_nxt = v_cnt + 1;

					if (v_cnt == 4) begin
						state_nxt = IDLE;
					end
				end
			end
			else begin // 3x3
				case (counter) inside
					[0:2]: 
					case (v_cnt) inside
						[0:2]: filter_nxt[v_cnt + 1][counter + 1] = in_data;
					endcase
				endcase
				
				if (counter == 2) begin
					counter_nxt = 0;
					v_cnt_nxt = v_cnt + 1;

					if (v_cnt == 2) begin
						state_nxt = IDLE;
					end
				end
			end
		end
		PROC3: begin
// case (counter) inside [0:7]: begin
			if (v_cnt == 0) begin
				image_buffer_nxt[1][counter + 2] = image_buffer[2][counter + 2];
				image_buffer_nxt[2][counter + 2] = pad_mode_reg ? in_data : 0;
				image_buffer_nxt[3][counter + 2] = in_data;
			end
			else if (v_cnt >= image_size_reg) begin
				image_buffer_nxt[1][counter + 2] = image_buffer[2][counter + 2]; 
				image_buffer_nxt[2][counter + 2] = image_buffer[3][counter + 2]; 
				image_buffer_nxt[3][counter + 2] = pad_mode_reg ? image_buffer[3][counter + 2] : 0;
			end
			else begin
				image_buffer_nxt[1][counter + 2] = image_buffer[2][counter + 2]; 
				image_buffer_nxt[2][counter + 2] = image_buffer[3][counter + 2]; 
				image_buffer_nxt[3][counter + 2] = in_data;
			end
// end endcase

			if (counter == 0) begin
				image_buffer_nxt[1][1] = image_buffer[2][1]; 
				image_buffer_nxt[2][1] = image_buffer[3][1]; 
				image_buffer_nxt[3][1] = pad_mode_reg ? (v_cnt >= image_size_reg ? image_buffer[3][1]: in_data) : 0;
			end
			else if (counter == image_size_reg - 1) begin
				case (image_size_reg) inside
					[3: 8]: begin
						image_buffer_nxt[1][image_size_reg + 2] = image_buffer[2][image_size_reg + 2]; 
						image_buffer_nxt[2][image_size_reg + 2] = 
							v_cnt == 0 ? pad_mode_reg ? in_data : 0 : image_buffer[3][image_size_reg + 2];
						image_buffer_nxt[3][image_size_reg + 2] = pad_mode_reg ? (v_cnt >= image_size_reg ? image_buffer[3][image_size_reg + 2]: in_data) : 0;
					end
				endcase
			end

			if (v_cnt == 1 && counter == 0) begin
				conv_enable_nxt = 1;
				conv_counter_nxt = 0;
			end

			if (counter == image_size_reg - 1) begin
				v_cnt_nxt = v_cnt + 1;
				counter_nxt = 0;
			end
		end	
		PROC5: begin
case (counter) inside [0:7]: begin
			if (v_cnt == 0) begin
				image_buffer_nxt[2][counter + 2] = pad_mode_reg ? in_data : 0;
				image_buffer_nxt[3][counter + 2] = pad_mode_reg ? in_data : 0;
				image_buffer_nxt[4][counter + 2] = in_data;
			end
			else if (v_cnt >= image_size_reg) begin
				if (image_size_reg != 3) begin
					image_buffer_nxt[0][counter + 2] = image_buffer[1][counter + 2]; 
					image_buffer_nxt[1][counter + 2] = image_buffer[2][counter + 2]; 
					image_buffer_nxt[2][counter + 2] = image_buffer[3][counter + 2]; 
					image_buffer_nxt[3][counter + 2] = image_buffer[4][counter + 2]; 
					image_buffer_nxt[4][counter + 2] = pad_mode_reg ? image_buffer[4][counter + 2] : 0;
				end
			end
			else begin
				image_buffer_nxt[0][counter + 2] = image_buffer[1][counter + 2]; 
				image_buffer_nxt[1][counter + 2] = image_buffer[2][counter + 2]; 
				image_buffer_nxt[2][counter + 2] = image_buffer[3][counter + 2]; 
				image_buffer_nxt[3][counter + 2] = image_buffer[4][counter + 2]; 
				image_buffer_nxt[4][counter + 2] = in_data;
			end

			if (counter == 0) begin
				image_buffer_nxt[0][0] = image_buffer[1][0]; 
				image_buffer_nxt[1][0] = image_buffer[2][0]; 
				image_buffer_nxt[2][0] = image_buffer[3][0]; 
				image_buffer_nxt[3][0] = image_buffer[4][0]; 
				image_buffer_nxt[4][0] = pad_mode_reg ? (v_cnt >= image_size_reg ? image_buffer[4][0]: in_data) : 0;

				image_buffer_nxt[0][1] = image_buffer[1][1]; 
				image_buffer_nxt[1][1] = image_buffer[2][1]; 
				image_buffer_nxt[2][1] = image_buffer[3][1]; 
				image_buffer_nxt[3][1] = image_buffer[4][1]; 
				image_buffer_nxt[4][1] = pad_mode_reg ? (v_cnt >= image_size_reg ? image_buffer[4][1]: in_data) : 0;
			end
			else if (counter == image_size_reg - 1) begin
				image_buffer_nxt[0][image_size_reg + 2] = image_buffer[1][image_size_reg + 2]; 
				image_buffer_nxt[1][image_size_reg + 2] = image_buffer[2][image_size_reg + 2]; 
				image_buffer_nxt[2][image_size_reg + 2] = 
					v_cnt == 0 ? pad_mode_reg ? in_data : 0 : image_buffer[3][image_size_reg + 2];  
				image_buffer_nxt[3][image_size_reg + 2] = 
					v_cnt == 0 ? pad_mode_reg ? in_data : 0 : image_buffer[4][image_size_reg + 2]; 
				image_buffer_nxt[4][image_size_reg + 2] = 
					pad_mode_reg ? (v_cnt >= image_size_reg ? image_buffer[4][image_size_reg + 2]: in_data) : 0;

				image_buffer_nxt[0][image_size_reg + 3] = image_buffer[1][image_size_reg + 3]; 
				image_buffer_nxt[1][image_size_reg + 3] = image_buffer[2][image_size_reg + 3]; 
				image_buffer_nxt[2][image_size_reg + 3] = 
					v_cnt == 0 ? pad_mode_reg ? in_data : 0 : image_buffer[3][image_size_reg + 3]; 
				image_buffer_nxt[3][image_size_reg + 3] = 
					v_cnt == 0 ? pad_mode_reg ? in_data : 0 : image_buffer[4][image_size_reg + 3]; 
				image_buffer_nxt[4][image_size_reg + 3] = 
					pad_mode_reg ? (v_cnt >= image_size_reg ? image_buffer[4][image_size_reg + 3]: in_data) : 0;
			end

			if (v_cnt == 2 && counter == 1) begin
				conv_enable_nxt = 1;
				conv_counter_nxt = 0;
			end

			if (counter == image_size_reg - 1) begin
				v_cnt_nxt = v_cnt + 1;
				counter_nxt = 0;
			end
end endcase	
		end
	endcase

	if (conv_enable) begin
		if (filter_size_reg) begin
			if (conv_counter == 2) begin
				sum_enable1_nxt = 1;
			end
			if (image_size_reg >= 5 && v_cnt == image_size_reg + 2 && conv_counter == 2) begin
				sum_enable1_nxt = 0;
				state_nxt = IDLE;
			end

			if (v_cnt == 6 && image_size_reg == 3 && conv_counter == 2) begin
				sum_enable1_nxt = 0;
				state_nxt = IDLE;
			end

			if (v_cnt == 7 && image_size_reg == 4 && conv_counter == 2) begin
				sum_enable1_nxt = 0;
				state_nxt = IDLE;
			end
			
			if (image_size_reg == 3 && conv_counter == 2) begin
				image_buffer_nxt[0][2] = image_buffer[1][2]; 
				image_buffer_nxt[1][2] = image_buffer[2][2]; 
				image_buffer_nxt[2][2] = image_buffer[3][2]; 
				image_buffer_nxt[3][2] = image_buffer[4][2]; 
				image_buffer_nxt[4][2] = pad_mode_reg ? image_buffer[4][2] : 0;

				image_buffer_nxt[0][3] = image_buffer[1][3]; 
				image_buffer_nxt[1][3] = image_buffer[2][3]; 
				image_buffer_nxt[2][3] = image_buffer[3][3]; 
				image_buffer_nxt[3][3] = image_buffer[4][3]; 
				image_buffer_nxt[4][3] = pad_mode_reg ? image_buffer[4][3] : 0;

				image_buffer_nxt[0][4] = image_buffer[1][4]; 
				image_buffer_nxt[1][4] = image_buffer[2][4]; 
				image_buffer_nxt[2][4] = image_buffer[3][4]; 
				image_buffer_nxt[3][4] = image_buffer[4][4]; 
				image_buffer_nxt[4][4] = pad_mode_reg ? image_buffer[4][4] : 0;
			end


			case (conv_counter) inside
				0: begin					
					image_in_nxt[0][0] = image_buffer[0][0];
					image_in_nxt[1][0] = image_buffer[1][0];
					image_in_nxt[2][0] = image_buffer[2][0];
					image_in_nxt[3][0] = image_buffer[3][0];
					image_in_nxt[4][0] = image_buffer[4][0];

					image_in_nxt[0][1] = image_buffer[0][1];
					image_in_nxt[1][1] = image_buffer[1][1];
					image_in_nxt[2][1] = image_buffer[2][1];
					image_in_nxt[3][1] = image_buffer[3][1];
					image_in_nxt[4][1] = image_buffer[4][1];

					image_in_nxt[0][2] = image_buffer[0][2];
					image_in_nxt[1][2] = image_buffer[1][2];
					image_in_nxt[2][2] = image_buffer[2][2];
					image_in_nxt[3][2] = image_buffer[3][2];
					image_in_nxt[4][2] = image_buffer[4][2];

					image_in_nxt[0][3] = image_buffer[0][3];
					image_in_nxt[1][3] = image_buffer[1][3];
					image_in_nxt[2][3] = image_buffer[2][3];
					image_in_nxt[3][3] = image_buffer[3][3];
					image_in_nxt[4][3] = image_buffer[4][3];

					case (image_size_reg) inside
						[3: 8]: begin
							image_in_nxt[0][4] = image_buffer[0][image_size_reg + 3];
							image_in_nxt[1][4] = image_buffer[1][image_size_reg + 3];
							image_in_nxt[2][4] = image_buffer[2][image_size_reg + 3];
							image_in_nxt[3][4] = image_buffer[3][image_size_reg + 3];
							image_in_nxt[4][4] = image_buffer[4][image_size_reg + 3];
						end
					endcase
				end
				[1: 7]: begin
					image_in_nxt[0][0] = image_buffer[0][conv_counter];
					image_in_nxt[1][0] = image_buffer[1][conv_counter];
					image_in_nxt[2][0] = image_buffer[2][conv_counter];
					image_in_nxt[3][0] = image_buffer[3][conv_counter];
					image_in_nxt[4][0] = image_buffer[4][conv_counter];

					image_in_nxt[0][1] = image_buffer[0][1 + conv_counter];
					image_in_nxt[1][1] = image_buffer[1][1 + conv_counter];
					image_in_nxt[2][1] = image_buffer[2][1 + conv_counter];
					image_in_nxt[3][1] = image_buffer[3][1 + conv_counter];
					image_in_nxt[4][1] = image_buffer[4][1 + conv_counter];

					image_in_nxt[0][2] = image_buffer[0][2 + conv_counter];
					image_in_nxt[1][2] = image_buffer[1][2 + conv_counter];
					image_in_nxt[2][2] = image_buffer[2][2 + conv_counter];
					image_in_nxt[3][2] = image_buffer[3][2 + conv_counter];
					image_in_nxt[4][2] = image_buffer[4][2 + conv_counter];

					image_in_nxt[0][3] = image_buffer[0][3 + conv_counter];
					image_in_nxt[1][3] = image_buffer[1][3 + conv_counter];
					image_in_nxt[2][3] = image_buffer[2][3 + conv_counter];
					image_in_nxt[3][3] = image_buffer[3][3 + conv_counter];
					image_in_nxt[4][3] = image_buffer[4][3 + conv_counter];

					image_in_nxt[0][4] = image_buffer[0][3 + conv_counter];
					image_in_nxt[1][4] = image_buffer[1][3 + conv_counter];
					image_in_nxt[2][4] = image_buffer[2][3 + conv_counter];
					image_in_nxt[3][4] = image_buffer[3][3 + conv_counter];
					image_in_nxt[4][4] = image_buffer[4][3 + conv_counter];
				end
			endcase
		end 
		else begin
			if ((v_cnt == 1 || v_cnt == 2) && conv_counter == 2) begin
				sum_enable1_nxt = 1;
			end

			if ((v_cnt == image_size_reg + 1 && counter == 3) || (v_cnt == image_size_reg + 2 && counter == 0)) begin
				sum_enable1_nxt = 0;
				state_nxt = IDLE;
			end
			
			case (conv_counter) inside
				0: begin
					image_in_nxt[1][1] = image_buffer[1][1];
					image_in_nxt[2][1] = image_buffer[2][1];
					image_in_nxt[3][1] = image_buffer[3][1];

					image_in_nxt[1][2] = image_buffer[1][2];
					image_in_nxt[2][2] = image_buffer[2][2];
					image_in_nxt[3][2] = image_buffer[3][2];
					
					case (image_size_reg) inside
						[3: 8]: begin
							image_in_nxt[1][3] = image_buffer[1][image_size_reg + 2];
							image_in_nxt[2][3] = image_buffer[2][image_size_reg + 2];
							image_in_nxt[3][3] = image_buffer[3][image_size_reg + 2];
						end
					endcase
				end
				[1: 7]: begin
					image_in_nxt[1][1] = image_buffer[1][conv_counter + 1];
					image_in_nxt[2][1] = image_buffer[2][conv_counter + 1];
					image_in_nxt[3][1] = image_buffer[3][conv_counter + 1];

					image_in_nxt[1][2] = image_buffer[1][conv_counter + 2];
					image_in_nxt[2][2] = image_buffer[2][conv_counter + 2];
					image_in_nxt[3][2] = image_buffer[3][conv_counter + 2];
					
					image_in_nxt[1][3] = image_buffer[1][conv_counter + 2];
					image_in_nxt[2][3] = image_buffer[2][conv_counter + 2];
					image_in_nxt[3][3] = image_buffer[3][conv_counter + 2];
				end
			endcase
		end
		if (conv_counter == image_size_reg - 1) begin
			conv_counter_nxt = 0;
		end
	end

	for (integer i = 0; i < 5; i = i + 1) begin
		for (integer j = 0; j < 5; j = j + 1) begin
			conv_result_A_nxt[i][j] = image_in[j][i] * filter[j][i];
		end
		conv_result_nxt[i] = 
			(conv_result_A[i][0] + conv_result_A[i][1]) + 
			conv_result_A[i][2] +
			(conv_result_A[i][3] + conv_result_A[i][4]);
	end

	conv_result_B_nxt = (conv_result[1] + conv_result[2]) + (filter_size_reg ? conv_result[0] + conv_result[3] : 0);
	
	conv_sum_nxt = (filter_size_reg ? conv_result[4] : conv_result[3]) + conv_result_B;
	
	if (out_enable) begin
		out_valid_nxt = 1;
		out_data_nxt = (
			conv_sum >= 0 ? 
			conv_sum > 32767 ? 32767 : conv_sum :
			act_mode_reg ? (conv_sum / 10 < -32768 ? -32768 : conv_sum / 10) : 0
		);
	end
end

always_ff @(posedge clk) begin
	counter 	 <= counter_nxt;
	conv_counter <= conv_counter_nxt;

	conv_sum <= conv_sum_nxt;
end

always_ff @(posedge clk) begin
	filter_size_reg	<=	filter_size_reg_nxt;
	pad_mode_reg 	<=	pad_mode_reg_nxt;
	act_mode_reg 	<=	act_mode_reg_nxt;
	image_size_reg	<=	image_size_reg_nxt;
end

always_ff @(posedge clk) begin
	for (integer i = 0; i < 5; i = i + 1) begin
		for (integer j = 0; j < 5; j = j + 1) begin
			conv_result_A[i][j] <= conv_result_A_nxt[i][j];
		end
	end

	for (integer i = 0; i < 5; i = i + 1) begin
		for (integer j = 0; j < 5; j = j + 1) begin
			filter[i][j] <= filter_nxt[i][j];
		end
	end

	for (integer i = 0; i < 5; i = i + 1) begin
		for (integer j = 0; j < 5; j = j + 1) begin
			image_in[i][j] <= image_in_nxt[i][j];
		end
	end

	for (integer i = 0; i < 5; i = i + 1) begin
		for (integer j = 0; j < 12; j = j + 1) begin
			image_buffer[i][j] <= image_buffer_nxt[i][j];
		end
	end

	conv_result[0] <= conv_result_nxt[0];
	conv_result[1] <= conv_result_nxt[1];
	conv_result[2] <= conv_result_nxt[2];
	conv_result[3] <= conv_result_nxt[3];
	conv_result[4] <= conv_result_nxt[4];

	conv_result_B <= conv_result_B_nxt;
end

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		v_cnt <= 0;
	end
	else begin
		v_cnt <= v_cnt_nxt;
	end
end

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		state 		<= IDLE;
		conv_enable <= 0;
		sum_enable 	<= 0;
		sum_enable1 <= 0;
		out_enable 	<= 0;
		out_valid 	<= 0;
		out_data 	<= 0;
	end
	else begin
		state 		<= state_nxt;
		conv_enable <= conv_enable_nxt;
		sum_enable 	<= sum_enable_nxt;
		sum_enable1 <= sum_enable1_nxt;
		out_enable 	<= out_enable_nxt;
		out_valid 	<= out_valid_nxt;
		out_data 	<= out_data_nxt;
	end
end

endmodule
