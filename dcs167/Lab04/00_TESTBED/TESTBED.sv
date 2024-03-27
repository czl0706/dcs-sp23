`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
`include "Seq.sv"
`elsif GATE
`include "Seq_SYN.v"
`endif

module TESTBED();

logic clk, rst_n, in_valid, out_valid, out_data;
logic [3:0]in_data;

initial begin
  `ifdef RTL
	$fsdbDumpfile("Seq.fsdb");		
	$fsdbDumpvars(0,"+mda");
  `elsif GATE
    $fsdbDumpfile("Seq_SYN.fsdb");
	$sdf_annotate("Seq_SYN.sdf",I_Seq);	
	$fsdbDumpvars(0,"+mda");
  `endif
end

Seq I_Seq(
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

