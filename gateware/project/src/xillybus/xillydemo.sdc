# Clock constraints

create_clock -name "pcie_refclk" -period 10.000ns [get_ports {pcie_refclk}]

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# False paths to calm down TimeQuest
set_false_path -from [get_ports pcie_perstn]
set_false_path -to [get_ports user_led[*]]
