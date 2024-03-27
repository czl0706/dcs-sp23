`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
`include "DCT.sv"
`elsif GATE
`include "DCT_SYN.v"
`endif

module TESTBED();

logic clk, rst_n, in_valid, out_valid;
logic [7:0]in_data;
logic [9:0]out_data;

initial begin
  `ifdef RTL
	$fsdbDumpfile("DCT.fsdb");	
	$fsdbDumpvars(0,"+mda");
  `elsif GATE
    $fsdbDumpfile("DCT_SYN.fsdb");
	$sdf_annotate("DCT_SYN.sdf",I_DCT);
	$fsdbDumpvars(0,"+mda");
  `endif
end

DCT I_DCT(
  .clk(clk),
  .rst_n(rst_n),
	.in_valid(in_valid),
	.in_data(in_data),
	.out_valid(out_valid),
	.out_data(out_data)
);

PATTERN I_PATTERN(
  .clk(clk),
  .rst_n(rst_n),
	.in_valid(in_valid),
	.in_data(in_data),
	.out_valid(out_valid),
	.out_data(out_data)
);
endmodule

