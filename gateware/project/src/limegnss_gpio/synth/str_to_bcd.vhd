-- ----------------------------------------------------------------------------
-- FILE:          str_to_bcd.vhd
-- DESCRIPTION:   Converts data coded as string to BCD
-- DATE:          1:57 PM Friday, March 2, 2018
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
entity str_to_bcd is
   generic (
      char_n      : integer := 2
      );
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      
      char_vec    : in std_logic_vector(char_n*8-1 downto 0);
      bcd_vect    : out std_logic_vector(char_n*4-1 downto 0)
   );
end str_to_bcd;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of str_to_bcd is
--declare signals,  components here

-- ----------------------------------------------------------------------------
-- Converts decimal number string to BCD number function
-- ----------------------------------------------------------------------------
function fstr_to_bcd(h : std_logic_vector) return std_logic_vector is
   constant hh : std_logic_vector(7 downto 0) := h;
begin 
   case hh is 
      when x"30" => 
         return x"0";
      when x"31" => 
         return x"1";
      when x"32" => 
         return x"2";
      when x"33" => 
         return x"3";         
      when x"34" => 
         return x"4";
      when x"35" => 
         return x"5";
      when x"36" => 
         return x"6";
      when x"37" => 
         return x"7";
      when x"38" => 
         return x"8";
      when x"39" => 
         return x"9";
      when others=> 
         return x"0";
   end case;
end function;

  
begin

-- ----------------------------------------------------------------------------
-- Output register
-- ----------------------------------------------------------------------------
 process(reset_n, clk)
    begin
      if reset_n='0' then
         bcd_vect <= (others => '0');
      elsif (clk'event and clk = '1') then
         for i in 0 to char_n - 1 loop
            bcd_vect(i*4+4-1 downto i*4) <= fstr_to_bcd(char_vec(i*8+8-1 downto i*8));        
         end loop;
      end if;
    end process;
  
end arch;   


