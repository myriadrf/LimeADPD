-- ----------------------------------------------------------------------------
-- FILE:          tamercfg_pkg.vhd
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
package tamercfg_pkg is
   
   -- Outputs from the 
   type t_FROM_TAMERCFG is record
      en                : std_logic;
      pps_1s_err_tol    : std_logic_vector(31 downto 0);
      pps_10s_err_tol   : std_logic_vector(31 downto 0);
      pps_100s_err_tol  : std_logic_vector(31 downto 0);
   end record t_FROM_TAMERCFG;
  
   -- Inputs to the 
   type t_TO_TAMERCFG is record
      accuracy          : std_logic_vector(3 downto 0);
      state             : std_logic_vector(3 downto 0);
      dac_tuned_val     : std_logic_vector(15 downto 0);
      pps_1s_err        : std_logic_vector(31 downto 0);
      pps_10s_err       : std_logic_vector(31 downto 0);
      pps_100s_err      : std_logic_vector(31 downto 0);
   end record t_TO_TAMERCFG;
   

      
end package tamercfg_pkg;