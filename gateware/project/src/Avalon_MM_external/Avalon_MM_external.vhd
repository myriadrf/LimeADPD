-- ----------------------------------------------------------------------------
-- FILE:          Avalon_MM_external.vhd
-- DESCRIPTION:   Component to export Avalon master bus from QSYS system
-- DATE:          10:29 AM Friday, February 23, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity Avalon_MM_external is
    port (
        avs_s0_address       : in  std_logic_vector(7 downto 0) := (others => '0'); --       avs_s0.address
        avs_s0_read          : in  std_logic                    := '0';             --             .read
        avs_s0_readdata      : out std_logic_vector(7 downto 0);                    --             .readdata
        avs_s0_write         : in  std_logic                    := '0';             --             .write
        avs_s0_writedata     : in  std_logic_vector(7 downto 0) := (others => '0'); --             .writedata
        avs_s0_waitrequest   : out std_logic;                                       --             .waitrequest
        avs_s0_readdatavalid : out std_logic;                                       --             .readdatavalid
        clock_clk            : in  std_logic                    := '0';             --        clock.clk
        reset_reset          : in  std_logic                    := '0';             --        reset.reset
        avm_m0_address       : out std_logic_vector(7 downto 0);                    --       avm_m0.address
        avm_m0_read          : out std_logic;                                       --             .read
        avm_m0_waitrequest   : in  std_logic                    := '0';             --             .waitrequest
        avm_m0_readdata      : in  std_logic_vector(7 downto 0) := (others => '0'); --             .readdata
        avm_m0_write         : out std_logic;                                       --             .write
        avm_m0_writedata     : out std_logic_vector(7 downto 0);                    --             .writedata
        avm_m0_readdatavalid : in  std_logic                    := '0';             --             .readdatavalid
        clock_source_clk     : out std_logic;                                       -- clock_source.clk
        reset_source_reset   : out std_logic                                        -- reset_source.reset
    );
end entity Avalon_MM_external;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture rtl of Avalon_MM_external is
begin

   avs_s0_readdata      <= avm_m0_readdata;

   avs_s0_waitrequest   <= avm_m0_waitrequest;
   
   avs_s0_readdatavalid <= avm_m0_readdatavalid;

   avm_m0_address       <= avs_s0_address;

   avm_m0_read          <= avs_s0_read;

   avm_m0_write         <= avs_s0_write;

   avm_m0_writedata     <= avs_s0_writedata;

   clock_source_clk     <= clock_clk;

   reset_source_reset   <= reset_reset;

end architecture rtl;
