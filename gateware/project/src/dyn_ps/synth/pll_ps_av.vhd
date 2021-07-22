-- ----------------------------------------------------------------------------
-- FILE:          pll_ps_av.vhd
-- DESCRIPTION:   Phase shift module with avalon MM interface
-- DATE:          11:21 AM Friday, January 19, 2018
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
entity pll_ps_av is
   port (
      clk               : in std_logic; -- connect to PLL scanclk output
      reset_n           : in std_logic;
      busy              : out std_logic; -- 1 - busy, 0 - not busy
      en                : in std_logic; -- rising edge triggers dynamic phase shift
      phase             : in std_logic_vector(9 downto 0); -- phase value in steps
      cnt               : in std_logic_vector(2 downto 0); -- 000 - ALL, 001 -   M, 010 - C0,
                                                  -- 011 -  C1, 100 -  C2, 101 - C3,
                                                  -- 110 -  C4
      updown            : in std_logic; -- 1- UP, 0 - DOWN      
      --AVMM pll reconfig ports
      mgmt_read_data    : in std_logic_vector(31 downto 0);
      mgmt_write_data   : out std_logic_vector(31 downto 0);
      mgmt_address      : out std_logic_vector(5 downto 0);
      mgmt_read         : out std_logic;
      mgmt_write        : out std_logic;
      mgmt_reset        : out std_logic;
      mgmt_waitrequest  : in std_logic


      );
end pll_ps_av;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pll_ps_av is
--declare signals,  components here
signal en_reg     : std_logic;
signal phase_reg  : std_logic_vector(9 downto 0);
signal cnt_reg    : std_logic_vector(2 downto 0);
signal updown_reg : std_logic;
signal busy_reg   : std_logic;


type state_type is (idle);
signal current_state, next_state : state_type;


  
begin

-- ----------------------------------------------------------------------------
-- Input registers
-- ----------------------------------------------------------------------------
process(reset_n, clk)
   begin
      if reset_n='0' then
         en_reg      <= '0';
         phase_reg   <= (others => '0');
         cnt_reg     <= (others => '0');
         updown_reg  <= '0';
      elsif (clk'event and clk = '1') then
         en_reg <= en;
         
         --capture on rising edge of en port
         if en_reg = '0' AND en = '1' then 
            phase_reg   <= phase;
            cnt_reg     <= cnt;
            updown_reg  <= updown;
         else 
            phase_reg   <= phase_reg;
            cnt_reg     <= cnt_reg;
            updown_reg  <= updown_reg;
         end if;
      end if;
   end process;
    
-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
   if(reset_n = '0')then
      current_state  <= idle;
   elsif(clk'event and clk = '1')then 
      current_state <= next_state;
   end if;
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state) begin
   next_state <= current_state;
   case current_state is
   
      when idle =>                     -- wait for start

         
      when others => 
         next_state <= idle;
   end case;
end process;

-- ----------------------------------------------------------------------------
-- fsm dependant registers
-- ----------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
-- output ports
-- ----------------------------------------------------------------------------

  
end arch;   


