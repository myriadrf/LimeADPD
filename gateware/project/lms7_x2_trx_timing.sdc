# ----------------------------------------------------------------------------
# FILE: 	lms_trx_pcie_timing.sdc
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
#CLK100_FPGA
	#Clock period 100MHz
set CLK100_FPGA_prd			10.000

#CLK_LMK_FPGA_IN
	#Clock period 30.72MHz
set CLK_LMK_FPGA_IN_prd		32.552

#CLK125_FPGA_TOP
	#Clock period 125MHz
set CLK125_FPGA_TOP_prd		8.000

#CLK125_FPGA_BOT
	#Clock period 125MHz
set CLK125_FPGA_BOT_prd		8.000

#FX3_SPI_SCLK
	#Clock period 10MHz
set FX3_SPI_SCLK_prd			100.000

#PCIE_REFCLK
	#Clock period 100MHz
set PCIE_REFCLK_prd			10.000

#NIOS PLLCFG_SCLK
	#Clock period 10MHz
set NIOS_PLLCFG_SCLK_prd	100.000

#NIOS PLLCFG_SCLK
	#Clock period 5MHz
set NIOS_DACSPI1_SCLK_prd	200.000

#set NIOS_PLLCFG_SCLK_div 	[expr {int($NIOS_PLLCFG_SCLK_prd / $CLK100_FPGA_prd)}]
#set NIOS_DACSPI1_SCLK_div 	[expr {int($NIOS_DACSPI1_SCLK_prd / $CLK100_FPGA_prd)}]

set NIOS_PLLCFG_SCLK_div 	4
set NIOS_DACSPI1_SCLK_div 	8
set NIOS_FPGASPI0_SCLK     8
# ----------------------------------------------------------------------------
#Base clocks
# ----------------------------------------------------------------------------
#FPGA pll, 100MHz
create_clock -period $CLK100_FPGA_prd 		-name CLK100_FPGA 		[get_ports CLK100_FPGA]
#LMK clk, 30.72MHz
create_clock -period $CLK_LMK_FPGA_IN_prd	-name CLK_LMK_FPGA_IN	[get_ports CLK_LMK_FPGA_IN]
#FX3 spi clock
create_clock -period $FX3_SPI_SCLK_prd 	-name FX3_SPI_SCLK 		[get_ports FX3_SPI_SCLK]
#RAM clk
create_clock -period $CLK125_FPGA_TOP_prd	-name CLK125_FPGA_BOT	[get_ports CLK125_FPGA_BOT]
create_clock -period $CLK125_FPGA_BOT_prd	-name CLK125_FPGA_TOP	[get_ports CLK125_FPGA_TOP]
# ----------------------------------------------------------------------------
#Virtual clocks
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
#Generated clocks
# ----------------------------------------------------------------------------
#FPGA pll
	#FPGA PLL VCO   
create_generated_clock 	-name FPGA_PLL_VCOPH \
								-source  [get_pins -compatibility_mode *fpga_pll*|refclkin*]\
								-divide_by 6 -multiply_by 125 \
								[get_pins -compatibility_mode *fpga_pll*|*vcoph[0]*]
                        
   #FPGA PLL C0 (Clock output for ADC)                        
create_generated_clock 	-name FPGA_PLL_C0 \
								-source  [get_pins -compatibility_mode *fpga_pll*|*vcoph[0]*]\
								-divide_by 4 -multiply_by 1 \
								[get_pins -compatibility_mode *fpga_pll*|*[0]*divclk*]
                        
   #FPGA PLL C1 (Clock for DAC)   
create_generated_clock 	-name FPGA_PLL_C1 \
								-source  [get_pins -compatibility_mode *fpga_pll*|*vcoph[0]*]\
								-divide_by 4 -multiply_by 1 \
								[get_pins -compatibility_mode *fpga_pll*|*[1]*divclk*]   
                        

#Clock outputs generated with FPGA PLL
	#For ADC
create_generated_clock 	-name ADC_CLK \
								-source [get_pins -compatibility_mode *adc_dac_pll*|inst2*|dataout] [get_ports ADC_CLK]
	#For DAC
create_generated_clock 	-name DAC_CLK_WRT \
								-invert \
								-source [get_pins -compatibility_mode *adc_dac_pll*|inst2*|dataout] [get_ports DAC_CLK_WRT]


#NIOS II generated clocks 
create_generated_clock 	-name NIOS_PLLCFG_SCLK \
								-divide_by $NIOS_PLLCFG_SCLK_div \
								-source [get_ports {CLK_LMK_FPGA_IN}] \
[get_registers {nios_cpu_top:inst175|nios_cpu:u0|nios_cpu_PLLCFG_SPI:pllcfg_spi|SCLK_reg}]

create_generated_clock 	-name NIOS_DACSPI1_SCLK \
								-divide_by $NIOS_DACSPI1_SCLK_div \
								-source [get_ports {CLK_LMK_FPGA_IN}] \
[get_registers {nios_cpu_top:inst175|nios_cpu:u0|nios_cpu_dac_spi1:dac_spi1|SCLK_reg}]

create_generated_clock 	-name NIOS_FPGASPI0_SCLK \
								-divide_by $NIOS_FPGASPI0_SCLK \
								-source [get_ports {CLK_LMK_FPGA_IN}] \
                        [get_registers *nios_cpu*\|*fpga_spi*\|*SCLK_reg*]




# ----------------------------------------------------------------------------
#Other clock constraints
# ----------------------------------------------------------------------------
# clock uncertainty is already derived in other sdc files
derive_clock_uncertainty
derive_pll_clocks

# ----------------------------------------------------------------------------											
#Timing Exceptions
# ----------------------------------------------------------------------------
#For synchronizer chain in design (sync_reg and bus_sync_reg)
set_false_path -to [get_keepers *sync_reg[0]*]
set_false_path -to [get_registers *sync_reg[0]*]
set_false_path -to [get_keepers *sync_reg0[*]*]
set_false_path -to [get_registers *sync_reg0[*]*]


#For asynchronous resets in IP (Signal is synchronised inside IP)
set_false_path -from [get_registers adc_top:inst130|sync_reg:sync_reg0|sync_reg[1]]



#False paths
set_false_path -from [get_clocks {FPGA_PLL_C1}] -to [get_clocks {ADC_CLKOUT}]
set_false_path -from [get_clocks {NIOS_DACSPI1_SCLK}] -to [get_clocks {ADC_CLKOUT}]

#Clock outputs 
set_false_path -to [get_ports ADC_CLK]
set_false_path -to [get_ports DAC_CLK_WRT]


#set false paths
set_false_path -from * -to [get_ports FPGA_LED* ]
set_false_path -from * -to [get_ports PMOD_A_PIN*]
set_false_path -from [get_ports FPGA_SW*] -to *
set_false_path -from [get_ports EXT_GND*] -to *
set_false_path -from [get_ports PCIE_PERSTn]

#Currently we dont care about these slow inputs
set_false_path -from [get_ports FPGA_SPI0_MISO]
set_false_path -from [get_ports FPGA_SPI0_MISO_ADC]
set_false_path -from [get_ports FPGA_SPI0_MISO_LMS1]
set_false_path -from [get_ports FPGA_SPI0_MISO_LMS2]
set_false_path -from [get_ports FX3_SPI_FPGA_SS]
set_false_path -from [get_ports FX3_SPI_MOSI]
set_false_path -from [get_ports LM75_OS]
set_false_path -from [get_ports I2C_SCL]
set_false_path -from [get_ports I2C_SDA]
set_false_path -from [get_ports BOM_VER[*]]
set_false_path -from [get_ports HW_VER[*]]




#Currently we dont care about these slow outputs
set_false_path -from [get_ports FPGA_SPI0_MISO]
set_false_path -from [get_ports FX3_SPI_FPGA_SS]
set_false_path -from [get_ports FX3_SPI_MOSI]
set_false_path -from [get_ports LM75_OS]

set_false_path -to [get_ports FAN_CTRL]
set_false_path -to [get_ports FPGA_ADC_RESET]
set_false_path -to [get_ports {FPGA_SPI0*}]
set_false_path -to [get_ports FX3_SPI_MISO]
set_false_path -to [get_ports LMS1_CORE_LDO_EN]
set_false_path -to [get_ports LMS1_RESET]
set_false_path -to [get_ports LMS1_RXEN]
set_false_path -to [get_ports LMS1_TXEN]
set_false_path -to [get_ports LMS1_TXNRX1]
set_false_path -to [get_ports LMS1_TXNRX2]
set_false_path -to [get_ports LMS2_CORE_LDO_EN]
set_false_path -to [get_ports LMS2_RESET]
set_false_path -to [get_ports LMS2_RXEN]
set_false_path -to [get_ports LMS2_TXEN]
set_false_path -to [get_ports LMS2_TXNRX1]
set_false_path -to [get_ports LMS2_TXNRX2]
set_false_path -to [get_ports I2C_SCL]
set_false_path -to [get_ports I2C_SDA]

set_false_path -from [get_ports virtddioq[*]]
set_false_path -from [get_ports virtfsync]

# False Paths on JTAG (for SignalTap)
if {[get_collection_size [get_ports -nowarn {altera_reserved*}]] > 0} {
	if {[get_collection_size [get_clocks -nowarn {altera_reserved_tck}]] == 0} {
		create_clock -period "10 MHz" -name altera_reserved_tck [get_ports altera_reserved_tck]
	}
	set_false_path -from [get_ports {altera_reserved_tdi}]
	set_false_path -from [get_ports {altera_reserved_tms}]
	set_false_path -to [get_ports {altera_reserved_tdo}]
	# Specify the JTAG clock in a group
	set_clock_groups -asynchronous -group altera_reserved_tck
}

#False paths between DCFIFO used in design
#For paths crossing from the write into the read domain, (between the delayed_wrptr_g and rs_dgwp registers)
set_false_path -from [get_registers {*dcfifo*delayed_wrptr_g[*]}] -to [get_registers {*dcfifo*rs_dgwp*}]
# For paths crossing from the read into the write domain (between the rdptr_g and ws_dgrp registers)
set_false_path -from [get_registers {*dcfifo*rdptr_g[*]}] -to [get_registers {*dcfifo*ws_dgrp*}]


