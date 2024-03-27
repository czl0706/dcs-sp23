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

logic [11:0] cards, cards_nxt;
logic [1:0]  cnt, cnt_nxt;
logic out_data_nxt;
logic out_valid_nxt;

//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------

always_comb begin
    cards_nxt = in_valid ? {cards[7:0], in_data} : cards;
    cnt_nxt   = in_valid ? cnt + (cnt < 2) : 0;
    out_valid_nxt = (in_valid && (cnt == 2));
    out_data_nxt = out_valid_nxt && (
        ((cards_nxt[11:8] < cards_nxt[7:4]) && (cards_nxt[7:4] < cards_nxt[3:0])) || 
        ((cards_nxt[11:8] > cards_nxt[7:4]) && (cards_nxt[7:4] > cards_nxt[3:0])) );
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) cards <= 0;       
    else        cards <= cards_nxt;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) cnt <= 0;
    else        cnt <= cnt_nxt;
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
