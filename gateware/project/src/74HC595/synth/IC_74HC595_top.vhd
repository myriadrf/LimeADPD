-- ----------------------------------------------------------------------------
-- FILE:          IC_74HC595_top.vhd
-- DESCRIPTION:   top file for IC_74HC595
-- DATE:          4:36 PM Thursday, December 14, 2017
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
entity IC_74HC595_top is
   port (

      clk      : in std_logic;
      reset_n  : in std_logic;
      data     : in std_logic_vector(15 downto 0);
      busy     : out std_logic;
      
      SHCP     : out std_logic;  -- shift register clock
      STCP     : out std_logic;  -- storage register clock
      DS       : out std_logic   -- serial data
      
        );
end IC_74HC595_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of IC_74HC595_top is
--declare signals,  components here
signal reset_n_sync     : std_logic;
signal reset_n_delayed  : std_logic;
signal data_remaped     : std_logic_vector (15 downto 0) ;
signal data_sync        : std_logic_vector (15 downto 0); 
signal data_sync_reg    : std_logic_vector (15 downto 0);
signal data_change      : std_logic;
signal reset_cnt        : unsigned(7 downto 0);


begin

-- ----------------------------------------------------------------------------
-- Remaping data into desired order
-- ----------------------------------------------------------------------------
--Original order
--data_remaped(0)   <= data(0);
--data_remaped(1)   <= data(1);
--data_remaped(2)   <= data(2);
--data_remaped(3)   <= data(3);
--data_remaped(4)   <= data(4);
--data_remaped(5)   <= data(5);
--data_remaped(6)   <= data(6);
--data_remaped(7)   <= data(7);
--data_remaped(8)   <= data(8);
--data_remaped(9)   <= data(9);
--data_remaped(10)  <= data(10);
--data_remaped(11)  <= data(11);
--data_remaped(12)  <= data(12);
--data_remaped(13)  <= data(13);
--data_remaped(14)  <= data(14);
--data_remaped(15)  <= data(15);

--Signals has to be remaped in new order to folow SPI map
--    Shift reg order     Bit to remap                            Signals on SPI MAP
--15  LMS2_TX2_2_LB_SH    15  -> 15       LMS2_TX2_2_LB_SH    15  LMS2_TX2_2_LB_SH
--14  LMS2_TX1_2_LB_AT    14  -> 10       LMS2_TX1_2_LB_AT    14  LMS2_TX2_2_LB_AT
--13  LMS2_TX1_2_LB_SH    13  -> 11       LMS2_TX1_2_LB_SH    13  LMS2_TX2_2_LB_H
--12  LMS2_TX2_2_LB_AT    12  -> 14       LMS2_TX2_2_LB_AT    12  LMS2_TX2_2_LB_L
--11  LMS2_TX1_2_LB_H     11  -> 9        LMS2_TX1_2_LB_H     11  LMS2_TX1_2_LB_SH
--10  LMS2_TX1_2_LB_L     10  -> 8        LMS2_TX1_2_LB_L     10  LMS2_TX1_2_LB_AT
--9   LMS2_TX2_2_LB_H     9   -> 13       LMS2_TX2_2_LB_H     9   LMS2_TX1_2_LB_H
--8   LMS2_TX2_2_LB_L     8   -> 12       LMS2_TX2_2_LB_L     8   LMS2_TX1_2_LB_L
--                            
--7   LMS1_TX2_2_LB_L     7   -> 4        LMS1_TX2_2_LB_L     7   LMS1_TX2_2_LB_SH
--6   LMS1_TX2_2_LB_H     6   -> 5        LMS1_TX2_2_LB_H     6   LMS1_TX2_2_LB_AT
--5   LMS1_TX1_2_LB_L     5   -> 0        LMS1_TX1_2_LB_L     5   LMS1_TX2_2_LB_H
--4   LMS1_TX1_2_LB_H     4   -> 1        LMS1_TX1_2_LB_H     4   LMS1_TX2_2_LB_L
--3   LMS1_TX1_2_LB_AT    3   -> 2        LMS1_TX1_2_LB_AT    3   LMS1_TX1_2_LB_SH
--2   LMS1_TX1_2_LB_SH    2   -> 3        LMS1_TX1_2_LB_SH    2   LMS1_TX1_2_LB_AT
--1   LMS1_TX2_2_LB_SH    1   -> 7        LMS1_TX2_2_LB_SH    1   LMS1_TX1_2_LB_H
--0   LMS1_TX2_2_LB_AT    0   -> 6        LMS1_TX2_2_LB_AT    0   LMS1_TX1_2_LB_L


--New remaped signals by SPI map
data_remaped(0)   <= data(6);
data_remaped(1)   <= data(7);
data_remaped(2)   <= data(3);
data_remaped(3)   <= data(2);
data_remaped(4)   <= data(1);
data_remaped(5)   <= data(0);
data_remaped(6)   <= data(5);
data_remaped(7)   <= data(4);
data_remaped(8)   <= data(12);
data_remaped(9)   <= data(13);
data_remaped(10)  <= data(8);
data_remaped(11)  <= data(9);
data_remaped(12)  <= data(14);
data_remaped(13)  <= data(11);
data_remaped(14)  <= data(10);
data_remaped(15)  <= data(15);
 
-- ----------------------------------------------------------------------------
-- Data synchronization into clk domain
-- ----------------------------------------------------------------------------
sync_reg0 : entity work.sync_reg 
port map(clk, reset_n, reset_n, reset_n_sync);

bus_sync_reg0 : entity work.bus_sync_reg
generic map (16)
port map(clk, reset_n_sync, data_remaped, data_sync);

process(clk, reset_n_sync)
begin
   if reset_n_sync = '0' then 
      reset_cnt         <= (others=>'0');
      reset_n_delayed   <= '0';
   elsif (clk'event AND clk='1') then 
      if reset_cnt < 255 then 
         reset_cnt <= reset_cnt + 1;
         reset_n_delayed <= '0';
      else 
         reset_cnt <= reset_cnt;
         reset_n_delayed <= '1';
      end if;         
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Detecting signal change
-- ----------------------------------------------------------------------------
 process(reset_n_delayed, clk)
    begin
      if reset_n_delayed='0' then
         data_sync_reg  <= (others=> '0');
         data_change    <= '0';
      elsif (clk'event and clk = '1') then
         data_sync_reg <= data_sync;
         if data_sync_reg = data_sync then 
            data_change <= '0';
         else 
            data_change <= '1';
         end if;
      end if;
    end process;

-- ----------------------------------------------------------------------------
-- Module instance
-- ----------------------------------------------------------------------------
IC_74HC595_inst0 : entity work.IC_74HC595
   generic map (
      data_width   => 16
   )
   port map (
      clk      => clk,
      reset_n  => reset_n_delayed,
      en       => data_change,
      data     => data_sync_reg,
      busy     => busy,
      
      SHCP     => SHCP,
      STCP     => STCP,
      DS       => DS
      );
  
end arch;   


