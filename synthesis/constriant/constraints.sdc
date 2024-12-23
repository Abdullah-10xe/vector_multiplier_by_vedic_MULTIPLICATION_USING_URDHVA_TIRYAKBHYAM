create_clock -name clk    -period   0.666  -waveform {0 0.32}  [get_ports clk]
set_clock_transition -rise 0.03 [get_clocks clk]
set_clock_transition -fall 0.03 [get_clocks clk]
set_clock_uncertainty 0.03 [get_ports "clk"]
set_input_delay -max 0.333 [remove_from_collection [all_inputs] [get_ports { clk  rst}]] -clock [get_clocks "clk"]
set_output_delay -max 0.333 [all_outputs]  -clock [get_clocks "clk"]

