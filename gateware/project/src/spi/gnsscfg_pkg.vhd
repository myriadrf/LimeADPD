-- ----------------------------------------------------------------------------
-- FILE:          gnsscfg_pkg.vhd
-- DESCRIPTION:   Package for memcfg module
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
package gnsscfg_pkg is
   
   -- Outputs from the 
   type t_FROM_GNSSCFG is record
      en    : std_logic;  -- 0 - disable, 1 - enable. gnss module control
   end record t_FROM_GNSSCFG;
  
   -- Inputs to the 
   type t_TO_GNSSCFG is record
      gprmc_utc         : std_logic_vector(35 downto 0); -- HH-MM-SS1.SSS0 
      gprmc_status      : std_logic; --Status 1 = Data valid, 0 = Navigation receiver warning
      gprmc_lat         : std_logic_vector(32 downto 0); -- n_s-LL3-LL2.LL1-LL0
      gprmc_long        : std_logic_vector(36 downto 0); -- e_w-Y4-YY3-YY2.YY1-YY0
      gprmc_speed       : std_logic_vector(23 downto 0); -- XX2-XX1.XX0
      gprmc_course      : std_logic_vector(19 downto 0); -- X2-XX1.XX0 
      gprmc_date        : std_logic_vector(23 downto 0); -- DD-MM-YY
      gpgsa_fix         : std_logic_vector(3 downto 0); --1 = Fix not available, 2 = 2D, 3 = 3D
   end record t_TO_GNSSCFG;
   

      
end package gnsscfg_pkg;