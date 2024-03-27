`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
`include "Counter.sv"
`elsif GATE
`include "Counter_SYN.v"
`endif

module TESTBED();

logic clk, rst_n;
logic clk2;

initial begin
  `ifdef RTL
	$fsdbDumpfile("Counter.fsdb");	
	$fsdbDumpvars;
  `elsif GATE
    $fsdbDumpfile("Counter_SYN.fsdb");
	$sdf_annotate("Counter_SYN.sdf",I_Counter);
	$fsdbDumpvars();
  `endif
end

Counter I_Counter(
  .clk(clk),
  .clk2(clk2),
  .rst_n(rst_n)
);

PATTERN I_PATTERN(
  .clk(clk),
  .clk2(clk2),
  .rst_n(rst_n)
);
endmodule

