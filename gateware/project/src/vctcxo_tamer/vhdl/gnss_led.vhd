-- ----------------------------------------------------------------------------
-- FILE:          gnss_led.vhd
-- DESCRIPTION:   describe file
-- DATE:          Jan 27, 2016
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
entity gnss_led is
   port (

      clk                  : in std_logic;
      reset_n              : in std_logic;
      
      --
      vctcxo_tune_en       : in std_logic;
      vctcxo_tune_accuracy : in std_logic_vector(3 downto 0);
      
      --gnss module ports
      gnss_fix             : in std_logic;
      gnss_tpulse          : in std_logic;
      gnss_led_r           : out std_logic;
      gnss_led_g           : out std_logic
      );
end gnss_led;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of gnss_led is
--declare signals,  components here
signal gnss_tpulse_sync       : std_logic; 
signal gnss_tpulse_sync_reg   : std_logic;
signal tpulse_int             : std_logic; -- time pulse synced to clk domain
signal led_blink              : std_logic;
signal led_r_reg              : std_logic;
signal led_g_reg              : std_logic;

  
begin

--Synchronization registers for asynchronous input ports
sync_reg0 : entity work.sync_reg 
port map(clk, reset_n, gnss_tpulse, gnss_tpulse_sync);

-- ----------------------------------------------------------------------------
-- tpulse in clk domain
-- ----------------------------------------------------------------------------
 process(reset_n, clk)
    begin
      if reset_n='0' then
         gnss_tpulse_sync_reg <= '0';
      elsif (clk'event and clk = '1') then
         gnss_tpulse_sync_reg <= gnss_tpulse_sync;
         
         --one cycle pulse trigered on gnss_tpulse rising edge
         if gnss_tpulse_sync = '1' AND gnss_tpulse_sync_reg = '0'  then 
            tpulse_int <= '1';
         else 
            tpulse_int <= '0';
         end if;
         
      end if;
    end process;
    
    
-- ----------------------------------------------------------------------------
-- led blinker
-- ----------------------------------------------------------------------------   
 process(reset_n, clk)
    begin
      if reset_n='0' then
         led_blink <= '0';
      elsif (clk'event and clk = '1') then   
      
         if tpulse_int = '1' then 
            led_blink   <= not led_blink;
         else 
            led_blink   <= led_blink;
         end if;      
         
      end if;
    end process;
    
 process(reset_n, clk)
    begin
      if reset_n='0' then
         led_r_reg <= '0';
         led_g_reg <= '0';
      elsif (clk'event and clk = '1') then
         if vctcxo_tune_en = '1' then 
            if gnss_fix = '1' then 
               if unsigned(vctcxo_tune_accuracy) = 0 OR unsigned(vctcxo_tune_accuracy) = 1 then
                  -- blinking red
                  led_r_reg <= led_blink;
                  led_g_reg <= '0';
               elsif unsigned(vctcxo_tune_accuracy) = 2 then
                  --blinking green/red
                  led_r_reg <= led_blink;
                  led_g_reg <= not led_blink;               
               else
                  --blinking green
                  led_r_reg <= '0';
                  led_g_reg <= led_blink;               
               end if;
            else 
               --solid red
               led_r_reg <= '1';
               led_g_reg <= '0';
            end if;
         else
            -- no lights
            led_r_reg <= '0';
            led_g_reg <= '0';
         end if;
         
      end if;
    end process;
    

-- ----------------------------------------------------------------------------
-- output ports
-- ---------------------------------------------------------------------------- 
gnss_led_r <= led_r_reg; 
gnss_led_g <= led_g_reg;
    
    

  
end arch;   


