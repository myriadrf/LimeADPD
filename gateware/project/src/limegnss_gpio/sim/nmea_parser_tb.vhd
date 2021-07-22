-- ----------------------------------------------------------------------------
-- FILE:          nmea_parser_tb.vhd
-- DESCRIPTION:   
-- DATE:          4:49 PM Monday, February 26, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity nmea_parser_tb is
end nmea_parser_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of nmea_parser_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 
   
   --
   signal file_read_en     : std_logic;
   signal nmea_data        : std_logic_vector(7 downto 0);
   
   signal dut0_GPGSA_valid    : std_logic;
   signal dut0_GPGSA_fix      : std_logic_vector(7 downto 0);
   signal dut0_GNRMC_valid    : std_logic;
   signal dut0_GNRMC_utc      : std_logic_vector(79 downto 0);
   signal dut0_GNRMC_status   : std_logic_vector(7 downto 0);
   signal dut0_GNRMC_lat      : std_logic_vector(87 downto 0);
   signal dut0_GNRMC_long     : std_logic_vector(95 downto 0);
   signal dut0_GNRMC_speed    : std_logic_vector(55 downto 0);
   signal dut0_GNRMC_course   : std_logic_vector(47 downto 0);
   signal dut0_GNRMC_date     : std_logic_vector(47 downto 0);
   
   
   signal dut1_GNRMC_utc      : std_logic_vector(71 downto 0);
  
begin 
  
      clock0: process is
   begin
      clk0 <= '0'; wait for clk0_period/2;
      clk0 <= '1'; wait for clk0_period/2;
   end process clock0;

      clock: process is
   begin
      clk1 <= '0'; wait for clk1_period/2;
      clk1 <= '1'; wait for clk1_period/2;
   end process clock;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      reset_n <= '1'; wait;
   end process res;

-- ----------------------------------------------------------------------------
-- File reading 
-- ----------------------------------------------------------------------------
   process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         file_read_en <= '0';
      elsif (clk0'event AND clk0='1') then 
         file_read_en <= not file_read_en;
      end if;
   end process;
   
   -- READ NMEA log file in binary format
process is
   type char_file_t is file of character;
   file char_file    : char_file_t;
   variable char_v   : character;
begin
   file_open(char_file, "sim/LogNMEA.txt");
      while not endfile(char_file) loop
         wait until rising_edge(file_read_en);
         read(char_file, char_v);
         nmea_data <= std_logic_vector(to_unsigned(character'pos(char_v),8));
         report "Char: " & " #" & char_v;
      end loop;
   file_close(char_file);
   wait;
end process;

-- ----------------------------------------------------------------------------
-- Unit under test
-- ----------------------------------------------------------------------------
nmea_parser_dut0 : entity work.nmea_parser
   port map(
      clk            => clk0,
      reset_n        => reset_n,
      data           => nmea_data,
      data_v         => file_read_en,
      GPGSA_valid    => dut0_GPGSA_valid,
      GPGSA_fix      => dut0_GPGSA_fix,
      GNRMC_valid    => dut0_GNRMC_valid,
      GNRMC_utc      => dut0_GNRMC_utc,
      GNRMC_status   => dut0_GNRMC_status,
      GNRMC_lat      => dut0_GNRMC_lat,
      GNRMC_long     => dut0_GNRMC_long,
      GNRMC_speed    => dut0_GNRMC_speed,
      GNRMC_course   => dut0_GNRMC_course,
      GNRMC_date     => dut0_GNRMC_date
   );
   
   nmea_str_to_bcd_dut1 : entity work.nmea_str_to_bcd
   port map(
      clk               => clk0,
      reset_n           => reset_n,

      GPGSA_valid_str => dut0_GPGSA_valid,
      GPGSA_fix_str   => dut0_GPGSA_fix,
      GNRMC_valid_str => dut0_GNRMC_valid,
      GNRMC_utc_str   => dut0_GNRMC_utc,
      GNRMC_status_str=> dut0_GNRMC_status,
      GNRMC_lat_str   => dut0_GNRMC_lat,
      GNRMC_long_str  => dut0_GNRMC_long,
      GNRMC_speed_str => dut0_GNRMC_speed,
      GNRMC_course_str=> dut0_GNRMC_course,
      GNRMC_date_str  => dut0_GNRMC_date,
      --Parsed NMEA sentences (BCD format)
      GPGSA_valid_bcd => open,
      GPGSA_fix_bcd   => open,
      GNRMC_valid_bcd => open,
      GNRMC_utc_bcd   => open,
      GNRMC_status    => open,
      GNRMC_lat_bcd   => open,
      GNRMC_lat_n_s   => open,
      GNRMC_long_bcd  => open,
      GNRMC_long_e_w  => open,
      GNRMC_speed_bcd => open,
      GNRMC_course_bcd=> open,
      GNRMC_date_bcd  => open
   );
   

end tb_behave;

