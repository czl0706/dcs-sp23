//`timescale 1us/100ns
`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
	`include "SMJ.sv"
`elsif GATE
	`include "SMJ_SYN.v"
`endif

module TESTBENCH();

logic [5:0] hand_n0, hand_n1, hand_n2, hand_n3, hand_n4;
logic [1:0] out_data;

initial begin
	`ifdef RTL
		$fsdbDumpfile("SMJ.fsdb");
		$fsdbDumpvars(0,"+mda");
	`elsif GATE
		$fsdbDumpfile("SMJ_SYN.fsdb");
		$sdf_annotate("SMJ_SYN.sdf", I_SMJ);
		$fsdbDumpvars(0,"+mda");
	`endif
end

SMJ I_SMJ
(
    .hand_n0(hand_n0),
    .hand_n1(hand_n1),
    .hand_n2(hand_n2),
    .hand_n3(hand_n3),
    .hand_n4(hand_n4),
    .out_data(out_data)
);

PATTERN I_PATTERN
(
    .hand_n0(hand_n0),
    .hand_n1(hand_n1),
    .hand_n2(hand_n2),
    .hand_n3(hand_n3),
    .hand_n4(hand_n4),
    .out_data(out_data)
);
endmodule

