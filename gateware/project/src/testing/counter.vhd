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
entity counter is
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
		  cnt_reset	: in std_logic;
		  cnt_en 	: in std_logic;
		  cnt_out	: out std_logic_vector(15 downto 0)

        --output ports 
        
        );
end counter;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of counter is
--declare signals,  components here
signal cnt : unsigned (15 downto 0); 

  
begin

  process(reset_n, clk)
    begin
      if reset_n='0' then
        cnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if cnt_reset='1' then 
				cnt<=(others=>'0');
			else 
				if cnt_en='1' then 
					cnt<=cnt+1;
				else	
					cnt<=cnt;
				end if;
			end if;
 	    end if;
    end process;
	 
	cnt_out<=std_logic_vector(cnt); 
  
end arch;   




