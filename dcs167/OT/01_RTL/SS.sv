module SS(
// input signals
    clk,
    rst_n,
    in_valid,
    matrix,
    matrix_size,
// output signals
    out_valid,
    out_value
);
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input               clk, rst_n, in_valid;
input        [15:0] matrix;
input               matrix_size;

output logic        out_valid;
output logic [39:0] out_value;

logic out_valid_nxt;
logic [39:0] out_value_nxt;

parameter [2:0] IDLE = 0, DATA2 = 1, DATA4 = 2, CALC2 = 3, CALC4 = 4;

logic [4:0] state, state_nxt;

logic [39:0] W [0:3][0:3];
logic [39:0] W_nxt [0:3][0:3];

logic [39:0] X [0:3][0:3];
logic [39:0] X_nxt [0:3][0:3];

logic [39:0] Y_r [0:3][0:3];
logic [39:0] Y_r_nxt [0:3][0:3];

logic [39:0] Y [0:3][0:3];
logic [39:0] Y_nxt [0:3][0:3];

logic [39:0] Y_in [0:3];

logic [5:0] counter, counter_nxt;

always_comb begin
    state_nxt = state;
    counter_nxt = counter + 1;

    out_valid_nxt = 0;
    out_value_nxt = 0;

    Y_in[0] = 0;
    Y_in[1] = 0;
    Y_in[2] = 0;
    Y_in[3] = 0;

    W_nxt[0][0] = W[0][0];
    W_nxt[0][1] = W[0][1];
    W_nxt[0][2] = W[0][2];
    W_nxt[0][3] = W[0][3];
    W_nxt[1][0] = W[1][0];
    W_nxt[1][1] = W[1][1];
    W_nxt[1][2] = W[1][2];
    W_nxt[1][3] = W[1][3];
    W_nxt[2][0] = W[2][0];
    W_nxt[2][1] = W[2][1];
    W_nxt[2][2] = W[2][2];
    W_nxt[2][3] = W[2][3];
    W_nxt[3][0] = W[3][0];
    W_nxt[3][1] = W[3][1];
    W_nxt[3][2] = W[3][2];
    W_nxt[3][3] = W[3][3];
        
    X_nxt[0][0] = X[0][0];
    X_nxt[0][1] = X[0][1];
    X_nxt[0][2] = X[0][2];
    X_nxt[0][3] = X[0][3];
    X_nxt[1][0] = X[1][0];
    X_nxt[1][1] = X[1][1];
    X_nxt[1][2] = X[1][2];
    X_nxt[1][3] = X[1][3];
    X_nxt[2][0] = X[2][0];
    X_nxt[2][1] = X[2][1];
    X_nxt[2][2] = X[2][2];
    X_nxt[2][3] = X[2][3];
    X_nxt[3][0] = X[3][0];
    X_nxt[3][1] = X[3][1];
    X_nxt[3][2] = X[3][2];
    X_nxt[3][3] = X[3][3];

    case (state) inside 
        IDLE: begin
            if (in_valid) begin
                W_nxt[0][0] = 0;
                W_nxt[0][1] = 0;
                W_nxt[0][2] = 0;
                W_nxt[0][3] = 0;
                W_nxt[1][0] = 0;
                W_nxt[1][1] = 0;
                W_nxt[1][2] = 0;
                W_nxt[1][3] = 0;
                W_nxt[2][0] = 0;
                W_nxt[2][1] = 0;
                W_nxt[2][2] = 0;
                W_nxt[2][3] = 0;
                W_nxt[3][0] = 0;
                W_nxt[3][1] = 0;
                W_nxt[3][2] = 0;
                W_nxt[3][3] = 0;
                
                X_nxt[0][0] = 0;
                X_nxt[0][1] = 0;
                X_nxt[0][2] = 0;
                X_nxt[0][3] = 0;
                X_nxt[1][0] = 0;
                X_nxt[1][1] = 0;
                X_nxt[1][2] = 0;
                X_nxt[1][3] = 0;
                X_nxt[2][0] = 0;
                X_nxt[2][1] = 0;
                X_nxt[2][2] = 0;
                X_nxt[2][3] = 0;
                X_nxt[3][0] = 0;
                X_nxt[3][1] = 0;
                X_nxt[3][2] = 0;
                X_nxt[3][3] = 0;

                Y_r_nxt[0][0] = 0;
                Y_r_nxt[0][1] = 0;
                Y_r_nxt[0][2] = 0;
                Y_r_nxt[0][3] = 0;
                Y_r_nxt[1][0] = 0;
                Y_r_nxt[1][1] = 0;
                Y_r_nxt[1][2] = 0;
                Y_r_nxt[1][3] = 0;
                Y_r_nxt[2][0] = 0;
                Y_r_nxt[2][1] = 0;
                Y_r_nxt[2][2] = 0;
                Y_r_nxt[2][3] = 0;
                Y_r_nxt[3][0] = 0;
                Y_r_nxt[3][1] = 0;
                Y_r_nxt[3][2] = 0;
                Y_r_nxt[3][3] = 0;
                
                Y_nxt[0][0] = 0;
                Y_nxt[0][1] = 0;
                Y_nxt[0][2] = 0;
                Y_nxt[0][3] = 0;
                Y_nxt[1][0] = 0;
                Y_nxt[1][1] = 0;
                Y_nxt[1][2] = 0;
                Y_nxt[1][3] = 0;
                Y_nxt[2][0] = 0;
                Y_nxt[2][1] = 0;
                Y_nxt[2][2] = 0;
                Y_nxt[2][3] = 0;
                Y_nxt[3][0] = 0;
                Y_nxt[3][1] = 0;
                Y_nxt[3][2] = 0;
                Y_nxt[3][3] = 0;
                W_nxt[0][0] = matrix;
                counter_nxt = 0;
                if (matrix_size) begin
                    state_nxt = DATA4;
                end
                else begin
                    state_nxt = DATA2;
                end
            end
        end
        DATA2: begin
            case (counter) 
                0: W_nxt[0][1] = matrix;
                1: W_nxt[1][0] = matrix;
                2: W_nxt[1][1] = matrix;
                3: X_nxt[0][0] = matrix;
                4: X_nxt[0][1] = matrix;
                5: X_nxt[1][0] = matrix;
                6: begin
                    X_nxt[1][1] = matrix;
                    state_nxt = CALC2;
                    counter_nxt = 0;
                end
            endcase
        end
        DATA4: begin
            case (counter) 
                0: W_nxt[0][1] = matrix;
                1: W_nxt[0][2] = matrix;
                2: W_nxt[0][3] = matrix;
                3: W_nxt[1][0] = matrix;
                4: W_nxt[1][1] = matrix;
                5: W_nxt[1][2] = matrix;
                6: W_nxt[1][3] = matrix;
                7: W_nxt[2][0] = matrix;
                8: W_nxt[2][1] = matrix;
                9: W_nxt[2][2] = matrix;
                10: W_nxt[2][3] = matrix;
                11: W_nxt[3][0] = matrix;
                12: W_nxt[3][1] = matrix;
                13: W_nxt[3][2] = matrix;
                14: W_nxt[3][3] = matrix;
                15: X_nxt[0][0] = matrix;
                16: X_nxt[0][1] = matrix;
                17: X_nxt[0][2] = matrix;
                18: X_nxt[0][3] = matrix;
                19: X_nxt[1][0] = matrix;
                20: X_nxt[1][1] = matrix;
                21: X_nxt[1][2] = matrix;
                22: X_nxt[1][3] = matrix;
                23: X_nxt[2][0] = matrix;
                24: X_nxt[2][1] = matrix;
                25: X_nxt[2][2] = matrix;
                26: X_nxt[2][3] = matrix;
                27: X_nxt[3][0] = matrix;
                28: X_nxt[3][1] = matrix;
                29: X_nxt[3][2] = matrix;
                30: begin
                    X_nxt[3][3] = matrix;
                    state_nxt = CALC4;
                    counter_nxt = 0;
                end
            endcase
        end
        CALC2: begin
            case(counter) 
                0: begin
                    Y_in[0] = X[0][0];
                    Y_in[1] = 0;
                end
                1: begin
                    Y_in[0] = X[1][0];
                    Y_in[1] = X[0][1];
                    
                end
                2: begin
                    Y_in[0] = 0;
                    Y_in[1] = X[1][1];
                    out_valid_nxt = 1;
                    out_value_nxt = Y[1][0] + Y[1][1];
                end
                3: begin
                    Y_in[0] = 0;
                    Y_in[1] = 0;
                    out_valid_nxt = 1;
                    out_value_nxt = Y[1][0] + Y[1][1];
                end
                4: begin
                    Y_in[0] = 0;
                    Y_in[1] = 0;
                    out_valid_nxt = 1;
                    out_value_nxt = Y[1][0] + Y[1][1];
                    state_nxt = IDLE;
                    counter_nxt = 0;
                end
            endcase
        end
        CALC4: begin
            case(counter) 
                0: begin
                    Y_in[0] = X[0][0];
                    Y_in[1] = 0;
                    Y_in[2] = 0;
                    Y_in[3] = 0;
                end
                1: begin
                    Y_in[0] = X[1][0];
                    Y_in[1] = X[0][1];
                    Y_in[2] = 0;
                    Y_in[3] = 0;
                end
                2: begin
                    Y_in[0] = X[2][0];
                    Y_in[1] = X[1][1];
                    Y_in[2] = X[0][2];
                    Y_in[3] = 0;
                end
                3: begin
                    Y_in[0] = X[3][0];
                    Y_in[1] = X[2][1];
                    Y_in[2] = X[1][2];
                    Y_in[3] = X[0][3];
                end
                4: begin
                    Y_in[0] = 0;
                    Y_in[1] = X[3][1];
                    Y_in[2] = X[2][2];
                    Y_in[3] = X[1][3];

                    out_valid_nxt = 1;
                    out_value_nxt = Y[3][0] + Y[3][1] + Y[3][2] + Y[3][3];
                end
                5: begin
                    Y_in[0] = 0;
                    Y_in[1] = 0;
                    Y_in[2] = X[3][2];
                    Y_in[3] = X[2][3];

                    out_valid_nxt = 1;
                    out_value_nxt = Y[3][0] + Y[3][1] + Y[3][2] + Y[3][3];
                end
                6: begin
                    Y_in[0] = 0;
                    Y_in[1] = 0;
                    Y_in[2] = 0;
                    Y_in[3] = X[3][3];

                    out_valid_nxt = 1;
                    out_value_nxt = Y[3][0] + Y[3][1] + Y[3][2] + Y[3][3];
                end
                7: begin
                    Y_in[0] = 0;
                    Y_in[1] = 0;
                    Y_in[2] = 0;
                    Y_in[3] = 0;

                    out_valid_nxt = 1;
                    out_value_nxt = Y[3][0] + Y[3][1] + Y[3][2] + Y[3][3];
                end
                8: begin
                    Y_in[0] = 0;
                    Y_in[1] = 0;
                    Y_in[2] = 0;
                    Y_in[3] = 0;

                    out_valid_nxt = 1;
                    out_value_nxt = Y[3][0] + Y[3][1] + Y[3][2] + Y[3][3];
                end
                9: begin
                    Y_in[0] = 0;
                    Y_in[1] = 0;
                    Y_in[2] = 0;
                    Y_in[3] = 0;

                    out_valid_nxt = 1;
                    out_value_nxt = Y[3][0] + Y[3][1] + Y[3][2] + Y[3][3];
                end
                10: begin
                    Y_in[0] = 0;
                    Y_in[1] = 0;
                    Y_in[2] = 0;
                    Y_in[3] = 0;

                    out_valid_nxt = 1;
                    out_value_nxt = Y[3][0] + Y[3][1] + Y[3][2] + Y[3][3];
                    state_nxt = IDLE;
                    counter_nxt = 0;
                end
            endcase
        end

    endcase

    Y_r_nxt[0][0] = Y_in[0];
    Y_r_nxt[0][1] = Y_r[0][0];
    Y_r_nxt[0][2] = Y_r[0][1];
    Y_r_nxt[0][3] = Y_r[0][2];

    Y_r_nxt[1][0] = Y_in[1];
    Y_r_nxt[1][1] = Y_r[1][0];
    Y_r_nxt[1][2] = Y_r[1][1];
    Y_r_nxt[1][3] = Y_r[1][2];

    Y_r_nxt[2][0] = Y_in[2];
    Y_r_nxt[2][1] = Y_r[2][0];
    Y_r_nxt[2][2] = Y_r[2][1];
    Y_r_nxt[2][3] = Y_r[2][2];

    Y_r_nxt[3][0] = Y_in[3];
    Y_r_nxt[3][1] = Y_r[3][0];
    Y_r_nxt[3][2] = Y_r[3][1];
    Y_r_nxt[3][3] = Y_r[3][2];

    Y_nxt[0][0] = W[0][0] * Y_in[0];
    Y_nxt[0][1] = W[0][1] * Y_r[0][0];
    Y_nxt[0][2] = W[0][2] * Y_r[0][1];
    Y_nxt[0][3] = W[0][3] * Y_r[0][2];

    Y_nxt[1][0] = Y[0][0] + W[1][0] * Y_in[1];
    Y_nxt[1][1] = Y[0][1] + W[1][1] * Y_r[1][0];
    Y_nxt[1][2] = Y[0][2] + W[1][2] * Y_r[1][1];
    Y_nxt[1][3] = Y[0][3] + W[1][3] * Y_r[1][2];

    Y_nxt[2][0] = Y[1][0] + W[2][0] * Y_in[2];
    Y_nxt[2][1] = Y[1][1] + W[2][1] * Y_r[2][0];
    Y_nxt[2][2] = Y[1][2] + W[2][2] * Y_r[2][1];
    Y_nxt[2][3] = Y[1][3] + W[2][3] * Y_r[2][2];

    Y_nxt[3][0] = Y[2][0] + W[3][0] * Y_in[3];
    Y_nxt[3][1] = Y[2][1] + W[3][1] * Y_r[3][0];
    Y_nxt[3][2] = Y[2][2] + W[3][2] * Y_r[3][1];
    Y_nxt[3][3] = Y[2][3] + W[3][3] * Y_r[3][2];
end

// always_ff @(posedge clk, negedge rst_n) begin
//     if (!rst_n) begin
//         out_valid <= 0;
//         out_value <= 0;
//         state <= IDLE;
//         W[0][0] <= 0;
//         W[0][1] <= 0;
//         W[0][2] <= 0;
//         W[0][3] <= 0;
//         W[1][0] <= 0;
//         W[1][1] <= 0;
//         W[1][2] <= 0;
//         W[1][3] <= 0;
//         W[2][0] <= 0;
//         W[2][1] <= 0;
//         W[2][2] <= 0;
//         W[2][3] <= 0;
//         W[3][0] <= 0;
//         W[3][1] <= 0;
//         W[3][2] <= 0;
//         W[3][3] <= 0;
        
//         X[0][0] <= 0;
//         X[0][1] <= 0;
//         X[0][2] <= 0;
//         X[0][3] <= 0;
//         X[1][0] <= 0;
//         X[1][1] <= 0;
//         X[1][2] <= 0;
//         X[1][3] <= 0;
//         X[2][0] <= 0;
//         X[2][1] <= 0;
//         X[2][2] <= 0;
//         X[2][3] <= 0;
//         X[3][0] <= 0;
//         X[3][1] <= 0;
//         X[3][2] <= 0;
//         X[3][3] <= 0;

//         Y_r[0][0] <= 0;
//         Y_r[0][1] <= 0;
//         Y_r[0][2] <= 0;
//         Y_r[0][3] <= 0;
//         Y_r[1][0] <= 0;
//         Y_r[1][1] <= 0;
//         Y_r[1][2] <= 0;
//         Y_r[1][3] <= 0;
//         Y_r[2][0] <= 0;
//         Y_r[2][1] <= 0;
//         Y_r[2][2] <= 0;
//         Y_r[2][3] <= 0;
//         Y_r[3][0] <= 0;
//         Y_r[3][1] <= 0;
//         Y_r[3][2] <= 0;
//         Y_r[3][3] <= 0;
        
//         Y[0][0] <= 0;
//         Y[0][1] <= 0;
//         Y[0][2] <= 0;
//         Y[0][3] <= 0;
//         Y[1][0] <= 0;
//         Y[1][1] <= 0;
//         Y[1][2] <= 0;
//         Y[1][3] <= 0;
//         Y[2][0] <= 0;
//         Y[2][1] <= 0;
//         Y[2][2] <= 0;
//         Y[2][3] <= 0;
//         Y[3][0] <= 0;
//         Y[3][1] <= 0;
//         Y[3][2] <= 0;
//         Y[3][3] <= 0;

//         counter <= 0;
//     end
//     else begin
//         out_valid <= out_valid_nxt;
//         out_value <= out_value_nxt;
//         state <= state_nxt;

//         W[0][0] <= W_nxt[0][0];
//         W[0][1] <= W_nxt[0][1];
//         W[0][2] <= W_nxt[0][2];
//         W[0][3] <= W_nxt[0][3];
//         W[1][0] <= W_nxt[1][0];
//         W[1][1] <= W_nxt[1][1];
//         W[1][2] <= W_nxt[1][2];
//         W[1][3] <= W_nxt[1][3];
//         W[2][0] <= W_nxt[2][0];
//         W[2][1] <= W_nxt[2][1];
//         W[2][2] <= W_nxt[2][2];
//         W[2][3] <= W_nxt[2][3];
//         W[3][0] <= W_nxt[3][0];
//         W[3][1] <= W_nxt[3][1];
//         W[3][2] <= W_nxt[3][2];
//         W[3][3] <= W_nxt[3][3];
        
//         X[0][0] <= X_nxt[0][0];
//         X[0][1] <= X_nxt[0][1];
//         X[0][2] <= X_nxt[0][2];
//         X[0][3] <= X_nxt[0][3];
//         X[1][0] <= X_nxt[1][0];
//         X[1][1] <= X_nxt[1][1];
//         X[1][2] <= X_nxt[1][2];
//         X[1][3] <= X_nxt[1][3];
//         X[2][0] <= X_nxt[2][0];
//         X[2][1] <= X_nxt[2][1];
//         X[2][2] <= X_nxt[2][2];
//         X[2][3] <= X_nxt[2][3];
//         X[3][0] <= X_nxt[3][0];
//         X[3][1] <= X_nxt[3][1];
//         X[3][2] <= X_nxt[3][2];
//         X[3][3] <= X_nxt[3][3];

//         Y_r[0][0] <= Y_r_nxt[0][0];
//         Y_r[0][1] <= Y_r_nxt[0][1];
//         Y_r[0][2] <= Y_r_nxt[0][2];
//         Y_r[0][3] <= Y_r_nxt[0][3];
//         Y_r[1][0] <= Y_r_nxt[1][0];
//         Y_r[1][1] <= Y_r_nxt[1][1];
//         Y_r[1][2] <= Y_r_nxt[1][2];
//         Y_r[1][3] <= Y_r_nxt[1][3];
//         Y_r[2][0] <= Y_r_nxt[2][0];
//         Y_r[2][1] <= Y_r_nxt[2][1];
//         Y_r[2][2] <= Y_r_nxt[2][2];
//         Y_r[2][3] <= Y_r_nxt[2][3];
//         Y_r[3][0] <= Y_r_nxt[3][0];
//         Y_r[3][1] <= Y_r_nxt[3][1];
//         Y_r[3][2] <= Y_r_nxt[3][2];
//         Y_r[3][3] <= Y_r_nxt[3][3];
        
//         Y[0][0] <= Y_nxt[0][0];
//         Y[0][1] <= Y_nxt[0][1];
//         Y[0][2] <= Y_nxt[0][2];
//         Y[0][3] <= Y_nxt[0][3];
//         Y[1][0] <= Y_nxt[1][0];
//         Y[1][1] <= Y_nxt[1][1];
//         Y[1][2] <= Y_nxt[1][2];
//         Y[1][3] <= Y_nxt[1][3];
//         Y[2][0] <= Y_nxt[2][0];
//         Y[2][1] <= Y_nxt[2][1];
//         Y[2][2] <= Y_nxt[2][2];
//         Y[2][3] <= Y_nxt[2][3];
//         Y[3][0] <= Y_nxt[3][0];
//         Y[3][1] <= Y_nxt[3][1];
//         Y[3][2] <= Y_nxt[3][2];
//         Y[3][3] <= Y_nxt[3][3];

//         counter <= counter_nxt;
//     end
// end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state     <= IDLE;
        out_valid <= 0;
        out_value <= 0;
        counter   <= 0;
    end
    else begin
        state     <= state_nxt;
        out_valid <= out_valid_nxt;
        out_value <= out_value_nxt;
        counter   <= counter_nxt;
    end
end

always_ff @(posedge clk) begin
    W[0][0] <= W_nxt[0][0];
    W[0][1] <= W_nxt[0][1];
    W[0][2] <= W_nxt[0][2];
    W[0][3] <= W_nxt[0][3];
    W[1][0] <= W_nxt[1][0];
    W[1][1] <= W_nxt[1][1];
    W[1][2] <= W_nxt[1][2];
    W[1][3] <= W_nxt[1][3];
    W[2][0] <= W_nxt[2][0];
    W[2][1] <= W_nxt[2][1];
    W[2][2] <= W_nxt[2][2];
    W[2][3] <= W_nxt[2][3];
    W[3][0] <= W_nxt[3][0];
    W[3][1] <= W_nxt[3][1];
    W[3][2] <= W_nxt[3][2];
    W[3][3] <= W_nxt[3][3];
    
    X[0][0] <= X_nxt[0][0];
    X[0][1] <= X_nxt[0][1];
    X[0][2] <= X_nxt[0][2];
    X[0][3] <= X_nxt[0][3];
    X[1][0] <= X_nxt[1][0];
    X[1][1] <= X_nxt[1][1];
    X[1][2] <= X_nxt[1][2];
    X[1][3] <= X_nxt[1][3];
    X[2][0] <= X_nxt[2][0];
    X[2][1] <= X_nxt[2][1];
    X[2][2] <= X_nxt[2][2];
    X[2][3] <= X_nxt[2][3];
    X[3][0] <= X_nxt[3][0];
    X[3][1] <= X_nxt[3][1];
    X[3][2] <= X_nxt[3][2];
    X[3][3] <= X_nxt[3][3];

    Y_r[0][0] <= Y_r_nxt[0][0];
    Y_r[0][1] <= Y_r_nxt[0][1];
    Y_r[0][2] <= Y_r_nxt[0][2];
    Y_r[0][3] <= Y_r_nxt[0][3];
    Y_r[1][0] <= Y_r_nxt[1][0];
    Y_r[1][1] <= Y_r_nxt[1][1];
    Y_r[1][2] <= Y_r_nxt[1][2];
    Y_r[1][3] <= Y_r_nxt[1][3];
    Y_r[2][0] <= Y_r_nxt[2][0];
    Y_r[2][1] <= Y_r_nxt[2][1];
    Y_r[2][2] <= Y_r_nxt[2][2];
    Y_r[2][3] <= Y_r_nxt[2][3];
    Y_r[3][0] <= Y_r_nxt[3][0];
    Y_r[3][1] <= Y_r_nxt[3][1];
    Y_r[3][2] <= Y_r_nxt[3][2];
    Y_r[3][3] <= Y_r_nxt[3][3];
    
    Y[0][0] <= Y_nxt[0][0];
    Y[0][1] <= Y_nxt[0][1];
    Y[0][2] <= Y_nxt[0][2];
    Y[0][3] <= Y_nxt[0][3];
    Y[1][0] <= Y_nxt[1][0];
    Y[1][1] <= Y_nxt[1][1];
    Y[1][2] <= Y_nxt[1][2];
    Y[1][3] <= Y_nxt[1][3];
    Y[2][0] <= Y_nxt[2][0];
    Y[2][1] <= Y_nxt[2][1];
    Y[2][2] <= Y_nxt[2][2];
    Y[2][3] <= Y_nxt[2][3];
    Y[3][0] <= Y_nxt[3][0];
    Y[3][1] <= Y_nxt[3][1];
    Y[3][2] <= Y_nxt[3][2];
    Y[3][3] <= Y_nxt[3][3];
end

endmodule