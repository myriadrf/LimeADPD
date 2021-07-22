-- ----------------------------------------------------------------------------
-- FILE:          txtspcfg_pkg.vhd
-- DESCRIPTION:   Package for tamercfg module
-- DATE:          11:13 AM Friday, May 11, 2018
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
package txtspcfg_pkg is
   
   -- Outputs from the 
   type t_FROM_TXTSPCFG is record
         -- Control lines  
      en          : std_logic;
      gcorri      : std_logic_vector(10 downto 0);
      gcorrq      : std_logic_vector(10 downto 0);
      iqcorr      : std_logic_vector(11 downto 0);
      dccorri     : std_logic_vector(7 downto 0);
      dccorrq     : std_logic_vector(7 downto 0);
      ovr         : std_logic_vector(2 downto 0);	--HBI interpolation ratio 
      gfir1l      : std_logic_vector(2 downto 0);    --Length of GPFIR1
      gfir1n      : std_logic_vector(7 downto 0);    --Clock division ratio of GPFIR1
      gfir2l      : std_logic_vector(2 downto 0);    --Length of GPFIR2
      gfir2n      : std_logic_vector(7 downto 0);    --Clock division ratio of GPFIR2
      gfir3l      : std_logic_vector(2 downto 0);    --Length of GPFIR3
      gfir3n      : std_logic_vector(7 downto 0);    --Clock division ratio of GPFIR3
      dc_reg      : std_logic_vector(15 downto 0);   --DC level to drive DACI
      insel       : std_logic;
      ph_byp      : std_logic;
      gc_byp      : std_logic;
      gfir1_byp   : std_logic;
      gfir2_byp   : std_logic;
      gfir3_byp   : std_logic;
      dc_byp      : std_logic;
      isinc_byp   : std_logic;
      cmix_sc     : std_logic;
      cmix_byp    : std_logic;
      cmix_gain   : std_logic_vector(2 downto 0);
      bstart      : std_logic;           -- BIST start flag
      tsgfcw      : std_logic_vector(8 downto 7);
      tsgdcldq    : std_logic;
      tsgdcldi    : std_logic;
      tsgswapiq   : std_logic;
      tsgmode     : std_logic;
      tsgfc       : std_logic;
      nco_fcv     : std_logic_vector(31 downto 0);
   end record t_FROM_TXTSPCFG;
  
   -- Inputs to the 
   type t_TO_TXTSPCFG is record
      txen     : std_logic;  -- Power down all modules when txen=0
      bstate   : std_logic;            -- BIST state flag
      bsigi    : std_logic_vector(22 downto 0);  -- BIST signature, channel I
      bsigq    : std_logic_vector(22 downto 0);  -- BIST signature, channel Q
   end record t_TO_TXTSPCFG;
  
end package txtspcfg_pkg;