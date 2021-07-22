-- ----------------------------------------------------------------------------	
-- FILE: 	sign_to_uns_std.vhd
-- DESCRIPTION:	converts signed std to unsigned std
-- DATE:	Aprl 27, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity sign_to_uns_std is
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
		  signd_in	: in std_logic_vector(13 downto 0);
		  unsgnd_out : out std_logic_vector(13 downto 0)

        --output ports 
        
        );
end sign_to_uns_std;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of sign_to_uns_std is
--declare signals,  components here

  
begin

process(reset_n, clk)
begin 
	if reset_n='0' then 
		unsgnd_out<=(others=>'0');
	elsif (clk'event and clk='1') then 
		unsgnd_out(13 downto 0)<=std_logic_vector(signed(signd_in(13 downto 0))+8192);
	end if;
end process;

end arch;





