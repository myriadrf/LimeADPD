-- ----------------------------------------------------------------------------
-- FILE:          IC_74HC595.vhd
-- DESCRIPTION:   module for 74HC595 shift register
-- DATE:          4:37 PM Thursday, December 14, 2017
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES: Module is written to work with 30.72MHz frequency. 
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity IC_74HC595 is
   generic(
      data_width   : integer := 16
   );
   port (

      clk      : in std_logic;
      reset_n  : in std_logic;
      en       : in std_logic;
      data     : in std_logic_vector(data_width-1 downto 0);
      busy     : out std_logic;
      
      SHCP     : out std_logic;  -- shift register clock
      STCP     : out std_logic;  -- storage register clock
      DS       : out std_logic   -- serial data
      
        );
end IC_74HC595;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of IC_74HC595 is
--declare signals,  components here
signal SHCP_reg      : std_logic;
signal STCP_reg      : std_logic;
signal clk_reg       : std_logic;
signal shift_reg     : std_logic_vector(data_width-1 downto 0);
signal en_reg        : std_logic;
signal shift_cnt     : unsigned(7 downto 0);
signal latch_cnt     : unsigned(3 downto 0);
signal busy_reg      : std_logic;

type state_type is (idle, shift_en, latch);
signal current_state, next_state : state_type;

  
begin
 
-- ----------------------------------------------------------------------------
-- Input registers
-- ----------------------------------------------------------------------------
process(reset_n, clk)
    begin
      if reset_n='0' then
         en_reg <= '0';
      elsif (clk'event and clk = '1') then
         en_reg <=  en;    
      end if;
    end process;   

-- ----------------------------------------------------------------------------
-- Counter for counting shift cycles
-- ----------------------------------------------------------------------------
 process(reset_n, clk)
    begin
      if reset_n='0' then
         shift_cnt <= (others=>'0');
         latch_cnt <= (others=>'0');
      elsif (clk'event and clk = '1') then
         if current_state = shift_en then 
            shift_cnt <= shift_cnt + 1;
         else 
            shift_cnt <= (others=>'0');
         end if;
      end if;
    end process;    
     
-- ----------------------------------------------------------------------------
--state machine to control when to read from FIFO
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
   if(reset_n = '0')then
      current_state <= idle;
   elsif(clk'event and clk = '1')then 
      current_state <= next_state;
   end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, en, en_reg, shift_cnt, latch_cnt) begin
   next_state <= current_state;
   case current_state is
   
      when idle =>         -- idle state, waiting for rising edge of en signal
         if en = '1' AND en_reg = '0' then 
            next_state <= shift_en;
         else 
            next_state <= idle;
         end if;
      
      when shift_en =>     -- serial data is shifted out at this stage
         if shift_cnt < data_width*2 - 1 then 
            next_state <= shift_en;
         else 
            next_state <= latch;
         end if;
         
      when latch =>        -- data is latched at storage registers of 74HC595
         next_state <= idle;
   
      when others => 
         next_state<=idle;
         
   end case;
end process;


-- ----------------------------------------------------------------------------
-- Busy signal for state indication
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      busy_reg <= '0';
   elsif (clk'event AND clk='1') then 
      if en = '1' AND en_reg = '0' then 
         busy_reg <= '1';
      elsif current_state = idle then 
         busy_reg <= '0';
      else 
         busy_reg <= busy_reg;
      end if;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Shift register
-- ----------------------------------------------------------------------------
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         shift_reg <= (others=>'0');
      elsif (clk'event AND clk='1') then
         if en = '1' AND en_reg = '0' then 
            shift_reg <= data;
         elsif SHCP_reg = '1' then 
            shift_reg <= shift_reg(data_width-2 downto 0) & '0';
         else 
            shift_reg <= shift_reg;
         end if;
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- Shift clock generation
-- ----------------------------------------------------------------------------  
   process(reset_n, clk)
    begin
      if reset_n='0' then
         SHCP_reg <= '0';
      elsif (clk'event and clk = '1') then
         if current_state = shift_en then 
            SHCP_reg <= not SHCP_reg;
         else 
            SHCP_reg <= '0';
         end if;
      end if;
    end process;
    
-- ----------------------------------------------------------------------------
-- Storage register clock generation 
-- ----------------------------------------------------------------------------  
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         STCP_reg <= '0';
      elsif (clk'event AND clk='1') then 
         if current_state = latch then 
            STCP_reg <= '1';
         else 
            STCP_reg <= '0';
         end if;
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
 busy       <= busy_reg;
 SHCP       <= SHCP_reg;
 STCP       <= STCP_reg; 
 DS         <= shift_reg(data_width-1);

  
end arch;   


