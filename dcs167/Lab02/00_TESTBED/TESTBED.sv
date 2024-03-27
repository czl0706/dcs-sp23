`timescale 1us/100ns
`include "PATTERN.sv"
`ifdef RTL
`include "Sort.sv"
`elsif GATE
`include "Sort_SYN.v"
`endif


module TESTBED();

logic [5:0] in_num0, in_num1, in_num2, in_num3, in_num4;
logic [5:0] out_num;


initial begin
  `ifdef RTL
    $fsdbDumpfile("Sort.fsdb");
	  $fsdbDumpvars(0,"+mda");
  `elsif GATE
    $fsdbDumpfile("Sort_SYN.fsdb");
	  $sdf_annotate("Sort_SYN.sdf",I_Sort);
	  $fsdbDumpvars(0,"+mda");
  `endif
end

Sort I_Sort
(
	.in_num0(in_num0),
	.in_num1(in_num1),
	.in_num2(in_num2),
	.in_num3(in_num3),
	.in_num4(in_num4),
	.out_num(out_num)
);

PATTERN I_PATTERN
(
	.in_num0(in_num0),
	.in_num1(in_num1),
	.in_num2(in_num2),
	.in_num3(in_num3),
	.in_num4(in_num4),
	.out_num(out_num)
);
endmodule

