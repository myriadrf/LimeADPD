#To avoid warnings with truncated timing values
set_time_format -unit ns -decimal_places 4 
#=======================Timing parameters===================================
#ADC
	#Clock period 160MHz
set ADC_clk_period	6.25
	#Waveform for 90deg phase shifted virtual clock
set ADC_clk90_waveform	{4.6875 7.8125}
	#Setup and hold times from datasheet
set ADC_Tsu	1.5
set ADC_Th	.35
	#Calculated expresions
set ADC_max_dly [expr $ADC_clk_period/4 - $ADC_Tsu]
set ADC_min_dly [expr $ADC_Th - $ADC_clk_period/4]

#DAC
set DAC_Tsu	1
set DAC_Th	1
	#Calculated expresions
set DAC_max_dly [expr $DAC_Tsu]
set DAC_min_dly [expr -$DAC_Th]


#=======================Base clocks=====================================
#FPGA pll
create_clock -period "100MHz" 			-name CLK100_FPGA 		[get_ports CLK100_FPGA]
#LMK clk
create_clock -period "30.72MHz" 	 		-name CLK_LMK_FPGA_IN	[get_ports CLK_LMK_FPGA_IN]
#RX pll
create_clock -period "160MHz" 			-name LMS1_MCLK2 			[get_ports LMS1_MCLK2]
#TX pll
create_clock -period "160MHz" 			-name LMS1_MCLK1			[get_ports LMS1_MCLK1] 
#ADC clock (ADC LATCH clk)
create_clock -period $ADC_clk_period	-name ADC_CLKOUT			[get_ports ADC_CLKOUT]
#FX3 spi clock
create_clock -period "1MHz" 				-name FX3_SPI_SCLK 		[get_ports FX3_SPI_SCLK]
#FX3 output clock
create_clock -period "100 MHz" 			-waveform {5 10} 			[get_ports FX3_PCLK] 
#RAM clk
create_clock -period "125MHz"				-name CLK125_FPGA_BOT	[get_ports CLK125_FPGA_BOT]
create_clock -period "125MHz"				-name CLK125_FPGA_TOP	[get_ports CLK125_FPGA_TOP]

#======================Virtual clocks============================================
#FX3 
create_clock -period "100MHz" 	-name fx3_clk_virt
#ADC
create_clock -period $ADC_clk_period -name ADC_LAUNCH_CLK -waveform $ADC_clk90_waveform

#======================Generated clocks==========================================
#FPGA pll
create_generated_clock -name ADC_CLK_OUT \
-source [get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|vco0ph[0]}] \
-divide_by 4 -multiply_by 1 \
[get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]

create_generated_clock -name DAC_DATA_CLK \
-source [get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|counter[1].output_counter|vco0ph[0]}] \
-divide_by 4 -multiply_by 1 \
[get_pins {inst34|fpga_pll_inst|altera_pll_i|cyclonev_pll|counter[1].output_counter|divclk}]

create_generated_clock 	-name DAC_CLK_OUT \
								-source [get_pins {inst33|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|dataout}] [get_ports DAC_CLK_WRT]


#====================Other clock constraints====================================
derive_clock_uncertainty
derive_pll_clocks
#====================Input constraints====================================
#ADC
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
#FX3
set_input_delay -clock [get_clocks fx3_clk_virt] -max 8.225 [get_ports {FX3_DQ*}]
set_input_delay -clock [get_clocks fx3_clk_virt] -min 0.225 [get_ports {FX3_DQ*}] -add_delay

set_output_delay -clock [get_clocks fx3_clk_virt] -max 2.5 [get_ports {FX3_DQ* FX3_CTL7 FX3_CTL3}]
set_output_delay -clock [get_clocks fx3_clk_virt] -min 0.75 [get_ports {FX3_DQ* FX3_CTL7 FX3_CTL3}] -add_delay


#====================Ootput constraints====================================
set_output_delay -max $DAC_max_dly -clock [get_clocks DAC_CLK_OUT] [get_ports DAC*]
set_output_delay -min $DAC_min_dly -clock [get_clocks DAC_CLK_OUT] [get_ports DAC*] -add_delay


# Set clkA and clkB to be mutually exclusive clocks.
set_clock_groups -exclusive 		-group {CLK100_FPGA} \
											-group {FX3_SPI_SCLK} \
											-group {LMS1_MCLK1} \
											-group {LMS1_MCLK2} \
											-group {CLK_LMK_FPGA_IN} \
											-group {ADC_CLKOUT ADC_LAUNCH_CLK}

#============================Timing Exceptions====================================
#For ADC (Same-Edge Capture Center-Aligned inputs)
set_false_path -setup -fall_from [get_clocks ADC_LAUNCH_CLK] -rise_to \
[get_clocks ADC_CLKOUT]

set_false_path -setup -rise_from [get_clocks ADC_LAUNCH_CLK] -fall_to \
[get_clocks ADC_CLKOUT]

set_false_path -hold -rise_from [get_clocks ADC_LAUNCH_CLK] -rise_to \
[get_clocks ADC_CLKOUT]

set_false_path -hold -fall_from [get_clocks ADC_LAUNCH_CLK] -fall_to \
[get_clocks ADC_CLKOUT]

#FOR DAC
set_false_path -setup -rise_from [get_clocks DAC_DATA_CLK] -fall_to \
[get_clocks DAC_CLK_OUT]

set_false_path -setup -fall_from [get_clocks DAC_DATA_CLK] -rise_to \
[get_clocks DAC_CLK_OUT]

set_false_path -hold -rise_from [get_clocks DAC_DATA_CLK] -rise_to \
[get_clocks DAC_CLK_OUT]

set_false_path -hold -fall_from [get_clocks DAC_DATA_CLK] -fall_to \
[get_clocks DAC_CLK_OUT]


#============================False paths========================================
#set false paths
# LED's
set_false_path -from * -to [get_ports FPGA_LED* ]
set_false_path -from * -to [get_ports PMOD_A_PIN*]
set_false_path -from [get_ports FPGA_SW*] -to *
set_false_path -from [get_ports EXT_GND*] -to *