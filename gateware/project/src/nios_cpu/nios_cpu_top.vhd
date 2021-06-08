-- ----------------------------------------------------------------------------	
-- FILE: 	nios_cpu.vhd
-- DESCRIPTION:	NIOS CPU top level
-- DATE:	Mar 24, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity nios_cpu_top is
  port (
			clk100							: in    std_logic;
			nrst								: out		std_logic;
			
			fpga_spi0_MISO      : in  std_logic;
			fpga_spi0_MOSI      : out std_logic;
			fpga_spi0_SCLK      : out std_logic;
			fpga_spi0_SS_n      : out std_logic;
			pllcfg_MISO      : in  std_logic;
			pllcfg_MOSI      : out std_logic;
			pllcfg_SCLK      : out std_logic;
			pllcfg_SS_n      : out std_logic;
			gpi0                : in  std_logic_vector(7 downto 0);
			gpio0		            : out std_logic_vector(7 downto 0);
			pll_cmd					: in  std_logic_vector(2 downto 0);
			pll_stat					: out  std_logic_vector(9 downto 0);
			pll_recfg_from_pll0 : in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll0   : out std_logic_vector(63 downto 0);
			pll_recfg_from_pll1 : in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll1   : out std_logic_vector(63 downto 0);
			pll_recfg_from_pll2 : in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll2   : out std_logic_vector(63 downto 0);
			pll_recfg_from_pll3 : in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll3   : out std_logic_vector(63 downto 0);
			pll_recfg_from_pll4 : in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll4   : out std_logic_vector(63 downto 0);
			pll_recfg_from_pll5 : in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll5   : out std_logic_vector(63 downto 0);
			pll_rst							: out std_logic_vector(31 downto 0)

        );
end nios_cpu_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of nios_cpu_top is
--declare signals,  components here
		
	component nios_cpu is
		port (
			clk_clk                                : in  std_logic                     := 'X';             -- clk
			fpga_spi0_MISO                         : in  std_logic                     := 'X';             -- MISO
			fpga_spi0_MOSI                         : out std_logic;                                        -- MOSI
			fpga_spi0_SCLK                         : out std_logic;                                        -- SCLK
			fpga_spi0_SS_n                         : out std_logic;                                        -- SS_n
			gpi0_export                            : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- export
			gpio0_export                           : out std_logic_vector(7 downto 0);                     -- export
			pll_recfg_from_pll_0_reconfig_from_pll : in  std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_1_reconfig_from_pll : in  std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_2_reconfig_from_pll : in  std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_3_reconfig_from_pll : in  std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_4_reconfig_from_pll : in  std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_5_reconfig_from_pll : in  std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_to_pll_0_reconfig_to_pll     : out std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_1_reconfig_to_pll     : out std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_2_reconfig_to_pll     : out std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_3_reconfig_to_pll     : out std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_4_reconfig_to_pll     : out std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_5_reconfig_to_pll     : out std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_rst_export                         : out std_logic_vector(31 downto 0);                    -- export
			pllcfg_cmd_export                      : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- export
			pllcfg_spi_MISO                        : in  std_logic                     := 'X';             -- MISO
			pllcfg_spi_MOSI                        : out std_logic;                                        -- MOSI
			pllcfg_spi_SCLK                        : out std_logic;                                        -- SCLK
			pllcfg_spi_SS_n                        : out std_logic;                                        -- SS_n
			pllcfg_stat_export                     : out std_logic_vector(9 downto 0);                     -- export
			reset_reset_n                          : out std_logic                                         -- reset_n
		);
	end component nios_cpu;










  
begin

	u0 : component nios_cpu
		port map (
			clk_clk                                => clk100,
			fpga_spi0_MISO                         => fpga_spi0_MISO,
			fpga_spi0_MOSI                         => fpga_spi0_MOSI,
			fpga_spi0_SCLK                         => fpga_spi0_SCLK,
			fpga_spi0_SS_n                         => fpga_spi0_SS_n,
			gpi0_export														 => gpi0,
			gpio0_export                           => gpio0,
			pll_recfg_from_pll_0_reconfig_from_pll => pll_recfg_from_pll0,
			pll_recfg_to_pll_0_reconfig_to_pll     => pll_recfg_to_pll0,
			pll_recfg_from_pll_1_reconfig_from_pll => pll_recfg_from_pll1,
			pll_recfg_to_pll_1_reconfig_to_pll     => pll_recfg_to_pll1,
			pll_recfg_from_pll_2_reconfig_from_pll => pll_recfg_from_pll2,
			pll_recfg_to_pll_2_reconfig_to_pll     => pll_recfg_to_pll2,
			pll_recfg_from_pll_3_reconfig_from_pll => pll_recfg_from_pll3,
			pll_recfg_to_pll_3_reconfig_to_pll     => pll_recfg_to_pll3,
			pll_recfg_from_pll_4_reconfig_from_pll => pll_recfg_from_pll4,
			pll_recfg_to_pll_4_reconfig_to_pll     => pll_recfg_to_pll4,
			pll_recfg_from_pll_5_reconfig_from_pll => pll_recfg_from_pll5,
			pll_recfg_to_pll_5_reconfig_to_pll     => pll_recfg_to_pll5,
			pll_rst_export                         => pll_rst,
			pllcfg_cmd_export											 => pll_cmd,
			pllcfg_stat_export										 => pll_stat,
			pllcfg_spi_MISO                        => pllcfg_MISO,
			pllcfg_spi_MOSI                        => pllcfg_MOSI,
			pllcfg_spi_SCLK                        => pllcfg_SCLK, 
			pllcfg_spi_SS_n                        => pllcfg_SS_n,

			reset_reset_n                          => nrst
		);
		
		


end arch;   




