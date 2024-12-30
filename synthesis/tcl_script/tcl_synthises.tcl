# ****************************************************************************
# * Script Name  : Synthesis 
# * Developed by : Abdullah Jhatial 
  * gmail        : abdullah.jhatial@10xengineers.ai 
# * Version      : 1.0         
# * Firm         : 10xengineers    https://10xengineers.ai/
# * 
# ****************************************************************************
# * Description:
# *   This Tcl file is desing for syntheising the Vector Multiplier 
# ***************************************************************************
# ****************************************************************************

set_db init_lib_search_path ../12_nm_lib/
set_db init_hdl_search_path ../../RTL
read_libs  tcbn12ffcllbwp16p90ssgnp0p9v125c_ccs.lib
read_hdl -sv -f tcl_xrun.arg
set_db tns_opto true 
set_db information_level 9

elaborate v_mult_su 

read_sdc ../constraint_file/constraints.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

syn_generic
syn_map
syn_opt

#reports
report_timing > reports/report_timing_v_mult_effm.rpt
report_power  > reports/report_power_v_mult_effm.rpt
report_area -detail  > reports/report_area_v_mult_effm.rpt
report_qor    > reports/report_qor_v_mult_effm.rpt

#Outputs
write_hdl > outputs/MX_netlist.v
write_sdc > outputs/MX_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge  -setuphold split > outputs/delays.sdf 
report_gates  > gates_effm.rpt
report_timing -logic_levels 100 >  logic_gate_level_inpaths_effm.rpt



















