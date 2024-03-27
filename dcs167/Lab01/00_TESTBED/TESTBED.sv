`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
`include "BCD.sv"
`elsif GATE
`include "BCD_SYN.v"
`endif

module TESTBED();

logic [8:0] in_bin;
logic [2:0] out_hundred;
logic [3:0] out_ten;
logic [3:0] out_unit;


initial begin
  `ifdef RTL
    $fsdbDumpfile("BCD.fsdb");
	  $fsdbDumpvars;
  `elsif GATE
    $fsdbDumpfile("BCD_SYN.fsdb");
	  $sdf_annotate("BCD_SYN.sdf",I_BCD);
	  $fsdbDumpvars();
  `endif
end

BCD I_BCD
(
  .in_bin(in_bin),
  .out_hundred(out_hundred),
  .out_ten(out_ten),
  .out_unit(out_unit)
);


PATTERN I_PATTERN
(
  .in_bin(in_bin),
  .out_hundred(out_hundred),
  .out_ten(out_ten),
  .out_unit(out_unit)
);

endmodule
