# ----------------------------------------------------------------------------
# FILE: 	LMS2_timing.sdc
# DESCRIPTION:	Timing constrains file for TimeQuest
# DATE:	June 2, 2017
# AUTHOR(s):	Lime Microsystems
# REVISIONS:
# ----------------------------------------------------------------------------
# NOTES:
# 
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
#Time settings
# ----------------------------------------------------------------------------
set_time_format -unit ns -decimal_places 3

# ----------------------------------------------------------------------------
#Timing parameters
# ----------------------------------------------------------------------------
#LMS7002
	#LMS_MCLK2 period
set MCLK2_period		        8.00
set MCLK1_period  	        8.00
set LMS2_MCLK1_period_5MHz 200.00
set LMS2_MCLK2_period_5MHz 200.00
	#Setup and hold times from datasheet
set LMS7_Tsu				     1.0
set LMS7_Th				        0.2

set LMS7_Tco_max				  4.05
set LMS7_Tco_min				  2.9

#Tsu and Th based delays
#set LMS7_IN_MAX_DELAY [expr -$LMS7_Tsu]
#set LMS7_IN_MIN_DELAY [expr $LMS7_Th - $MCLK2_period/2]

#Tco based
set LMS7_IN_MAX_DELAY [expr $LMS7_Tco_max]
set LMS7_IN_MIN_DELAY [expr $LMS7_Tco_min]

# ----------------------------------------------------------------------------
#Base clocks
# ----------------------------------------------------------------------------

create_clock 	-period $MCLK1_period \
					-name LMS2_MCLK1 [get_ports LMS2_MCLK1] 
					
#create_clock 	-period $LMS2_MCLK1_period_5MHz \
#					-name LMS2_MCLK1_5MHz [get_ports LMS2_MCLK1] -add

create_clock 	-period $MCLK2_period \
					-name LMS2_MCLK2 [get_ports LMS2_MCLK2]
					
#create_clock 	-period $LMS2_MCLK2_period_5MHz \
#					-name LMS2_MCLK2_5MHz [get_ports LMS2_MCLK2] -add

# ----------------------------------------------------------------------------
#Virtual clocks
# ----------------------------------------------------------------------------
create_clock -name LMS2_MCLK2_VIRT			-period $MCLK2_period
#create_clock -name LMS2_MCLK2_VIRT_5MHz	-period $LMS2_MCLK2_period_5MHz

# ----------------------------------------------------------------------------
#Generated clocks
# ----------------------------------------------------------------------------
#LMS2 TXPLL
create_generated_clock 	-name LMS2_MCLK1_GLOBAL \
								-master [get_clocks LMS2_MCLK1] \
                        -source [get_pins -compatibility_mode *pll_top*|inst2*|clkctrl*|inclk*] \
                        [get_pins -compatibility_mode *pll_top*|inst2*|clkctrl*|outclk*]
                        
                        
create_generated_clock 	-name LMS2_TXPLL_VCOPH \
								-master [get_clocks LMS2_MCLK1_GLOBAL] \
								-source  [get_pins -compatibility_mode *pll_top*|inst2*|*refclkin*]\
								-divide_by 1 -multiply_by 2 \
								[get_pins -compatibility_mode *pll_top*|inst2*|*vcoph[0]*]

create_generated_clock 	-name LMS2_TXPLL_C0 \
								-source  [get_pins -compatibility_mode *pll_top*|inst2*|*vcoph[0]*]\
								-divide_by 2 -multiply_by 1 \
								[get_pins -compatibility_mode *pll_top*|inst2*|*[0]*divclk*]

create_generated_clock 	-name LMS2_TXPLL_C1 \
								-source  [get_pins -compatibility_mode *pll_top*|inst2*|*vcoph[0]*]\
								-divide_by 2 -multiply_by 1 -phase 90 \
								[get_pins -compatibility_mode *pll_top*|inst2*|*[1]*divclk*]
                        
create_generated_clock 	-name LMS2_TXPLL_C2 \
								-source  [get_pins -compatibility_mode *pll_top|inst2*|*vcoph[0]*]\
								-divide_by 1 -multiply_by 1 -phase 0 \
								[get_pins -compatibility_mode *pll_top|inst2*|*[2]*divclk*]                         

#LMS2_FCLK1 clock output pin 
create_generated_clock 	-name LMS2_FCLK1_PLL \
								-master [get_clocks LMS2_TXPLL_C0] \
								-source [get_pins -compatibility_mode *pll_top*|inst2*|ALTDDIO*|dataout] \
								[get_ports LMS2_FCLK1]
								
#create_generated_clock 	-name LMS2_FCLK1_DRCT \
#								-master [get_clocks LMS2_MCLK1_5MHz] \
#								-source [get_pins -compatibility_mode *inst121|tx*|ALTDDIO*|dataout] \
#								[get_ports LMS2_FCLK1] -add
#LMS2 RXPLL

#create_generated_clock 	-name LMS2_MCLK2_GLOBAL \
#								-master [get_clocks LMS2_MCLK2] \
#                        -source [get_pins -compatibility_mode *inst121*|rx_pll*|clkctrl*|inclk*] \
#                        [get_pins -compatibility_mode *inst121*|rx_pll*|clkctrl*|outclk*]
#                        
#create_generated_clock 	-name LMS2_RXPLL_VCOPH \
#								-master [get_clocks LMS2_MCLK2_GLOBAL] \
#								-source  [get_pins -compatibility_mode *inst121|rx*|*refclkin*]\
#								-divide_by 1 -multiply_by 2 \
#								[get_pins -compatibility_mode *inst121|rx*|*vcoph[0]*]
                        
create_generated_clock 	-name LMS2_RXPLL_VCOPH \
								-master [get_clocks LMS2_MCLK2] \
								-source  [get_pins -compatibility_mode *pll_top*|inst3*|*refclkin*]\
								-divide_by 1 -multiply_by 2 \
								[get_pins -compatibility_mode *pll_top*|inst3*|*vcoph[0]*]

create_generated_clock 	-name LMS2_RXPLL_C0 \
								-source  [get_pins -compatibility_mode *pll_top*|inst3*|*vcoph[0]*]\
								-divide_by 2 -multiply_by 1 \
								[get_pins -compatibility_mode *pll_top*|inst3*|*[0]*divclk*]

create_generated_clock 	-name LMS2_RXPLL_C1 \
								-source  [get_pins -compatibility_mode *pll_top*|inst3*|*vcoph[0]*]\
								-divide_by 2 -multiply_by 1 -phase 90 \
								[get_pins -compatibility_mode *pll_top*|inst3*|*[1]*divclk*]

#LMS2_FCLK2 clock output pin 
create_generated_clock 	-name LMS2_FCLK2_PLL \
								-master [get_clocks LMS2_RXPLL_C0] \
								-source [get_pins -compatibility_mode *pll_top*|inst3*|ALTDDIO*|dataout] \
								[get_ports LMS2_FCLK2]
								
#create_generated_clock 	-name LMS2_FCLK2_DRCT \
#								-master [get_clocks LMS2_MCLK2_5MHz] \
#								-source [get_pins -compatibility_mode *inst121|rx*|ALTDDIO*|dataout] \
#								[get_ports LMS2_FCLK2] -add								
# ----------------------------------------------------------------------------
#Input constraints
# ----------------------------------------------------------------------------
#LMS2
set_input_delay	-max $LMS7_IN_MAX_DELAY \
						-clock [get_clocks LMS2_MCLK2_VIRT] [get_ports {LMS2_DIQ2_D* LMS2_ENABLE_IQSEL2}]
						
set_input_delay	-min $LMS7_IN_MIN_DELAY \
						-clock [get_clocks LMS2_MCLK2_VIRT] [get_ports {LMS2_DIQ2_D* LMS2_ENABLE_IQSEL2}]
						
set_input_delay	-max $LMS7_IN_MAX_DELAY \
						-clock [get_clocks LMS2_MCLK2_VIRT] \
						-clock_fall [get_ports {LMS2_DIQ2_D* LMS2_ENABLE_IQSEL2}] -add_delay
												
set_input_delay	-min $LMS7_IN_MIN_DELAY \
						-clock [get_clocks LMS2_MCLK2_VIRT] \
						-clock_fall [get_ports {LMS2_DIQ2_D* LMS2_ENABLE_IQSEL2}] -add_delay
						
#LMS2 when clocked with direct clock						
#set_input_delay	-max $LMS7_IN_MAX_DELAY \
#						-clock [get_clocks LMS2_MCLK2_VIRT_5MHz] [get_ports {LMS2_DIQ2_D* LMS2_ENABLE_IQSEL2}] -add_delay
#						
#set_input_delay	-min $LMS7_IN_MIN_DELAY \
#						-clock [get_clocks LMS2_MCLK2_VIRT_5MHz] [get_ports {LMS2_DIQ2_D* LMS2_ENABLE_IQSEL2}] -add_delay
#						
#set_input_delay	-max $LMS7_IN_MAX_DELAY \
#						-clock [get_clocks LMS2_MCLK2_VIRT_5MHz] \
#						-clock_fall [get_ports {LMS2_DIQ2_D* LMS2_ENABLE_IQSEL2}] -add_delay
#												
#set_input_delay	-min $LMS7_IN_MIN_DELAY \
#						-clock [get_clocks LMS2_MCLK2_VIRT_5MHz] \
#						-clock_fall [get_ports {LMS2_DIQ2_D* LMS2_ENABLE_IQSEL2}] -add_delay						
						
# ----------------------------------------------------------------------------
#Output constraints
# ----------------------------------------------------------------------------
#LMS2						
set_output_delay	-max $LMS7_Tsu \
						-clock [get_clocks LMS2_FCLK1_PLL] [get_ports {LMS2_DIQ1_D* LMS2_ENABLE_IQSEL1}] 
						
set_output_delay	-min -$LMS7_Th \
						-clock [get_clocks LMS2_FCLK1_PLL] [get_ports {LMS2_DIQ1_D* LMS2_ENABLE_IQSEL1}]						
						
set_output_delay	-max $LMS7_Tsu \
						-clock [get_clocks LMS2_FCLK1_PLL] \
						-clock_fall [get_ports {LMS2_DIQ1_D* LMS2_ENABLE_IQSEL1}] -add_delay
											
set_output_delay	-min -$LMS7_Th \
						-clock [get_clocks LMS2_FCLK1_PLL] \
						-clock_fall [get_ports {LMS2_DIQ1_D* LMS2_ENABLE_IQSEL1}] -add_delay	
						
						
#set_output_delay	-max $LMS7_Tsu \
#						-clock [get_clocks LMS2_FCLK1_DRCT] [get_ports {LMS2_DIQ1_D* LMS2_ENABLE_IQSEL1}] -add_delay
#						
#set_output_delay	-min -$LMS7_Th \
#						-clock [get_clocks LMS2_FCLK1_DRCT] [get_ports {LMS2_DIQ1_D* LMS2_ENABLE_IQSEL1}] -add_delay	 					
#						
#set_output_delay	-max $LMS7_Tsu \
#						-clock [get_clocks LMS2_FCLK1_DRCT] \
#						-clock_fall [get_ports {LMS2_DIQ1_D* LMS2_ENABLE_IQSEL1}] -add_delay
#											
#set_output_delay	-min -$LMS7_Th \
#						-clock [get_clocks LMS2_FCLK1_DRCT] \
#						-clock_fall [get_ports {LMS2_DIQ1_D* LMS2_ENABLE_IQSEL1}] -add_delay	
						
# ----------------------------------------------------------------------------
#Exceptions
# ----------------------------------------------------------------------------
#Cut path between rising to falling and falling to rising edges
#set_false_path -setup -rise_from [get_clocks LMS2_MCLK2_VIRT] -fall_to \
#[get_clocks LMS2_RXPLL_C1]
#
#set_false_path -setup -fall_from [get_clocks LMS2_MCLK2_VIRT] -rise_to \
#[get_clocks LMS2_RXPLL_C1]
#
#set_false_path -hold -rise_from [get_clocks LMS2_MCLK2_VIRT] -rise_to \
#[get_clocks LMS2_RXPLL_C1]
#
#set_false_path -hold -fall_from [get_clocks LMS2_MCLK2_VIRT] -fall_to \
#[get_clocks LMS2_RXPLL_C1]

set_multicycle_path \
   -setup 2 \
   -rise_from [get_clocks LMS2_MCLK2_VIRT] \
   -rise_to [get_clocks LMS2_RXPLL_C1] 
   
set_multicycle_path \
   -setup 2 \
   -fall_from [get_clocks LMS2_MCLK2_VIRT] \
   -fall_to [get_clocks LMS2_RXPLL_C1] 
	
#Clock groups					
#Clock groups are set in top .sdc file
											
#False Path between PLL output and clock output ports LMS2_FCLK1 an LMS2_FCLK2
set_false_path -to [get_ports LMS2_FCLK*]

