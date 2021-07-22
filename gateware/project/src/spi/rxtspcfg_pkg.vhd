-- ----------------------------------------------------------------------------
-- FILE:          rxtspcfg_pkg.vhd
-- DESCRIPTION:   Package for tstcfg module
-- DATE:          9:57 AM Monday, May 14, 2018
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
package rxtspcfg_pkg is
   
   -- Outputs from the 
   type t_FROM_RXTSPCFG is record
      en          : std_logic;
      gcorri      : std_logic_vector(10 downto 0);
      gcorrq      : std_logic_vector(10 downto 0);
      iqcorr      : std_logic_vector(11 downto 0);
      dccorr_avg  : std_logic_vector(2 downto 0);
      ovr         : std_logic_vector(2 downto 0); --HBD decimation ratio
      gfir1l      : std_logic_vector(2 downto 0); --Length of GPFIR1
      gfir1n      : std_logic_vector(7 downto 0); --Clock division ratio of GPFIR1
      gfir2l      : std_logic_vector(2 downto 0); --Length of GPFIR2
      gfir2n      : std_logic_vector(7 downto 0); --Clock division ratio of GPFIR2
      gfir3l      : std_logic_vector(2 downto 0); --Length of GPFIR3
      gfir3n      : std_logic_vector(7 downto 0); --Clock division ratio of GPFIR3
      insel       : std_logic;
      agc_k       : std_logic_vector(17 downto 0);
      agc_adesired: std_logic_vector(11 downto 0);
      agc_avg     : std_logic_vector(11 downto 0);
      agc_mode    : std_logic_vector(1 downto 0);
      gc_byp      : std_logic;
      ph_byp      : std_logic;
      dc_byp      : std_logic;
      agc_byp     : std_logic;
      gfir1_byp   : std_logic;
      gfir2_byp   : std_logic;
      gfir3_byp   : std_logic;
      cmix_byp    : std_logic;
      cmix_sc     : std_logic;
      cmix_gain   : std_logic_vector(2 downto 0);
      bstart      : std_logic; -- BIST start flag
      capture     : std_logic;
      capsel      : std_logic_vector(1 downto 0);
      tsgfcw      : std_logic_vector(8 downto 7);
      tsgdcldq    : std_logic;
      tsgdcldi    : std_logic;
      tsgswapiq   : std_logic;
      tsgmode     : std_logic;
      tsgfc       : std_logic;
      dc_reg      : std_logic_vector(15 downto 0); --DC level to drive DAC
      hbd_dly     : std_logic_vector(2 downto 0);   
      rssi_mode   : std_logic_vector(1 downto 0);
      rxdcloop_en : std_logic;
   end record t_FROM_RXTSPCFG;
  
   -- Inputs to the .
   type t_TO_RXTSPCFG is record
      rxen        : std_logic;-- Power down all modules when rxen=0
      capd        : std_logic_vector(31 downto 0);-- Captured data
      rxtspout_i  : std_logic_vector(15 downto 0);
      rxtspout_q  : std_logic_vector(15 downto 0);
   end record t_TO_RXTSPCFG;
   

end package rxtspcfg_pkg;