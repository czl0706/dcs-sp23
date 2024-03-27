module Counter(
    // Input signals
	clk,
	rst_n,
    // Output signals
	clk2
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n;
output logic clk2;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

logic [1:0] cnt, cnt_nxt;

//---------------------------------------------------------------------
//   Your design
//---------------------------------------------------------------------

assign cnt_nxt = cnt + 1;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        cnt <= 1;
    else
        cnt <= cnt_nxt;     
end

assign clk2 = cnt[1];

// parameter DIVISION = 4;

// assign cnt_nxt = (cnt == DIVISION - 1) ? 0 : cnt + 1;

// always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) 
//         cnt <= 0;
//     else
//         cnt <= cnt_nxt;     
// end

// always_ff @(posedge clk or negedge rst_n) begin
//     if (!rst_n) 
//         clk2 <= 0;
//     else
//         clk2 <= (cnt < DIVISION / 2);    
// end

endmodule