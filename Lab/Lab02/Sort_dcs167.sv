module Sort(
    // Input signals
    in_num0,
    in_num1,
    in_num2,
    in_num3,
    in_num4,
    // Output signals
    out_num
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
localparam BITS = 6;
input [BITS - 1:0] in_num0;
input [BITS - 1:0] in_num1;
input [BITS - 1:0] in_num2;
input [BITS - 1:0] in_num3;
input [BITS - 1:0] in_num4;
output logic [BITS - 1:0] out_num;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

logic [BITS - 1:0] s0[4:0], s1[4:0], s2[4:0], s3[4:0], s4[4:0];

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

//            -------        
// in_num0 -> |     | -> s0_0 ------------> s1_0    ......
//            |  c0 |                               ......
//            |  _0 |            -------            ......
// in_num1 -> |     | -> s0_1 -> |     | -> s1_1    ...... 
//            -------            |  c1 |            ...... 
//            -------            |  _0 |            ...... 
// in_num2 -> |     | -> s0_2 -> |     | -> s1_2    ...... 
//            |  c1 |            -------            ......
//            |  _1 |            -------            ......
// in_num3 -> |     | -> s0_3 -> |     | -> s1_3    ...... 
//            -------            |  c1 |            ...... 
//                               |  _1 |            ...... 
// in_num4 ------------> s0_4 -> |     | -> s1_4    ...... 
//                               -------         

comp_mux c0_0(in_num0, in_num1, s0[0], s0[1]);
comp_mux c0_1(in_num2, in_num3, s0[2], s0[3]);
assign s0[4] = in_num4;

assign s1[0] = s0[0];
comp_mux c1_0(s0[1], s0[2], s1[1], s1[2]);
comp_mux c1_1(s0[3], s0[4], s1[3], s1[4]);

comp_mux c2_0(s1[0], s1[1], s2[0], s2[1]);
comp_mux c2_1(s1[2], s1[3], s2[2], s2[3]);
assign s2[4] = s1[4];

assign s3[0] = s2[0];
comp_mux c3_0(s2[1], s2[2], s3[1], s3[2]);
comp_mux c3_1(s2[3], s2[4], s3[3], s3[4]);

comp_mux c4_0(s3[0], s3[1], s4[0], s4[1]);
comp_mux c4_1(s3[2], s3[3], s4[2], s4[3]);
assign s4[4] = s3[4];

assign out_num = s4[2];

endmodule

module comp_mux#(parameter BITS = 6)(a, b, o1, o2);
    input [BITS - 1:0] a;
    input [BITS - 1:0] b;

    output [BITS - 1:0] o1;
    output [BITS - 1:0] o2;

    assign {o1, o2} = a > b ? {a, b} : {b, a};
endmodule