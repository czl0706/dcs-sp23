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

// // Decoder
// always_comb begin
// 	unique case (in_bin) 
// 		9'd0: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd0};
// 		9'd1: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd1};
// 		9'd2: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd2};
// 		9'd3: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd3};
// 		9'd4: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd4};
// 		9'd5: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd5};
// 		9'd6: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd6};
// 		9'd7: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd7};
// 		9'd8: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd8};
// 		9'd9: {out_hundred, out_ten, out_unit} = {3'd0, 4'd0, 4'd9};
// 		9'd10: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd0};
// 		9'd11: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd1};
// 		9'd12: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd2};
// 		9'd13: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd3};
// 		9'd14: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd4};
// 		9'd15: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd5};
// 		9'd16: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd6};
// 		9'd17: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd7};
// 		9'd18: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd8};
// 		9'd19: {out_hundred, out_ten, out_unit} = {3'd0, 4'd1, 4'd9};
// 		9'd20: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd0};
// 		9'd21: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd1};
// 		9'd22: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd2};
// 		9'd23: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd3};
// 		9'd24: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd4};
// 		9'd25: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd5};
// 		9'd26: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd6};
// 		9'd27: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd7};
// 		9'd28: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd8};
// 		9'd29: {out_hundred, out_ten, out_unit} = {3'd0, 4'd2, 4'd9};
// 		9'd30: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd0};
// 		9'd31: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd1};
// 		9'd32: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd2};
// 		9'd33: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd3};
// 		9'd34: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd4};
// 		9'd35: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd5};
// 		9'd36: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd6};
// 		9'd37: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd7};
// 		9'd38: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd8};
// 		9'd39: {out_hundred, out_ten, out_unit} = {3'd0, 4'd3, 4'd9};
// 		9'd40: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd0};
// 		9'd41: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd1};
// 		9'd42: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd2};
// 		9'd43: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd3};
// 		9'd44: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd4};
// 		9'd45: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd5};
// 		9'd46: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd6};
// 		9'd47: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd7};
// 		9'd48: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd8};
// 		9'd49: {out_hundred, out_ten, out_unit} = {3'd0, 4'd4, 4'd9};
// 		9'd50: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd0};
// 		9'd51: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd1};
// 		9'd52: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd2};
// 		9'd53: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd3};
// 		9'd54: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd4};
// 		9'd55: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd5};
// 		9'd56: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd6};
// 		9'd57: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd7};
// 		9'd58: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd8};
// 		9'd59: {out_hundred, out_ten, out_unit} = {3'd0, 4'd5, 4'd9};
// 		9'd60: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd0};
// 		9'd61: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd1};
// 		9'd62: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd2};
// 		9'd63: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd3};
// 		9'd64: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd4};
// 		9'd65: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd5};
// 		9'd66: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd6};
// 		9'd67: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd7};
// 		9'd68: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd8};
// 		9'd69: {out_hundred, out_ten, out_unit} = {3'd0, 4'd6, 4'd9};
// 		9'd70: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd0};
// 		9'd71: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd1};
// 		9'd72: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd2};
// 		9'd73: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd3};
// 		9'd74: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd4};
// 		9'd75: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd5};
// 		9'd76: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd6};
// 		9'd77: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd7};
// 		9'd78: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd8};
// 		9'd79: {out_hundred, out_ten, out_unit} = {3'd0, 4'd7, 4'd9};
// 		9'd80: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd0};
// 		9'd81: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd1};
// 		9'd82: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd2};
// 		9'd83: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd3};
// 		9'd84: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd4};
// 		9'd85: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd5};
// 		9'd86: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd6};
// 		9'd87: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd7};
// 		9'd88: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd8};
// 		9'd89: {out_hundred, out_ten, out_unit} = {3'd0, 4'd8, 4'd9};
// 		9'd90: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd0};
// 		9'd91: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd1};
// 		9'd92: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd2};
// 		9'd93: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd3};
// 		9'd94: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd4};
// 		9'd95: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd5};
// 		9'd96: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd6};
// 		9'd97: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd7};
// 		9'd98: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd8};
// 		9'd99: {out_hundred, out_ten, out_unit} = {3'd0, 4'd9, 4'd9};
// 		9'd100: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd0};
// 		9'd101: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd1};
// 		9'd102: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd2};
// 		9'd103: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd3};
// 		9'd104: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd4};
// 		9'd105: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd5};
// 		9'd106: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd6};
// 		9'd107: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd7};
// 		9'd108: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd8};
// 		9'd109: {out_hundred, out_ten, out_unit} = {3'd1, 4'd0, 4'd9};
// 		9'd110: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd0};
// 		9'd111: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd1};
// 		9'd112: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd2};
// 		9'd113: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd3};
// 		9'd114: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd4};
// 		9'd115: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd5};
// 		9'd116: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd6};
// 		9'd117: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd7};
// 		9'd118: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd8};
// 		9'd119: {out_hundred, out_ten, out_unit} = {3'd1, 4'd1, 4'd9};
// 		9'd120: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd0};
// 		9'd121: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd1};
// 		9'd122: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd2};
// 		9'd123: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd3};
// 		9'd124: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd4};
// 		9'd125: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd5};
// 		9'd126: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd6};
// 		9'd127: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd7};
// 		9'd128: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd8};
// 		9'd129: {out_hundred, out_ten, out_unit} = {3'd1, 4'd2, 4'd9};
// 		9'd130: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd0};
// 		9'd131: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd1};
// 		9'd132: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd2};
// 		9'd133: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd3};
// 		9'd134: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd4};
// 		9'd135: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd5};
// 		9'd136: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd6};
// 		9'd137: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd7};
// 		9'd138: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd8};
// 		9'd139: {out_hundred, out_ten, out_unit} = {3'd1, 4'd3, 4'd9};
// 		9'd140: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd0};
// 		9'd141: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd1};
// 		9'd142: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd2};
// 		9'd143: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd3};
// 		9'd144: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd4};
// 		9'd145: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd5};
// 		9'd146: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd6};
// 		9'd147: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd7};
// 		9'd148: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd8};
// 		9'd149: {out_hundred, out_ten, out_unit} = {3'd1, 4'd4, 4'd9};
// 		9'd150: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd0};
// 		9'd151: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd1};
// 		9'd152: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd2};
// 		9'd153: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd3};
// 		9'd154: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd4};
// 		9'd155: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd5};
// 		9'd156: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd6};
// 		9'd157: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd7};
// 		9'd158: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd8};
// 		9'd159: {out_hundred, out_ten, out_unit} = {3'd1, 4'd5, 4'd9};
// 		9'd160: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd0};
// 		9'd161: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd1};
// 		9'd162: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd2};
// 		9'd163: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd3};
// 		9'd164: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd4};
// 		9'd165: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd5};
// 		9'd166: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd6};
// 		9'd167: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd7};
// 		9'd168: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd8};
// 		9'd169: {out_hundred, out_ten, out_unit} = {3'd1, 4'd6, 4'd9};
// 		9'd170: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd0};
// 		9'd171: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd1};
// 		9'd172: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd2};
// 		9'd173: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd3};
// 		9'd174: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd4};
// 		9'd175: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd5};
// 		9'd176: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd6};
// 		9'd177: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd7};
// 		9'd178: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd8};
// 		9'd179: {out_hundred, out_ten, out_unit} = {3'd1, 4'd7, 4'd9};
// 		9'd180: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd0};
// 		9'd181: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd1};
// 		9'd182: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd2};
// 		9'd183: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd3};
// 		9'd184: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd4};
// 		9'd185: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd5};
// 		9'd186: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd6};
// 		9'd187: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd7};
// 		9'd188: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd8};
// 		9'd189: {out_hundred, out_ten, out_unit} = {3'd1, 4'd8, 4'd9};
// 		9'd190: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd0};
// 		9'd191: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd1};
// 		9'd192: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd2};
// 		9'd193: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd3};
// 		9'd194: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd4};
// 		9'd195: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd5};
// 		9'd196: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd6};
// 		9'd197: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd7};
// 		9'd198: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd8};
// 		9'd199: {out_hundred, out_ten, out_unit} = {3'd1, 4'd9, 4'd9};
// 		9'd200: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd0};
// 		9'd201: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd1};
// 		9'd202: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd2};
// 		9'd203: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd3};
// 		9'd204: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd4};
// 		9'd205: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd5};
// 		9'd206: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd6};
// 		9'd207: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd7};
// 		9'd208: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd8};
// 		9'd209: {out_hundred, out_ten, out_unit} = {3'd2, 4'd0, 4'd9};
// 		9'd210: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd0};
// 		9'd211: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd1};
// 		9'd212: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd2};
// 		9'd213: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd3};
// 		9'd214: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd4};
// 		9'd215: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd5};
// 		9'd216: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd6};
// 		9'd217: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd7};
// 		9'd218: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd8};
// 		9'd219: {out_hundred, out_ten, out_unit} = {3'd2, 4'd1, 4'd9};
// 		9'd220: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd0};
// 		9'd221: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd1};
// 		9'd222: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd2};
// 		9'd223: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd3};
// 		9'd224: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd4};
// 		9'd225: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd5};
// 		9'd226: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd6};
// 		9'd227: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd7};
// 		9'd228: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd8};
// 		9'd229: {out_hundred, out_ten, out_unit} = {3'd2, 4'd2, 4'd9};
// 		9'd230: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd0};
// 		9'd231: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd1};
// 		9'd232: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd2};
// 		9'd233: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd3};
// 		9'd234: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd4};
// 		9'd235: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd5};
// 		9'd236: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd6};
// 		9'd237: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd7};
// 		9'd238: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd8};
// 		9'd239: {out_hundred, out_ten, out_unit} = {3'd2, 4'd3, 4'd9};
// 		9'd240: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd0};
// 		9'd241: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd1};
// 		9'd242: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd2};
// 		9'd243: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd3};
// 		9'd244: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd4};
// 		9'd245: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd5};
// 		9'd246: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd6};
// 		9'd247: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd7};
// 		9'd248: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd8};
// 		9'd249: {out_hundred, out_ten, out_unit} = {3'd2, 4'd4, 4'd9};
// 		9'd250: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd0};
// 		9'd251: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd1};
// 		9'd252: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd2};
// 		9'd253: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd3};
// 		9'd254: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd4};
// 		9'd255: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd5};
// 		9'd256: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd6};
// 		9'd257: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd7};
// 		9'd258: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd8};
// 		9'd259: {out_hundred, out_ten, out_unit} = {3'd2, 4'd5, 4'd9};
// 		9'd260: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd0};
// 		9'd261: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd1};
// 		9'd262: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd2};
// 		9'd263: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd3};
// 		9'd264: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd4};
// 		9'd265: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd5};
// 		9'd266: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd6};
// 		9'd267: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd7};
// 		9'd268: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd8};
// 		9'd269: {out_hundred, out_ten, out_unit} = {3'd2, 4'd6, 4'd9};
// 		9'd270: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd0};
// 		9'd271: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd1};
// 		9'd272: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd2};
// 		9'd273: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd3};
// 		9'd274: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd4};
// 		9'd275: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd5};
// 		9'd276: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd6};
// 		9'd277: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd7};
// 		9'd278: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd8};
// 		9'd279: {out_hundred, out_ten, out_unit} = {3'd2, 4'd7, 4'd9};
// 		9'd280: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd0};
// 		9'd281: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd1};
// 		9'd282: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd2};
// 		9'd283: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd3};
// 		9'd284: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd4};
// 		9'd285: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd5};
// 		9'd286: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd6};
// 		9'd287: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd7};
// 		9'd288: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd8};
// 		9'd289: {out_hundred, out_ten, out_unit} = {3'd2, 4'd8, 4'd9};
// 		9'd290: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd0};
// 		9'd291: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd1};
// 		9'd292: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd2};
// 		9'd293: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd3};
// 		9'd294: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd4};
// 		9'd295: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd5};
// 		9'd296: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd6};
// 		9'd297: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd7};
// 		9'd298: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd8};
// 		9'd299: {out_hundred, out_ten, out_unit} = {3'd2, 4'd9, 4'd9};
// 		9'd300: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd0};
// 		9'd301: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd1};
// 		9'd302: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd2};
// 		9'd303: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd3};
// 		9'd304: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd4};
// 		9'd305: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd5};
// 		9'd306: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd6};
// 		9'd307: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd7};
// 		9'd308: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd8};
// 		9'd309: {out_hundred, out_ten, out_unit} = {3'd3, 4'd0, 4'd9};
// 		9'd310: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd0};
// 		9'd311: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd1};
// 		9'd312: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd2};
// 		9'd313: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd3};
// 		9'd314: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd4};
// 		9'd315: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd5};
// 		9'd316: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd6};
// 		9'd317: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd7};
// 		9'd318: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd8};
// 		9'd319: {out_hundred, out_ten, out_unit} = {3'd3, 4'd1, 4'd9};
// 		9'd320: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd0};
// 		9'd321: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd1};
// 		9'd322: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd2};
// 		9'd323: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd3};
// 		9'd324: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd4};
// 		9'd325: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd5};
// 		9'd326: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd6};
// 		9'd327: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd7};
// 		9'd328: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd8};
// 		9'd329: {out_hundred, out_ten, out_unit} = {3'd3, 4'd2, 4'd9};
// 		9'd330: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd0};
// 		9'd331: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd1};
// 		9'd332: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd2};
// 		9'd333: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd3};
// 		9'd334: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd4};
// 		9'd335: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd5};
// 		9'd336: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd6};
// 		9'd337: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd7};
// 		9'd338: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd8};
// 		9'd339: {out_hundred, out_ten, out_unit} = {3'd3, 4'd3, 4'd9};
// 		9'd340: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd0};
// 		9'd341: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd1};
// 		9'd342: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd2};
// 		9'd343: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd3};
// 		9'd344: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd4};
// 		9'd345: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd5};
// 		9'd346: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd6};
// 		9'd347: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd7};
// 		9'd348: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd8};
// 		9'd349: {out_hundred, out_ten, out_unit} = {3'd3, 4'd4, 4'd9};
// 		9'd350: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd0};
// 		9'd351: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd1};
// 		9'd352: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd2};
// 		9'd353: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd3};
// 		9'd354: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd4};
// 		9'd355: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd5};
// 		9'd356: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd6};
// 		9'd357: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd7};
// 		9'd358: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd8};
// 		9'd359: {out_hundred, out_ten, out_unit} = {3'd3, 4'd5, 4'd9};
// 		9'd360: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd0};
// 		9'd361: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd1};
// 		9'd362: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd2};
// 		9'd363: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd3};
// 		9'd364: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd4};
// 		9'd365: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd5};
// 		9'd366: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd6};
// 		9'd367: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd7};
// 		9'd368: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd8};
// 		9'd369: {out_hundred, out_ten, out_unit} = {3'd3, 4'd6, 4'd9};
// 		9'd370: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd0};
// 		9'd371: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd1};
// 		9'd372: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd2};
// 		9'd373: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd3};
// 		9'd374: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd4};
// 		9'd375: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd5};
// 		9'd376: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd6};
// 		9'd377: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd7};
// 		9'd378: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd8};
// 		9'd379: {out_hundred, out_ten, out_unit} = {3'd3, 4'd7, 4'd9};
// 		9'd380: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd0};
// 		9'd381: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd1};
// 		9'd382: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd2};
// 		9'd383: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd3};
// 		9'd384: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd4};
// 		9'd385: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd5};
// 		9'd386: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd6};
// 		9'd387: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd7};
// 		9'd388: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd8};
// 		9'd389: {out_hundred, out_ten, out_unit} = {3'd3, 4'd8, 4'd9};
// 		9'd390: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd0};
// 		9'd391: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd1};
// 		9'd392: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd2};
// 		9'd393: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd3};
// 		9'd394: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd4};
// 		9'd395: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd5};
// 		9'd396: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd6};
// 		9'd397: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd7};
// 		9'd398: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd8};
// 		9'd399: {out_hundred, out_ten, out_unit} = {3'd3, 4'd9, 4'd9};
// 		9'd400: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd0};
// 		9'd401: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd1};
// 		9'd402: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd2};
// 		9'd403: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd3};
// 		9'd404: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd4};
// 		9'd405: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd5};
// 		9'd406: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd6};
// 		9'd407: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd7};
// 		9'd408: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd8};
// 		9'd409: {out_hundred, out_ten, out_unit} = {3'd4, 4'd0, 4'd9};
// 		9'd410: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd0};
// 		9'd411: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd1};
// 		9'd412: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd2};
// 		9'd413: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd3};
// 		9'd414: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd4};
// 		9'd415: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd5};
// 		9'd416: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd6};
// 		9'd417: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd7};
// 		9'd418: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd8};
// 		9'd419: {out_hundred, out_ten, out_unit} = {3'd4, 4'd1, 4'd9};
// 		9'd420: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd0};
// 		9'd421: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd1};
// 		9'd422: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd2};
// 		9'd423: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd3};
// 		9'd424: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd4};
// 		9'd425: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd5};
// 		9'd426: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd6};
// 		9'd427: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd7};
// 		9'd428: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd8};
// 		9'd429: {out_hundred, out_ten, out_unit} = {3'd4, 4'd2, 4'd9};
// 		9'd430: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd0};
// 		9'd431: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd1};
// 		9'd432: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd2};
// 		9'd433: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd3};
// 		9'd434: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd4};
// 		9'd435: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd5};
// 		9'd436: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd6};
// 		9'd437: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd7};
// 		9'd438: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd8};
// 		9'd439: {out_hundred, out_ten, out_unit} = {3'd4, 4'd3, 4'd9};
// 		9'd440: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd0};
// 		9'd441: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd1};
// 		9'd442: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd2};
// 		9'd443: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd3};
// 		9'd444: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd4};
// 		9'd445: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd5};
// 		9'd446: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd6};
// 		9'd447: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd7};
// 		9'd448: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd8};
// 		9'd449: {out_hundred, out_ten, out_unit} = {3'd4, 4'd4, 4'd9};
// 		9'd450: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd0};
// 		9'd451: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd1};
// 		9'd452: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd2};
// 		9'd453: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd3};
// 		9'd454: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd4};
// 		9'd455: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd5};
// 		9'd456: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd6};
// 		9'd457: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd7};
// 		9'd458: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd8};
// 		9'd459: {out_hundred, out_ten, out_unit} = {3'd4, 4'd5, 4'd9};
// 		9'd460: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd0};
// 		9'd461: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd1};
// 		9'd462: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd2};
// 		9'd463: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd3};
// 		9'd464: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd4};
// 		9'd465: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd5};
// 		9'd466: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd6};
// 		9'd467: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd7};
// 		9'd468: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd8};
// 		9'd469: {out_hundred, out_ten, out_unit} = {3'd4, 4'd6, 4'd9};
// 		9'd470: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd0};
// 		9'd471: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd1};
// 		9'd472: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd2};
// 		9'd473: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd3};
// 		9'd474: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd4};
// 		9'd475: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd5};
// 		9'd476: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd6};
// 		9'd477: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd7};
// 		9'd478: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd8};
// 		9'd479: {out_hundred, out_ten, out_unit} = {3'd4, 4'd7, 4'd9};
// 		9'd480: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd0};
// 		9'd481: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd1};
// 		9'd482: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd2};
// 		9'd483: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd3};
// 		9'd484: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd4};
// 		9'd485: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd5};
// 		9'd486: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd6};
// 		9'd487: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd7};
// 		9'd488: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd8};
// 		9'd489: {out_hundred, out_ten, out_unit} = {3'd4, 4'd8, 4'd9};
// 		9'd490: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd0};
// 		9'd491: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd1};
// 		9'd492: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd2};
// 		9'd493: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd3};
// 		9'd494: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd4};
// 		9'd495: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd5};
// 		9'd496: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd6};
// 		9'd497: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd7};
// 		9'd498: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd8};
// 		9'd499: {out_hundred, out_ten, out_unit} = {3'd4, 4'd9, 4'd9};
// 		9'd500: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd0};
// 		9'd501: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd1};
// 		9'd502: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd2};
// 		9'd503: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd3};
// 		9'd504: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd4};
// 		9'd505: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd5};
// 		9'd506: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd6};
// 		9'd507: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd7};
// 		9'd508: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd8};
// 		9'd509: {out_hundred, out_ten, out_unit} = {3'd5, 4'd0, 4'd9};
// 		9'd510: {out_hundred, out_ten, out_unit} = {3'd5, 4'd1, 4'd0};
// 		9'd511: {out_hundred, out_ten, out_unit} = {3'd5, 4'd1, 4'd1};
// 	endcase
// end

// //---------------------------------------------------------------------
// //   LOGIC DECLARATION
// //---------------------------------------------------------------------
// logic [10:0] bcd_code;
// logic [3:0]  inet[8:0];

// //---------------------------------------------------------------------
// //   Your DESIGN                        
// //---------------------------------------------------------------------

// always_comb begin
// 	plus_3({1'b0, in_bin[8:6]}, inet[0]);
// 	plus_3({inet[0][2:0], in_bin[5]}, inet[1]);
// 	plus_3({inet[1][2:0], in_bin[4]}, inet[2]);
// 	plus_3({inet[2][2:0], in_bin[3]}, inet[3]);
// 	plus_3({inet[3][2:0], in_bin[2]}, inet[4]);
// 	plus_3({inet[4][2:0], in_bin[1]}, inet[5]);

// 	plus_3({1'b0, inet[0][3], inet[1][3], inet[2][3]}, inet[6]);
// 	plus_3({inet[6][2:0], inet[3][3]}, inet[7]);
// 	plus_3({inet[7][2:0], inet[4][3]}, inet[8]);
// end

// assign out_hundred = {inet[6][3], inet[7][3], inet[8][3]};
// assign out_ten = {inet[8][2:0], inet[5][3]};
// assign out_unit = {inet[5][2:0], in_bin[0]};

// task plus_3;
// 	input  [3:0] bin_in;
// 	output [3:0] bin_out;
// 	bin_out = bin_in >= 4'h5 ? bin_in + 4'h3 : bin_in;
// endtask
