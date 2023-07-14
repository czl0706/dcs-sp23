module Seq(
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
input clk, rst_n, in_valid;
input [3:0] in_data;
output logic out_valid;
output logic out_data;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------

logic [7:0] cards, cards_nxt;
logic out_data_nxt;
logic out_valid_nxt;

//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------

always_comb begin
    cards_nxt = in_valid ? {cards[3:0], in_data} : 0;
    out_valid_nxt = (in_valid && |cards[7:4] && |cards[3:0]);
    out_data_nxt = out_valid_nxt && (
        ((cards[7:4] < cards[3:0]) && (cards[3:0] < in_data)) || 
        ((cards[7:4] > cards[3:0]) && (cards[3:0] > in_data)) );
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) cards <= 0;       
    else        cards <= cards_nxt;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) out_valid <= 0;
    else        out_valid <= out_valid_nxt;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) out_data <= 0;
    else        out_data <= out_data_nxt;
end

endmodule
