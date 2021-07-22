-- ----------------------------------------------------------------------------
-- FILE:          clock_div.vhd
-- DESCRIPTION:   Clock divider module
-- DATE:          2020/04/03
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity clock_div is
   generic(
      ndiv : integer := 1000000
   );
   port (

      clk      : in std_logic;
      reset_n  : in std_logic;
      divout   : out std_logic
   );
end clock_div;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of clock_div is
--declare signals,  components here
signal cnt     : unsigned (19 downto 0); 
signal divclk  : std_logic;

  
begin


 process(reset_n, clk)
    begin
      if reset_n='0' then
         cnt      <= (others=>'0');
         divclk   <= '0';
      elsif rising_edge(clk) then
      
         if cnt < ndiv - 1 then 
            cnt <=cnt +1;
            divclk <= divclk;
         else
            cnt <= (others=>'0');
            divclk <= not divclk;
         end if;
         
      end if;
    end process;
    
   divout <= divclk;
  
end arch;   


