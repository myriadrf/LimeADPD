-- ----------------------------------------------------------------------------	
-- FILE: 	mac_ch_sel.vhd
-- DESCRIPTION:	selects what channels to disable
-- DATE:	Jan 27, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity mac_ch_sel is
   port (

      mac		: in std_logic_vector(1 downto 0);
      chA_dis	: out std_logic;
		chB_dis	: out std_logic


        );
end mac_ch_sel;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of mac_ch_sel is
--declare signals,  components here


  
begin



chA_dis<= '1' when mac="10" else '0';
chB_dis<= '1' when mac="01" else '0';

  
end arch;   





