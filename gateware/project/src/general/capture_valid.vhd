-- ----------------------------------------------------------------------------	
-- FILE: 	capture_valid.vhd
-- DESCRIPTION:	describe file
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
entity capture_valid is
   generic(
      diq_width   : integer := 12
   );
   port (
      clk               : in std_logic;
      reset_n           : in std_logic;
      data_in_valid_n   : in std_logic;
      data_in_h         : in std_logic_vector(diq_width-1 downto 0);
      data_in_l         : in std_logic_vector(diq_width-1 downto 0);
      data_out_h        : out std_logic_vector(diq_width-1 downto 0);
      data_out_l        : out std_logic_vector(diq_width-1 downto 0)
      
        );
end capture_valid;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of capture_valid is
--declare signals,  components here

signal data_out_h_reg : std_logic_vector(diq_width-1 downto 0);
signal data_out_l_reg : std_logic_vector(diq_width-1 downto 0);
 
begin


 process(reset_n, clk)
    begin
      if reset_n='0' then
        data_out_h_reg <= (others=>'0');
        data_out_l_reg <= (others=>'0');
      elsif (clk'event and clk = '1') then
 	      if data_in_valid_n = '0' then 
            data_out_h_reg <= data_in_h;
            data_out_l_reg <= data_in_l;
         else 
            data_out_h_reg <= data_out_h_reg;
            data_out_l_reg <= data_out_l_reg;
         end if;
 	    end if;
    end process;
    
data_out_h <=  data_out_h_reg;   
data_out_l <=  data_out_l_reg;     
  
end arch;   





