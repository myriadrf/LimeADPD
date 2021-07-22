-- ----------------------------------------------------------------------------
-- FILE:          adc_dac_pll_top.vhd
-- DESCRIPTION:   top file for PLL dedicated for external ADC and DAC
-- DATE:          3:23 PM Tuesday, August 28, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;
USE altera_mf.altera_mf_components.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity adc_dac_pll_top is
   generic(
      intended_device_family  : STRING    := "Cyclone V GX"
   );
   port (
      pll_inclk            : in  std_logic;
      pll_rcnfg_to_pll     : in  std_logic_vector(63 downto 0);
      pll_rcnfg_from_pll   : out std_logic_vector(63 downto 0);
      pll_areset_n         : in  std_logic;
      pll_c0               : out std_logic;
      pll_c0_pin           : out std_logic;
      pll_c1               : out std_logic;
      pll_c1_pin           : out std_logic;
      pll_locked           : out std_logic
   );
end adc_dac_pll_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of adc_dac_pll_top is
--declare signals,  components here
signal pll_inclk_global : std_logic;

--inst1
signal inst1_outclk_0 : std_logic;
signal inst1_outclk_1 : std_logic;

--inst2
signal inst2_dataout : std_logic_vector(0 downto 0);

--inst3
signal inst3_dataout : std_logic_vector(0 downto 0);

COMPONENT clkctrl_c5 is
   port (
      inclk  : in  std_logic := '0'; --  altclkctrl_input.inclk
      ena    : in  std_logic := '0'; --                  .ena
      outclk : out std_logic         -- altclkctrl_output.outclk
   );
end COMPONENT;

component fpga_pll is
	port (
		refclk            : in  std_logic                     := '0';             --            refclk.clk
		rst               : in  std_logic                     := '0';             --             reset.reset
		outclk_0          : out std_logic;                                        --           outclk0.clk
		outclk_1          : out std_logic;                                        --           outclk1.clk
		locked            : out std_logic;                                        --            locked.export
		reconfig_to_pll   : in  std_logic_vector(63 downto 0) := (others => '0'); --   reconfig_to_pll.reconfig_to_pll
		reconfig_from_pll : out std_logic_vector(63 downto 0)                     -- reconfig_from_pll.reconfig_from_pll
	);
end component;

begin

----------------------------------------------------------------------------
   -- Global clock control block
----------------------------------------------------------------------------
   inst0_clkctrl_c5 : clkctrl_c5
   port map(
      inclk  => pll_inclk,
      ena    => '1',
      outclk => pll_inclk_global
   );

----------------------------------------------------------------------------
-- PLL instance
---------------------------------------------------------------------------- 
   inst1_fpga_pll : fpga_pll
	port map(
		refclk            => pll_inclk_global,
		rst               => not pll_areset_n,
		outclk_0          => inst1_outclk_0,
		outclk_1          => inst1_outclk_1,
		locked            => pll_locked,
		reconfig_to_pll   => pll_rcnfg_to_pll,
		reconfig_from_pll => pll_rcnfg_from_pll
	);

-- ----------------------------------------------------------------------------
-- DDR output buffers
-- ----------------------------------------------------------------------------
   inst2_ALTDDIO_OUT_component : ALTDDIO_OUT
   GENERIC MAP (
      extend_oe_disable       => "OFF",
      intended_device_family  => intended_device_family,
      invert_output           => "OFF",
      lpm_hint                => "UNUSED",
      lpm_type                => "altddio_out",
      oe_reg                  => "UNREGISTERED",
      power_up_high           => "OFF",
      width                   => 1
   )
   PORT MAP (
      aclr           => '0',
      datain_h       => "1",
      datain_l       => "0",
      outclock       => inst1_outclk_0,
      dataout        => inst2_dataout
   );

   inst3_ALTDDIO_OUT_component : ALTDDIO_OUT
   GENERIC MAP (
      extend_oe_disable       => "OFF",
      intended_device_family  => intended_device_family,
      invert_output           => "OFF",
      lpm_hint                => "UNUSED",
      lpm_type                => "altddio_out",
      oe_reg                  => "UNREGISTERED",
      power_up_high           => "OFF",
      width                   => 1
   )
   PORT MAP (
      aclr           => '0',
      datain_h       => "0",
      datain_l       => "1",
      outclock       => inst1_outclk_1,
      dataout        => inst3_dataout
   );

-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
   pll_c0      <= inst1_outclk_0;
   pll_c0_pin  <= inst2_dataout(0);
   pll_c1      <= inst1_outclk_1;
   pll_c1_pin  <= inst3_dataout(0);
  
end arch;   


