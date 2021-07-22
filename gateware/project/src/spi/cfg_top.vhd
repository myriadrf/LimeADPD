-- ----------------------------------------------------------------------------
-- FILE:          cfg_top.vhd
-- DESCRIPTION:   Wrapper file for SPI configuration memories
-- DATE:          11:09 AM Friday, May 11, 2018
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
use work.pllcfg_pkg.all;
use work.tstcfg_pkg.all;
use work.txtspcfg_pkg.all;
use work.rxtspcfg_pkg.all;
use work.periphcfg_pkg.all;
use work.tamercfg_pkg.all;
use work.gnsscfg_pkg.all;
use work.memcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity cfg_top is
   generic(
      -- CFG_START_ADDR has to be multiple of 32, because there are 32 addresses
      FPGACFG_START_ADDR   : integer := 0;
      PLLCFG_START_ADDR    : integer := 32;
      TSTCFG_START_ADDR    : integer := 96;
      TXTSPCFG_START_ADDR  : integer := 128;
      RXTSPCFG_START_ADDR  : integer := 160;
      PERIPHCFG_START_ADDR : integer := 192;
      TAMERCFG_START_ADDR  : integer := 224;
      GNSSCFG_START_ADDR   : integer := 256;
      MEMCFG_START_ADDR    : integer := 65504
      );
   port (
      -- Serial port IOs
      sdin                 : in  std_logic;  -- Data in
      sclk                 : in  std_logic;  -- Data clock
      sen                  : in  std_logic;  -- Enable signal (active low)
      sdout                : out std_logic;  -- Data out
      
      pllcfg_sdin          : in  std_logic;  -- Data in
      pllcfg_sclk          : in  std_logic;  -- Data clock
      pllcfg_sen           : in  std_logic;  -- Enable signal (active low)
      pllcfg_sdout         : out std_logic;  -- Data out
      
      -- Signals coming from the pins or top level serial interface
      lreset               : in  std_logic;   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset               : in  std_logic;   -- Memory reset signal, resets configuration memory only (use only one reset)
      to_fpgacfg_0         : in  t_TO_FPGACFG;
      from_fpgacfg_0       : out t_FROM_FPGACFG;
      to_fpgacfg_1         : in  t_TO_FPGACFG;
      from_fpgacfg_1       : out t_FROM_FPGACFG;
      to_fpgacfg_2         : in  t_TO_FPGACFG;
      from_fpgacfg_2       : out t_FROM_FPGACFG;
      to_pllcfg            : in  t_TO_PLLCFG;
      from_pllcfg          : out t_FROM_PLLCFG;
      to_tstcfg            : in  t_TO_TSTCFG;
      to_tstcfg_from_rxtx  : in  t_TO_TSTCFG_FROM_RXTX;
      from_tstcfg          : out t_FROM_TSTCFG;
      to_txtspcfg_0        : in  t_TO_TXTSPCFG;
      from_txtspcfg_0      : out t_FROM_TXTSPCFG;  
      to_txtspcfg_1        : in  t_TO_TXTSPCFG;
      from_txtspcfg_1      : out t_FROM_TXTSPCFG; 
      to_rxtspcfg          : in  t_TO_RXTSPCFG;
      from_rxtspcfg        : out t_FROM_RXTSPCFG;    
      to_periphcfg         : in  t_TO_PERIPHCFG;
      from_periphcfg       : out t_FROM_PERIPHCFG;
      to_tamercfg          : in  t_TO_TAMERCFG;
      from_tamercfg        : out t_FROM_TAMERCFG;
      to_gnsscfg           : in  t_TO_GNSSCFG;
      from_gnsscfg         : out t_FROM_GNSSCFG;
      to_memcfg            : in  t_TO_MEMCFG;
      from_memcfg          : out t_FROM_MEMCFG
   );
end cfg_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of cfg_top is
--declare signals,  components here
--inst0_0
signal inst0_0_sen     : std_logic; 
signal inst0_0_sdout   : std_logic;

--inst0_1
signal inst0_1_sen     : std_logic;
signal inst0_1_sdout   : std_logic;

--inst0_2
signal inst0_2_sen     : std_logic;
signal inst0_2_sdout   : std_logic;

--inst1
signal inst1_sdoutA  : std_logic;

--inst3
signal inst3_sdout   : std_logic;

--inst4_0
signal inst4_0_sen     : std_logic; 
signal inst4_0_sdout   : std_logic;

--inst4_1
signal inst4_1_sen     : std_logic; 
signal inst4_1_sdout   : std_logic;

--inst5
signal inst5_sen     : std_logic;
signal inst5_sdout   : std_logic;

--inst6
signal inst6_sdout   : std_logic;

--inst7
signal inst7_sdout   : std_logic;

--inst8
signal inst8_sdout   : std_logic;

--inst255
signal inst255_sdout         : std_logic;
signal inst255_to_memcfg     : t_TO_MEMCFG;
signal inst255_from_memcfg   : t_FROM_MEMCFG;

begin

-- ----------------------------------------------------------------------------
-- fpgacfg instance
-- ----------------------------------------------------------------------------
   inst0_0_sen <= sen when inst255_from_memcfg.mac(0)='1' else '1';

      
   inst0_0_fpgacfg : entity work.fpgacfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(FPGACFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => inst0_0_sen,
      sdout       => inst0_0_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,      
      to_fpgacfg  => to_fpgacfg_0,
      from_fpgacfg=> from_fpgacfg_0
   );
   
   
   inst0_1_sen <= sen when inst255_from_memcfg.mac(1)='1' else '1';
   
   inst0_1_fpgacfg : entity work.fpgacfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(FPGACFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => inst0_1_sen,
      sdout       => inst0_1_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,      
      to_fpgacfg  => to_fpgacfg_1,
      from_fpgacfg=> from_fpgacfg_1
   );
   
   inst0_2_sen <= sen when inst255_from_memcfg.mac(2)='1' else '1';
   
   inst0_2_fpgacfg : entity work.fpgacfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(FPGACFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => inst0_2_sen,
      sdout       => inst0_2_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,      
      to_fpgacfg  => to_fpgacfg_2,
      from_fpgacfg=> from_fpgacfg_2
   );
   
-- ----------------------------------------------------------------------------
-- pllcfg instance
-- ----------------------------------------------------------------------------  
   inst1_pllcfg : entity work.pllcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress       => std_logic_vector(to_unsigned(PLLCFG_START_ADDR/32,10)),
      mimo_en        => '1',      
      -- Serial port A IOs
      sdinA          => sdin,
      sclkA          => sclk,
      senA           => sen,
      sdoutA         => inst1_sdoutA,    
      oenA           => open,     
      -- Serial port B IOs
      sdinB          => pllcfg_sdin,
      sclkB          => pllcfg_sclk,
      senB           => pllcfg_sen,
      sdoutB         => pllcfg_sdout,    
      oenB           => open,       
      -- Signals coming from the pins or top level serial interface
      lreset         => lreset, -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset         => mreset,-- Memory reset signal, resets configuration memory only (use only one reset)      
      to_pllcfg      => to_pllcfg,
      from_pllcfg    => from_pllcfg
   );
   
-- ----------------------------------------------------------------------------
-- tstcfg instance
-- ----------------------------------------------------------------------------    
   inst3_tstcfg : entity work.tstcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress             => std_logic_vector(to_unsigned(TSTCFG_START_ADDR/32,10)),
      mimo_en              => '1',   
      -- Serial port IOs
      sdin                 => sdin,
      sclk                 => sclk,
      sen                  => sen,
      sdout                => inst3_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset               => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset               => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen                  => open,
      stateo               => open,    
      to_tstcfg            => to_tstcfg,
      to_tstcfg_from_rxtx  => to_tstcfg_from_rxtx,
      from_tstcfg          => from_tstcfg
   );

-- ----------------------------------------------------------------------------
-- txtspcfg instance
-- ----------------------------------------------------------------------------
   inst4_0_sen <= sen when inst255_from_memcfg.mac(0)='1' else '1';
    
   inst4_0_txtsp : entity work.txtspcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress       => std_logic_vector(to_unsigned(TXTSPCFG_START_ADDR/32,10)),
      mimo_en        => '1', -- MIMO enable, from TOP SPI
   
      -- Serial port IOs
      sdin           => sdin, -- Data in
      sclk           => sclk, -- Data clock
      sen            => inst4_0_sen,  -- Enable signal (active low)
      sdout          => inst4_0_sdout,   -- Data out
      -- Signals coming from the pins or top level serial interface
      lreset         => lreset, -- Logic reset signal, resets logic cells only
      mreset         => mreset, -- Memory reset signal, resets configuration memory only    
      oen            => open,
      stateo         => open,
      
      to_txtspcfg    => to_txtspcfg_0,
      from_txtspcfg  => from_txtspcfg_0

   );
   
   inst4_1_sen <= sen when inst255_from_memcfg.mac(1)='1' else '1';
      
   inst4_1_txtsp : entity work.txtspcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress       => std_logic_vector(to_unsigned(TXTSPCFG_START_ADDR/32,10)),
      mimo_en        => '1', -- MIMO enable, from TOP SPI
   
      -- Serial port IOs
      sdin           => sdin, -- Data in
      sclk           => sclk, -- Data clock
      sen            => inst4_1_sen,  -- Enable signal (active low)
      sdout          => inst4_1_sdout,   -- Data out
      -- Signals coming from the pins or top level serial interface
      lreset         => lreset, -- Logic reset signal, resets logic cells only
      mreset         => mreset, -- Memory reset signal, resets configuration memory only    
      oen            => open,
      stateo         => open,
      
      to_txtspcfg    => to_txtspcfg_1,
      from_txtspcfg  => from_txtspcfg_1

   );
-- ----------------------------------------------------------------------------
-- rxtspcfg instance
-- ---------------------------------------------------------------------------- 
   inst5_sen <= sen when inst255_from_memcfg.mac(0)='1' else '1';
   
   inst5_rxtspcfg : entity work.rxtspcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress             => std_logic_vector(to_unsigned(RXTSPCFG_START_ADDR/32,10)),
      mimo_en              => '1',   
      -- Serial port IOs
      sdin                 => sdin,
      sclk                 => sclk,
      sen                  => inst5_sen,
      sdout                => inst5_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset               => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset               => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen                  => open,
      stateo               => open,    
      to_rxtspcfg          => to_rxtspcfg,
      from_rxtspcfg        => from_rxtspcfg
   );
   
-- ----------------------------------------------------------------------------
-- periphcfg instance
-- ----------------------------------------------------------------------------    
   inst6_periphcfg : entity work.periphcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(PERIPHCFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen,
      sdout       => inst6_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,    
      to_periphcfg   => to_periphcfg,
      from_periphcfg => from_periphcfg
   );
   
-- ----------------------------------------------------------------------------
-- tamercfg instance
-- ----------------------------------------------------------------------------    
   inst7_tamercfg : entity work.tamercfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(TAMERCFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen,
      sdout       => inst7_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,    
      to_tamercfg    => to_tamercfg,
      from_tamercfg  => from_tamercfg
   );
   
-- ----------------------------------------------------------------------------
-- gnsscfg instance
-- ----------------------------------------------------------------------------    
   inst8_gnsscfg : entity work.gnsscfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(GNSSCFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen,
      sdout       => inst8_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,    
      to_gnsscfg     => to_gnsscfg,
      from_gnsscfg   => from_gnsscfg
   );
   
-- ----------------------------------------------------------------------------
-- memcfg instance
-- ----------------------------------------------------------------------------     
   inst255_memcfg : entity work.memcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(MEMCFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen,
      sdout       => inst255_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,      
      to_memcfg   => inst255_to_memcfg,
      from_memcfg => inst255_from_memcfg
   );
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
   sdout <= inst0_0_sdout OR inst0_1_sdout OR inst0_2_sdout OR inst1_sdoutA OR 
            inst3_sdout OR inst4_0_sdout OR inst4_1_sdout OR inst5_sdout OR 
            inst6_sdout OR inst7_sdout OR inst8_sdout OR inst255_sdout;
            
            
      inst255_to_memcfg <= to_memcfg;
      from_memcfg       <= inst255_from_memcfg;
  
end arch;   


