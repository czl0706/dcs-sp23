module HE(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_image,
  // Output signals
	out_valid,
	out_image
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input				clk,rst_n,in_valid;
input [7:0]			in_image;
output logic 		out_valid;
output logic [7:0]	out_image;

//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------

parameter [1:0] IDLE = 0, PXL_IN = 2, STAT = 1, DUMP = 3;

//---------------------------------------------------------------------
//   LOGIC DECLARATION                             
//---------------------------------------------------------------------

logic out_valid_nxt;
logic [7:0]	out_image_nxt;

logic [63:0] raw_pixel;
logic [63:0] raw_pixel_nxt;

logic [9:0] hist 		[0:7];
logic [9:0] hist_nxt 	[0:7];

logic [1:0] state, state_nxt;

logic [9:0] counter, counter_nxt;

//---------------------------------------------------------------------
//   Finite-State Mechine                                          
//---------------------------------------------------------------------

logic [7:0]	hist_to_img, hist_to_img_la;

always_comb begin
	state_nxt = state;
	raw_pixel_nxt = raw_pixel;
	
	hist_nxt[0] = hist[0];  
	hist_nxt[1] = hist[1]; 
	hist_nxt[2] = hist[2]; 
	hist_nxt[3] = hist[3]; 
	hist_nxt[4] = hist[4]; 
	hist_nxt[5] = hist[5]; 
	hist_nxt[6] = hist[6]; 
	hist_nxt[7] = hist[7]; 

	counter_nxt = counter + 1;

	out_valid_nxt = 0;
	out_image_nxt = 0;

	case (state) 
		IDLE: begin
			if (in_valid) begin
				raw_pixel_nxt[63:56] = in_image;
				counter_nxt = 0;
				state_nxt = PXL_IN;
			end
		end
		PXL_IN: begin
			case (counter) 
				0: raw_pixel_nxt[55:48] = in_image;
				1: raw_pixel_nxt[47:40] = in_image;
				2: raw_pixel_nxt[39:32] = in_image;
				3: raw_pixel_nxt[31:24] = in_image;
				4: raw_pixel_nxt[23:16] = in_image;
				5: raw_pixel_nxt[15:8]  = in_image;
				6: raw_pixel_nxt[7:0]   = in_image;
			endcase 

			if (counter == 6) begin
				state_nxt = STAT;
				hist_nxt[0] = 0; 
				hist_nxt[1] = 0;
				hist_nxt[2] = 0;
				hist_nxt[3] = 0;
				hist_nxt[4] = 0;
				hist_nxt[5] = 0;
				hist_nxt[6] = 0;
				hist_nxt[7] = 0;
				counter_nxt = 0;
			end
		end	
		STAT: begin
			hist_nxt[0] = (hist[0] == 1023) ? hist[0] : hist[0] + (in_image <= raw_pixel[7:0]  );  
			hist_nxt[1] = (hist[1] == 1023) ? hist[1] : hist[1] + (in_image <= raw_pixel[15:8] ); 
			hist_nxt[2] = (hist[2] == 1023) ? hist[2] : hist[2] + (in_image <= raw_pixel[23:16]); 
			hist_nxt[3] = (hist[3] == 1023) ? hist[3] : hist[3] + (in_image <= raw_pixel[31:24]); 
			hist_nxt[4] = (hist[4] == 1023) ? hist[4] : hist[4] + (in_image <= raw_pixel[39:32]); 
			hist_nxt[5] = (hist[5] == 1023) ? hist[5] : hist[5] + (in_image <= raw_pixel[47:40]); 
			hist_nxt[6] = (hist[6] == 1023) ? hist[6] : hist[6] + (in_image <= raw_pixel[55:48]); 
			hist_nxt[7] = (hist[7] == 1023) ? hist[7] : hist[7] + (in_image <= raw_pixel[63:56]); 

			if (counter == 1023) begin
				state_nxt = DUMP;
				counter_nxt = 0;

				hist_nxt[7] = hist_nxt[6];

				if (in_image <= raw_pixel[63:56])
					out_image_nxt = hist_to_img_la;
				else 
					out_image_nxt = hist_to_img;
					
				out_valid_nxt = 1;
			end
		end
		DUMP: begin
			if (counter == 6) begin
				state_nxt = IDLE;
			end
			
			case (counter) 
				0: hist_nxt[7] = hist[5];
				1: hist_nxt[7] = hist[4];
				2: hist_nxt[7] = hist[3];
				3: hist_nxt[7] = hist[2];
				4: hist_nxt[7] = hist[1];
				5: hist_nxt[7] = hist[0];
			endcase 

			out_image_nxt = hist_to_img;
			out_valid_nxt = 1;
		end
	endcase
end

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state 	  <= IDLE;
		out_valid <= 0;
		out_image <= 0;
	end
	else begin
		state 	  <= state_nxt;
		out_valid <= out_valid_nxt;
		out_image <= out_image_nxt;
	end
end

always_ff @(posedge clk) begin
	hist[0] <= hist_nxt[0];
	hist[1] <= hist_nxt[1];
	hist[2] <= hist_nxt[2];
	hist[3] <= hist_nxt[3];
	hist[4] <= hist_nxt[4];
	hist[5] <= hist_nxt[5];
	hist[6] <= hist_nxt[6];
	hist[7] <= hist_nxt[7];	
end

always_ff @(posedge clk) begin
	counter	  <= counter_nxt;
	raw_pixel <= raw_pixel_nxt;
end

always_comb begin
	case (hist[7])
		10'd0, 10'd1, 10'd2, 10'd3, 10'd4, 10'd5, 10'd6, 10'd7, 10'd8: hist_to_img = 0;
		10'd9, 10'd10, 10'd11, 10'd12, 10'd13: hist_to_img = 1;
		10'd14, 10'd15, 10'd16, 10'd17: hist_to_img = 2;
		10'd18, 10'd19, 10'd20, 10'd21: hist_to_img = 3;
		10'd22, 10'd23, 10'd24, 10'd25, 10'd26: hist_to_img = 4;
		10'd27, 10'd28, 10'd29, 10'd30: hist_to_img = 5;
		10'd31, 10'd32, 10'd33, 10'd34: hist_to_img = 6;
		10'd35, 10'd36, 10'd37, 10'd38, 10'd39: hist_to_img = 7;
		10'd40, 10'd41, 10'd42, 10'd43: hist_to_img = 8;
		10'd44, 10'd45, 10'd46, 10'd47, 10'd48: hist_to_img = 9;
		10'd49, 10'd50, 10'd51, 10'd52: hist_to_img = 10;
		10'd53, 10'd54, 10'd55, 10'd56: hist_to_img = 11;
		10'd57, 10'd58, 10'd59, 10'd60, 10'd61: hist_to_img = 12;
		10'd62, 10'd63, 10'd64, 10'd65: hist_to_img = 13;
		10'd66, 10'd67, 10'd68, 10'd69: hist_to_img = 14;
		10'd70, 10'd71, 10'd72, 10'd73, 10'd74: hist_to_img = 15;
		10'd75, 10'd76, 10'd77, 10'd78: hist_to_img = 16;
		10'd79, 10'd80, 10'd81, 10'd82: hist_to_img = 17;
		10'd83, 10'd84, 10'd85, 10'd86, 10'd87: hist_to_img = 18;
		10'd88, 10'd89, 10'd90, 10'd91: hist_to_img = 19;
		10'd92, 10'd93, 10'd94, 10'd95, 10'd96: hist_to_img = 20;
		10'd97, 10'd98, 10'd99, 10'd100: hist_to_img = 21;
		10'd101, 10'd102, 10'd103, 10'd104: hist_to_img = 22;
		10'd105, 10'd106, 10'd107, 10'd108, 10'd109: hist_to_img = 23;
		10'd110, 10'd111, 10'd112, 10'd113: hist_to_img = 24;
		10'd114, 10'd115, 10'd116, 10'd117: hist_to_img = 25;
		10'd118, 10'd119, 10'd120, 10'd121, 10'd122: hist_to_img = 26;
		10'd123, 10'd124, 10'd125, 10'd126: hist_to_img = 27;
		10'd127, 10'd128, 10'd129, 10'd130, 10'd131: hist_to_img = 28;
		10'd132, 10'd133, 10'd134, 10'd135: hist_to_img = 29;
		10'd136, 10'd137, 10'd138, 10'd139: hist_to_img = 30;
		10'd140, 10'd141, 10'd142, 10'd143, 10'd144: hist_to_img = 31;
		10'd145, 10'd146, 10'd147, 10'd148: hist_to_img = 32;
		10'd149, 10'd150, 10'd151, 10'd152: hist_to_img = 33;
		10'd153, 10'd154, 10'd155, 10'd156, 10'd157: hist_to_img = 34;
		10'd158, 10'd159, 10'd160, 10'd161: hist_to_img = 35;
		10'd162, 10'd163, 10'd164, 10'd165: hist_to_img = 36;
		10'd166, 10'd167, 10'd168, 10'd169, 10'd170: hist_to_img = 37;
		10'd171, 10'd172, 10'd173, 10'd174: hist_to_img = 38;
		10'd175, 10'd176, 10'd177, 10'd178, 10'd179: hist_to_img = 39;
		10'd180, 10'd181, 10'd182, 10'd183: hist_to_img = 40;
		10'd184, 10'd185, 10'd186, 10'd187: hist_to_img = 41;
		10'd188, 10'd189, 10'd190, 10'd191, 10'd192: hist_to_img = 42;
		10'd193, 10'd194, 10'd195, 10'd196: hist_to_img = 43;
		10'd197, 10'd198, 10'd199, 10'd200: hist_to_img = 44;
		10'd201, 10'd202, 10'd203, 10'd204, 10'd205: hist_to_img = 45;
		10'd206, 10'd207, 10'd208, 10'd209: hist_to_img = 46;
		10'd210, 10'd211, 10'd212, 10'd213, 10'd214: hist_to_img = 47;
		10'd215, 10'd216, 10'd217, 10'd218: hist_to_img = 48;
		10'd219, 10'd220, 10'd221, 10'd222: hist_to_img = 49;
		10'd223, 10'd224, 10'd225, 10'd226, 10'd227: hist_to_img = 50;
		10'd228, 10'd229, 10'd230, 10'd231: hist_to_img = 51;
		10'd232, 10'd233, 10'd234, 10'd235: hist_to_img = 52;
		10'd236, 10'd237, 10'd238, 10'd239, 10'd240: hist_to_img = 53;
		10'd241, 10'd242, 10'd243, 10'd244: hist_to_img = 54;
		10'd245, 10'd246, 10'd247, 10'd248: hist_to_img = 55;
		10'd249, 10'd250, 10'd251, 10'd252, 10'd253: hist_to_img = 56;
		10'd254, 10'd255, 10'd256, 10'd257: hist_to_img = 57;
		10'd258, 10'd259, 10'd260, 10'd261, 10'd262: hist_to_img = 58;
		10'd263, 10'd264, 10'd265, 10'd266: hist_to_img = 59;
		10'd267, 10'd268, 10'd269, 10'd270: hist_to_img = 60;
		10'd271, 10'd272, 10'd273, 10'd274, 10'd275: hist_to_img = 61;
		10'd276, 10'd277, 10'd278, 10'd279: hist_to_img = 62;
		10'd280, 10'd281, 10'd282, 10'd283: hist_to_img = 63;
		10'd284, 10'd285, 10'd286, 10'd287, 10'd288: hist_to_img = 64;
		10'd289, 10'd290, 10'd291, 10'd292: hist_to_img = 65;
		10'd293, 10'd294, 10'd295, 10'd296, 10'd297: hist_to_img = 66;
		10'd298, 10'd299, 10'd300, 10'd301: hist_to_img = 67;
		10'd302, 10'd303, 10'd304, 10'd305: hist_to_img = 68;
		10'd306, 10'd307, 10'd308, 10'd309, 10'd310: hist_to_img = 69;
		10'd311, 10'd312, 10'd313, 10'd314: hist_to_img = 70;
		10'd315, 10'd316, 10'd317, 10'd318: hist_to_img = 71;
		10'd319, 10'd320, 10'd321, 10'd322, 10'd323: hist_to_img = 72;
		10'd324, 10'd325, 10'd326, 10'd327: hist_to_img = 73;
		10'd328, 10'd329, 10'd330, 10'd331: hist_to_img = 74;
		10'd332, 10'd333, 10'd334, 10'd335, 10'd336: hist_to_img = 75;
		10'd337, 10'd338, 10'd339, 10'd340: hist_to_img = 76;
		10'd341, 10'd342, 10'd343, 10'd344, 10'd345: hist_to_img = 77;
		10'd346, 10'd347, 10'd348, 10'd349: hist_to_img = 78;
		10'd350, 10'd351, 10'd352, 10'd353: hist_to_img = 79;
		10'd354, 10'd355, 10'd356, 10'd357, 10'd358: hist_to_img = 80;
		10'd359, 10'd360, 10'd361, 10'd362: hist_to_img = 81;
		10'd363, 10'd364, 10'd365, 10'd366: hist_to_img = 82;
		10'd367, 10'd368, 10'd369, 10'd370, 10'd371: hist_to_img = 83;
		10'd372, 10'd373, 10'd374, 10'd375: hist_to_img = 84;
		10'd376, 10'd377, 10'd378, 10'd379, 10'd380: hist_to_img = 85;
		10'd381, 10'd382, 10'd383, 10'd384: hist_to_img = 86;
		10'd385, 10'd386, 10'd387, 10'd388: hist_to_img = 87;
		10'd389, 10'd390, 10'd391, 10'd392, 10'd393: hist_to_img = 88;
		10'd394, 10'd395, 10'd396, 10'd397: hist_to_img = 89;
		10'd398, 10'd399, 10'd400, 10'd401: hist_to_img = 90;
		10'd402, 10'd403, 10'd404, 10'd405, 10'd406: hist_to_img = 91;
		10'd407, 10'd408, 10'd409, 10'd410: hist_to_img = 92;
		10'd411, 10'd412, 10'd413, 10'd414: hist_to_img = 93;
		10'd415, 10'd416, 10'd417, 10'd418, 10'd419: hist_to_img = 94;
		10'd420, 10'd421, 10'd422, 10'd423: hist_to_img = 95;
		10'd424, 10'd425, 10'd426, 10'd427, 10'd428: hist_to_img = 96;
		10'd429, 10'd430, 10'd431, 10'd432: hist_to_img = 97;
		10'd433, 10'd434, 10'd435, 10'd436: hist_to_img = 98;
		10'd437, 10'd438, 10'd439, 10'd440, 10'd441: hist_to_img = 99;
		10'd442, 10'd443, 10'd444, 10'd445: hist_to_img = 100;
		10'd446, 10'd447, 10'd448, 10'd449: hist_to_img = 101;
		10'd450, 10'd451, 10'd452, 10'd453, 10'd454: hist_to_img = 102;
		10'd455, 10'd456, 10'd457, 10'd458: hist_to_img = 103;
		10'd459, 10'd460, 10'd461, 10'd462, 10'd463: hist_to_img = 104;
		10'd464, 10'd465, 10'd466, 10'd467: hist_to_img = 105;
		10'd468, 10'd469, 10'd470, 10'd471: hist_to_img = 106;
		10'd472, 10'd473, 10'd474, 10'd475, 10'd476: hist_to_img = 107;
		10'd477, 10'd478, 10'd479, 10'd480: hist_to_img = 108;
		10'd481, 10'd482, 10'd483, 10'd484: hist_to_img = 109;
		10'd485, 10'd486, 10'd487, 10'd488, 10'd489: hist_to_img = 110;
		10'd490, 10'd491, 10'd492, 10'd493: hist_to_img = 111;
		10'd494, 10'd495, 10'd496, 10'd497: hist_to_img = 112;
		10'd498, 10'd499, 10'd500, 10'd501, 10'd502: hist_to_img = 113;
		10'd503, 10'd504, 10'd505, 10'd506: hist_to_img = 114;
		10'd507, 10'd508, 10'd509, 10'd510, 10'd511: hist_to_img = 115;
		10'd512, 10'd513, 10'd514, 10'd515: hist_to_img = 116;
		10'd516, 10'd517, 10'd518, 10'd519: hist_to_img = 117;
		10'd520, 10'd521, 10'd522, 10'd523, 10'd524: hist_to_img = 118;
		10'd525, 10'd526, 10'd527, 10'd528: hist_to_img = 119;
		10'd529, 10'd530, 10'd531, 10'd532: hist_to_img = 120;
		10'd533, 10'd534, 10'd535, 10'd536, 10'd537: hist_to_img = 121;
		10'd538, 10'd539, 10'd540, 10'd541: hist_to_img = 122;
		10'd542, 10'd543, 10'd544, 10'd545, 10'd546: hist_to_img = 123;
		10'd547, 10'd548, 10'd549, 10'd550: hist_to_img = 124;
		10'd551, 10'd552, 10'd553, 10'd554: hist_to_img = 125;
		10'd555, 10'd556, 10'd557, 10'd558, 10'd559: hist_to_img = 126;
		10'd560, 10'd561, 10'd562, 10'd563: hist_to_img = 127;
		10'd564, 10'd565, 10'd566, 10'd567: hist_to_img = 128;
		10'd568, 10'd569, 10'd570, 10'd571, 10'd572: hist_to_img = 129;
		10'd573, 10'd574, 10'd575, 10'd576: hist_to_img = 130;
		10'd577, 10'd578, 10'd579, 10'd580: hist_to_img = 131;
		10'd581, 10'd582, 10'd583, 10'd584, 10'd585: hist_to_img = 132;
		10'd586, 10'd587, 10'd588, 10'd589: hist_to_img = 133;
		10'd590, 10'd591, 10'd592, 10'd593, 10'd594: hist_to_img = 134;
		10'd595, 10'd596, 10'd597, 10'd598: hist_to_img = 135;
		10'd599, 10'd600, 10'd601, 10'd602: hist_to_img = 136;
		10'd603, 10'd604, 10'd605, 10'd606, 10'd607: hist_to_img = 137;
		10'd608, 10'd609, 10'd610, 10'd611: hist_to_img = 138;
		10'd612, 10'd613, 10'd614, 10'd615: hist_to_img = 139;
		10'd616, 10'd617, 10'd618, 10'd619, 10'd620: hist_to_img = 140;
		10'd621, 10'd622, 10'd623, 10'd624: hist_to_img = 141;
		10'd625, 10'd626, 10'd627, 10'd628, 10'd629: hist_to_img = 142;
		10'd630, 10'd631, 10'd632, 10'd633: hist_to_img = 143;
		10'd634, 10'd635, 10'd636, 10'd637: hist_to_img = 144;
		10'd638, 10'd639, 10'd640, 10'd641, 10'd642: hist_to_img = 145;
		10'd643, 10'd644, 10'd645, 10'd646: hist_to_img = 146;
		10'd647, 10'd648, 10'd649, 10'd650: hist_to_img = 147;
		10'd651, 10'd652, 10'd653, 10'd654, 10'd655: hist_to_img = 148;
		10'd656, 10'd657, 10'd658, 10'd659: hist_to_img = 149;
		10'd660, 10'd661, 10'd662, 10'd663: hist_to_img = 150;
		10'd664, 10'd665, 10'd666, 10'd667, 10'd668: hist_to_img = 151;
		10'd669, 10'd670, 10'd671, 10'd672: hist_to_img = 152;
		10'd673, 10'd674, 10'd675, 10'd676, 10'd677: hist_to_img = 153;
		10'd678, 10'd679, 10'd680, 10'd681: hist_to_img = 154;
		10'd682, 10'd683, 10'd684, 10'd685: hist_to_img = 155;
		10'd686, 10'd687, 10'd688, 10'd689, 10'd690: hist_to_img = 156;
		10'd691, 10'd692, 10'd693, 10'd694: hist_to_img = 157;
		10'd695, 10'd696, 10'd697, 10'd698: hist_to_img = 158;
		10'd699, 10'd700, 10'd701, 10'd702, 10'd703: hist_to_img = 159;
		10'd704, 10'd705, 10'd706, 10'd707: hist_to_img = 160;
		10'd708, 10'd709, 10'd710, 10'd711, 10'd712: hist_to_img = 161;
		10'd713, 10'd714, 10'd715, 10'd716: hist_to_img = 162;
		10'd717, 10'd718, 10'd719, 10'd720: hist_to_img = 163;
		10'd721, 10'd722, 10'd723, 10'd724, 10'd725: hist_to_img = 164;
		10'd726, 10'd727, 10'd728, 10'd729: hist_to_img = 165;
		10'd730, 10'd731, 10'd732, 10'd733: hist_to_img = 166;
		10'd734, 10'd735, 10'd736, 10'd737, 10'd738: hist_to_img = 167;
		10'd739, 10'd740, 10'd741, 10'd742: hist_to_img = 168;
		10'd743, 10'd744, 10'd745, 10'd746: hist_to_img = 169;
		10'd747, 10'd748, 10'd749, 10'd750, 10'd751: hist_to_img = 170;
		10'd752, 10'd753, 10'd754, 10'd755: hist_to_img = 171;
		10'd756, 10'd757, 10'd758, 10'd759, 10'd760: hist_to_img = 172;
		10'd761, 10'd762, 10'd763, 10'd764: hist_to_img = 173;
		10'd765, 10'd766, 10'd767, 10'd768: hist_to_img = 174;
		10'd769, 10'd770, 10'd771, 10'd772, 10'd773: hist_to_img = 175;
		10'd774, 10'd775, 10'd776, 10'd777: hist_to_img = 176;
		10'd778, 10'd779, 10'd780, 10'd781: hist_to_img = 177;
		10'd782, 10'd783, 10'd784, 10'd785, 10'd786: hist_to_img = 178;
		10'd787, 10'd788, 10'd789, 10'd790: hist_to_img = 179;
		10'd791, 10'd792, 10'd793, 10'd794, 10'd795: hist_to_img = 180;
		10'd796, 10'd797, 10'd798, 10'd799: hist_to_img = 181;
		10'd800, 10'd801, 10'd802, 10'd803: hist_to_img = 182;
		10'd804, 10'd805, 10'd806, 10'd807, 10'd808: hist_to_img = 183;
		10'd809, 10'd810, 10'd811, 10'd812: hist_to_img = 184;
		10'd813, 10'd814, 10'd815, 10'd816: hist_to_img = 185;
		10'd817, 10'd818, 10'd819, 10'd820, 10'd821: hist_to_img = 186;
		10'd822, 10'd823, 10'd824, 10'd825: hist_to_img = 187;
		10'd826, 10'd827, 10'd828, 10'd829: hist_to_img = 188;
		10'd830, 10'd831, 10'd832, 10'd833, 10'd834: hist_to_img = 189;
		10'd835, 10'd836, 10'd837, 10'd838: hist_to_img = 190;
		10'd839, 10'd840, 10'd841, 10'd842, 10'd843: hist_to_img = 191;
		10'd844, 10'd845, 10'd846, 10'd847: hist_to_img = 192;
		10'd848, 10'd849, 10'd850, 10'd851: hist_to_img = 193;
		10'd852, 10'd853, 10'd854, 10'd855, 10'd856: hist_to_img = 194;
		10'd857, 10'd858, 10'd859, 10'd860: hist_to_img = 195;
		10'd861, 10'd862, 10'd863, 10'd864: hist_to_img = 196;
		10'd865, 10'd866, 10'd867, 10'd868, 10'd869: hist_to_img = 197;
		10'd870, 10'd871, 10'd872, 10'd873: hist_to_img = 198;
		10'd874, 10'd875, 10'd876, 10'd877, 10'd878: hist_to_img = 199;
		10'd879, 10'd880, 10'd881, 10'd882: hist_to_img = 200;
		10'd883, 10'd884, 10'd885, 10'd886: hist_to_img = 201;
		10'd887, 10'd888, 10'd889, 10'd890, 10'd891: hist_to_img = 202;
		10'd892, 10'd893, 10'd894, 10'd895: hist_to_img = 203;
		10'd896, 10'd897, 10'd898, 10'd899: hist_to_img = 204;
		10'd900, 10'd901, 10'd902, 10'd903, 10'd904: hist_to_img = 205;
		10'd905, 10'd906, 10'd907, 10'd908: hist_to_img = 206;
		10'd909, 10'd910, 10'd911, 10'd912: hist_to_img = 207;
		10'd913, 10'd914, 10'd915, 10'd916, 10'd917: hist_to_img = 208;
		10'd918, 10'd919, 10'd920, 10'd921: hist_to_img = 209;
		10'd922, 10'd923, 10'd924, 10'd925, 10'd926: hist_to_img = 210;
		10'd927, 10'd928, 10'd929, 10'd930: hist_to_img = 211;
		10'd931, 10'd932, 10'd933, 10'd934: hist_to_img = 212;
		10'd935, 10'd936, 10'd937, 10'd938, 10'd939: hist_to_img = 213;
		10'd940, 10'd941, 10'd942, 10'd943: hist_to_img = 214;
		10'd944, 10'd945, 10'd946, 10'd947: hist_to_img = 215;
		10'd948, 10'd949, 10'd950, 10'd951, 10'd952: hist_to_img = 216;
		10'd953, 10'd954, 10'd955, 10'd956: hist_to_img = 217;
		10'd957, 10'd958, 10'd959, 10'd960, 10'd961: hist_to_img = 218;
		10'd962, 10'd963, 10'd964, 10'd965: hist_to_img = 219;
		10'd966, 10'd967, 10'd968, 10'd969: hist_to_img = 220;
		10'd970, 10'd971, 10'd972, 10'd973, 10'd974: hist_to_img = 221;
		10'd975, 10'd976, 10'd977, 10'd978: hist_to_img = 222;
		10'd979, 10'd980, 10'd981, 10'd982: hist_to_img = 223;
		10'd983, 10'd984, 10'd985, 10'd986, 10'd987: hist_to_img = 224;
		10'd988, 10'd989, 10'd990, 10'd991: hist_to_img = 225;
		10'd992, 10'd993, 10'd994, 10'd995: hist_to_img = 226;
		10'd996, 10'd997, 10'd998, 10'd999, 10'd1000: hist_to_img = 227;
		10'd1001, 10'd1002, 10'd1003, 10'd1004: hist_to_img = 228;
		10'd1005, 10'd1006, 10'd1007, 10'd1008, 10'd1009: hist_to_img = 229;
		10'd1010, 10'd1011, 10'd1012, 10'd1013: hist_to_img = 230;
		10'd1014, 10'd1015, 10'd1016, 10'd1017: hist_to_img = 231;
		10'd1018, 10'd1019, 10'd1020, 10'd1021, 10'd1022: hist_to_img = 232;
		10'd1023: hist_to_img = 233;
	endcase

	case (hist[7])
		10'd0, 10'd1, 10'd2, 10'd3, 10'd4, 10'd5, 10'd6, 10'd7: hist_to_img_la = 0;
		10'd8, 10'd9, 10'd10, 10'd11, 10'd12: hist_to_img_la = 1;
		10'd13, 10'd14, 10'd15, 10'd16: hist_to_img_la = 2;
		10'd17, 10'd18, 10'd19, 10'd20: hist_to_img_la = 3;
		10'd21, 10'd22, 10'd23, 10'd24, 10'd25: hist_to_img_la = 4;
		10'd26, 10'd27, 10'd28, 10'd29: hist_to_img_la = 5;
		10'd30, 10'd31, 10'd32, 10'd33: hist_to_img_la = 6;
		10'd34, 10'd35, 10'd36, 10'd37, 10'd38: hist_to_img_la = 7;
		10'd39, 10'd40, 10'd41, 10'd42: hist_to_img_la = 8;
		10'd43, 10'd44, 10'd45, 10'd46, 10'd47: hist_to_img_la = 9;
		10'd48, 10'd49, 10'd50, 10'd51: hist_to_img_la = 10;
		10'd52, 10'd53, 10'd54, 10'd55: hist_to_img_la = 11;
		10'd56, 10'd57, 10'd58, 10'd59, 10'd60: hist_to_img_la = 12;
		10'd61, 10'd62, 10'd63, 10'd64: hist_to_img_la = 13;
		10'd65, 10'd66, 10'd67, 10'd68: hist_to_img_la = 14;
		10'd69, 10'd70, 10'd71, 10'd72, 10'd73: hist_to_img_la = 15;
		10'd74, 10'd75, 10'd76, 10'd77: hist_to_img_la = 16;
		10'd78, 10'd79, 10'd80, 10'd81: hist_to_img_la = 17;
		10'd82, 10'd83, 10'd84, 10'd85, 10'd86: hist_to_img_la = 18;
		10'd87, 10'd88, 10'd89, 10'd90: hist_to_img_la = 19;
		10'd91, 10'd92, 10'd93, 10'd94, 10'd95: hist_to_img_la = 20;
		10'd96, 10'd97, 10'd98, 10'd99: hist_to_img_la = 21;
		10'd100, 10'd101, 10'd102, 10'd103: hist_to_img_la = 22;
		10'd104, 10'd105, 10'd106, 10'd107, 10'd108: hist_to_img_la = 23;
		10'd109, 10'd110, 10'd111, 10'd112: hist_to_img_la = 24;
		10'd113, 10'd114, 10'd115, 10'd116: hist_to_img_la = 25;
		10'd117, 10'd118, 10'd119, 10'd120, 10'd121: hist_to_img_la = 26;
		10'd122, 10'd123, 10'd124, 10'd125: hist_to_img_la = 27;
		10'd126, 10'd127, 10'd128, 10'd129, 10'd130: hist_to_img_la = 28;
		10'd131, 10'd132, 10'd133, 10'd134: hist_to_img_la = 29;
		10'd135, 10'd136, 10'd137, 10'd138: hist_to_img_la = 30;
		10'd139, 10'd140, 10'd141, 10'd142, 10'd143: hist_to_img_la = 31;
		10'd144, 10'd145, 10'd146, 10'd147: hist_to_img_la = 32;
		10'd148, 10'd149, 10'd150, 10'd151: hist_to_img_la = 33;
		10'd152, 10'd153, 10'd154, 10'd155, 10'd156: hist_to_img_la = 34;
		10'd157, 10'd158, 10'd159, 10'd160: hist_to_img_la = 35;
		10'd161, 10'd162, 10'd163, 10'd164: hist_to_img_la = 36;
		10'd165, 10'd166, 10'd167, 10'd168, 10'd169: hist_to_img_la = 37;
		10'd170, 10'd171, 10'd172, 10'd173: hist_to_img_la = 38;
		10'd174, 10'd175, 10'd176, 10'd177, 10'd178: hist_to_img_la = 39;
		10'd179, 10'd180, 10'd181, 10'd182: hist_to_img_la = 40;
		10'd183, 10'd184, 10'd185, 10'd186: hist_to_img_la = 41;
		10'd187, 10'd188, 10'd189, 10'd190, 10'd191: hist_to_img_la = 42;
		10'd192, 10'd193, 10'd194, 10'd195: hist_to_img_la = 43;
		10'd196, 10'd197, 10'd198, 10'd199: hist_to_img_la = 44;
		10'd200, 10'd201, 10'd202, 10'd203, 10'd204: hist_to_img_la = 45;
		10'd205, 10'd206, 10'd207, 10'd208: hist_to_img_la = 46;
		10'd209, 10'd210, 10'd211, 10'd212, 10'd213: hist_to_img_la = 47;
		10'd214, 10'd215, 10'd216, 10'd217: hist_to_img_la = 48;
		10'd218, 10'd219, 10'd220, 10'd221: hist_to_img_la = 49;
		10'd222, 10'd223, 10'd224, 10'd225, 10'd226: hist_to_img_la = 50;
		10'd227, 10'd228, 10'd229, 10'd230: hist_to_img_la = 51;
		10'd231, 10'd232, 10'd233, 10'd234: hist_to_img_la = 52;
		10'd235, 10'd236, 10'd237, 10'd238, 10'd239: hist_to_img_la = 53;
		10'd240, 10'd241, 10'd242, 10'd243: hist_to_img_la = 54;
		10'd244, 10'd245, 10'd246, 10'd247: hist_to_img_la = 55;
		10'd248, 10'd249, 10'd250, 10'd251, 10'd252: hist_to_img_la = 56;
		10'd253, 10'd254, 10'd255, 10'd256: hist_to_img_la = 57;
		10'd257, 10'd258, 10'd259, 10'd260, 10'd261: hist_to_img_la = 58;
		10'd262, 10'd263, 10'd264, 10'd265: hist_to_img_la = 59;
		10'd266, 10'd267, 10'd268, 10'd269: hist_to_img_la = 60;
		10'd270, 10'd271, 10'd272, 10'd273, 10'd274: hist_to_img_la = 61;
		10'd275, 10'd276, 10'd277, 10'd278: hist_to_img_la = 62;
		10'd279, 10'd280, 10'd281, 10'd282: hist_to_img_la = 63;
		10'd283, 10'd284, 10'd285, 10'd286, 10'd287: hist_to_img_la = 64;
		10'd288, 10'd289, 10'd290, 10'd291: hist_to_img_la = 65;
		10'd292, 10'd293, 10'd294, 10'd295, 10'd296: hist_to_img_la = 66;
		10'd297, 10'd298, 10'd299, 10'd300: hist_to_img_la = 67;
		10'd301, 10'd302, 10'd303, 10'd304: hist_to_img_la = 68;
		10'd305, 10'd306, 10'd307, 10'd308, 10'd309: hist_to_img_la = 69;
		10'd310, 10'd311, 10'd312, 10'd313: hist_to_img_la = 70;
		10'd314, 10'd315, 10'd316, 10'd317: hist_to_img_la = 71;
		10'd318, 10'd319, 10'd320, 10'd321, 10'd322: hist_to_img_la = 72;
		10'd323, 10'd324, 10'd325, 10'd326: hist_to_img_la = 73;
		10'd327, 10'd328, 10'd329, 10'd330: hist_to_img_la = 74;
		10'd331, 10'd332, 10'd333, 10'd334, 10'd335: hist_to_img_la = 75;
		10'd336, 10'd337, 10'd338, 10'd339: hist_to_img_la = 76;
		10'd340, 10'd341, 10'd342, 10'd343, 10'd344: hist_to_img_la = 77;
		10'd345, 10'd346, 10'd347, 10'd348: hist_to_img_la = 78;
		10'd349, 10'd350, 10'd351, 10'd352: hist_to_img_la = 79;
		10'd353, 10'd354, 10'd355, 10'd356, 10'd357: hist_to_img_la = 80;
		10'd358, 10'd359, 10'd360, 10'd361: hist_to_img_la = 81;
		10'd362, 10'd363, 10'd364, 10'd365: hist_to_img_la = 82;
		10'd366, 10'd367, 10'd368, 10'd369, 10'd370: hist_to_img_la = 83;
		10'd371, 10'd372, 10'd373, 10'd374: hist_to_img_la = 84;
		10'd375, 10'd376, 10'd377, 10'd378, 10'd379: hist_to_img_la = 85;
		10'd380, 10'd381, 10'd382, 10'd383: hist_to_img_la = 86;
		10'd384, 10'd385, 10'd386, 10'd387: hist_to_img_la = 87;
		10'd388, 10'd389, 10'd390, 10'd391, 10'd392: hist_to_img_la = 88;
		10'd393, 10'd394, 10'd395, 10'd396: hist_to_img_la = 89;
		10'd397, 10'd398, 10'd399, 10'd400: hist_to_img_la = 90;
		10'd401, 10'd402, 10'd403, 10'd404, 10'd405: hist_to_img_la = 91;
		10'd406, 10'd407, 10'd408, 10'd409: hist_to_img_la = 92;
		10'd410, 10'd411, 10'd412, 10'd413: hist_to_img_la = 93;
		10'd414, 10'd415, 10'd416, 10'd417, 10'd418: hist_to_img_la = 94;
		10'd419, 10'd420, 10'd421, 10'd422: hist_to_img_la = 95;
		10'd423, 10'd424, 10'd425, 10'd426, 10'd427: hist_to_img_la = 96;
		10'd428, 10'd429, 10'd430, 10'd431: hist_to_img_la = 97;
		10'd432, 10'd433, 10'd434, 10'd435: hist_to_img_la = 98;
		10'd436, 10'd437, 10'd438, 10'd439, 10'd440: hist_to_img_la = 99;
		10'd441, 10'd442, 10'd443, 10'd444: hist_to_img_la = 100;
		10'd445, 10'd446, 10'd447, 10'd448: hist_to_img_la = 101;
		10'd449, 10'd450, 10'd451, 10'd452, 10'd453: hist_to_img_la = 102;
		10'd454, 10'd455, 10'd456, 10'd457: hist_to_img_la = 103;
		10'd458, 10'd459, 10'd460, 10'd461, 10'd462: hist_to_img_la = 104;
		10'd463, 10'd464, 10'd465, 10'd466: hist_to_img_la = 105;
		10'd467, 10'd468, 10'd469, 10'd470: hist_to_img_la = 106;
		10'd471, 10'd472, 10'd473, 10'd474, 10'd475: hist_to_img_la = 107;
		10'd476, 10'd477, 10'd478, 10'd479: hist_to_img_la = 108;
		10'd480, 10'd481, 10'd482, 10'd483: hist_to_img_la = 109;
		10'd484, 10'd485, 10'd486, 10'd487, 10'd488: hist_to_img_la = 110;
		10'd489, 10'd490, 10'd491, 10'd492: hist_to_img_la = 111;
		10'd493, 10'd494, 10'd495, 10'd496: hist_to_img_la = 112;
		10'd497, 10'd498, 10'd499, 10'd500, 10'd501: hist_to_img_la = 113;
		10'd502, 10'd503, 10'd504, 10'd505: hist_to_img_la = 114;
		10'd506, 10'd507, 10'd508, 10'd509, 10'd510: hist_to_img_la = 115;
		10'd511, 10'd512, 10'd513, 10'd514: hist_to_img_la = 116;
		10'd515, 10'd516, 10'd517, 10'd518: hist_to_img_la = 117;
		10'd519, 10'd520, 10'd521, 10'd522, 10'd523: hist_to_img_la = 118;
		10'd524, 10'd525, 10'd526, 10'd527: hist_to_img_la = 119;
		10'd528, 10'd529, 10'd530, 10'd531: hist_to_img_la = 120;
		10'd532, 10'd533, 10'd534, 10'd535, 10'd536: hist_to_img_la = 121;
		10'd537, 10'd538, 10'd539, 10'd540: hist_to_img_la = 122;
		10'd541, 10'd542, 10'd543, 10'd544, 10'd545: hist_to_img_la = 123;
		10'd546, 10'd547, 10'd548, 10'd549: hist_to_img_la = 124;
		10'd550, 10'd551, 10'd552, 10'd553: hist_to_img_la = 125;
		10'd554, 10'd555, 10'd556, 10'd557, 10'd558: hist_to_img_la = 126;
		10'd559, 10'd560, 10'd561, 10'd562: hist_to_img_la = 127;
		10'd563, 10'd564, 10'd565, 10'd566: hist_to_img_la = 128;
		10'd567, 10'd568, 10'd569, 10'd570, 10'd571: hist_to_img_la = 129;
		10'd572, 10'd573, 10'd574, 10'd575: hist_to_img_la = 130;
		10'd576, 10'd577, 10'd578, 10'd579: hist_to_img_la = 131;
		10'd580, 10'd581, 10'd582, 10'd583, 10'd584: hist_to_img_la = 132;
		10'd585, 10'd586, 10'd587, 10'd588: hist_to_img_la = 133;
		10'd589, 10'd590, 10'd591, 10'd592, 10'd593: hist_to_img_la = 134;
		10'd594, 10'd595, 10'd596, 10'd597: hist_to_img_la = 135;
		10'd598, 10'd599, 10'd600, 10'd601: hist_to_img_la = 136;
		10'd602, 10'd603, 10'd604, 10'd605, 10'd606: hist_to_img_la = 137;
		10'd607, 10'd608, 10'd609, 10'd610: hist_to_img_la = 138;
		10'd611, 10'd612, 10'd613, 10'd614: hist_to_img_la = 139;
		10'd615, 10'd616, 10'd617, 10'd618, 10'd619: hist_to_img_la = 140;
		10'd620, 10'd621, 10'd622, 10'd623: hist_to_img_la = 141;
		10'd624, 10'd625, 10'd626, 10'd627, 10'd628: hist_to_img_la = 142;
		10'd629, 10'd630, 10'd631, 10'd632: hist_to_img_la = 143;
		10'd633, 10'd634, 10'd635, 10'd636: hist_to_img_la = 144;
		10'd637, 10'd638, 10'd639, 10'd640, 10'd641: hist_to_img_la = 145;
		10'd642, 10'd643, 10'd644, 10'd645: hist_to_img_la = 146;
		10'd646, 10'd647, 10'd648, 10'd649: hist_to_img_la = 147;
		10'd650, 10'd651, 10'd652, 10'd653, 10'd654: hist_to_img_la = 148;
		10'd655, 10'd656, 10'd657, 10'd658: hist_to_img_la = 149;
		10'd659, 10'd660, 10'd661, 10'd662: hist_to_img_la = 150;
		10'd663, 10'd664, 10'd665, 10'd666, 10'd667: hist_to_img_la = 151;
		10'd668, 10'd669, 10'd670, 10'd671: hist_to_img_la = 152;
		10'd672, 10'd673, 10'd674, 10'd675, 10'd676: hist_to_img_la = 153;
		10'd677, 10'd678, 10'd679, 10'd680: hist_to_img_la = 154;
		10'd681, 10'd682, 10'd683, 10'd684: hist_to_img_la = 155;
		10'd685, 10'd686, 10'd687, 10'd688, 10'd689: hist_to_img_la = 156;
		10'd690, 10'd691, 10'd692, 10'd693: hist_to_img_la = 157;
		10'd694, 10'd695, 10'd696, 10'd697: hist_to_img_la = 158;
		10'd698, 10'd699, 10'd700, 10'd701, 10'd702: hist_to_img_la = 159;
		10'd703, 10'd704, 10'd705, 10'd706: hist_to_img_la = 160;
		10'd707, 10'd708, 10'd709, 10'd710, 10'd711: hist_to_img_la = 161;
		10'd712, 10'd713, 10'd714, 10'd715: hist_to_img_la = 162;
		10'd716, 10'd717, 10'd718, 10'd719: hist_to_img_la = 163;
		10'd720, 10'd721, 10'd722, 10'd723, 10'd724: hist_to_img_la = 164;
		10'd725, 10'd726, 10'd727, 10'd728: hist_to_img_la = 165;
		10'd729, 10'd730, 10'd731, 10'd732: hist_to_img_la = 166;
		10'd733, 10'd734, 10'd735, 10'd736, 10'd737: hist_to_img_la = 167;
		10'd738, 10'd739, 10'd740, 10'd741: hist_to_img_la = 168;
		10'd742, 10'd743, 10'd744, 10'd745: hist_to_img_la = 169;
		10'd746, 10'd747, 10'd748, 10'd749, 10'd750: hist_to_img_la = 170;
		10'd751, 10'd752, 10'd753, 10'd754: hist_to_img_la = 171;
		10'd755, 10'd756, 10'd757, 10'd758, 10'd759: hist_to_img_la = 172;
		10'd760, 10'd761, 10'd762, 10'd763: hist_to_img_la = 173;
		10'd764, 10'd765, 10'd766, 10'd767: hist_to_img_la = 174;
		10'd768, 10'd769, 10'd770, 10'd771, 10'd772: hist_to_img_la = 175;
		10'd773, 10'd774, 10'd775, 10'd776: hist_to_img_la = 176;
		10'd777, 10'd778, 10'd779, 10'd780: hist_to_img_la = 177;
		10'd781, 10'd782, 10'd783, 10'd784, 10'd785: hist_to_img_la = 178;
		10'd786, 10'd787, 10'd788, 10'd789: hist_to_img_la = 179;
		10'd790, 10'd791, 10'd792, 10'd793, 10'd794: hist_to_img_la = 180;
		10'd795, 10'd796, 10'd797, 10'd798: hist_to_img_la = 181;
		10'd799, 10'd800, 10'd801, 10'd802: hist_to_img_la = 182;
		10'd803, 10'd804, 10'd805, 10'd806, 10'd807: hist_to_img_la = 183;
		10'd808, 10'd809, 10'd810, 10'd811: hist_to_img_la = 184;
		10'd812, 10'd813, 10'd814, 10'd815: hist_to_img_la = 185;
		10'd816, 10'd817, 10'd818, 10'd819, 10'd820: hist_to_img_la = 186;
		10'd821, 10'd822, 10'd823, 10'd824: hist_to_img_la = 187;
		10'd825, 10'd826, 10'd827, 10'd828: hist_to_img_la = 188;
		10'd829, 10'd830, 10'd831, 10'd832, 10'd833: hist_to_img_la = 189;
		10'd834, 10'd835, 10'd836, 10'd837: hist_to_img_la = 190;
		10'd838, 10'd839, 10'd840, 10'd841, 10'd842: hist_to_img_la = 191;
		10'd843, 10'd844, 10'd845, 10'd846: hist_to_img_la = 192;
		10'd847, 10'd848, 10'd849, 10'd850: hist_to_img_la = 193;
		10'd851, 10'd852, 10'd853, 10'd854, 10'd855: hist_to_img_la = 194;
		10'd856, 10'd857, 10'd858, 10'd859: hist_to_img_la = 195;
		10'd860, 10'd861, 10'd862, 10'd863: hist_to_img_la = 196;
		10'd864, 10'd865, 10'd866, 10'd867, 10'd868: hist_to_img_la = 197;
		10'd869, 10'd870, 10'd871, 10'd872: hist_to_img_la = 198;
		10'd873, 10'd874, 10'd875, 10'd876, 10'd877: hist_to_img_la = 199;
		10'd878, 10'd879, 10'd880, 10'd881: hist_to_img_la = 200;
		10'd882, 10'd883, 10'd884, 10'd885: hist_to_img_la = 201;
		10'd886, 10'd887, 10'd888, 10'd889, 10'd890: hist_to_img_la = 202;
		10'd891, 10'd892, 10'd893, 10'd894: hist_to_img_la = 203;
		10'd895, 10'd896, 10'd897, 10'd898: hist_to_img_la = 204;
		10'd899, 10'd900, 10'd901, 10'd902, 10'd903: hist_to_img_la = 205;
		10'd904, 10'd905, 10'd906, 10'd907: hist_to_img_la = 206;
		10'd908, 10'd909, 10'd910, 10'd911: hist_to_img_la = 207;
		10'd912, 10'd913, 10'd914, 10'd915, 10'd916: hist_to_img_la = 208;
		10'd917, 10'd918, 10'd919, 10'd920: hist_to_img_la = 209;
		10'd921, 10'd922, 10'd923, 10'd924, 10'd925: hist_to_img_la = 210;
		10'd926, 10'd927, 10'd928, 10'd929: hist_to_img_la = 211;
		10'd930, 10'd931, 10'd932, 10'd933: hist_to_img_la = 212;
		10'd934, 10'd935, 10'd936, 10'd937, 10'd938: hist_to_img_la = 213;
		10'd939, 10'd940, 10'd941, 10'd942: hist_to_img_la = 214;
		10'd943, 10'd944, 10'd945, 10'd946: hist_to_img_la = 215;
		10'd947, 10'd948, 10'd949, 10'd950, 10'd951: hist_to_img_la = 216;
		10'd952, 10'd953, 10'd954, 10'd955: hist_to_img_la = 217;
		10'd956, 10'd957, 10'd958, 10'd959, 10'd960: hist_to_img_la = 218;
		10'd961, 10'd962, 10'd963, 10'd964: hist_to_img_la = 219;
		10'd965, 10'd966, 10'd967, 10'd968: hist_to_img_la = 220;
		10'd969, 10'd970, 10'd971, 10'd972, 10'd973: hist_to_img_la = 221;
		10'd974, 10'd975, 10'd976, 10'd977: hist_to_img_la = 222;
		10'd978, 10'd979, 10'd980, 10'd981: hist_to_img_la = 223;
		10'd982, 10'd983, 10'd984, 10'd985, 10'd986: hist_to_img_la = 224;
		10'd987, 10'd988, 10'd989, 10'd990: hist_to_img_la = 225;
		10'd991, 10'd992, 10'd993, 10'd994: hist_to_img_la = 226;
		10'd995, 10'd996, 10'd997, 10'd998, 10'd999: hist_to_img_la = 227;
		10'd1000, 10'd1001, 10'd1002, 10'd1003: hist_to_img_la = 228;
		10'd1004, 10'd1005, 10'd1006, 10'd1007, 10'd1008: hist_to_img_la = 229;
		10'd1009, 10'd1010, 10'd1011, 10'd1012: hist_to_img_la = 230;
		10'd1013, 10'd1014, 10'd1015, 10'd1016: hist_to_img_la = 231;
		10'd1017, 10'd1018, 10'd1019, 10'd1020, 10'd1021: hist_to_img_la = 232;
		10'd1022, 10'd1023: hist_to_img_la = 233;
	endcase
end

endmodule