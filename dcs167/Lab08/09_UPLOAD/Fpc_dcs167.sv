module Fpc(
// input signals
clk,
rst_n,
in_valid,
in_a,
in_b,
mode,
// output signals
out_valid,
out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, mode;
input [15:0] in_a, in_b;
output logic out_valid;
output logic [15:0] out;

//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------

parameter [1:0] IDLE = 0, ADD = 1, MULT = 2, OUTPUT = 3;
logic [1:0] state, state_nxt;

logic [15:0] num_a, num_b;
logic [15:0] num_a_nxt, num_b_nxt;

logic [15:0] reg_a, reg_b;
logic [15:0] reg_a_nxt, reg_b_nxt;

logic [15:0] w1, w2;

logic signed [8:0] num1, num2;
logic signed [9:0] sum;

logic [15:0] mul_buf;

logic [15:0] out_nxt;
logic out_valid_nxt;

always_comb begin
    num_a_nxt = num_a;
    num_b_nxt = num_b;

    reg_a_nxt = reg_a;
    reg_b_nxt = reg_b;
    state_nxt = state;

    out_nxt = 0;
    out_valid_nxt = 0;

    case (state) 
        IDLE: begin
            if (in_valid) begin
                num_a_nxt = in_a;
                num_b_nxt = in_b;
                state_nxt = (mode == 0) ? ADD : MULT;        
            end
        end
        ADD: begin
            if (num_a[14:7] > num_b[14:7]) begin
                w1 = num_a;
                w2 = num_b;
            end
            else begin
                w1 = num_b;
                w2 = num_a;
            end

            num1 = {1'b1, w1[6:0]};
            num2 = {1'b1, w2[6:0]} >> (w1[14:7] - w2[14:7]);

            if (w1[15]) begin
                num1 = ~num1 + 1'b1;
            end

            if (w2[15]) begin
                num2 = ~num2 + 1'b1;
            end

            sum = num1 + num2;
            if (sum[9]) begin
                out_nxt[15] = 1;
                sum = ~sum + 1;
            end
            else begin
                out_nxt[15] = 0;
            end
            
            if (sum[8]) begin
                out_nxt[14:7] = w1[14:7] + 1;
                out_nxt[6:0] = sum[7:1];
            end
            else if (sum[7]) begin
                out_nxt[14:7] = w1[14:7] + 0;
                out_nxt[6:0] = sum[6:0];
            end
            else if (sum[6]) begin
                out_nxt[14:7] = w1[14:7] - 1;
                out_nxt[6:0] = {sum[5:0], 1'b0};
            end
            else if (sum[5]) begin
                out_nxt[14:7] = w1[14:7] - 2;
                out_nxt[6:0] = {sum[4:0], 2'b0};
            end
            else if (sum[4]) begin
                out_nxt[14:7] = w1[14:7] - 3;
                out_nxt[6:0] = {sum[3:0], 3'b0};
            end
            else if (sum[3]) begin
                out_nxt[14:7] = w1[14:7] - 4;
                out_nxt[6:0] = {sum[2:0], 4'b0};
            end
            else if (sum[2]) begin
                out_nxt[14:7] = w1[14:7] - 5;
                out_nxt[6:0] = {sum[1:0], 5'b0};
            end
            else if (sum[1]) begin
                out_nxt[14:7] = w1[14:7] - 6;
                out_nxt[6:0] = {sum[1:0], 6'b0};
            end
            else begin
                out_nxt[14:7] = w1[14:7] - 7;
                out_nxt[6:0] = {sum[0], 7'b0};
            end
            
            state_nxt = OUTPUT;
            out_valid_nxt = 1;
        end
        MULT: begin
            out_nxt[15] = num_a[15] ^ num_b[15];
            mul_buf = {1'b1, num_a[6:0]} * {1'b1, num_b[6:0]};

            if (mul_buf[15]) begin
                out_nxt[14:7] = num_a[14:7] + num_b[14:7] + 1 - 127; 
                out_nxt[6:0] = mul_buf[14:8];
            end
            else begin
                out_nxt[14:7] = num_a[14:7] + num_b[14:7] - 127;
                out_nxt[6:0] = mul_buf[13:7];
            end
            
            state_nxt = OUTPUT;
            out_valid_nxt = 1;
        end
        OUTPUT: begin
            state_nxt = IDLE;
        end
    endcase

end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        out <= 0;
        out_valid <= 0;
    end
    else begin
        state <= state_nxt;
        out <= out_nxt;
        out_valid <= out_valid_nxt;
    end
end

always_ff @(posedge clk) begin
    num_a <= num_a_nxt;
    num_b <= num_b_nxt;

    reg_a <= reg_a_nxt;
    reg_b <= reg_b_nxt;
end

endmodule

