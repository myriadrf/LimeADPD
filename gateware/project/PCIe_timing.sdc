# ----------------------------------------------------------------------------
# FILE: 	PCIe_timing.sdc
# DESCRIPTION:	Timing constrains file for PCIe core
# DATE:	June 2, 2017
# AUTHOR(s):	Lime Microsystems
# REVISIONS:
# ----------------------------------------------------------------------------
# NOTES:
# 
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
#Timing parameters
# ----------------------------------------------------------------------------
#PCIE_REFCLK
	#Clock period 100MHz
set PCIE_REFCLK_prd			10.000

# ----------------------------------------------------------------------------
#Base clocks
# ----------------------------------------------------------------------------

#PCIE
create_clock -period $PCIE_REFCLK_prd 		-name PCIE_REFCLK 		[get_ports PCIE_REFCLK]



# ----------------------------------------------------------------------------											
#Timing Exceptions
# ----------------------------------------------------------------------------
# HIP testin pins SDC constraints
#set_false_path -from [get_pins -compatibility_mode *hip_ctrl*]