-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_player_rst_ctrl.vhd
-- DESCRIPTION:	reset controller for wfm player
-- DATE:	August 18, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_player_rst_ctrl is
   port (

      clk                     : in std_logic;
      global_reset_n          : in std_logic;
      
      wfm_load                : in std_logic;
      wfm_load_ext            : out std_logic;
      wfm_play_stop           : in std_logic;
      
      ram_init_done           : in std_logic;
      ram_global_reset_n      : out std_logic;
      ram_soft_reset_n        : out std_logic;
      ram_wcmd_reset_n        : out std_logic;
      ram_rcmd_reset_n        : out std_logic;
            
      wfm_player_reset_n      : out std_logic;
      wfm_player_wcmd_reset_n : out std_logic;
      wfm_player_rcmd_reset_n : out std_logic;
      
      dcmpr_reset_n           : out std_logic;
      
      clk0                    : in std_logic;
      clk0_reset_n            : out std_logic;
      clk0_reset_n_pulse      : out std_logic


        );
end wfm_player_rst_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_player_rst_ctrl is
--declare signals,  components here
signal wfm_load_synch            : std_logic;
signal wfm_load_ext_sig          : std_logic;
signal ram_init_done_synch       : std_logic;
signal wfm_load_pulse_on_rising  : std_logic;
signal global_reset_n_synch      : std_logic; 

--ram internal signals
signal ram_global_reset_n_int       : std_logic;
signal ram_soft_reset_n_int         : std_logic;
signal ram_wcmd_reset_n_int         : std_logic;
signal ram_rcmd_reset_n_int         : std_logic;
--wfm player internal signals
signal wfm_player_reset_n_int       : std_logic;
signal wfm_player_wcmd_reset_n_int  : std_logic;
signal wfm_player_rcmd_reset_n_int  : std_logic;

--data decompres signals
signal dcmpr_reset_n_int            : std_logic;

--clk0 domain signals
signal wfm_load_clk0                   : std_logic;
signal wfm_load_pulse_on_rising_clk0   : std_logic; 
 
begin

--Synchronizing an Asynchronous Reset
reset_n_synch_inst0 : entity work.reset_n_synch
port map(clk, global_reset_n, global_reset_n_synch);

--Synchronizing an asynchronous wfm_load signal   
sync_reg0 : entity work.sync_reg 
port map(clk, global_reset_n_synch, wfm_load, wfm_load_synch);

sync_reg1 : entity work.sync_reg 
port map(clk, global_reset_n_synch, ram_init_done, ram_init_done_synch);
   
--to detect rising edge of wfm_load
edge_pulse_inst1 : entity work.edge_pulse(arch_rising) 
port map(
   clk         => clk,
   reset_n     => global_reset_n_synch, 
   sig_in      => wfm_load_synch,
   pulse_out   => wfm_load_pulse_on_rising
);

-- ----------------------------------------------------------------------------
-- clk0 domain signals
-- ----------------------------------------------------------------------------
--Synchronizing an asynchronous wfm_load signal   
sync_reg0_clk0 : entity work.sync_reg 
port map(clk0, global_reset_n, wfm_load, wfm_load_clk0);

--to detect rising edge of wfm_load
edge_pulse_inst0_clk0 : entity work.edge_pulse(arch_rising) 
port map(
   clk         => clk0,
   reset_n     => global_reset_n, 
   sig_in      => wfm_load_clk0,
   pulse_out   => wfm_load_pulse_on_rising_clk0
);

--output registers
process(global_reset_n, clk0)
begin 
   if global_reset_n_synch = '0' then
      clk0_reset_n         <= '0';      
      clk0_reset_n_pulse   <= '0';
   elsif (clk0'event AND clk0 = '1') then 
      clk0_reset_n         <= wfm_load_clk0;      
      clk0_reset_n_pulse   <= NOT wfm_load_pulse_on_rising_clk0;
   end if;
end process;
-- ----------------------------------------------------------------------------
               
         

process(global_reset_n_synch, clk)
begin 
   if global_reset_n_synch = '0' then 
      wfm_load_ext_sig <= '0';
   elsif (clk'event AND clk = '1') then 
      if wfm_load_pulse_on_rising = '1' then 
         wfm_load_ext_sig <= '1';
      elsif wfm_load_synch = '0' then 
         wfm_load_ext_sig <= '0';
      else 
         wfm_load_ext_sig <= wfm_load_ext_sig;
      end if;
   end if;
end process;



-- ----------------------------------------------------------------------------
-- Ram reset part
-- ----------------------------------------------------------------------------
ram_global_reset_n_int  <= global_reset_n;
ram_soft_reset_n_int    <= not wfm_load_pulse_on_rising;
ram_wcmd_reset_n_int    <= not wfm_load_pulse_on_rising;
ram_rcmd_reset_n_int    <= ram_init_done_synch;

-- ----------------------------------------------------------------------------
-- wfm player part
-- ----------------------------------------------------------------------------
wfm_player_reset_n_int      <= not wfm_load_pulse_on_rising;
wfm_player_wcmd_reset_n_int <= not wfm_load_pulse_on_rising;
wfm_player_rcmd_reset_n_int <= ram_init_done_synch;

-- ----------------------------------------------------------------------------
-- data decompres reset part
-- ----------------------------------------------------------------------------
dcmpr_reset_n_int <= not wfm_load_synch;




-- ----------------------------------------------------------------------------
-- Output registers
-- ----------------------------------------------------------------------------
 process(global_reset_n_synch, clk)
    begin
      if global_reset_n_synch='0' then        
         ram_soft_reset_n        <= '0'; 
         ram_wcmd_reset_n        <= '0';
         ram_rcmd_reset_n        <= '0';     
         wfm_player_reset_n      <= '0';
         wfm_player_wcmd_reset_n <= '0';
         wfm_player_rcmd_reset_n <= '0';
         dcmpr_reset_n           <= '0';
         wfm_load_ext            <= '0';
      elsif (clk'event and clk = '1') then 
         ram_soft_reset_n        <= ram_soft_reset_n_int; 
         ram_wcmd_reset_n        <= ram_wcmd_reset_n_int;
         ram_rcmd_reset_n        <= ram_rcmd_reset_n_int;     
         wfm_player_reset_n      <= wfm_player_reset_n_int;
         wfm_player_wcmd_reset_n <= wfm_player_wcmd_reset_n_int;
         wfm_player_rcmd_reset_n <= wfm_player_rcmd_reset_n_int;
         dcmpr_reset_n           <= dcmpr_reset_n_int;
         wfm_load_ext            <= wfm_load_ext_sig;
 	    end if;
    end process;
    
   ram_global_reset_n      <= ram_global_reset_n_int; 
  
end arch;   





