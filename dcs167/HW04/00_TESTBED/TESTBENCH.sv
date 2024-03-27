`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
	`include "HE.sv"
`elsif GATE
	`include "HE_SYN.v"
`endif

module TESTBENCH();

logic				clk,rst_n,in_valid;
logic [7:0]			in_image;
logic 		out_valid;
logic [7:0]	out_image;

initial begin
	`ifdef RTL
		$fsdbDumpfile("HE.fsdb");
		$fsdbDumpvars(0,"+mda");
	`elsif GATE
		$fsdbDumpfile("HE.fsdb");
		$sdf_annotate("HE_SYN.sdf", I_HE);
		$fsdbDumpvars(0,"+mda");
	`endif
end

HE I_HE
(
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .in_image(in_image),
  .out_valid(out_valid),
  .out_image(out_image)
);

PATTERN I_PATTERN
(
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .in_image(in_image),
  .out_valid(out_valid),
  .out_image(out_image)
);
endmodule
