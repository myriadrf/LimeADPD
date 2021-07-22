set_global_assignment -entity "fpga_pll" -library "lib_fpga_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "fpga_pll" -library "lib_fpga_pll" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "fpga_pll" -library "lib_fpga_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_fpga_pll" -name SPD_FILE [file join $::quartus(sip_path) "fpga_pll.spd"]

set_global_assignment -library "lib_fpga_pll" -name MISC_FILE [file join $::quartus(sip_path) "fpga_pll_sim/fpga_pll.vho"]
