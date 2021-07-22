-- ----------------------------------------------------------------------------	
-- FILE: 	file_name.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity const is
  port (
		  const_out	: out std_logic_vector(47 downto 0)

        --output ports 
        
        );
end const;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of const is
--declare signals,  components here
signal xpi			 : std_logic_vector(11 downto 0); 
signal xpq			 : std_logic_vector(11 downto 0); 
signal ypi			 : std_logic_vector(11 downto 0); 
signal ypq			 : std_logic_vector(11 downto 0); 

  
begin

xpi<="011111111111";
xpq<="100000000000";
ypi<="000000000000";
ypq<="000000000001";

const_out<=ypq & ypi & xpq & xpi;

  
end arch;


