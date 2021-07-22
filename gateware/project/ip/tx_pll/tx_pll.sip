set_global_assignment -entity "tx_pll" -library "lib_tx_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "tx_pll" -library "lib_tx_pll" -name IP_TOOL_VERSION "18.0"
set_global_assignment -entity "tx_pll" -library "lib_tx_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_tx_pll" -name SPD_FILE [file join $::quartus(sip_path) "tx_pll.spd"]

set_global_assignment -library "lib_tx_pll" -name MISC_FILE [file join $::quartus(sip_path) "tx_pll_sim/tx_pll.vho"]
