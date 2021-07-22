# ----------------------------------------------------------------------------
# FILE: 	ADS4246_timing.sdc
# DESCRIPTION:	Timing constrains file for TimeQuest
# DATE:	June 2, 2017
# AUTHOR(s):	Lime Microsystems
# REVISIONS:
# ----------------------------------------------------------------------------
# NOTES:
# 
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
#Timing parameters for ADS4246
# ----------------------------------------------------------------------------
#ADC
	#Clock period 160MHz
set ADC_clk_prd				6.25
	#Waveform for 90deg phase shifted virtual clock
set ADC_clk90_waveform	{4.6875 7.8125}
	#Setup and hold times from datasheet
set ADC_Tsu	1.50
set ADC_Th	0.35
	#Calculated expressions
set ADC_max_dly [expr $ADC_clk_prd/4 - $ADC_Tsu]
set ADC_min_dly [expr $ADC_Th - $ADC_clk_prd/4]

# ----------------------------------------------------------------------------
#Base clocks
# ----------------------------------------------------------------------------
#ADC clock (ADC LATCH clk)
create_clock -period $ADC_clk_prd			-name ADC_CLKOUT			[get_ports ADC_CLKOUT]

# ----------------------------------------------------------------------------
#Virtual clocks
# ----------------------------------------------------------------------------
create_clock -period $ADC_clk_prd -name ADC_LAUNCH_CLK -waveform $ADC_clk90_waveform

# ----------------------------------------------------------------------------
#Input constraints
# ----------------------------------------------------------------------------
set_input_delay	-max $ADC_max_dly \
						-clock [get_clocks ADC_LAUNCH_CLK] [get_ports {ADC_DA* ADC_DB*}]
						
set_input_delay	-min $ADC_min_dly \
						-clock [get_clocks ADC_LAUNCH_CLK] [get_ports {ADC_DA* ADC_DB*}]
						
set_input_delay	-max $ADC_max_dly \
						-clock [get_clocks ADC_LAUNCH_CLK] \
						-clock_fall [get_ports {ADC_DA* ADC_DB*}] -add_delay
												
set_input_delay	-min $ADC_min_dly \
						-clock [get_clocks ADC_LAUNCH_CLK] \
						-clock_fall [get_ports {ADC_DA* ADC_DB*}] -add_delay
						
# ----------------------------------------------------------------------------
#Exceptions
# ----------------------------------------------------------------------------
#For ADC used Same-Edge Capture Center-Aligned inputs)
set_false_path -setup -fall_from [get_clocks ADC_LAUNCH_CLK] -rise_to \
[get_clocks ADC_CLKOUT]

set_false_path -setup -rise_from [get_clocks ADC_LAUNCH_CLK] -fall_to \
[get_clocks ADC_CLKOUT]

set_false_path -hold -rise_from [get_clocks ADC_LAUNCH_CLK] -rise_to \
[get_clocks ADC_CLKOUT]

set_false_path -hold -fall_from [get_clocks ADC_LAUNCH_CLK] -fall_to \
[get_clocks ADC_CLKOUT]