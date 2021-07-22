-- ----------------------------------------------------------------------------
-- FILE:          nmea_parser_pkg.vhd
-- DESCRIPTION:   parser constants and functions for nmea_parser
-- DATE:          11:07 AM Tuesday, February 27, 2018
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
-- Package declaration
-- ----------------------------------------------------------------------------
package nmea_parser_pkg is
   
   --Converts string to std_logic_vector
   function str_to_slv(s: string) 
      return std_logic_vector;
      
   --Converts std_logic_vector in string representation 
   function hex_to_slv(h: std_logic_vector)
      return std_logic_vector;
      
   -- Constants
   constant C_dollar       : std_logic_vector(7 downto 0);  -- Sentence start delimiter
   constant C_comma        : std_logic_vector(7 downto 0);  -- Comma, data field separator
   constant C_asterisk     : std_logic_vector(7 downto 0);  -- Asterisk, Checksum separator
   constant C_GP           : std_logic_vector(15 downto 0); -- Talker ID = GPS
   constant C_GN           : std_logic_vector(15 downto 0); -- Talker ID = Multi-GNSS
   
   constant C_GSA          : std_logic_vector(23 downto 0); -- Sentence ID = GNSS DOP and Active Satellites
   
   constant C_GPGSA        : std_logic_vector(39 downto 0);
   constant C_GNGGA        : std_logic_vector(39 downto 0);
   constant C_GNRMC        : std_logic_vector(39 downto 0);
   
   
   constant talker_id_len  : integer := 2;
   constant sentence_id_len: integer := 3;
   constant checksum_len   : integer := 2;
   
   -- sentence data field numbers starts from 1
   constant gsa_fix_d    : integer := 2; 
   constant gga_utc_d    : integer := 1;
   --RMC � Recommended Minimum Specific GNSS Data field numbers
   constant rmc_utc_d      : integer := 1;
   constant rmc_stat_d     : integer := 2;
   constant rmc_lat_d0     : integer := 3;
   constant rmc_lat_d1     : integer := 4;
   constant rmc_long_d0    : integer := 5;
   constant rmc_long_d1    : integer := 6;
   constant rmc_speed_d    : integer := 7;
   constant rmc_course_d   : integer := 8;
   constant rmc_date_d     : integer := 9;
   constant rmc_mag_var_d0 : integer := 10;
   constant rmc_mag_var_d1 : integer := 11;
   constant rmc_mag_var_d2 : integer := 12;
   
   constant rmc_utc_max_char      : integer := 10;
   constant rmc_stat_max_char     : integer := 1;
   constant rmc_lat_max_char      : integer := 11;
   constant rmc_long_max_char     : integer := 12;
   constant rmc_speed_max_char    : integer := 7;
   constant rmc_course_max_char   : integer := 6;
   constant rmc_date_max_char     : integer := 6;
   constant rmc_mag_var_max_char  : integer := 2;
   
   --types
   type talker_id_t is array (0 to 1) of std_logic_vector(7 downto 0);
   type sentence_id_t is array (0 to 2) of std_logic_vector(7 downto 0);
   
   
end  nmea_parser_pkg;

-- ----------------------------------------------------------------------------
-- Package body
-- ----------------------------------------------------------------------------
package body nmea_parser_pkg is

-- ----------------------------------------------------------------------------
-- Convert string to std_logic_vector
-- ----------------------------------------------------------------------------
function str_to_slv(s: string) return std_logic_vector is 
   constant ss: string(1 to s'length) := s; 
   variable answer: std_logic_vector(1 to 8 * s'length); 
   variable p: integer; 
   variable c: integer; 
begin 
   for i in ss'range loop
      p := 8 * i;
      c := character'pos(ss(i));
      answer(p - 7 to p) := std_logic_vector(to_unsigned(c,8)); 
   end loop; 
   return answer;
end function;

function hex_to_slv(h : std_logic_vector) return std_logic_vector is
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
      when x"41" => 
         return x"A";
      when x"42" => 
         return x"B";
      when x"43" => 
         return x"C";             
      when x"44" => 
         return x"D";
      when x"45" => 
         return x"E"; 
      when x"46" => 
         return x"F";
      when others=> 
         return x"0";
   end case;
end function;
-- ----------------------------------------------------------------------------
-- Deferred constants
-- ----------------------------------------------------------------------------
constant C_dollar    : std_logic_vector(7 downto 0) := str_to_slv("$");
constant C_comma     : std_logic_vector(7 downto 0) := str_to_slv(",");
constant C_asterisk  : std_logic_vector(7 downto 0) := str_to_slv("*");


constant C_GP        : std_logic_vector(15 downto 0) := str_to_slv("GP");
constant C_GN        : std_logic_vector(15 downto 0) := str_to_slv("GN");

constant C_GSA       : std_logic_vector(23 downto 0) := str_to_slv("GSA");

constant C_GPGSA     : std_logic_vector(39 downto 0) := str_to_slv("GPGSA");
constant C_GNGGA     : std_logic_vector(39 downto 0) := str_to_slv("GNGGA");
constant C_GNRMC     : std_logic_vector(39 downto 0) := str_to_slv("GNRMC");
   
   
end nmea_parser_pkg;
      
      