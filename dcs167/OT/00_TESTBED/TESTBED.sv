`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
`include "SS.sv"
`elsif GATE
`include "SS_SYN.sv"
`endif

module TESTBED();

wire clk;
wire rst_n;

wire in_valid;
wire [15:0] matrix;
wire matrix_size;


wire out_valid;
wire [39:0] out_value;


SS U_SS(
	.clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .matrix(matrix),
	.matrix_size(matrix_size),
    .out_valid(out_valid),
    .out_value(out_value)
);

PATTERN U_PATTERN(
	.clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid), 
    .matrix(matrix),
	.matrix_size(matrix_size),
    .out_valid(out_valid),
    .out_value(out_value)
);

initial begin
	`ifdef RTL
		$fsdbDumpfile("SS.fsdb");
		$fsdbDumpvars(0,"+mda");
		$fsdbDumpvars();
	`endif
	`ifdef GATE
		$sdf_annotate("SS_SYN.sdf",U_SS);
		// $fsdbDumpfile("SS_SYN.fsdb");
		// $fsdbDumpvars(0,"+mda");
		// $fsdbDumpvars();
	`endif
end

endmodule

