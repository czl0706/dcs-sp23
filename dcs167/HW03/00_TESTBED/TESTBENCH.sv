`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
`include "TL.sv"
`elsif GATE
`include "TL_SYN.v"
`endif



module TESTBENCH();



logic clk,rst_n,in_valid;
logic [2:0] car_main_s, car_main_lt, car_side_s, car_side_lt;
logic out_valid;
logic [1:0]light_main, light_side;

initial begin 
  `ifdef RTL
      $fsdbDumpfile("TL.fsdb");
	    $fsdbDumpvars(0,"+mda");
      $fsdbDumpvars();
  `elsif GATE
      $fsdbDumpfile("TL_SYN.fsdb");
	    $sdf_annotate("TL_SYN.sdf",I_TL);
	    $fsdbDumpvars(0,"+mda");
      $fsdbDumpvars();
  `endif 
end
//================================================================
// parameters & integer
//================================================================



TL I_TL
(
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .car_main_s(car_main_s),
  .car_main_lt(car_main_lt),
  .car_side_s(car_side_s),
  .car_side_lt(car_side_lt),
  .out_valid(out_valid),
  .light_main(light_main),
  .light_side(light_side)
);



PATTERN I_PATTERN
(
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .car_main_s(car_main_s),
  .car_main_lt(car_main_lt),
  .car_side_s(car_side_s),
  .car_side_lt(car_side_lt),
  .out_valid(out_valid),
  .light_main(light_main),
  .light_side(light_side)
);
endmodule
