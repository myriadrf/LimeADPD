-- ----------------------------------------------------------------------------	
-- FILE: 	pulse_gen.vhd
-- DESCRIPTION:	Generate one clk cycle pulses
-- DATE:	Feb 17, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pulse_gen is
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      n           : in std_logic_vector(7 downto 0); -- Generate pulse every n cycle
      pulse_out   : out std_logic

        );
end pulse_gen;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pulse_gen is
--declare signals,  components here
signal cnt     : unsigned(7 downto 0);
signal n_sync  : std_logic_vector(7 downto 0);
signal pulse   : std_logic;

  
begin

bus_sync_reg0 : entity work.bus_sync_reg
 generic map (8) 
 port map(clk, '1', n, n_sync);


   process(clk, reset_n) 
      begin 
         if reset_n = '0' then 
            cnt <= (others=>'0');
         elsif clk'event and clk='1' then 
            if cnt < unsigned(n_sync) then 
               cnt <= cnt +1;
            else 
               cnt <= (others=> '0');
            end if;
         end if;
   end process;
   
   process(cnt, n_sync)
      begin 
         if cnt = unsigned(n_sync) then 
            pulse <= '1';
         else 
            pulse <= '0';
         end if;
   end process;
   
   pulse_out <= pulse;
  
end arch;   





