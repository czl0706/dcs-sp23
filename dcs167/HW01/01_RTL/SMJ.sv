module SMJ(
    // Input signals
    hand_n0,
    hand_n1,
    hand_n2,
    hand_n3,
    hand_n4,
    // Output signals
    out_data
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [5:0] hand_n0;
input [5:0] hand_n1;
input [5:0] hand_n2;
input [5:0] hand_n3;
input [5:0] hand_n4;
output logic [1:0] out_data;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

logic [5:0] hands [4:0];
logic [3:0] h_num [4:0];

logic [4:0] h_invalid;
logic [5:0] is_char;

logic h_eq [4:0][4:0];

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

// Indexing 
assign {hands[0], hands[1], hands[2], hands[3], hands[4]} = {hand_n0, hand_n1, hand_n2, hand_n3, hand_n4};

// The number on the tile
assign h_num[0] = hands[0][3:0];
assign h_num[1] = hands[1][3:0];
assign h_num[2] = hands[2][3:0];
assign h_num[3] = hands[3][3:0];
assign h_num[4] = hands[4][3:0];

// Checks if hands[i] is character tile
assign is_char[0] = (hands[0][5:4] == 2'b01);
assign is_char[1] = (hands[1][5:4] == 2'b01);
assign is_char[2] = (hands[2][5:4] == 2'b01);
assign is_char[3] = (hands[3][5:4] == 2'b01);
assign is_char[4] = (hands[4][5:4] == 2'b01);

// hands[i] == hands[j] -> h_eq[i][j], i < j, *: available, -: not available
//  i\j 0 1 2 3 4
//   0  - * * * *
//   1  - - * * *
//   2  - - - * *
//   3  - - - - *
//   4  - - - - -
assign h_eq[0][1] = ~|(hands[0] ^ hands[1]); // hands[0] == hands[1]
assign h_eq[0][2] = ~|(hands[0] ^ hands[2]);
assign h_eq[0][3] = ~|(hands[0] ^ hands[3]);
assign h_eq[0][4] = ~|(hands[0] ^ hands[4]);
assign h_eq[1][2] = ~|(hands[1] ^ hands[2]);
assign h_eq[1][3] = ~|(hands[1] ^ hands[3]);
assign h_eq[1][4] = ~|(hands[1] ^ hands[4]);
assign h_eq[2][3] = ~|(hands[2] ^ hands[3]);
assign h_eq[2][4] = ~|(hands[2] ^ hands[4]);
assign h_eq[3][4] = ~|(hands[3] ^ hands[4]);

// Checks input has n n+1 n+2 sequence(unordered) 
function check_seq;
    input [3:0] a;
    input [3:0] b;
    input [3:0] c;

    check_seq = 
        ~|(a+1 ^ b) && ~|(b+1 ^ c) ||
        ~|(a+1 ^ c) && ~|(c+1 ^ b) ||
        ~|(b+1 ^ a) && ~|(a+1 ^ c) ||
        ~|(a+1 ^ b) && ~|(c+1 ^ a) ||
        ~|(b+1 ^ c) && ~|(c+1 ^ a) ||
        ~|(b+1 ^ a) && ~|(c+1 ^ b) ;
endfunction

always_comb begin: check_input_valid
    case (hands[0][5:4])
        2'b00:   h_invalid[0] = h_num[0] > 6;
        default: h_invalid[0] = h_num[0] > 8;
    endcase
    case (hands[1][5:4])
        2'b00:   h_invalid[1] = h_num[1] > 6;
        default: h_invalid[1] = h_num[1] > 8;
    endcase
    case (hands[2][5:4])
        2'b00:   h_invalid[2] = h_num[2] > 6;
        default: h_invalid[2] = h_num[2] > 8;
    endcase
    case (hands[3][5:4])
        2'b00:   h_invalid[3] = h_num[3] > 6;
        default: h_invalid[3] = h_num[3] > 8;
    endcase
    case (hands[4][5:4])
        2'b00:   h_invalid[4] = h_num[4] > 6;
        default: h_invalid[4] = h_num[4] > 8;
    endcase
end

always_comb begin: calc_out_data
    if ((|h_invalid) || (h_eq[0][1] && h_eq[1][2] && h_eq[2][3] && h_eq[3][4])) 
        out_data = 2'b01; // error detected
    else if (
        (h_eq[0][1] && h_eq[2][3] && h_eq[3][4]) ||
        (h_eq[0][2] && h_eq[1][3] && h_eq[3][4]) ||
        (h_eq[0][3] && h_eq[1][2] && h_eq[2][4]) ||
        (h_eq[0][4] && h_eq[1][2] && h_eq[2][3]) ||
        (h_eq[0][3] && h_eq[3][4] && h_eq[1][2]) ||
        (h_eq[1][3] && h_eq[0][2] && h_eq[2][4]) ||
        (h_eq[1][4] && h_eq[0][2] && h_eq[2][3]) ||
        (h_eq[2][3] && h_eq[0][1] && h_eq[1][4]) ||
        (h_eq[0][1] && h_eq[1][3] && h_eq[2][4]) ||
        (h_eq[0][1] && h_eq[1][2] && h_eq[3][4])) 
        out_data = 2'b11; // trip + pair
    else if (
        (is_char[2] && is_char[3] && is_char[4] && check_seq(h_num[2], h_num[3], h_num[4]) && h_eq[0][1]) ||
        (is_char[1] && is_char[3] && is_char[4] && check_seq(h_num[1], h_num[3], h_num[4]) && h_eq[0][2]) ||
        (is_char[1] && is_char[2] && is_char[4] && check_seq(h_num[1], h_num[2], h_num[4]) && h_eq[0][3]) ||
        (is_char[1] && is_char[2] && is_char[3] && check_seq(h_num[1], h_num[2], h_num[3]) && h_eq[0][4]) ||
        (is_char[0] && is_char[3] && is_char[4] && check_seq(h_num[0], h_num[3], h_num[4]) && h_eq[1][2]) ||
        (is_char[0] && is_char[2] && is_char[4] && check_seq(h_num[0], h_num[2], h_num[4]) && h_eq[1][3]) ||
        (is_char[0] && is_char[2] && is_char[3] && check_seq(h_num[0], h_num[2], h_num[3]) && h_eq[1][4]) ||
        (is_char[0] && is_char[1] && is_char[4] && check_seq(h_num[0], h_num[1], h_num[4]) && h_eq[2][3]) ||
        (is_char[0] && is_char[1] && is_char[3] && check_seq(h_num[0], h_num[1], h_num[3]) && h_eq[2][4]) ||
        (is_char[0] && is_char[1] && is_char[2] && check_seq(h_num[0], h_num[1], h_num[2]) && h_eq[3][4]))  
        out_data = 2'b10; // seq + pair
    else 
        out_data = 2'b00;
end

endmodule
