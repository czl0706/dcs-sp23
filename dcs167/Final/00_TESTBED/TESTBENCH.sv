
`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
`include "Conv.sv"
`elsif GATE
`include "Conv_SYN.v"
`endif

module TESTBED();

logic clk, rst_n, image_valid, filter_valid, filter_size, pad_mode, act_mode;
logic [3:0] image_size;
logic signed [7:0] in_data;
logic out_valid;
logic signed [15:0] out_data;


initial begin
  `ifdef RTL
    $fsdbDumpfile("Conv.fsdb");
	  $fsdbDumpvars();
	  $fsdbDumpvars("+mda");
  `elsif GATE
    $fsdbDumpfile("Conv_SYN.fsdb");
	  $sdf_annotate("Conv_SYN.sdf",I_design);
	  $fsdbDumpvars();
  `endif 
end

	


Conv I_design
(
	.clk(clk),
	.rst_n(rst_n),
	.filter_valid(filter_valid),
	.image_valid(image_valid),
	.filter_size(filter_size),
	.image_size(image_size),
	.pad_mode(pad_mode),
	.act_mode(act_mode),
	.in_data(in_data),
	.out_valid(out_valid),
	.out_data(out_data)
);


PATTERN I_PATTERN
(
	.clk(clk),
	.rst_n(rst_n),
	.filter_valid(filter_valid),
	.image_valid(image_valid),
	.filter_size(filter_size),
	.image_size(image_size),
	.pad_mode(pad_mode),
	.act_mode(act_mode),
	.in_data(in_data),
	.out_valid(out_valid),
	.out_data(out_data)
);
endmodule

