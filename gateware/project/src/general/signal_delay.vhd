-- ----------------------------------------------------------------------------	
-- FILE: 	signal_delay.vhd
-- DESCRIPTION:
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
entity signal_delay is
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      sign_in0    : in std_logic;
      sign_in1    : in std_logic;
      sign_out    : out std_logic

        );
end signal_delay;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of signal_delay is
--declare signals,  components here
signal sign_out_reg     : std_logic;
signal sign_in0_sync    : std_logic;
signal sign_in1_sync    : std_logic;

  
begin

sync_reg0 : entity work.sync_reg 
port map(clk, '1', sign_in0, sign_in0_sync);

sync_reg1 : entity work.sync_reg 
port map(clk, '1', sign_in1, sign_in1_sync);


process(reset_n, clk)
   begin
      if reset_n='0' then
         sign_out_reg <= '0';
      elsif (clk'event and clk = '1') then
         if sign_in0_sync = '1' then 
            sign_out_reg <= '1';
         elsif sign_in0_sync = '0' AND sign_in1_sync = '0' then 
            sign_out_reg <= '0';
         else 
            sign_out_reg <= sign_out_reg;
         end if;
      end if;
end process;


sign_out <= sign_out_reg;
  
end arch;   





