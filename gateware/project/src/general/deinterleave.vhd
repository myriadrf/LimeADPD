-- ----------------------------------------------------------------------------	
-- FILE: 	deinterleave.vhd
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
entity deinterleave is
   generic(
      diq_width   : integer := 12
   );
   port (
      clk               : in std_logic;
      reset_n           : in std_logic;
		fidm					: in std_logic; -- frame start ID
      iqsel   				: in std_logic;
      data_in_h         : in std_logic_vector(diq_width-1 downto 0);
      data_in_l         : in std_logic_vector(diq_width-1 downto 0);
		ch_A_valid			: out std_logic;
      ch_A_h        		: out std_logic_vector(diq_width-1 downto 0);
      ch_A_l        		: out std_logic_vector(diq_width-1 downto 0);
		ch_b_valid			: out std_logic;
		ch_B_h        		: out std_logic_vector(diq_width-1 downto 0);
      ch_B_l        		: out std_logic_vector(diq_width-1 downto 0)
      
        );
end deinterleave;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of deinterleave is
--declare signals,  components here

signal ch_A_h_reg : std_logic_vector(diq_width-1 downto 0);
signal ch_A_l_reg : std_logic_vector(diq_width-1 downto 0);
signal ch_B_h_reg : std_logic_vector(diq_width-1 downto 0);
signal ch_B_l_reg : std_logic_vector(diq_width-1 downto 0);

signal iqsel_reg	: std_logic;
 
begin



-- ----------------------------------------------------------------------------
-- Ch. A capture registers
-- ----------------------------------------------------------------------------
 process(reset_n, clk)
    begin
      if reset_n='0' then
        ch_A_h_reg <= (others=>'0');
        ch_A_l_reg <= (others=>'0');
      elsif (clk'event and clk = '1') then
 	      if iqsel = fidm then 
            ch_A_h_reg <= data_in_h;
            ch_A_l_reg <= data_in_l;
         else 
            ch_A_h_reg <= ch_A_h_reg;
            ch_A_l_reg <= ch_A_l_reg;
         end if;
 	    end if;
    end process;
	 
-- ----------------------------------------------------------------------------
-- Ch. B capture registers
-- ----------------------------------------------------------------------------	 
 process(reset_n, clk)
    begin
      if reset_n='0' then
        ch_B_h_reg <= (others=>'0');
        ch_B_l_reg <= (others=>'0');
      elsif (clk'event and clk = '1') then
 	      if iqsel = not fidm  then 
            ch_B_h_reg <= data_in_h;
            ch_B_l_reg <= data_in_l;
         else 
            ch_B_h_reg <= ch_B_h_reg;
            ch_B_l_reg <= ch_B_l_reg;
         end if;
 	    end if;
    end process;
	 
	 
-- ----------------------------------------------------------------------------
-- iqsel register
-- ----------------------------------------------------------------------------
 process(reset_n, clk)
    begin
      if reset_n='0' then
			iqsel_reg <='0';
      elsif (clk'event and clk = '1') then
			iqsel_reg <= iqsel; 
		end if;
    end process;

	 
-- ----------------------------------------------------------------------------
-- To output ports
-- ----------------------------------------------------------------------------  

ch_A_valid <= not iqsel_reg when fidm = '0' else iqsel_reg;
ch_A_h <=  ch_A_h_reg;   
ch_A_l <=  ch_A_l_reg;

ch_b_valid <= iqsel_reg when fidm = '0' else not iqsel_reg;
ch_B_h <=  ch_B_h_reg;   
ch_B_l <=  ch_B_l_reg;      
  
end arch;   





