-- ----------------------------------------------------------------------------	
-- FILE: 	ADS4246.vhd
-- DESCRIPTION:	Samples data from ADC, in LVDS mode
-- DATE:	Apr 25, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity ADS4246 is
   generic( dev_family	: string := "Cyclone V"
   );
  port (
      --input ports 
      clk         : in std_logic;
      reset_n     : in std_logic;
      ch_a        : in std_logic_vector(6 downto 0); 	--Input to DDR cells from pins
      ch_b        : in std_logic_vector(6 downto 0); 	--Input to DDR cells from pins
      --output ports 
      data_ch_a   : out std_logic_vector(13 downto 0); --Sampled data
      data_ch_b   : out std_logic_vector(13 downto 0) --Sampled data
      
        );
end ADS4246;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of ADS4246 is
--declare signals,  components here
   
   component ADS4246_ch is
      generic( dev_family	: string := "Cyclone V"
      );
      port (
         --input ports 
         clk       : in std_logic;
         reset_n   : in std_logic;
         dd_in     : in std_logic_vector(6 downto 0); --Input to DDR cells from pins
         --output ports 
         data      : out std_logic_vector(13 downto 0) --Sampled data
         
        );
   end component;



begin

--Channel A inst 
   ch_a_inst :  ADS4246_ch 
      generic map( dev_family	=> "Cyclone V"
         )
      port map(
         clk         => clk, 
         reset_n     => reset_n,
         dd_in       => ch_a,
         data        => data_ch_a  
        );

--Channel B inst  
   ch_b_inst :  ADS4246_ch 
      generic map( dev_family	=> "Cyclone V"
         )
      port map(
         clk       => clk, 
         reset_n   => reset_n,
         dd_in     => ch_b,
         data      => data_ch_b  
        );
 
end arch;

