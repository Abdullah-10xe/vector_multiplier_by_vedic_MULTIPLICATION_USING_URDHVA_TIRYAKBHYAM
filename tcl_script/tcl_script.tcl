# ****************************************************************************
# * Script Name  : Synthesis 
# * Developed by : Abdullah Jhatial abdullahjhatial92@gmail.com 
# * Version      : 1.0         
# * Firm         : 10xengineers    https://10xengineers.ai/
# * 
# ****************************************************************************
# * Description:
# *   This Tcl file is desing for syntheising the Vector Multiplier 
# ***************************************************************************
# ****************************************************************************


set_db init_lib_search_path ../12_nm_lib/
set_db init_hdl_search_path ../../rtl
read_libs  tcbn12ffcllbwp16p90ssgnp0p9v125c_ccs.lib
read_hdl -sv { mul_32bit_2stage_opt_design.sv }
set_db tns_opto true 
set_db information_level 9

elaborate 

set_max_fanout 3.0
read_sdc ../sdc_files/constraint.sdc
#define_cost_group -name C2C
#path_group -from [all_registers] -to [all_registers] -group C2C -name C2C

set_db syn_generic_effort low
set_db syn_map_effort low
set_db syn_opt_effort low
syn_generic
syn_map
syn_opt

#reports
report_timing > reports/report_timing_mul_32bit_precision_control_sel_tc.rpt
report_power  > reports/report_powermul_32bit_precision_control_sel_tc.rpt
report_area -detail  > reports/report_area_mul_32bit_precision_control_sel_tc.rpt
report_qor    > reports/report_qor_carray_sel.rpt

#Outputs
write_hdl > outputs/MX_netlist.v
write_sdc > outputs/MX_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge  -setuphold split > outputs/delays.sdf 
write_snapshot -directory /reports -levels_of_logic  -hierarchical 

#retime -min_delay
#write_snapshot -dir snapshot -tag op.elab
