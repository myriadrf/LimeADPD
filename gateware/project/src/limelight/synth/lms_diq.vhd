-- ----------------------------------------------------------------------------
-- FILE:          lms_diq.vhd
-- DESCRIPTION:   LMS7002 DIQ interface
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
use work.fpgacfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lms_diq is
   generic(
      g_DEV_FAMILY   : string := "Cyclone V GX";
      g_DIQ_WIDTH    : integer := 12
   );
   port (
      -- Configuration port
      from_fpgacfg      : in t_FROM_FPGACFG;
      -- RX interface
      rx_clk            : in  std_logic;  -- RX interface clock
      rx_io_reset_n     : in  std_logic;
      rx_logic_reset_n  : in  std_logic;
      rx_tst_en         : in  std_logic;  -- Test pattern. 0 - Disabled, 1 - Enabled 
      rx_diq            : in  std_logic_vector(g_DIQ_WIDTH-1 downto 0); -- LMS7002 DIQ bus
      rx_diq_fsync      : in  std_logic;  -- LMS7002 IQ select
      rx_iq             : out std_logic_vector(4*g_DIQ_WIDTH-1 downto 0); -- Captured IQ samples
      rx_iq_valid       : out std_logic;  -- Valid word indication of rx_iq
      rx_iq_cmp_start   : in std_logic;
      rx_iq_cmp_length  : in std_logic_vector(15 downto 0);
      rx_iq_cmp_done    : out std_logic;
      rx_iq_cmp_err     : out std_logic;
      -- TX interface
      tx_clk            : in  std_logic;  -- RX interface clock
      tx_io_reset_n     : in  std_logic;
      tx_logic_reset_n  : in  std_logic;
      tx_tst_en         : in  std_logic;  -- Test pattern. 0 - Disabled, 1 - Enabled 
      tx_diq            : out std_logic_vector(g_DIQ_WIDTH-1 downto 0); -- LMS7002 DIQ bus
      tx_diq_fsync      : out std_logic;  -- LMS7002 IQ select
      tx_fifo_wrclk     : in  std_logic;
      tx_fifo_data      : in  std_logic_vector(4*g_DIQ_WIDTH-1 downto 0); -- IQ samples to send
      tx_fifo_wrreq     : out std_logic;  --
      tx_fifo_wrfull    : out std_logic

      );
end lms_diq;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms_diq is
--declare signals,  components here
signal my_sig_name : std_logic_vector (7 downto 0); 

  
begin


 process(reset_n, clk)
    begin
      if reset_n='0' then
        --reset  
      elsif (clk'event and clk = '1') then
         --in process
      end if;
    end process;
  
end arch;   


