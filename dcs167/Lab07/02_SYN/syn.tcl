#======================================================
#
# Synopsys Synthesis Scripts (Design Vision dctcl mode)
#
#======================================================

#======================================================
#  Set Libraries
#======================================================

#set search_path { ./../01_RTL \
#					/mnt/NAS/CAD/UMC018/Synthesis/ \
#					/CAD/synopsys/synthesis/cur/libraries/syn/ \
#					/CAD/synopsys/synthesis/cur/dw/ }

# below for iclab/ above for DCS
set search_path {	./../01_RTL \
					~iclabta01/umc018/Synthesis/ \
					/usr/synthesis/libraries/syn/ \
					/usr/synthesis/dw/ }

set synthetic_library {dw_foundation.sldb}
set link_library {* dw_foundation.sldb standard.sldb slow.db }
set target_library {slow.db}

#report_lib slow
#======================================================
#  Global Parameters
#======================================================
set CYCLE 8

#======================================================
#  Read RTL Code
#======================================================
#set hdlin_auto_save_templates TRUE

read_sverilog {DCT\.sv}
current_design DCT

#======================================================
#  Global Setting
#======================================================
#set_wire_load_mode top

#======================================================
#  Set Design Constraints
#======================================================

create_clock -name "clk" -period $CYCLE clk
set_input_delay  [ expr $CYCLE*0.5 ] -clock clk [all_inputs]
set_output_delay [ expr $CYCLE*0.5 ] -clock clk [all_outputs]
set_input_delay 0 -clock clk clk
set_input_delay 0 -clock clk rst_n

set_load 0.05 [all_outputs]

set_dont_use slow/JKFF*

#======================================================
#  Optimization
#======================================================
uniquify
check_design > Report/DCT\.check
set_fix_multiple_port_nets -all -buffer_constants
compile_ultra

#======================================================
#  Output Reports 
#======================================================
report_timing >  Report/DCT\.timing
report_area >  Report/DCT\.area
report_resource >  Report/DCT\.resource

#======================================================
#  Change Naming Rule
#======================================================
set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true

change_names -hierarchy -rule verilog

define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
change_names -hierarchy -rules name_rule

#======================================================
#  Output Results
#======================================================

set verilogout_higher_designs_first true

write -format verilog -output Netlist/DCT\_SYN.v -hierarchy

write_sdf -version 3.0 -context verilog -load_delay cell Netlist/DCT\_SYN.sdf -significant_digits 6

#======================================================
#  Finish and Quit
#======================================================
report_area
report_timing
exit