module BCD(
  // Input signals
	in_bin,
  // Output signals
	out_hundred,
	out_ten,
	out_unit
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
//Input Ports
input [8:0] in_bin;

//output Ports
output logic [2:0]out_hundred;
output logic [3:0]out_ten;
output logic [3:0]out_unit;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [10:0] bcd_code;

//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------

// Double dabble
always_comb begin
	bcd_code = 11'h000;
	for (int i = 0; i <= 8; i = i + 1) begin
		if (bcd_code[10:8] >= 4'h5) bcd_code[10:8] = bcd_code[10:8] + 4'h3;
		if (bcd_code[7:4] >= 4'h5) bcd_code[7:4] = bcd_code[7:4] + 4'h3;
		if (bcd_code[3:0] >= 4'h5) bcd_code[3:0] = bcd_code[3:0] + 4'h3;

		bcd_code = {bcd_code[9:0], in_bin[8-i]};
	end
end

assign {out_hundred, out_ten, out_unit} = bcd_code;

endmodule