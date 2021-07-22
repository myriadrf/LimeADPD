-- ----------------------------------------------------------------------------
-- FILE:          nmea_str_to_bcd.vhd
-- DESCRIPTION:   Converts NMEA data coded as string to BCD
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
use work.nmea_parser_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity nmea_str_to_bcd is
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      
      --Parsed NMEA sentences (ASCII format)
         --GSA - GNSS DOP and Active Satellites
      GPGSA_valid_str : in std_logic;                    -- GPGSA message valid
         --d2, Mode: 1 = Fix not available, 2 = 2D, 3 = 3D, Max char = 1
      GPGSA_fix_str   : in std_logic_vector(7 downto 0);
         --RMC – Recommended Minimum Specific GNSS Data
      GNRMC_valid_str : in std_logic;                    -- GNRMC message valid
         --d1, UTC of position , Max char = 10
      GNRMC_utc_str  : in std_logic_vector(79 downto 0);
         --d2, Status A = Data valid, V = Navigation receiver warning
      GNRMC_status_str: in std_logic_vector(7 downto 0);
         --d3-d4, Latitude - N/S, Max char = 11
      GNRMC_lat_str   : in std_logic_vector(87 downto 0);
         --d5-d6, Longitude - E/W, Max char = 12
      GNRMC_long_str  : in std_logic_vector(95 downto 0);
         --d7, Speed over ground, knots, Max char = 7
      GNRMC_speed_str : in std_logic_vector(55 downto 0);
         --d8, Course Over Ground, degrees True, Max char = 6
      GNRMC_course_str: in std_logic_vector(47 downto 0);
         --d9, Date: ddmmyy, Max char = 6
      GNRMC_date_str  : in std_logic_vector(47 downto 0);
      
      --Parsed NMEA sentences (BCD format)
      --GSA - GNSS DOP and Active Satellites
      GPGSA_valid_bcd : out std_logic;                    -- GPGSA message valid
         --d2, Mode: 1 = Fix not available, 2 = 2D, 3 = 3D, Max char = 1
      GPGSA_fix_bcd   : out std_logic_vector(3 downto 0);
         --RMC – Recommended Minimum Specific GNSS Data
      GNRMC_valid_bcd : out std_logic;                    -- GNRMC message valid
         --d1, UTC of position , Max char = 10
      GNRMC_utc_bcd   : out std_logic_vector(35 downto 0);
         --d2, Status A = Data valid, V = Navigation receiver warning
      GNRMC_status    : out std_logic;
         --d3-d4, Latitude - N/S, Max char = 11
      GNRMC_lat_bcd   : out std_logic_vector(31 downto 0);
      GNRMC_lat_n_s   : out std_logic;
         --d5-d6, Longitude - E/W, Max char = 12
      GNRMC_long_bcd  : out std_logic_vector(35 downto 0);
      GNRMC_long_e_w  : out std_logic;
         --d7, Speed over ground, knots, Max char = 7
      GNRMC_speed_bcd : out std_logic_vector(23 downto 0);
         --d8, Course Over Ground, degrees True, Max char = 6
      GNRMC_course_bcd: out std_logic_vector(19 downto 0);
         --d9, Date: ddmmyy, Max char = 6
      GNRMC_date_bcd  : out std_logic_vector(23 downto 0)
      
   );
end nmea_str_to_bcd;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of nmea_str_to_bcd is
--declare signals,  components here
signal GNRMC_utc_vect   : std_logic_vector(71 downto 0); -- 9 char 
signal GNRMC_lat_vect   : std_logic_vector(63 downto 0); -- 8 char
signal GNRMC_long_vect  : std_logic_vector(71 downto 0); -- 9 char
signal GNRMC_speed_vect : std_logic_vector(47 downto 0); -- 6 char
signal GNRMC_course_vect: std_logic_vector(39 downto 0); -- 5 char 
signal GNRMC_date_vect  : std_logic_vector(47 downto 0); -- 6 char

signal str_vect         : std_logic_vector(351 downto 0); -- 43 char + 1
signal bcd_vect         : std_logic_vector(175 downto 0);

  
begin
   
   --Strings which do not represent numbers are removed 
   GNRMC_utc_vect    <= GNRMC_utc_str(79 downto 32) &  GNRMC_utc_str(23 downto 0);   
   GNRMC_lat_vect    <= GNRMC_lat_str(79 downto 48) & GNRMC_lat_str(39 downto 8);  
   GNRMC_long_vect   <= GNRMC_long_str(87 downto 48) & GNRMC_long_str(39 downto 8);   
   GNRMC_speed_vect  <= GNRMC_speed_str(55 downto 24) & GNRMC_speed_str(15 downto 0);   
   GNRMC_course_vect <= GNRMC_course_str(47 downto 24) & GNRMC_course_str(15 downto 0);   
   GNRMC_date_vect   <= GNRMC_date_str;
   
   str_vect          <= GNRMC_date_vect & GNRMC_course_vect & GNRMC_speed_vect & 
                        GNRMC_long_vect & GNRMC_lat_vect  & GNRMC_utc_vect & GPGSA_fix_str;
   
   -- string to bcd conversion
   str_to_bcd : entity work.str_to_bcd
   generic map(
      char_n      => 44
      )
   port map(
      clk         => clk,
      reset_n     => reset_n,
      char_vec    => str_vect,
      bcd_vect    => bcd_vect
   );

   
   GNRMC_status_str_proc : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         GNRMC_status <= '0';
      elsif (clk'event AND clk='1') then 
         if GNRMC_status_str = x"41" then 
            GNRMC_status <= '1'; -- Data valid
         else 
            GNRMC_status <= '0'; -- Navigation receiver warning
         end if;
      end if;
   end process;
   
   GNRMC_lat_n_s_str_proc : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         GNRMC_lat_n_s <= '0';
      elsif (clk'event AND clk='1') then 
         if GNRMC_lat_str(7 downto 0) = x"4E" then 
            GNRMC_lat_n_s <= '0'; -- N
         else 
            GNRMC_lat_n_s <= '1'; -- S
         end if;
      end if;
   end process;
   
   
   GNRMC_long_e_w_str_proc : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         GNRMC_long_e_w <= '0';
      elsif (clk'event AND clk='1') then 
         if GNRMC_long_str(7 downto 0) = x"45" then 
            GNRMC_long_e_w <= '0'; -- E
         else 
            GNRMC_long_e_w <= '1'; -- W
         end if;
      end if;
   end process;
   
   -- conversion takes one clock cycle, so valid signal is delayed on clock cycle
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         GPGSA_valid_bcd <= '0';
         GNRMC_valid_bcd <= '0';
      elsif (clk'event AND clk='1') then 
         GPGSA_valid_bcd <= GPGSA_valid_str;
         GNRMC_valid_bcd <= GNRMC_valid_str;
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------   
   GPGSA_fix_bcd     <= bcd_vect(3 downto 0);
   GNRMC_utc_bcd     <= bcd_vect(39 downto 4);
   GNRMC_lat_bcd     <= bcd_vect(71 downto 40);   
   GNRMC_long_bcd    <= bcd_vect(107 downto 72);
   GNRMC_speed_bcd   <= bcd_vect(131 downto 108);
   GNRMC_course_bcd  <= bcd_vect(151 downto 132);
   GNRMC_date_bcd    <= bcd_vect(175 downto 152);
   
   
   
  
end arch;   


