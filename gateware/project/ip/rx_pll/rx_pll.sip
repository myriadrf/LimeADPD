set_global_assignment -entity "rx_pll" -library "lib_rx_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "rx_pll" -library "lib_rx_pll" -name IP_TOOL_VERSION "18.0"
set_global_assignment -entity "rx_pll" -library "lib_rx_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_rx_pll" -name SPD_FILE [file join $::quartus(sip_path) "rx_pll.spd"]

set_global_assignment -library "lib_rx_pll" -name MISC_FILE [file join $::quartus(sip_path) "rx_pll_sim/rx_pll.vho"]
