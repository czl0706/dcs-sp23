`include "synchronizer.v"
module CDC(// Input signals
			clk_1,
			clk_2,
			in_valid,
			rst_n,
			in_a,
			mode,
			in_b,
		  //  Output signals
			out_valid,
			out
			);		
input clk_1; 
input clk_2;			
input rst_n;
input in_valid;
input[3:0]in_a,in_b;
input mode;
output logic out_valid;
output logic [7:0]out; 			

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

parameter [1:0] IDLE = 0, COMPUTE = 1, OUT = 2;

logic [1:0] state, state_nxt;

logic P, P_nxt, Q, Q_nxt;

logic SYN_out;

logic CDC_res;

logic out_valid_nxt;
logic [7:0] out_nxt; 	


logic [3:0] in_a_reg, in_b_reg, in_a_comb, in_b_comb;
logic mode_reg, mode_comb;  

//---------------------------------------------------------------------
//   your design  (Using synchronizer)       
// Example :
//logic P,Q,Y;
//synchronizer x5(.D(P),.Q(Y),.clk(clk_2),.rst_n(rst_n));           
//---------------------------------------------------------------------	

assign P_nxt = in_valid ^ P;

always_ff @(posedge clk_1, negedge rst_n) begin
    if (!rst_n) P <= 0;
    else        P <= P_nxt;
end

synchronizer x1(.D(P), .Q(SYN_out), .clk(clk_2), .rst_n(rst_n));

assign Q_nxt = SYN_out;

always_ff @(posedge clk_2, negedge rst_n) begin
    if (!rst_n) Q <= 0;
    else        Q <= Q_nxt;
end

assign CDC_res = Q ^ Q_nxt;

always_comb begin
    state_nxt = state;
    out_valid_nxt = 0;
    out_nxt = 0; 
    case (state) 
        IDLE: begin
            if (CDC_res) begin
                state_nxt = COMPUTE;
            end
        end
        COMPUTE: begin
            out_nxt = !mode_reg ? in_a_reg + in_b_reg : in_a_reg * in_b_reg;
            state_nxt = OUT;
            out_valid_nxt = 1;
        end
        OUT: begin
            state_nxt = IDLE;
        end
    endcase
end

always_ff @(posedge clk_2, negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        out_valid <= 0;
        out <= 0;
    end
    else begin
        state <= state_nxt;
        out_valid <= out_valid_nxt;
        out <= out_nxt;
    end
end



always_comb begin
    mode_comb = in_valid ? mode : mode_reg;
    in_a_comb = in_valid ? in_a : in_a_reg;
    in_b_comb = in_valid ? in_b : in_b_reg;
end

always_ff @(posedge clk_1, negedge rst_n) begin
    if (!rst_n) begin
        mode_reg <= 0;
        in_a_reg <= 0;
        in_b_reg <= 0;
    end
    else begin
        mode_reg <= mode_comb;
        in_a_reg <= in_a_comb;
        in_b_reg <= in_b_comb;
    end 
end


endmodule