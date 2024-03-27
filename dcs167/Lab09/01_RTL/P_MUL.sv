module P_MUL(
  // Input signals
	clk,
    rst_n,
    in_1,
    in_2,
    in_3,
    in_4,
    in_valid,
  // Output signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
input clk, rst_n, in_valid;
input [46:0] in_1, in_2, in_3, in_4;

output logic out_valid;
output logic [95:0] out;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [47:0] sum_A, sum_A_nxt;
logic [47:0] sum_B, sum_B_nxt;
logic st1_valid, st1_valid_nxt; 

logic [31:0] mul_A, mul_A_nxt;
logic [31:0] mul_B, mul_B_nxt;
logic [31:0] mul_C, mul_C_nxt;
logic [31:0] mul_D, mul_D_nxt;
logic [31:0] mul_E, mul_E_nxt;
logic [31:0] mul_F, mul_F_nxt;
logic [31:0] mul_G, mul_G_nxt;
logic [31:0] mul_H, mul_H_nxt;
logic [31:0] mul_I, mul_I_nxt;
logic st2_valid, st2_valid_nxt; 

logic [95:0] sum_C, sum_C_nxt;
logic [95:0] sum_D, sum_D_nxt;
logic [95:0] sum_E, sum_E_nxt;
logic st3_valid, st3_valid_nxt; 

logic [95:0] out_nxt;
logic out_valid_nxt;

//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------

always_comb begin
    sum_A_nxt = 'h0;
    sum_B_nxt = 'h0;
    sum_C_nxt = 'h0;
    sum_D_nxt = 'h0;
    sum_E_nxt = 'h0;
    st1_valid_nxt = 'h0;
    mul_A_nxt = 'h0;
    mul_B_nxt = 'h0;
    mul_C_nxt = 'h0;
    mul_D_nxt = 'h0;
    mul_E_nxt = 'h0;
    mul_F_nxt = 'h0;
    mul_G_nxt = 'h0;
    mul_H_nxt = 'h0;
    mul_I_nxt = 'h0;
    st2_valid_nxt = 'h0;
    st3_valid_nxt = 'h0;
    out_nxt = 'h0;
    out_valid_nxt = 'h0;
    
    if (in_valid) begin 
        sum_A_nxt = in_1 + in_2;
        sum_B_nxt = in_3 + in_4;
        st1_valid_nxt = 1;
    end 

    if (st1_valid) begin
        mul_A_nxt = sum_A[15:0] * sum_B[15:0];
        mul_B_nxt = sum_A[31:16] * sum_B[15:0];
        mul_C_nxt = sum_A[47:32] * sum_B[15:0];

        mul_D_nxt = sum_A[15:0] * sum_B[31:16];
        mul_E_nxt = sum_A[31:16] * sum_B[31:16];
        mul_F_nxt = sum_A[47:32] * sum_B[31:16];      

        mul_G_nxt = sum_A[15:0] * sum_B[47:32];
        mul_H_nxt = sum_A[31:16] * sum_B[47:32];
        mul_I_nxt = sum_A[47:32] * sum_B[47:32];

        st2_valid_nxt = 1;
    end

    if (st2_valid) begin
        sum_C_nxt = {mul_B, 16'b0} + {mul_D, 16'b0} + mul_A;
        sum_D_nxt = {mul_G, 32'b0} + {mul_E, 32'b0} + {mul_C, 32'b0};
        sum_E_nxt = {mul_I, 64'b0} + {mul_H, 48'b0} + {mul_F, 48'b0};
        st3_valid_nxt = 1;
    end

    if (st3_valid) begin
        out_nxt = sum_C + sum_D + sum_E;
        out_valid_nxt = 1;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        sum_A <= 'h0;
        sum_B <= 'h0;
        sum_C <= 'h0;
        sum_D <= 'h0;
        sum_E <= 'h0;
        st1_valid <= 'h0;
        mul_A <= 'h0;
        mul_B <= 'h0;
        mul_C <= 'h0;
        mul_D <= 'h0;
        mul_E <= 'h0;
        mul_F <= 'h0;
        mul_G <= 'h0;
        mul_H <= 'h0;
        mul_I <= 'h0;
        st2_valid <= 'h0;
        st3_valid <= 'h0;
        out <= 'h0;
        out_valid <= 'h0;
    end
    else begin
        sum_A <= sum_A_nxt;
        sum_B <= sum_B_nxt;
        sum_C <= sum_C_nxt;
        sum_D <= sum_D_nxt;
        sum_E <= sum_E_nxt;
        st1_valid <= st1_valid_nxt;
        mul_A <= mul_A_nxt;
        mul_B <= mul_B_nxt;
        mul_C <= mul_C_nxt;
        mul_D <= mul_D_nxt;
        mul_E <= mul_E_nxt;
        mul_F <= mul_F_nxt;
        mul_G <= mul_G_nxt;
        mul_H <= mul_H_nxt;
        mul_I <= mul_I_nxt;
        st2_valid <= st2_valid_nxt;
        st3_valid <= st3_valid_nxt;
        out <= out_nxt;
        out_valid <= out_valid_nxt;
    end
end

endmodule