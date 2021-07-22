-- ----------------------------------------------------------------------------
-- FILE:          nmea_parser.vhd
-- DESCRIPTION:   parser for nmea messages
-- DATE:          11:07 AM Tuesday, February 27, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- Talker Senctence Format:
--    $ttsss,d1,d2,...*hh<CR><LF>
-- Sentence Explanation:
--    $ - Sentence start, tt - Talker ID, sss - Sentence ID, dx - Data Fields, 
--    * - Checksum delimiter, hh - checksum
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.nmea_parser_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity nmea_parser is
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      data        : in std_logic_vector(7 downto 0);  --NMEA data character
      data_v      : in std_logic;                     --NMEA data valid
      
      --Parsed NMEA sentences (ASCII format)
         --GSA - GNSS DOP and Active Satellites
      GPGSA_valid : out std_logic;                    -- GPGSA message valid
         --d2, Mode: 1 = Fix not available, 2 = 2D, 3 = 3D, Max char = 1
      GPGSA_fix   : out std_logic_vector(7 downto 0);
         --RMC – Recommended Minimum Specific GNSS Data
      GNRMC_valid : out std_logic;                    -- GNRMC message valid
         --d1, UTC of position , Max char = 10
      GNRMC_utc   : out std_logic_vector(79 downto 0);
         --d2, Status A = Data valid, V = Navigation receiver warning
      GNRMC_status: out std_logic_vector(7 downto 0);
         --d3-d4, Latitude - N/S, Max char = 11
      GNRMC_lat   : out std_logic_vector(87 downto 0);
         --d5-d6, Longitude - E/W, Max char = 12
      GNRMC_long  : out std_logic_vector(95 downto 0);
         --d7, Speed over ground, knots, Max char = 7
      GNRMC_speed : out std_logic_vector(55 downto 0);
         --d8, Course Over Ground, degrees True, Max char = 6
      GNRMC_course: out std_logic_vector(47 downto 0);
         --d9, Date: ddmmyy, Max char = 6
      GNRMC_date  : out std_logic_vector(47 downto 0)

   );
end nmea_parser;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of nmea_parser is
--declare signals,  components here

type state_type is (idle, GET_TALKER_ID, GET_SENTENCE_ID, PARSE_SENTENCE, GET_CHECKSUM, CHECK_CHECKSUM);
signal current_state, next_state : state_type;

signal state_cnt           : unsigned(7 downto 0);
signal data_field_cnt      : unsigned(7 downto 0);
signal char_cnt            : unsigned(7 downto 0);

signal nmea_talker_id      : std_logic_vector(15 downto 0);
signal nmea_sentence_id    : std_logic_vector(23 downto 0);
signal nmea_checksum       : std_logic_vector(7 downto 0);

signal checksum            : std_logic_vector(7 downto 0);
signal checksum_reg        : std_logic_vector(7 downto 0);
signal checksum_valid      : std_logic;

--GPGSA
signal gpgsa_valid_int     : std_logic;
signal gpgsa_fix_int       : std_logic_vector(7 downto 0);

--GNRMC
signal gnrmc_valid_int     : std_logic;
signal gnrmc_utc_int       : std_logic_vector(rmc_utc_max_char*8-1 downto 0);
signal gnrmc_status_int    : std_logic_vector(rmc_stat_max_char*8-1 downto 0);
signal gnrmc_lat_int       : std_logic_vector(rmc_lat_max_char*8-1 downto 0);
signal gnrmc_long_int      : std_logic_vector(rmc_long_max_char*8-1 downto 0);
signal gnrmc_speed_int     : std_logic_vector(rmc_speed_max_char*8-1 downto 0);
signal gnrmc_course_int    : std_logic_vector(rmc_course_max_char*8-1 downto 0);
signal gnrmc_date_int      : std_logic_vector(rmc_date_max_char*8-1 downto 0);
  
begin

-- ----------------------------------------------------------------------------
-- Various counters
-- ----------------------------------------------------------------------------
-- Count when FSM is in same state
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         state_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if current_state = next_state AND data_v = '1' then 
            state_cnt <= state_cnt + 1;
         elsif current_state = next_state AND data_v = '0' then 
            state_cnt <= state_cnt;
         else 
            state_cnt <= (others=>'0');
         end if;
      end if;
   end process;
   
-- Data field counter. Data fields are separated with comma symbol. 
-- Counter is reset to 0 at sentence beginning
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         data_field_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if data = C_comma AND data_v = '1' then 
            data_field_cnt <= data_field_cnt + 1;
         elsif data = C_dollar AND data_v = '1' then 
            data_field_cnt <= (others=>'0');
         else 
            data_field_cnt <= data_field_cnt;
         end if;
      end if;
   end process;
   
-- Character counter in data fields. Counter is reset when comma is received 
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         char_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if data = C_comma AND data_v = '1' then 
            char_cnt <= (others=>'0');
         elsif data_v = '1' then 
            char_cnt <= char_cnt + 1;
         else 
            char_cnt <= char_cnt;
         end if;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- state machine
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_state <= next_state;
	end if;	
end process;

-- ----------------------------------------------------------------------------
-- state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, data, data_v, state_cnt) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state
         if data_v = '1' then 
            if data = C_dollar then       -- Sentence start delimiter
               next_state <= GET_TALKER_ID;
            else 
               next_state <= idle;
            end if;
         end if;
      
      when GET_TALKER_ID =>
         if data_v = '1' then 
            if state_cnt = talker_id_len - 1 then 
               next_state <= GET_SENTENCE_ID;
            else 
               next_state <= GET_TALKER_ID;
            end if;
         end if;
              
      when GET_SENTENCE_ID =>
         if data_v = '1' then 
            if state_cnt = sentence_id_len - 1 then 
               next_state <= PARSE_SENTENCE;
            else 
               next_state <= GET_SENTENCE_ID;
            end if;
         end if;
         
      when PARSE_SENTENCE =>
         if data_v = '1' then
            if data = C_asterisk then 
               next_state <= GET_CHECKSUM;
            else 
               next_state <= PARSE_SENTENCE;
            end if;
         end if; 
      
      when GET_CHECKSUM =>
         if data_v = '1' then 
            if state_cnt = checksum_len - 1 then 
               next_state <= CHECK_CHECKSUM;
            else 
               next_state <= GET_CHECKSUM;
            end if;
         end if;
      
      when CHECK_CHECKSUM => 
         next_state <= idle;
         
		when others => 
			next_state <= idle;
	end case;
end process;


-- ----------------------------------------------------------------------------
-- NMEA talker_id, sentence_id and checksum registers registers
-- ----------------------------------------------------------------------------
process(clk)
begin
   if (clk'event AND clk='1') then
      if data_v = '1' then 
      
         --talker id reg
         if current_state = GET_TALKER_ID then
            if state_cnt = 0 then 
               nmea_talker_id(15 downto 8) <= data;
            elsif state_cnt = 1 then 
               nmea_talker_id(7 downto 0) <= data;
            else 
               nmea_talker_id <= nmea_talker_id;
            end if;
         end if;
         
         --sentence id reg
         if current_state = GET_SENTENCE_ID then 
            if state_cnt = 0 then 
               nmea_sentence_id(23 downto 16) <= data;
            elsif state_cnt = 1 then 
               nmea_sentence_id(15 downto 8) <= data;
            elsif state_cnt = 2 then 
               nmea_sentence_id(7 downto 0) <= data;
            else 
               nmea_sentence_id <= nmea_sentence_id;
            end if;
         end if;
         
         --checksum value reg
         if current_state = GET_CHECKSUM then 
            if state_cnt = 0 then
               nmea_checksum(7 downto 4) <= hex_to_slv(data);
            elsif state_cnt = 1 then
               nmea_checksum(3 downto 0) <= hex_to_slv(data);
            else
               nmea_checksum <= nmea_checksum;
            end if;
         end if;
      end if;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Checksum
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      checksum       <= (others=>'0');
      checksum_reg   <= (others=>'0');
      checksum_valid <= '0';
   elsif (clk'event AND clk='1') then 
      if data_v = '1' then
         -- Calculate checksum 
         if data = C_dollar then 
            checksum <= (others=>'0');
         else 
            checksum <= checksum XOR data;
         end if;
         --Reset checksum_reg at beggining of sentence
         if data = C_asterisk then 
            checksum_reg <= checksum;
         else 
            checksum_reg <= checksum_reg;
         end if;
      end if;
      
      -- checksum valid signal=1 when all sentence is received and calculated crc is valid,
      -- parsed data is valid only when checksum_valid = 1
      if current_state = CHECK_CHECKSUM AND checksum_reg = nmea_checksum then
         checksum_valid <= '1';
      else 
         checksum_valid <= '0';
      end if;
      
   end if;
end process;

-- ----------------------------------------------------------------------------
-- GPGSA message
-- ----------------------------------------------------------------------------
GPGSA_proc : process(clk, reset_n)
begin
   if reset_n = '0' then 
      gpgsa_fix_int     <= (others=>'0');
      gpgsa_valid_int   <= '0';
   elsif (clk'event AND clk='1') then 
   
      if data /= C_comma AND data_v = '1' then 
         if data_field_cnt = gsa_fix_d then 
            gpgsa_fix_int <= data;
         else 
            gpgsa_fix_int <= gpgsa_fix_int;
         end if;
      else 
         gpgsa_fix_int <= gpgsa_fix_int;
      end if;
      
      if (nmea_talker_id & nmea_sentence_id) = C_GPGSA AND checksum_valid = '1' then 
         gpgsa_valid_int <= '1';
      else 
         gpgsa_valid_int <= '0';
      end if;
   end if;
end process;


-- ----------------------------------------------------------------------------
-- GNRMC message
-- ----------------------------------------------------------------------------
GNRMC_proc : process(clk, reset_n)
begin
   if reset_n = '0' then
      gnrmc_valid_int   <= '0';
      gnrmc_utc_int     <= x"30303030303030303030";
      gnrmc_status_int  <= x"30";
      gnrmc_lat_int     <= x"3030303030303030303030";
      gnrmc_long_int    <= x"303030303030303030303030";
      gnrmc_speed_int   <= x"30303030303030";
      gnrmc_course_int  <= x"303030303030";
      gnrmc_date_int    <= x"303030303030";
   elsif (clk'event AND clk='1') then 
   
      -- registers are reset when sentence start symbol "$"is received
      -- data fields are parsed by data field counter
      if data = C_dollar AND data_v = '1' then 
         gnrmc_utc_int     <= x"30303030303030303030";
         gnrmc_status_int  <= x"30";
         gnrmc_lat_int     <= x"3030303030303030303030";
         gnrmc_long_int    <= x"303030303030303030303030";
         gnrmc_speed_int   <= x"30303030303030";
         gnrmc_course_int  <= x"303030303030";
         gnrmc_date_int    <= x"303030303030";
      elsif data /= C_comma AND data_v = '1' then
      
         --d1 field
         if data_field_cnt = rmc_utc_d then 
            gnrmc_utc_int <= gnrmc_utc_int(rmc_utc_max_char*8-1-8 downto 0) & data;
         else 
            gnrmc_utc_int <= gnrmc_utc_int;
         end if;
         
         --d2 field
         if data_field_cnt = rmc_stat_d then 
            gnrmc_status_int <= data;
         else 
            gnrmc_status_int <= gnrmc_status_int;
         end if;
         
         --d3-d4 field
         if data_field_cnt = rmc_lat_d0 OR data_field_cnt = rmc_lat_d1 then 
            gnrmc_lat_int <= gnrmc_lat_int(rmc_lat_max_char*8-1-8 downto 0) & data;
         else 
            gnrmc_lat_int <= gnrmc_lat_int;
         end if;
         
         --d5-d6 field
         if data_field_cnt = rmc_long_d0 OR data_field_cnt = rmc_long_d1 then 
            gnrmc_long_int <= gnrmc_long_int(rmc_long_max_char*8-1-8 downto 0) & data;
         else 
            gnrmc_long_int <= gnrmc_long_int;
         end if;
         
         --d7 field
         if data_field_cnt = rmc_speed_d then 
            gnrmc_speed_int <= gnrmc_speed_int(rmc_speed_max_char*8-1-8 downto 0) & data;
         else 
            gnrmc_speed_int <= gnrmc_speed_int;
         end if;
         
         --d8 field
         if data_field_cnt = rmc_course_d then 
            gnrmc_course_int <= gnrmc_course_int(rmc_course_max_char*8-1-8 downto 0) & data;
         else 
            gnrmc_course_int <= gnrmc_course_int;
         end if;

         --d9 field
         if data_field_cnt = rmc_date_d then 
            gnrmc_date_int <= gnrmc_date_int(rmc_date_max_char*8-1-8 downto 0) & data;
         else 
            gnrmc_date_int <= gnrmc_date_int;
         end if;  
         
      else 
         gnrmc_utc_int     <= gnrmc_utc_int;
         gnrmc_status_int  <= gnrmc_status_int;
         gnrmc_lat_int     <= gnrmc_lat_int;
         gnrmc_long_int    <= gnrmc_long_int;  
         gnrmc_speed_int   <= gnrmc_speed_int; 
         gnrmc_course_int  <= gnrmc_course_int;
         gnrmc_date_int    <= gnrmc_date_int;  

      end if;
      
      --message valid signal
      if (nmea_talker_id & nmea_sentence_id) = C_GNRMC AND checksum_valid = '1' then 
         gnrmc_valid_int <= '1';
      else 
         gnrmc_valid_int <= '0';
      end if;
      
   end if;
end process;

-- ----------------------------------------------------------------------------
-- GPGSA message output registers
-- ----------------------------------------------------------------------------
GPGSA_outreg : process(clk, reset_n)
begin
   if reset_n = '0' then 
      GPGSA_valid    <= '0';
      GPGSA_fix      <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if gpgsa_valid_int = '1' then 
         GPGSA_fix      <= gpgsa_fix_int;
      end if;
      
      GPGSA_valid    <= gpgsa_valid_int;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- GNRMC message output registers
-- ----------------------------------------------------------------------------
GNRMC_outreg : process(clk, reset_n)
begin
   if reset_n = '0' then 
      GNRMC_valid    <= '0';
      GNRMC_utc      <= x"30303030303030303030";
      GNRMC_status   <= x"30";
      GNRMC_lat      <= x"3030303030303030303030";
      GNRMC_long     <= x"303030303030303030303030";
      GNRMC_speed    <= x"30303030303030";
      GNRMC_course   <= x"303030303030";
      GNRMC_date     <= x"303030303030";
   elsif (clk'event AND clk='1') then 
      if gnrmc_valid_int = '1' then 
         GNRMC_utc      <= gnrmc_utc_int;
         GNRMC_status   <= gnrmc_status_int;
         GNRMC_lat      <= gnrmc_lat_int; 
         GNRMC_long     <= gnrmc_long_int;
         GNRMC_speed    <= gnrmc_speed_int;
         GNRMC_course   <= gnrmc_course_int;
         GNRMC_date     <= gnrmc_date_int;
      end if;
      
      GNRMC_valid    <= gnrmc_valid_int;
   end if;
end process;

end arch;   


