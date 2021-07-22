-- ----------------------------------------------------------------------------
-- FILE:          lms7_trx_top.vhd
-- DESCRIPTION:   Top level file for LimeSDR-PCIe board
-- DATE:          10:06 AM Friday, May 11, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:     modified by B.J.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
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
use work.FIFO_PACK.all;

library altera; 
use altera.altera_primitives_components.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lms7_trx_top is
   generic(
      -- General parameters
      g_DEV_FAMILY            : string := "Cyclone V";
      -- LMS7002 related 
      g_LMS_DIQ_WIDTH         : integer := 12;
      g_EXT_ADC_D_WIDTH       : integer := 14;
      g_EXT_DAC_D_WIDTH       : integer := 14;
      -- Host related
      g_HOST2FPGA_S0_0_SIZE   : integer := 4096;   -- Stream, Host->FPGA, TX FIFO size in bytes, 
      g_HOST2FPGA_S0_1_SIZE   : integer := 4096;   -- Stream, Host->FPGA, WFM FIFO size in bytes
      g_HOST2FPGA_S1_0_SIZE   : integer := 4096;   -- Stream, Host->FPGA, TX FIFO size in bytes, 
      g_HOST2FPGA_S1_1_SIZE   : integer := 4096;   -- Stream, Host->FPGA, WFM FIFO size in bytes
      g_HOST2FPGA_S2_0_SIZE   : integer := 4096;   -- Stream, Host->FPGA, TX FIFO size in bytes, 
      g_HOST2FPGA_S2_1_SIZE   : integer := 4096;   -- Stream, Host->FPGA, WFM FIFO size in bytes
      g_FPGA2HOST_S0_0_SIZE   : integer := 8192;   -- Stream, FPGA->Host, FIFO size in bytes
      g_FPGA2HOST_S1_0_SIZE   : integer := 8192;   -- Stream, FPGA->Host, FIFO size in bytes
      g_FPGA2HOST_S2_0_SIZE   : integer := 8192;   -- Stream, FPGA->Host, FIFO size in bytes
      g_HOST2FPGA_C0_0_SIZE   : integer := 1024;   -- Control, Host->FPGA, FIFO size in bytes
      g_FPGA2HOST_C0_0_SIZE   : integer := 1024;   -- Control, FPGA->Host, FIFO size in bytes
      -- TX interface 
      g_TX_N_BUFF             : integer := 2;      -- N 4KB buffers in TX interface (2 OR 4)
      g_TX_PCT_SIZE           : integer := 4096;   -- TX packet size in bytes
      g_TX_IN_PCT_HDR_SIZE    : integer := 16;
      g_WFM_INFIFO_SIZE       : integer := 4096;   -- WFM in FIFO buffer size in bytes 
      -- Internal configuration memory 
      g_FPGACFG_START_ADDR    : integer := 0;
      g_PLLCFG_START_ADDR     : integer := 32;
      g_TSTCFG_START_ADDR     : integer := 96;
      g_TXTSPCFG_START_ADDR   : integer := 128;
      g_RXTSPCFG_START_ADDR   : integer := 160;
      g_PERIPHCFG_START_ADDR  : integer := 192;
      g_TAMERCFG_START_ADDR   : integer := 224;
      g_GNSSCFG_START_ADDR    : integer := 256;
      g_MEMCFG_START_ADDR     : integer := 65504;
      -- External periphery
      g_GPIO_N                : integer := 16
   );
   port (
      -- ----------------------------------------------------------------------------
      -- External GND pin for reset
      EXT_GND           : in     std_logic;
      -- ----------------------------------------------------------------------------
      -- Clock sources
         -- Reference clock, coming from LMK clock buffer.
      CLK_LMK_FPGA_IN   : in     std_logic;
         -- On-board oscillators
      CLK100_FPGA       : in     std_logic;
      CLK125_FPGA       : in     std_logic;
      CLK125_FPGA_TOP   : in     std_logic;
      CLK125_FPGA_BOT   : in     std_logic;
         -- Clock generator si5351c
      SI_CLK0           : in     std_logic;
      SI_CLK1           : in     std_logic;
      SI_CLK6           : in     std_logic;
      SI_CLK7           : in     std_logic;
      -- ----------------------------------------------------------------------------
      -- LMS7002 Digital 1
         -- PORT1
      LMS1_MCLK1        : in     std_logic;
      LMS1_FCLK1        : out    std_logic;
      LMS1_TXNRX1       : out    std_logic;
      LMS1_ENABLE_IQSEL1: out    std_logic;
      LMS1_DIQ1_D       : out    std_logic_vector(g_LMS_DIQ_WIDTH-1 downto 0);
         -- PORT2
      LMS1_MCLK2        : in     std_logic;
      LMS1_FCLK2        : out    std_logic;
      LMS1_TXNRX2       : out    std_logic;
      LMS1_ENABLE_IQSEL2: in     std_logic;
      LMS1_DIQ2_D       : in     std_logic_vector(g_LMS_DIQ_WIDTH-1 downto 0);
         --MISC
      LMS1_RESET        : out    std_logic := '1';
      LMS1_TXEN         : out    std_logic;
      LMS1_RXEN         : out    std_logic;
      LMS1_CORE_LDO_EN  : out    std_logic;
      
      -- LMS7002 Digital 2    
      LMS2_MCLK1        : in     std_logic;
      LMS2_FCLK1        : out    std_logic;
      LMS2_TXNRX1       : out    std_logic;
      LMS2_ENABLE_IQSEL1: out    std_logic;
      LMS2_DIQ1_D       : out    std_logic_vector(g_LMS_DIQ_WIDTH-1 downto 0);
         -- PORT2
      LMS2_MCLK2        : in     std_logic;
      LMS2_FCLK2        : out    std_logic;
      LMS2_TXNRX2       : out    std_logic;
      LMS2_ENABLE_IQSEL2: in     std_logic;
      LMS2_DIQ2_D       : in     std_logic_vector(g_LMS_DIQ_WIDTH-1 downto 0);
         --MISC
      LMS2_RESET        : out    std_logic := '1';
      LMS2_TXEN         : out    std_logic;
      LMS2_RXEN         : out    std_logic;
      LMS2_CORE_LDO_EN  : out    std_logic;
      -- ----------------------------------------------------------------------------
      -- PCIe
         -- Clock source
      PCIE_REFCLK       : in     std_logic;
--         -- Control, flags
      PCIE_PERSTn       : in     std_logic;
--         -- DATA
      PCIE_HSO          : in     std_logic_vector(3 downto 0);
      PCIE_HSI_IC       : out    std_logic_vector(3 downto 0);
      -- ----------------------------------------------------------------------------
      -- External memory (DDR3)
         -- DDR3_TOP
      DDR3_TOP_CK_P     : out    std_logic_vector(0 to 0);
      DDR3_TOP_CK_N     : out    std_logic_vector(0 to 0);
      DDR3_TOP_DQ       : inout  std_logic_vector(31 downto 0);
      DDR3_TOP_DQS_P    : inout  std_logic_vector(3 downto 0);
      DDR3_TOP_DQS_N    : inout  std_logic_vector(3 downto 0);
      DDR3_TOP_RASn     : out    std_logic_vector(0 to 0);
      DDR3_TOP_CASn     : out    std_logic_vector(0 to 0);
      DDR3_TOP_WEn      : out    std_logic_vector(0 to 0);
      DDR3_TOP_A        : out    std_logic_vector(13 downto 0);
      DDR3_TOP_BA       : out    std_logic_vector(2 downto 0);
      DDR3_TOP_CKE      : out    std_logic_vector(0 to 0);
      DDR3_TOP_CSn      : out    std_logic_vector(0 to 0);
      DDR3_TOP_DM       : out    std_logic_vector(3 downto 0);
      DDR3_TOP_ODT      : out    std_logic_vector(0 to 0);
      DDR3_TOP_RESETn   : out    std_logic;
--         -- DDR3_BOT
      DDR3_BOT_CK_P     : out    std_logic_vector(0 to 0);
      DDR3_BOT_CK_N     : out    std_logic_vector(0 to 0);
      DDR3_BOT_DQ       : inout  std_logic_vector(31 downto 0);
      DDR3_BOT_DQS_P    : inout  std_logic_vector(3 downto 0);
      DDR3_BOT_DQS_N    : inout  std_logic_vector(3 downto 0);
      DDR3_BOT_RASn     : out    std_logic_vector(0 to 0);
      DDR3_BOT_CASn     : out    std_logic_vector(0 to 0);
      DDR3_BOT_WEn      : out    std_logic_vector(0 to 0);
      DDR3_BOT_A        : out    std_logic_vector(13 downto 0);
      DDR3_BOT_BA       : out    std_logic_vector(2 downto 0);
      DDR3_BOT_CKE      : out    std_logic_vector(0 to 0);
      DDR3_BOT_CSn      : out    std_logic_vector(0 to 0);
      DDR3_BOT_DM       : out    std_logic_vector(3 downto 0);
      DDR3_BOT_ODT      : out    std_logic_vector(0 to 0);
      DDR3_BOT_RESETn   : out    std_logic;

      OCT_RZQIN0        : in     std_logic;
      OCT_RZQIN1        : in     std_logic;
      -- ----------------------------------------------------------------------------
      -- 14-bit ADC
      ADC_CLK           : out    std_logic;
      ADC_CLKOUT        : in     std_logic;
      ADC_DA            : in     std_logic_vector(6 downto 0);
      ADC_DB            : in     std_logic_vector(6 downto 0);
      FPGA_ADC_RESET    : out    std_logic;
      -- ----------------------------------------------------------------------------
      -- Two 14-bit DAC
         --Clock for DAC #1 and DAC #2
      DAC_CLK_WRT       : out    std_logic;
         --DAC #1
      DAC1_SLEEP        : out    std_logic;
      DAC1_MODE         : out    std_logic;
      DAC1_DA           : out    std_logic_vector(13 downto 0);
      DAC1_DB           : out    std_logic_vector(13 downto 0);
         -- DAC #2
      DAC2_SLEEP        : out    std_logic;
      DAC2_MODE         : out    std_logic;
      DAC2_DA           : out    std_logic_vector(13 downto 0);
      DAC2_DB           : out    std_logic_vector(13 downto 0);
      -- ----------------------------------------------------------------------------
      -- External communication interfaces
         -- FPGA_SPI0
      FPGA_SPI0_SCLK       : out    std_logic;
      FPGA_SPI0_MOSI       : out    std_logic;
      FPGA_SPI0_MISO_LMS1  : in     std_logic;
      FPGA_SPI0_MISO_LMS2  : in     std_logic;
      FPGA_SPI0_MISO_ADC   : in     std_logic;
      FPGA_SPI0_LMS1_SS    : out    std_logic;
      FPGA_SPI0_LMS2_SS    : out    std_logic;
      FPGA_SPI0_ADC_SS     : out    std_logic;
      FPGA_SPI0_ADF_SS     : out    std_logic;
      FPGA_SPI0_DAC_SS     : out    std_logic;     
         -- FPGA_SPI1
      FPGA_SPI1_SCLK       : out    std_logic;
      FPGA_SPI1_MOSI       : out    std_logic;
      FPGA_SPI1_MISO       : in     std_logic;
      FPGA_SPI1_FLASH_SS   : out    std_logic;     
         -- FPGA_SPI2
      FPGA_SPI2_SCLK_LS          : out    std_logic;
      FPGA_SPI2_LMS2_RX2_I_MISO  : in     std_logic;
      FPGA_SPI2_LMS2_RX1_I_MISO  : in     std_logic;
      FPGA_SPI2_LMS1_RX1_I_MISO  : in     std_logic;
      FPGA_SPI2_LMS2_RX1_Q_MISO  : in     std_logic;
      FPGA_SPI2_LMS1_RX1_Q_MISO  : in     std_logic;
      FPGA_SPI2_LMS2_RX2_Q_MISO  : in     std_logic;
      FPGA_SPI2_LMS_RX_DET_SS    : out    std_logic;
         -- FPGA AS
      --FPGA_AS_DCLK         : out    std_logic;
      --FPGA_AS_ASDO         : out    std_logic;
      --FPGA_AS_DATA0        : in     std_logic;
      --FPGA_AS_NCSO         : out    std_logic;
         -- FPGA I2C
      I2C_SCL              : inout  std_logic;
      I2C_SDA              : inout  std_logic;
      -- ----------------------------------------------------------------------------
      -- General periphery
         -- Switch
      FPGA_SW           : in     std_logic_vector(3 downto 0);
         -- LEDs          
      FPGA_LED1         : out    std_logic;
      FPGA_LED2         : out    std_logic;
      FPGA_LED3         : out    std_logic;
      FPGA_LED4         : out    std_logic;
      FPGA_LED5_R       : out    std_logic;
      FPGA_LED5_G       : out    std_logic;
         -- PMOD A
      PMOD_A_PIN1       : out  std_logic;
      PMOD_A_PIN2       : out  std_logic;
      PMOD_A_PIN3       : out  std_logic;
      PMOD_A_PIN4       : out  std_logic;
      PMOD_A_PIN7       : out  std_logic;
      PMOD_A_PIN8       : out  std_logic;
      PMOD_A_PIN9       : out  std_logic;
      PMOD_A_PIN10      : out  std_logic;
         -- PMOD B
      PMOD_B_PIN1       : inout  std_logic;
      PMOD_B_PIN2       : inout  std_logic;
      PMOD_B_PIN3       : inout  std_logic;
      PMOD_B_PIN4       : inout  std_logic;
      PMOD_B_PIN7       : inout  std_logic;
      PMOD_B_PIN8       : inout  std_logic;
      PMOD_B_PIN9       : inout  std_logic;
      PMOD_B_PIN10      : inout  std_logic;
         -- ADF lock status
      ADF_MUXOUT        : in     std_logic;
         -- Temperature sensor
      LM75_OS           : in     std_logic;
         -- Fan control 
      FAN_CTRL          : out    std_logic := '1';
         -- RF loop back control (Shift registers)
      SR_SCLK_LS        : out    std_logic;
      SR_LATCH_LS       : out    std_logic;
      SR_DIN_LS         : out    std_logic; 
         --GNSS
      GNSS_TX           : in     std_logic;
      GNSS_RX           : out    std_logic;
      GNSS_FIX          : in     std_logic;
      GNSS_TPULSE       : in     std_logic;
         -- Bill Of material and hardware version 
      BOM_VER           : in     std_logic_vector(3 downto 0);
      HW_VER            : in     std_logic_vector(3 downto 0);

      -- added	
		-- these signals control the RF switch
	   -- selecting the DPD monitoring input
      -- one of two inputs is connected to Rx_W, Ch.A		
		RF_SW_V1, RF_SW_V2, RF_SW_V3: out std_logic

   );
end lms7_trx_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms7_trx_top is
--declare signals,  components here

constant c_S0_DATA_WIDTH         : integer := 32;     -- Stream data width
constant c_S1_DATA_WIDTH         : integer := 32;     -- Stream data width
constant c_S2_DATA_WIDTH         : integer := 32;     -- Stream data width
constant c_C0_DATA_WIDTH         : integer := 32;     -- Control data width
constant c_H2F_S0_0_RWIDTH       : integer := 128;    -- Host->FPGA stream, FIFO rd width, FIFO number - 0
constant c_H2F_S1_0_RWIDTH       : integer := 128;    -- Host->FPGA stream, FIFO rd width, FIFO number - 0
constant c_H2F_S2_0_RWIDTH       : integer := 128;    -- Host->FPGA stream, FIFO rd width, FIFO number - 0
constant c_H2F_S0_1_RWIDTH       : integer := 64;     -- Host->FPGA stream, FIFO rd width, FIFO number - 1
constant c_H2F_S1_1_RWIDTH       : integer := 64;     -- Host->FPGA stream, FIFO rd width, FIFO number - 1 
constant c_H2F_S2_1_RWIDTH       : integer := 64;     -- Host->FPGA stream, FIFO rd width, FIFO number - 1  
constant c_F2H_S0_WWIDTH         : integer := 64;     -- FPGA->Host stream, FIFO wr width
constant c_F2H_S1_WWIDTH         : integer := 64;     -- FPGA->Host stream, FIFO wr width
constant c_F2H_S2_WWIDTH         : integer := 64;     -- FPGA->Host stream, FIFO wr width
constant c_H2F_C0_RWIDTH         : integer := 32;     -- Host->FPGA control, rd width
constant c_F2H_C0_WWIDTH         : integer := 32;     -- FPGA->Host control, wr width 

signal reset_n                   : std_logic;
signal reset_n_lmk_clk           : std_logic;
signal reset_n_clk100_fpga       : std_logic;
signal reset_n_si_clk0           : std_logic;

--inst0 (NIOS CPU instance)
signal inst0_exfifo_if_rd        : std_logic;
signal inst0_exfifo_of_d         : std_logic_vector(c_C0_DATA_WIDTH-1 downto 0);
signal inst0_exfifo_of_wr        : std_logic;
signal inst0_exfifo_of_rst       : std_logic;
signal inst0_gpo                 : std_logic_vector(7 downto 0);
signal inst0_lms_ctr_gpio        : std_logic_vector(3 downto 0);
signal inst0_spi_0_MISO          : std_logic;
signal inst0_spi_0_MOSI          : std_logic;
signal inst0_spi_0_SCLK          : std_logic;
signal inst0_spi_0_SS_n          : std_logic_vector(8 downto 0);
signal inst0_spi_1_MOSI          : std_logic;
signal inst0_spi_1_SCLK          : std_logic;
signal inst0_spi_1_SS_n          : std_logic;
signal inst0_spi_2_MISO          : std_logic;
signal inst0_spi_2_MOSI          : std_logic;
signal inst0_spi_2_SCLK          : std_logic;
signal inst0_spi_2_SS_n          : std_logic;
signal inst0_pll_stat            : std_logic_vector(9 downto 0);
signal inst0_pll_rst             : std_logic_vector(31 downto 0);
signal inst0_pll_rcfg_to_pll_0   : std_logic_vector(63 downto 0);
signal inst0_pll_rcfg_to_pll_1   : std_logic_vector(63 downto 0);
signal inst0_pll_rcfg_to_pll_2   : std_logic_vector(63 downto 0);
signal inst0_pll_rcfg_to_pll_3   : std_logic_vector(63 downto 0);
signal inst0_pll_rcfg_to_pll_4   : std_logic_vector(63 downto 0);
signal inst0_pll_rcfg_to_pll_5   : std_logic_vector(63 downto 0);
signal inst0_avmm_s0_readdata    : std_logic_vector(31 downto 0);
signal inst0_avmm_s0_waitrequest : std_logic;
signal inst0_avmm_s1_readdata    : std_logic_vector(31 downto 0);
signal inst0_avmm_s1_waitrequest : std_logic;
signal inst0_avmm_m0_address     : std_logic_vector(7 downto 0);
signal inst0_avmm_m0_read        : std_logic;
signal inst0_avmm_m0_write       : std_logic;
signal inst0_avmm_m0_writedata   : std_logic_vector(7 downto 0);
signal inst0_avmm_m0_clk_clk     : std_logic;
signal inst0_avmm_m0_reset_reset : std_logic;
signal inst0_from_fpgacfg_0      : t_FROM_FPGACFG;
signal inst0_from_fpgacfg_mod_0  : t_FROM_FPGACFG;
signal inst0_to_fpgacfg_0        : t_TO_FPGACFG;
signal inst0_from_fpgacfg_1      : t_FROM_FPGACFG;
signal inst0_from_fpgacfg_mod_1  : t_FROM_FPGACFG;
signal inst0_to_fpgacfg_1        : t_TO_FPGACFG;
signal inst0_from_fpgacfg_2      : t_FROM_FPGACFG;
signal inst0_from_fpgacfg_mod_2  : t_FROM_FPGACFG;
signal inst0_to_fpgacfg_2        : t_TO_FPGACFG;
signal inst0_from_pllcfg         : t_FROM_PLLCFG;
signal inst0_to_pllcfg           : t_TO_PLLCFG;
signal inst0_from_tstcfg         : t_FROM_TSTCFG;
signal inst0_to_tstcfg           : t_TO_TSTCFG;
signal inst0_from_txtspcfg_0     : t_FROM_TXTSPCFG;
signal inst0_to_txtspcfg_0       : t_TO_TXTSPCFG;
signal inst0_from_txtspcfg_1     : t_FROM_TXTSPCFG;
signal inst0_to_txtspcfg_1       : t_TO_TXTSPCFG;
signal inst0_from_rxtspcfg       : t_FROM_RXTSPCFG;
signal inst0_to_rxtspcfg         : t_TO_RXTSPCFG;
signal inst0_from_periphcfg      : t_FROM_PERIPHCFG;
signal inst0_to_periphcfg        : t_TO_PERIPHCFG;
signal inst0_from_tamercfg       : t_FROM_TAMERCFG;
signal inst0_to_tamercfg         : t_TO_TAMERCFG;
signal inst0_from_gnsscfg        : t_FROM_GNSSCFG;
signal inst0_to_gnsscfg          : t_TO_GNSSCFG;
signal inst0_to_memcfg           : t_TO_MEMCFG;
signal inst0_from_memcfg         : t_FROM_MEMCFG;




--inst1 (pll_top instance)
signal inst1_lms1_txpll_c1             : std_logic;
signal inst1_lms1_txpll_c2             : std_logic;
signal inst1_lms1_txpll_locked         : std_logic;
signal inst1_lms1_txpll_rcnfg_from_pll : std_logic_vector(63 downto 0);
signal inst1_lms1_rxpll_c1             : std_logic;
signal inst1_lms1_rxpll_locked         : std_logic;
signal inst1_lms1_rxpll_rcnfg_from_pll : std_logic_vector(63 downto 0);
signal inst1_lms1_smpl_cmp_en          : std_logic;
signal inst1_lms1_smpl_cmp_cnt         : std_logic_vector(15 downto 0);

signal inst1_lms2_txpll_c1             : std_logic;
signal inst1_lms2_txpll_c2             : std_logic;
signal inst1_lms2_txpll_locked         : std_logic;
signal inst1_lms2_txpll_rcnfg_from_pll : std_logic_vector(63 downto 0);
signal inst1_lms2_rxpll_c1             : std_logic;
signal inst1_lms2_rxpll_locked         : std_logic;
signal inst1_lms2_rxpll_rcnfg_from_pll : std_logic_vector(63 downto 0);
signal inst1_lms2_smpl_cmp_en          : std_logic;
signal inst1_lms2_smpl_cmp_cnt         : std_logic_vector(15 downto 0);

signal inst1_pll_0_c0                  : std_logic;
signal inst1_pll_0_c1                  : std_logic;
signal inst1_pll_0_locked              : std_logic;
signal inst1_pll_0_rcnfg_from_pll      : std_logic_vector(63 downto 0);

signal inst1_rcnfg_0_mgmt_read         : std_logic;
signal inst1_rcnfg_0_mgmt_write        : std_logic;
signal inst1_rcnfg_0_mgmt_address      : std_logic_vector(8 downto 0);
signal inst1_rcnfg_0_mgmt_writedata    : std_logic_vector(31 downto 0);

signal inst1_rcnfg_1_mgmt_read         : std_logic;
signal inst1_rcnfg_1_mgmt_write        : std_logic;
signal inst1_rcnfg_1_mgmt_address      : std_logic_vector(8 downto 0);
signal inst1_rcnfg_1_mgmt_writedata    : std_logic_vector(31 downto 0);


--inst2
constant c_H2F_S0_0_RDUSEDW_WIDTH: integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_S0_0_SIZE/(c_H2F_S0_0_RWIDTH/8),true);
constant c_H2F_S0_1_RDUSEDW_WIDTH: integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_S0_1_SIZE/(c_H2F_S0_1_RWIDTH/8),true);
constant c_H2F_S1_0_RDUSEDW_WIDTH: integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_S1_0_SIZE/(c_H2F_S1_0_RWIDTH/8),true);
constant c_H2F_S1_1_RDUSEDW_WIDTH: integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_S1_1_SIZE/(c_H2F_S1_1_RWIDTH/8),true);
constant c_H2F_S2_0_RDUSEDW_WIDTH: integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_S2_0_SIZE/(c_H2F_S2_0_RWIDTH/8),true);
constant c_H2F_S2_1_RDUSEDW_WIDTH: integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_S2_1_SIZE/(c_H2F_S2_1_RWIDTH/8),true);
constant c_F2H_S0_WRUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(g_FPGA2HOST_S0_0_SIZE/(c_F2H_S0_WWIDTH/8),true);
constant c_F2H_S1_WRUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(g_FPGA2HOST_S1_0_SIZE/(c_F2H_S1_WWIDTH/8),true);
constant c_F2H_S2_WRUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(g_FPGA2HOST_S2_0_SIZE/(c_F2H_S2_WWIDTH/8),true);
constant c_H2F_C0_RDUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_C0_0_SIZE/(c_H2F_C0_RWIDTH/8),true);
constant c_F2H_C0_WRUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(g_FPGA2HOST_C0_0_SIZE/(c_F2H_C0_WWIDTH/8),true);
signal inst2_F2H_S0_wfull        : std_logic;
signal inst2_F2H_S0_wrusedw      : std_logic_vector(c_F2H_S0_WRUSEDW_WIDTH-1 downto 0);
signal inst2_F2H_S1_wfull        : std_logic;
signal inst2_F2H_S1_wrusedw      : std_logic_vector(c_F2H_S1_WRUSEDW_WIDTH-1 downto 0);
signal inst2_F2H_S2_wfull        : std_logic;
signal inst2_F2H_S2_wrusedw      : std_logic_vector(c_F2H_S2_WRUSEDW_WIDTH-1 downto 0);
signal inst2_H2F_C0_rdata        : std_logic_vector(c_H2F_C0_RWIDTH-1 downto 0);
signal inst2_H2F_C0_rempty       : std_logic;
signal inst2_F2H_C0_wfull        : std_logic;
signal inst2_H2F_S0_0_rdata      : std_logic_vector(c_H2F_S0_0_RWIDTH-1 downto 0);
signal inst2_H2F_S0_0_rempty     : std_logic;
signal inst2_H2F_S0_0_rdusedw    : std_logic_vector(c_H2F_S0_0_RDUSEDW_WIDTH-1 downto 0);
signal inst2_H2F_S0_1_rdata      : std_logic_vector(c_H2F_S0_1_RWIDTH-1 downto 0);
signal inst2_H2F_S0_1_rempty     : std_logic;
signal inst2_H2F_S0_1_rdusedw    : std_logic_vector(c_H2F_S0_1_RDUSEDW_WIDTH-1 downto 0);
signal inst2_H2F_S1_0_rdata      : std_logic_vector(c_H2F_S1_0_RWIDTH-1 downto 0);
signal inst2_H2F_S1_0_rempty     : std_logic;
signal inst2_H2F_S1_0_rdusedw    : std_logic_vector(c_H2F_S1_0_RDUSEDW_WIDTH-1 downto 0);
signal inst2_H2F_S1_1_rdata      : std_logic_vector(c_H2F_S1_1_RWIDTH-1 downto 0);
signal inst2_H2F_S1_1_rempty     : std_logic;
signal inst2_H2F_S1_1_rdusedw    : std_logic_vector(c_H2F_S1_1_RDUSEDW_WIDTH-1 downto 0);
signal inst2_H2F_S2_0_rdata      : std_logic_vector(c_H2F_S2_0_RWIDTH-1 downto 0);
signal inst2_H2F_S2_0_rempty     : std_logic;
signal inst2_H2F_S2_0_rdusedw    : std_logic_vector(c_H2F_S2_0_RDUSEDW_WIDTH-1 downto 0);
signal inst2_H2F_S2_1_rdata      : std_logic_vector(c_H2F_S2_1_RWIDTH-1 downto 0);
signal inst2_H2F_S2_1_rempty     : std_logic;
signal inst2_H2F_S2_1_rdusedw    : std_logic_vector(c_H2F_S2_1_RDUSEDW_WIDTH-1 downto 0);
signal inst2_F2H_S0_open         : std_logic;
signal inst2_F2H_S1_open         : std_logic;
signal inst2_F2H_S2_open         : std_logic;
signal inst2_H2F_S0_open         : std_logic;
signal inst2_H2F_S1_open         : std_logic;
signal inst2_H2F_S2_open         : std_logic;

--inst5
signal inst5_busy : std_logic;

--inst6
signal inst6_rx_data_valid          : std_logic;
signal inst6_rx_data                : std_logic_vector(g_LMS_DIQ_WIDTH*4-1 downto 0);
signal inst6_tx_fifo_0_wrfull       : std_logic;
signal inst6_tx_fifo_0_wrusedw      : std_logic_vector(8 downto 0);
signal inst6_tx_fifo_1_wrfull       : std_logic;
signal inst6_tx_fifo_1_wrusedw      : std_logic_vector(8 downto 0); 
signal inst6_rx_smpl_cmp_done       : std_logic;
signal inst6_rx_smpl_cmp_err        : std_logic; 
signal inst6_sdout                  : std_logic;
signal inst6_tx_ant_en              : std_logic; 

--inst7
constant c_WFM_INFIFO_SIZE          : integer := FIFO_WORDS_TO_Nbits(g_WFM_INFIFO_SIZE/(c_S0_DATA_WIDTH/8),true);
signal inst7_tx_pct_loss_flg        : std_logic;
signal inst7_tx_txant_en            : std_logic;
signal inst7_tx_in_pct_full         : std_logic;
signal inst7_rx_pct_fifo_wrreq      : std_logic;
signal inst7_rx_pct_fifo_wdata      : std_logic_vector(63 downto 0);
signal inst7_to_tstcfg_from_rxtx    : t_TO_TSTCFG_FROM_RXTX;
signal inst7_rx_pct_fifo_aclrn_req  : std_logic;
signal inst7_tx_in_pct_rdreq        : std_logic;
signal inst7_tx_in_pct_reset_n_req  : std_logic;
signal inst7_wfm_in_pct_reset_n_req : std_logic;
signal inst7_wfm_in_pct_rdreq       : std_logic;
signal inst7_wfm_phy_clk            : std_logic;
signal inst7_tx_smpl_fifo_wrreq     : std_logic;
signal inst7_tx_smpl_fifo_data      : std_logic_vector(127 downto 0);

--inst8
signal inst8_rx_data_valid          : std_logic;
signal inst8_rx_data                : std_logic_vector(g_LMS_DIQ_WIDTH*4-1 downto 0);
signal inst8_tx_fifo_0_wrfull       : std_logic;
signal inst8_tx_fifo_0_wrusedw      : std_logic_vector(8 downto 0);
signal inst8_tx_fifo_1_wrfull       : std_logic;
signal inst8_tx_fifo_1_wrusedw      : std_logic_vector(8 downto 0); 
signal inst8_rx_smpl_cmp_done       : std_logic;
signal inst8_rx_smpl_cmp_err        : std_logic;
signal inst8_sdout                  : std_logic; 
signal inst8_tx_ant_en              : std_logic; 

--inst9
signal inst9_tx_pct_loss_flg        : std_logic;
signal inst9_tx_txant_en            : std_logic;
signal inst9_tx_in_pct_full         : std_logic;
signal inst9_rx_pct_fifo_wrreq      : std_logic;
signal inst9_rx_pct_fifo_wdata      : std_logic_vector(63 downto 0);
signal inst9_to_tstcfg_from_rxtx    : t_TO_TSTCFG_FROM_RXTX;
signal inst9_rx_pct_fifo_aclrn_req  : std_logic;
signal inst9_tx_in_pct_rdreq        : std_logic;
signal inst9_tx_in_pct_reset_n_req  : std_logic;
signal inst9_wfm_in_pct_reset_n_req : std_logic;
signal inst9_wfm_in_pct_rdreq       : std_logic;
signal inst9_wfm_phy_clk            : std_logic;
signal inst9_tx_smpl_fifo_wrreq     : std_logic;
signal inst9_tx_smpl_fifo_data      : std_logic_vector(127 downto 0);

--inst10
signal inst10_rx_data_valid         : std_logic;
signal inst10_rx_data               : std_logic_vector(14*4-1 downto 0);
signal inst10_tx_wrfull             : std_logic;
signal inst10_tx_wrusedw            : std_logic_vector(8 downto 0); 
signal inst10_data_ch_a             : std_logic_vector(g_EXT_ADC_D_WIDTH-1 downto 0);
signal inst10_data_ch_b             : std_logic_vector(g_EXT_ADC_D_WIDTH-1 downto 0);      

--inst11
signal inst11_tx_pct_loss_flg        : std_logic;
signal inst11_tx_txant_en            : std_logic;
signal inst11_tx_in_pct_full         : std_logic;
signal inst11_rx_pct_fifo_wrreq      : std_logic;
signal inst11_rx_pct_fifo_wdata      : std_logic_vector(63 downto 0);
signal inst11_rx_smpl_cmp_done       : std_logic;
signal inst11_rx_smpl_cmp_err        : std_logic;
signal inst11_to_tstcfg_from_rxtx    : t_TO_TSTCFG_FROM_RXTX;
signal inst11_rx_pct_fifo_aclrn_req  : std_logic;
signal inst11_tx_in_pct_rdreq        : std_logic;
signal inst11_tx_in_pct_reset_n_req  : std_logic;
signal inst11_wfm_in_pct_reset_n_req : std_logic;
signal inst11_wfm_in_pct_rdreq       : std_logic;
signal inst11_wfm_phy_clk            : std_logic;
signal inst11_tx_smpl_fifo_wrreq     : std_logic;
signal inst11_tx_smpl_fifo_data      : std_logic_vector(127 downto 0);

--inst12 
signal inst12_tx0_wrfull               : std_logic;
signal inst12_tx0_wrusedw              : std_logic_vector(8 downto 0);
signal inst12_tx1_wrfull               : std_logic;
signal inst12_tx1_wrreq                : std_logic;
signal inst12_tx1_data                 : std_logic_vector(27 downto 0);
signal inst12_tx_src_sel               : std_logic_vector(1 downto 0);

--inst19
signal inst19_phy_clk                  : std_logic;
signal inst19_wfm_0_infifo_rdreq       : std_logic;
signal inst19_wfm_1_infifo_rdreq       : std_logic;
signal inst19_wfm_0_Aiq_h              : std_logic_vector(12 downto 0);
signal inst19_wfm_0_Aiq_l              : std_logic_vector(12 downto 0);
signal inst19_wfm_0_outfifo_reset_n    : std_logic;
signal inst19_wfm_0_outfifo_wrreq      : std_logic;
signal inst19_wfm_0_outfifo_data       : std_logic_vector(127 downto 0);

--inst20
signal inst20_phy_clk                  : std_logic;
signal inst20_wfm_0_infifo_rdreq       : std_logic;
signal inst20_wfm_1_infifo_rdreq       : std_logic;
signal inst20_wfm_0_Aiq_h              : std_logic_vector(12 downto 0);
signal inst20_wfm_0_Aiq_l              : std_logic_vector(12 downto 0);
signal inst20_wfm_0_outfifo_reset_n    : std_logic;
signal inst20_wfm_0_outfifo_wrreq      : std_logic;
signal inst20_wfm_0_outfifo_data       : std_logic_vector(127 downto 0);

signal inst21_10ms_toggle             : std_logic;

-- added by B.J.
-- for transfer of DPD data streams through PCIe, needed for DPD training process
signal strm2_OUT_EXT_rdreq, strm2_OUT_EXT_rdempty: std_logic;
signal strm2_OUT_EXT_q : std_logic_vector(31 downto 0);
signal pcie_bus_clk: std_Logic;


-- added by B.J.
-- controls (turns on and off) the DC/DC converters and PAs in LimeNET box
-- explained below
signal PAEN0, PAEN1, DCEN0, DCEN1 : std_logic;

-- these are controlling the RF switch
-- one of two inputs is fed to Rx_W Ch.A, through RF switch 
signal rf_sw: std_logic_vector(2 downto 0);



begin

-- added by B.J. 	
-- controls (turns on and off) the DC/DC converters and PAs in LimeNET box
-- for both transmitting channels - Ch. A and Ch. B.

-- special PCBs are created for logic level translation
-- one PCB is mounted on each DC/DC converter in Lime NET box, 
-- the PCBs are driven by signals listed below, comming from PMOD B connector
-- each PCB generates direct enable signals for one DC/DCs and one PA
	
	 PMOD_B_PIN1<=PAEN0; -- for PA Ch.A
	 PMOD_B_PIN2<=DCEN0; -- for DCDC Ch.A
	 PMOD_B_PIN3<='0';	 
	 PMOD_B_PIN4<='0';
	 
	 PMOD_B_PIN7<=PAEN1; -- for PA Ch.B
	 PMOD_B_PIN8<=DCEN1; -- for DCDC Ch.B
	 PMOD_B_PIN9 <='0';	 
	 PMOD_B_PIN10 <='0';
   
-- ----------------------------------------------------------------------------
-- Reset logic
-- ----------------------------------------------------------------------------  
   -- Reset from FPGA pin. 
   reset_n <= not EXT_GND;
   
   -- Reset signal with synchronous removal to CLK100_FPGA clock domain, 
   sync_reg0 : entity work.sync_reg 
   port map(CLK100_FPGA, reset_n, '1', reset_n_clk100_fpga);
   
   -- Reset signal with synchronous removal to SI_CLK0 clock domain, 
   sync_reg1 : entity work.sync_reg 
   port map(SI_CLK0, reset_n, '1', reset_n_si_clk0);
   
   -- Reset signal with synchronous removal to LMK_CLK clock domain, 
   sync_reg3 : entity work.sync_reg 
   port map(CLK_LMK_FPGA_IN, reset_n, '1', reset_n_lmk_clk); 
   
     
-- ----------------------------------------------------------------------------
-- NIOS CPU instance.
-- CPU is responsible for communication interfaces and control logic
-- ----------------------------------------------------------------------------   
   inst0_nios_cpu : entity work.nios_cpu_top
   generic map (
      FPGACFG_START_ADDR   => g_FPGACFG_START_ADDR,
      PLLCFG_START_ADDR    => g_PLLCFG_START_ADDR,
      TSTCFG_START_ADDR    => g_TSTCFG_START_ADDR,
      TXTSPCFG_START_ADDR  => g_TXTSPCFG_START_ADDR,
      RXTSPCFG_START_ADDR  => g_RXTSPCFG_START_ADDR,
      PERIPHCFG_START_ADDR => g_PERIPHCFG_START_ADDR,
      TAMERCFG_START_ADDR  => g_TAMERCFG_START_ADDR,
      GNSSCFG_START_ADDR   => g_GNSSCFG_START_ADDR,
      MEMCFG_START_ADDR    => g_MEMCFG_START_ADDR
   )
   port map(
      clk                        => CLK_LMK_FPGA_IN,
      reset_n                    => reset_n_lmk_clk,
      -- Control data FIFO
      exfifo_if_d                => inst2_H2F_C0_rdata,
      exfifo_if_rd               => inst0_exfifo_if_rd, 
      exfifo_if_rdempty          => inst2_H2F_C0_rempty,
      exfifo_of_d                => inst0_exfifo_of_d, 
      exfifo_of_wr               => inst0_exfifo_of_wr, 
      exfifo_of_wrfull           => inst2_F2H_C0_wfull,
      exfifo_of_rst              => inst0_exfifo_of_rst, 
      -- SPI 0 
      spi_0_MISO                 => inst0_spi_0_MISO OR inst6_sdout,
      spi_0_MOSI                 => inst0_spi_0_MOSI,
      spi_0_SCLK                 => inst0_spi_0_SCLK,
      spi_0_SS_n                 => inst0_spi_0_SS_n,
      -- SPI 1
      spi_1_MISO                 => '0',
      spi_1_MOSI                 => inst0_spi_1_MOSI,
      spi_1_SCLK                 => inst0_spi_1_SCLK,
      spi_1_SS_n                 => inst0_spi_1_SS_n,
      -- SPI 1
      spi_2_MISO                 => '0',
      spi_2_MOSI                 => inst0_spi_2_MOSI,
      spi_2_SCLK                 => inst0_spi_2_SCLK,
      spi_2_SS_n                 => inst0_spi_2_SS_n,
      -- I2C
      i2c_scl                    => I2C_SCL,
      i2c_sda                    => I2C_SDA,
      -- Genral purpose I/O
      gpi                        => "0000" & FPGA_SW,
      gpo                        => inst0_gpo, 
      -- LMS7002 control 
      lms_ctr_gpio               => inst0_lms_ctr_gpio,
      -- VCTCXO tamer control
      vctcxo_tune_en             => '0',
      vctcxo_irq                 => '0',
      -- PLL reconfiguration
      pll_rst                    => inst0_pll_rst,
      pll_rcfg_from_pll_0        => inst1_lms1_txpll_rcnfg_from_pll,
      pll_rcfg_to_pll_0          => inst0_pll_rcfg_to_pll_0,
      pll_rcfg_from_pll_1        => inst1_lms1_rxpll_rcnfg_from_pll,
      pll_rcfg_to_pll_1          => inst0_pll_rcfg_to_pll_1,
      pll_rcfg_from_pll_2        => inst1_lms2_txpll_rcnfg_from_pll,
      pll_rcfg_to_pll_2          => inst0_pll_rcfg_to_pll_2,
      pll_rcfg_from_pll_3        => inst1_lms2_rxpll_rcnfg_from_pll,
      pll_rcfg_to_pll_3          => inst0_pll_rcfg_to_pll_3,
      pll_rcfg_from_pll_4        => inst1_pll_0_rcnfg_from_pll,
      pll_rcfg_to_pll_4          => inst0_pll_rcfg_to_pll_4,
      pll_rcfg_from_pll_5        => (others=>'0'),
      pll_rcfg_to_pll_5          => inst0_pll_rcfg_to_pll_5,
      -- Avalon Slave port 0
      avmm_s0_address            => inst1_rcnfg_0_mgmt_address,
      avmm_s0_read               => inst1_rcnfg_0_mgmt_read,
      avmm_s0_readdata           => inst0_avmm_s0_readdata, 
      avmm_s0_write              => inst1_rcnfg_0_mgmt_write,
      avmm_s0_writedata          => inst1_rcnfg_0_mgmt_writedata, 
      avmm_s0_waitrequest        => inst0_avmm_s0_waitrequest,
      -- Avalon Slave port 1
      avmm_s1_address            => inst1_rcnfg_1_mgmt_address,
      avmm_s1_read               => inst1_rcnfg_1_mgmt_read,
      avmm_s1_readdata           => inst0_avmm_s1_readdata,
      avmm_s1_write              => inst1_rcnfg_1_mgmt_write,
      avmm_s1_writedata          => inst1_rcnfg_1_mgmt_writedata, 
      avmm_s1_waitrequest        => inst0_avmm_s1_waitrequest,
      -- Avalon master
      avmm_m0_address            => inst0_avmm_m0_address,
      avmm_m0_read               => inst0_avmm_m0_read,
      avmm_m0_waitrequest        => '0',
      avmm_m0_readdata           => (others=>'0'),
      avmm_m0_readdatavalid      => '0',
      avmm_m0_write              => inst0_avmm_m0_write,
      avmm_m0_writedata          => inst0_avmm_m0_writedata,
      avmm_m0_clk_clk            => inst0_avmm_m0_clk_clk,
      avmm_m0_reset_reset        => inst0_avmm_m0_reset_reset,
      -- Configuration registers
      from_fpgacfg_0             => inst0_from_fpgacfg_0,
      to_fpgacfg_0               => inst0_to_fpgacfg_0,
      from_fpgacfg_1             => inst0_from_fpgacfg_1,
      to_fpgacfg_1               => inst0_to_fpgacfg_1,
      from_fpgacfg_2             => inst0_from_fpgacfg_2,
      to_fpgacfg_2               => inst0_to_fpgacfg_2,
      from_pllcfg                => inst0_from_pllcfg,
      to_pllcfg                  => inst0_to_pllcfg,
      from_tstcfg                => inst0_from_tstcfg,
      to_tstcfg                  => inst0_to_tstcfg,
      to_tstcfg_from_rxtx        => inst7_to_tstcfg_from_rxtx,
      from_txtspcfg_0            => inst0_from_txtspcfg_0,
      to_txtspcfg_0              => inst0_to_txtspcfg_0, 
      from_txtspcfg_1            => inst0_from_txtspcfg_1,
      to_txtspcfg_1              => inst0_to_txtspcfg_1, 
      from_rxtspcfg              => inst0_from_rxtspcfg,
      to_rxtspcfg                => inst0_to_rxtspcfg,      
      from_periphcfg             => inst0_from_periphcfg,
      to_periphcfg               => inst0_to_periphcfg,
      from_tamercfg              => inst0_from_tamercfg,
      to_tamercfg                => inst0_to_tamercfg,
      from_gnsscfg               => inst0_from_gnsscfg,
      to_gnsscfg                 => inst0_to_gnsscfg,
      to_memcfg                  => inst0_to_memcfg,
      from_memcfg                => inst0_from_memcfg
      
      
   );
   
   inst0_to_fpgacfg_0.HW_VER    <= HW_VER;
   inst0_to_fpgacfg_0.BOM_VER   <= BOM_VER; 
   inst0_to_fpgacfg_0.PWR_SRC   <= '0';
                        
   inst0_spi_0_MISO <=  FPGA_SPI0_MISO_ADC when inst0_spi_0_SS_n(5) = '0' else 
                        (FPGA_SPI0_MISO_LMS1 OR FPGA_SPI0_MISO_LMS2);
   
-- ----------------------------------------------------------------------------
-- pll_top instance.
-- Clock source for LMS#1, LMS#2 RX and TX logic
-- ----------------------------------------------------------------------------   
   inst1_pll_top : entity work.pll_top
   generic map(
      INTENDED_DEVICE_FAMILY  => g_DEV_FAMILY,
      N_PLL                   => 5,
      -- TX pll parameters
      LMS1_TXPLL_DRCT_C0_NDLY => 1,
      LMS1_TXPLL_DRCT_C1_NDLY => 3,
      -- RX pll parameters
      LMS1_RXPLL_DRCT_C0_NDLY => 1,
      LMS1_RXPLL_DRCT_C1_NDLY => 2,
      -- TX pll parameters
      LMS2_TXPLL_DRCT_C0_NDLY => 1,
      LMS2_TXPLL_DRCT_C1_NDLY => 3,
      -- RX pll parameters
      LMS2_RXPLL_DRCT_C0_NDLY => 1,
      LMS2_RXPLL_DRCT_C1_NDLY => 2
   )
   port map(
      -- LMS#1 TX PLL 0 ports
      lms1_txpll_inclk           => LMS1_MCLK1,
      lms1_txpll_reconfig_clk    => CLK_LMK_FPGA_IN,
      lms1_txpll_rcnfg_to_pll    => inst0_pll_rcfg_to_pll_0,
      lms1_txpll_rcnfg_from_pll  => inst1_lms1_txpll_rcnfg_from_pll,
      lms1_txpll_logic_reset_n   => not inst0_pll_rst(0),
      lms1_txpll_clk_ena         => inst0_from_fpgacfg_0.CLK_ENA(1 downto 0),
      lms1_txpll_drct_clk_en     => inst0_from_fpgacfg_0.drct_clk_en(0) & inst0_from_fpgacfg_0.drct_clk_en(0),
      lms1_txpll_c0              => LMS1_FCLK1,
      lms1_txpll_c1              => inst1_lms1_txpll_c1,
      lms1_txpll_c2              => inst1_lms1_txpll_c2,
      lms1_txpll_locked          => inst1_lms1_txpll_locked,
      -- LMS#1 RX PLL ports
      lms1_rxpll_inclk           => LMS1_MCLK2,
      lms1_rxpll_reconfig_clk    => CLK_LMK_FPGA_IN,
      lms1_rxpll_rcnfg_to_pll    => inst0_pll_rcfg_to_pll_1,
      lms1_rxpll_rcnfg_from_pll  => inst1_lms1_rxpll_rcnfg_from_pll,
      lms1_rxpll_logic_reset_n   => not inst0_pll_rst(1),
      lms1_rxpll_clk_ena         => inst0_from_fpgacfg_0.CLK_ENA(3 downto 2),
      lms1_rxpll_drct_clk_en     => inst0_from_fpgacfg_0.drct_clk_en(1) & inst0_from_fpgacfg_0.drct_clk_en(1),
      lms1_rxpll_c0              => LMS1_FCLK2,
      lms1_rxpll_c1              => inst1_lms1_rxpll_c1,
      lms1_rxpll_locked          => inst1_lms1_rxpll_locked,
      -- Sample comparing ports from LMS#1 RX interface
      lms1_smpl_cmp_en           => inst1_lms1_smpl_cmp_en,      
      lms1_smpl_cmp_done         => inst6_rx_smpl_cmp_done,
      lms1_smpl_cmp_error        => inst6_rx_smpl_cmp_err,
      lms1_smpl_cmp_cnt          => inst1_lms1_smpl_cmp_cnt, 
      
      -- LMS#2 TX PLL 0 ports
      lms2_txpll_inclk           => LMS2_MCLK1,
      lms2_txpll_reconfig_clk    => CLK_LMK_FPGA_IN,
      lms2_txpll_rcnfg_to_pll    => inst0_pll_rcfg_to_pll_2,
      lms2_txpll_rcnfg_from_pll  => inst1_lms2_txpll_rcnfg_from_pll,
      lms2_txpll_logic_reset_n   => not inst0_pll_rst(2),
      lms2_txpll_clk_ena         => inst0_from_fpgacfg_0.CLK_ENA(5 downto 4),
      lms2_txpll_drct_clk_en     => inst0_from_fpgacfg_0.drct_clk_en(2) & inst0_from_fpgacfg_0.drct_clk_en(2),
      lms2_txpll_c0              => LMS2_FCLK1,
      lms2_txpll_c1              => inst1_lms2_txpll_c1,
      lms2_txpll_c2              => inst1_lms2_txpll_c2,
      lms2_txpll_locked          => inst1_lms2_txpll_locked,
      -- LMS#2 RX PLL  0 ports
      lms2_rxpll_inclk           => LMS2_MCLK2,
      lms2_rxpll_reconfig_clk    => CLK_LMK_FPGA_IN,
      lms2_rxpll_rcnfg_to_pll    => inst0_pll_rcfg_to_pll_3,
      lms2_rxpll_rcnfg_from_pll  => inst1_lms2_rxpll_rcnfg_from_pll,
      lms2_rxpll_logic_reset_n   => not inst0_pll_rst(3),
      lms2_rxpll_clk_ena         => inst0_from_fpgacfg_0.CLK_ENA(7 downto 6),
      lms2_rxpll_drct_clk_en     => inst0_from_fpgacfg_0.drct_clk_en(3) & inst0_from_fpgacfg_0.drct_clk_en(3),
      lms2_rxpll_c0              => LMS2_FCLK2,
      lms2_rxpll_c1              => inst1_lms2_rxpll_c1,
      lms2_rxpll_locked          => inst1_lms2_rxpll_locked,
      -- Sample comparing ports from LMS#2 RX interface 
      lms2_smpl_cmp_en           => inst1_lms2_smpl_cmp_en,      
      lms2_smpl_cmp_done         => inst8_rx_smpl_cmp_done,
      lms2_smpl_cmp_error        => inst8_rx_smpl_cmp_err,
      lms2_smpl_cmp_cnt          => inst1_lms2_smpl_cmp_cnt,
      -- PLL for DAC, ADC
      pll_0_inclk                => CLK_LMK_FPGA_IN,
      pll_0_rcnfg_to_pll         => inst0_pll_rcfg_to_pll_4,
      pll_0_rcnfg_from_pll       => inst1_pll_0_rcnfg_from_pll,
      pll_0_logic_reset_n        => not inst0_pll_rst(4),
      pll_0_c0                   => inst1_pll_0_c0,
      pll_0_c0_pin               => ADC_CLK,
      pll_0_c1                   => inst1_pll_0_c1,
      pll_0_c1_pin               => DAC_CLK_WRT,
      pll_0_locked               => inst1_pll_0_locked, 
         --Reconfiguration  0 ports
      rcnfg_0_mgmt_readdata      => inst0_avmm_s0_readdata,		
      rcnfg_0_mgmt_waitrequest   => inst0_avmm_s0_waitrequest,
      rcnfg_0_mgmt_read          => inst1_rcnfg_0_mgmt_read,
      rcnfg_0_mgmt_write         => inst1_rcnfg_0_mgmt_write,
      rcnfg_0_mgmt_address       => inst1_rcnfg_0_mgmt_address,
      rcnfg_0_mgmt_writedata     => inst1_rcnfg_0_mgmt_writedata,
         --Reconfiguration  1 ports
      rcnfg_1_mgmt_readdata      => inst0_avmm_s1_readdata,		
      rcnfg_1_mgmt_waitrequest   => inst0_avmm_s1_waitrequest,
      rcnfg_1_mgmt_read          => inst1_rcnfg_1_mgmt_read,
      rcnfg_1_mgmt_write         => inst1_rcnfg_1_mgmt_write,
      rcnfg_1_mgmt_address       => inst1_rcnfg_1_mgmt_address,
      rcnfg_1_mgmt_writedata     => inst1_rcnfg_1_mgmt_writedata,        
      -- pllcfg ports
      from_pllcfg                => inst0_from_pllcfg,
      to_pllcfg                  => inst0_to_pllcfg
   );
      
-- ----------------------------------------------------------------------------
-- pcie_top instance.
-- PCIe interface 
-- ----------------------------------------------------------------------------
   inst2_pcie_top : entity work.pcie_top
   generic map(
      g_DEV_FAMILY               => g_DEV_FAMILY,
      g_S0_DATA_WIDTH            => c_S0_DATA_WIDTH,
      g_S1_DATA_WIDTH            => c_S1_DATA_WIDTH,
      g_S2_DATA_WIDTH            => c_S2_DATA_WIDTH,
      g_C0_DATA_WIDTH            => c_C0_DATA_WIDTH,
      -- Stream (Host->FPGA) 
      g_H2F_S0_0_RDUSEDW_WIDTH   => c_H2F_S0_0_RDUSEDW_WIDTH,
      g_H2F_S0_0_RWIDTH          => c_H2F_S0_0_RWIDTH,
      g_H2F_S0_1_RDUSEDW_WIDTH   => c_H2F_S0_1_RDUSEDW_WIDTH,
      g_H2F_S0_1_RWIDTH          => c_H2F_S0_1_RWIDTH,
      g_H2F_S1_0_RDUSEDW_WIDTH   => c_H2F_S1_0_RDUSEDW_WIDTH,
      g_H2F_S1_0_RWIDTH          => c_H2F_S1_0_RWIDTH,
      g_H2F_S1_1_RDUSEDW_WIDTH   => c_H2F_S1_1_RDUSEDW_WIDTH,
      g_H2F_S1_1_RWIDTH          => c_H2F_S1_1_RWIDTH,
      g_H2F_S2_0_RDUSEDW_WIDTH   => c_H2F_S2_0_RDUSEDW_WIDTH,
      g_H2F_S2_0_RWIDTH          => c_H2F_S2_0_RWIDTH,
      g_H2F_S2_1_RDUSEDW_WIDTH   => c_H2F_S2_1_RDUSEDW_WIDTH,
      g_H2F_S2_1_RWIDTH          => c_H2F_S2_1_RWIDTH,
      -- Stream (FPGA->Host)
      g_F2H_S0_WRUSEDW_WIDTH     => c_F2H_S0_WRUSEDW_WIDTH,
      g_F2H_S0_WWIDTH            => c_F2H_S0_WWIDTH,
      g_F2H_S1_WRUSEDW_WIDTH     => c_F2H_S1_WRUSEDW_WIDTH,
      g_F2H_S1_WWIDTH            => c_F2H_S1_WWIDTH,
      g_F2H_S2_WRUSEDW_WIDTH     => c_F2H_S2_WRUSEDW_WIDTH,
      g_F2H_S2_WWIDTH            => c_F2H_S2_WWIDTH,
      -- Control (Host->FPGA)
      g_H2F_C0_RDUSEDW_WIDTH     => c_H2F_C0_RDUSEDW_WIDTH,
      g_H2F_C0_RWIDTH            => c_H2F_C0_RWIDTH,
      -- Control (FPGA->Host)
      g_F2H_C0_WRUSEDW_WIDTH     => c_F2H_C0_WRUSEDW_WIDTH,
      g_F2H_C0_WWIDTH            => c_F2H_C0_WWIDTH 
   )
   port map(
      clk                  => CLK100_FPGA,    -- Input clock for PLL
      reset_n              => reset_n,
      -- PCIe interface
      pcie_perstn          => PCIE_PERSTN, 
      pcie_refclk          => PCIE_REFCLK, 
      pcie_rx              => PCIE_HSO,
      pcie_tx              => PCIE_HSI_IC,
      pcie_bus_clk         => pcie_bus_clk,  --modified by B.J. PCIe data clock output
      
      H2F_S0_sel           => inst0_from_fpgacfg_0.wfm_load,
      H2F_S1_sel           => inst0_from_fpgacfg_1.wfm_load,
      H2F_S2_sel           => inst0_from_fpgacfg_2.wfm_load,
      --Stream endpoint FIFO (Host->FPGA) 
      H2F_S0_0_rdclk       => inst1_lms1_txpll_c1,
      H2F_S0_0_aclrn       => inst7_tx_in_pct_reset_n_req,
      H2F_S0_0_rd          => inst7_tx_in_pct_rdreq,
      H2F_S0_0_rdata       => inst2_H2F_S0_0_rdata,
      H2F_S0_0_rempty      => inst2_H2F_S0_0_rempty,
      H2F_S0_0_rdusedw     => inst2_H2F_S0_0_rdusedw,
     
      H2F_S0_1_rdclk       => inst19_phy_clk,
      H2F_S0_1_aclrn       => inst0_from_fpgacfg_0.wfm_load,
      H2F_S0_1_rd          => inst19_wfm_0_infifo_rdreq,
      H2F_S0_1_rdata       => inst2_H2F_S0_1_rdata,
      H2F_S0_1_rempty      => inst2_H2F_S0_1_rempty,
      H2F_S0_1_rdusedw     => inst2_H2F_S0_1_rdusedw,

      H2F_S1_0_rdclk       => inst1_lms2_txpll_c1,
      H2F_S1_0_aclrn       => inst9_tx_in_pct_reset_n_req,
      H2F_S1_0_rd          => inst9_tx_in_pct_rdreq,
      H2F_S1_0_rdata       => inst2_H2F_S1_0_rdata,
      H2F_S1_0_rempty      => inst2_H2F_S1_0_rempty,
      H2F_S1_0_rdusedw     => inst2_H2F_S1_0_rdusedw,
     
      H2F_S1_1_rdclk       => inst20_phy_clk,
      H2F_S1_1_aclrn       => inst0_from_fpgacfg_1.wfm_load,
      H2F_S1_1_rd          => inst20_wfm_0_infifo_rdreq,
      H2F_S1_1_rdata       => inst2_H2F_S1_1_rdata,
      H2F_S1_1_rempty      => inst2_H2F_S1_1_rempty,
      H2F_S1_1_rdusedw     => inst2_H2F_S1_1_rdusedw, 

      H2F_S2_0_rdclk       => inst1_pll_0_c1,
      H2F_S2_0_aclrn       => inst11_tx_in_pct_reset_n_req,
      H2F_S2_0_rd          => inst11_tx_in_pct_rdreq,
      H2F_S2_0_rdata       => inst2_H2F_S2_0_rdata,
      H2F_S2_0_rempty      => inst2_H2F_S2_0_rempty,
      H2F_S2_0_rdusedw     => inst2_H2F_S2_0_rdusedw,
     
      H2F_S2_1_rdclk       => inst1_pll_0_c1,
      H2F_S2_1_aclrn       => inst0_from_fpgacfg_2.wfm_load,
      H2F_S2_1_rd          => inst11_wfm_in_pct_rdreq,
      H2F_S2_1_rdata       => inst2_H2F_S2_1_rdata,
      H2F_S2_1_rempty      => inst2_H2F_S2_1_rempty,
      H2F_S2_1_rdusedw     => inst2_H2F_S2_1_rdusedw,       
      --Stream endpoint FIFO (FPGA->Host)
      F2H_S0_wclk          => inst1_lms1_rxpll_c1,
      F2H_S0_aclrn         => inst7_rx_pct_fifo_aclrn_req,
      F2H_S0_wr            => inst7_rx_pct_fifo_wrreq,
      F2H_S0_wdata         => inst7_rx_pct_fifo_wdata,
      F2H_S0_wfull         => inst2_F2H_S0_wfull,
      F2H_S0_wrusedw       => inst2_F2H_S0_wrusedw,
      
      F2H_S1_wclk          => inst1_lms2_rxpll_c1,
      F2H_S1_aclrn         => inst9_rx_pct_fifo_aclrn_req,
      F2H_S1_wr            => inst9_rx_pct_fifo_wrreq,
      F2H_S1_wdata         => inst9_rx_pct_fifo_wdata,
      F2H_S1_wfull         => inst2_F2H_S1_wfull,
      F2H_S1_wrusedw       => inst2_F2H_S1_wrusedw,

--      modified by B.J.
--      for data stream capture, required by DPD training process 
--      B.J. commented this 
--      F2H_S2_wclk          => ADC_CLKOUT,
--      F2H_S2_aclrn         => inst11_rx_pct_fifo_aclrn_req,
--      F2H_S2_wr            => inst11_rx_pct_fifo_wrreq,
--      F2H_S2_wdata         => inst11_rx_pct_fifo_wdata,
--      F2H_S2_wfull         => inst2_F2H_S2_wfull,
--      F2H_S2_wrusedw       => inst2_F2H_S2_wrusedw,

strm2_OUT_EXT_rdreq	 =>  strm2_OUT_EXT_rdreq,
strm2_OUT_EXT_rdempty =>  strm2_OUT_EXT_rdempty,
strm2_OUT_EXT_q	    =>  strm2_OUT_EXT_q,

      --Control endpoint FIFO (Host->FPGA)
      H2F_C0_rdclk         => CLK_LMK_FPGA_IN,
      H2F_C0_aclrn         => reset_n,
      H2F_C0_rd            => inst0_exfifo_if_rd,
      H2F_C0_rdata         => inst2_H2F_C0_rdata,
      H2F_C0_rempty        => inst2_H2F_C0_rempty,
      --Control endpoint FIFO (FPGA->Host)
      F2H_C0_wclk          => CLK_LMK_FPGA_IN,
      F2H_C0_aclrn         => not inst0_exfifo_of_rst,
      F2H_C0_wr            => inst0_exfifo_of_wr,
      F2H_C0_wdata         => inst0_exfifo_of_d,
      F2H_C0_wfull         => inst2_F2H_C0_wfull,
      S0_rx_en             => inst0_from_fpgacfg_0.rx_en,
      S1_rx_en             => inst0_from_fpgacfg_1.rx_en,
      S2_rx_en             => inst0_from_fpgacfg_2.rx_en,
      F2H_S0_open          => inst2_F2H_S0_open,
      F2H_S1_open          => inst2_F2H_S1_open, 
      F2H_S2_open          => inst2_F2H_S2_open,
      H2F_S0_open          => inst2_H2F_S0_open,
      H2F_S1_open          => inst2_H2F_S1_open,
      H2F_S2_open          => inst2_H2F_S2_open 
      );
      
-- ----------------------------------------------------------------------------
-- tst_top instance.
-- Clock and External DDR2 memroy test logic
-- ----------------------------------------------------------------------------
--   inst3_tst_top : entity work.tst_top
--   port map(
--      --input ports 
--      FX3_clk           => CLK100_FPGA,
--      reset_n           => reset_n_clk100_fpga,    
--      Si5351C_clk_0     => SI_CLK0,
--      Si5351C_clk_1     => SI_CLK1,
--      Si5351C_clk_2     => SI_CLK2,
--      Si5351C_clk_3     => SI_CLK3,
--      Si5351C_clk_5     => SI_CLK5,
--      Si5351C_clk_6     => SI_CLK6,
--      Si5351C_clk_7     => SI_CLK7,
--      LMK_CLK           => LMK_CLK,
--      ADF_MUXOUT        => ADF_MUXOUT,    
--      --DDR2 external memory signals
--      mem_pllref_clk    => SI_CLK1,
--      mem_odt           => DDR2_2_ODT,
--      mem_cs_n          => DDR2_2_CS_N,
--      mem_cke           => DDR2_2_CKE,
--      mem_addr          => DDR2_2_ADDR,
--      mem_ba            => DDR2_2_BA,
--      mem_ras_n         => DDR2_2_RAS_N,
--      mem_cas_n         => DDR2_2_CAS_N,
--      mem_we_n          => DDR2_2_WE_N,
--      mem_dm            => DDR2_2_DM,
--      mem_clk           => DDR2_2_CLK,
--      mem_clk_n         => DDR2_2_CLK_N,
--      mem_dq            => DDR2_2_DQ,
--      mem_dqs           => DDR2_2_DQS,     
--      -- To configuration memory
--      to_tstcfg         => inst0_to_tstcfg,
--      from_tstcfg       => inst0_from_tstcfg
--   );    
   
-- ----------------------------------------------------------------------------
-- general_periph_top instance.
-- Control module for external periphery
-- ----------------------------------------------------------------------------
   inst4_general_periph_top : entity work.general_periph_top
   generic map(
      DEV_FAMILY  => g_DEV_FAMILY,
      N_GPIO      => g_GPIO_N
   )
   port map(
      -- General ports
      clk                  => CLK_LMK_FPGA_IN,
      reset_n              => reset_n_lmk_clk,
      -- configuration memory
      from_fpgacfg         => inst0_from_fpgacfg_0,
      to_periphcfg         => inst0_to_periphcfg,
      from_periphcfg       => inst0_from_periphcfg,     
      -- Dual colour LEDs
      -- LED1 (Clock and PLL lock status)
      led1_pll1_locked     => inst1_lms1_txpll_locked AND inst1_lms2_txpll_locked,
      led1_pll2_locked     => inst1_lms1_rxpll_locked AND inst1_lms2_rxpll_locked,
      led1_ctrl            => inst0_from_fpgacfg_0.FPGA_LED1_CTRL,
      led1_g               => FPGA_LED5_G,
      led1_r               => FPGA_LED5_R,      
      --LED2 (TCXO control status)
      led2_clk             => inst0_spi_1_SCLK,
      led2_adf_muxout      => ADF_MUXOUT,
      led2_dac_ss          => inst0_spi_0_SS_n(5),
      led2_adf_ss          => inst0_spi_0_SS_n(2),
      led2_ctrl            => inst0_from_fpgacfg_0.FPGA_LED2_CTRL,
      led2_g               => open,
      led2_r               => open,     
      --LED3 - LED6
      led3_in              => not inst1_lms1_txpll_locked,
      led4_in              => not inst1_lms1_rxpll_locked,
      led5_in              => not inst1_lms2_txpll_locked,
      led6_in              => not inst1_lms2_rxpll_locked,
      led3_out             => FPGA_LED1,
      led4_out             => FPGA_LED2,
      led5_out             => FPGA_LED3,
      led6_out             => FPGA_LED4,    
      --GPIO
      gpio_dir             => (others=>'1'),
      gpio_out_val         => (others=>'0'),
      gpio_rd_val          => open,
      gpio                 => open,      
      --Fan control
      fan_sens_in          => LM75_OS,
      fan_ctrl_out         => FAN_CTRL
   );
   
--   inst5_busy_delay : entity work.busy_delay
--   generic map(
--      clock_period   => 10,
--      delay_time     => 200  -- delay time in ms
--      --counter_value=delay_time*1000/clock_period<2^32
--      --delay counter is 32bit wide, 
--   )
--   port map(
--      --input ports 
--      clk      => CLK100_FPGA,
--      reset_n  => reset_n_clk100_fpga,
--      busy_in  => inst0_gpo(0),
--      busy_out => inst5_busy
--   );
    
-- ----------------------------------------------------------------------------
-- Receive and transmit interface for LMS7002 #1
-- ----------------------------------------------------------------------------
   -- Rx interface is enabled only when user_read_32 or user_write_32 port is opened from Host.
   process(inst0_from_fpgacfg_0, inst2_F2H_S0_open, inst2_H2F_S0_open)
   begin 
      inst0_from_fpgacfg_mod_0        <= inst0_from_fpgacfg_0;
      --inst0_from_fpgacfg_mod_0.rx_en  <= inst0_from_fpgacfg_0.rx_en AND inst2_F2H_S0_open;
      inst0_from_fpgacfg_mod_0.rx_en  <= inst0_from_fpgacfg_0.rx_en AND (inst2_F2H_S0_open OR inst2_H2F_S0_open);
 
   end process;
   
--   --Module for LMS7002 IC
   inst6_lms7002_top : entity work.lms7002_top
   generic map(

-- added by B.J. : 
-- LMS#1 has two CFR+FIT+DPD chains for both transmitting channels.
--	for trasmit only LMS#1 is used: both channels A and B are active
-- LMS#1 Ch.A. Receive is used for DPD monitoring path	
-- LMS#1 Ch.B. Receive is NOT used 
      DPDTopWrapper_enable    =>  1,
-- this generic forces the implementation of DPDTop module      

      g_DEV_FAMILY            => g_DEV_FAMILY,
      g_IQ_WIDTH              => g_LMS_DIQ_WIDTH,
      g_INV_INPUT_CLK         => "ON",
      g_TX_SMPL_FIFO_0_WRUSEDW  => 9,
      g_TX_SMPL_FIFO_0_DATAW    => 128,
      g_TX_SMPL_FIFO_1_WRUSEDW  => 9,
      g_TX_SMPL_FIFO_1_DATAW    => 128
   ) 
   port map(  
      from_fpgacfg         => inst0_from_fpgacfg_mod_0,
      from_tstcfg          => inst0_from_tstcfg,
      from_memcfg          => inst0_from_memcfg,
      -- Momory module reset
      mem_reset_n          => reset_n,
      -- PORT1 interface
      MCLK1                => inst1_lms1_txpll_c1,
      MCLK1_2x             => inst1_lms1_txpll_c2,
      FCLK1                => open, 
      DIQ1                 => LMS1_DIQ1_D,
      ENABLE_IQSEL1        => LMS1_ENABLE_IQSEL1,
      TXNRX1               => LMS1_TXNRX1,
      -- PORT2 interface
      MCLK2                => inst1_lms1_rxpll_c1,
      FCLK2                => open, 
      DIQ2                 => LMS1_DIQ2_D,
      ENABLE_IQSEL2        => LMS1_ENABLE_IQSEL2,
      TXNRX2               => LMS1_TXNRX2,
      -- MISC
      RESET                => LMS1_RESET, 
      TXEN                 => LMS1_TXEN,
      RXEN                 => LMS1_RXEN,
      CORE_LDO_EN          => LMS1_CORE_LDO_EN,
      -- Internal TX ports
      tx_reset_n           => inst1_lms1_txpll_locked,
      tx_fifo_0_wrclk      => inst1_lms1_txpll_c1,
      tx_fifo_0_reset_n    => inst0_from_fpgacfg_mod_0.rx_en,
      tx_fifo_0_wrreq      => inst7_tx_smpl_fifo_wrreq,
      tx_fifo_0_data       => inst7_tx_smpl_fifo_data,
      tx_fifo_0_wrfull     => inst6_tx_fifo_0_wrfull,
      tx_fifo_0_wrusedw    => inst6_tx_fifo_0_wrusedw,
      tx_fifo_1_wrclk      => inst19_phy_clk,
      tx_fifo_1_reset_n    => inst19_wfm_0_outfifo_reset_n,
      tx_fifo_1_wrreq      => inst19_wfm_0_outfifo_wrreq,
      tx_fifo_1_data       => inst19_wfm_0_outfifo_data,
      tx_fifo_1_wrfull     => inst6_tx_fifo_1_wrfull,
      tx_fifo_1_wrusedw    => inst6_tx_fifo_1_wrusedw,
      tx_ant_en            => inst6_tx_ant_en, 
      -- Internal RX ports
      rx_reset_n           => inst1_lms1_rxpll_locked,
      rx_diq_h             => open, 
      rx_diq_l             => open,
      rx_data_valid        => inst6_rx_data_valid,
      rx_data              => inst6_rx_data,
      rx_smpl_cmp_start    => inst1_lms1_smpl_cmp_en,
      rx_smpl_cmp_length   => inst1_lms1_smpl_cmp_cnt,
      rx_smpl_cmp_done     => inst6_rx_smpl_cmp_done,
      rx_smpl_cmp_err      => inst6_rx_smpl_cmp_err,
            -- SPI for internal modules
      sdin                 => inst0_spi_0_MOSI,  -- Data in
      sclk                 => inst0_spi_0_SCLK,  -- Data clock
      sen                  => inst0_spi_0_SS_n(6),  -- Enable signal (active low)
      sdout                => inst6_sdout,  -- Data out
      
      -- added by B.J.
		-- to support data stream capture, required by DPD  
      pcie_bus_clk  => pcie_bus_clk,	
		strm2_OUT_EXT_rdreq => strm2_OUT_EXT_rdreq, -- in
		strm2_OUT_EXT_q => strm2_OUT_EXT_q, -- out
		strm2_OUT_EXT_rdempty => strm2_OUT_EXT_rdempty, -- out
		
		-- added by B.J.
		-- power amplifies and DC/DC control over PMODA port 
		PAEN0 => PAEN0,
      PAEN1 => PAEN1,
		DCEN0 => DCEN0,
      DCEN1 => DCEN1,
		-- added by B.J.
		-- RF switch for selection of one of two receive inputs
		-- for DPD monitopring path, 
		-- one of two SMA inputs is through RF switch connected to Rx_W of Ch.A
	   rf_sw => rf_sw	
   );
   
   inst7_rxtx_top : entity work.rxtx_top
   generic map(
      DEV_FAMILY              => g_DEV_FAMILY,
      -- TX parameters
      TX_IQ_WIDTH             => g_LMS_DIQ_WIDTH,
      TX_N_BUFF               => g_TX_N_BUFF,              -- 2,4 valid values
      TX_IN_PCT_SIZE          => g_TX_PCT_SIZE,
      TX_IN_PCT_HDR_SIZE      => g_TX_IN_PCT_HDR_SIZE,
      TX_IN_PCT_DATA_W        => c_H2F_S0_0_RWIDTH,      -- 
      TX_IN_PCT_RDUSEDW_W     => c_H2F_S0_0_RDUSEDW_WIDTH,
      
      -- RX parameters
      RX_IQ_WIDTH             => g_LMS_DIQ_WIDTH,
      RX_INVERT_INPUT_CLOCKS  => "ON",
      RX_PCT_BUFF_WRUSEDW_W   => c_F2H_S0_WRUSEDW_WIDTH --bus width in bits 
      
   )
   port map(                                             
      from_fpgacfg            => inst0_from_fpgacfg_mod_0,
      to_tstcfg_from_rxtx     => inst7_to_tstcfg_from_rxtx,
      from_tstcfg             => inst0_from_tstcfg,      
      -- TX module signals
      tx_clk                  => inst1_lms1_txpll_c1,
      tx_clk_reset_n          => inst1_lms1_txpll_locked,     
      tx_pct_loss_flg         => inst7_tx_pct_loss_flg,
      tx_txant_en             => inst7_tx_txant_en,  
      --Tx interface data 
      tx_smpl_fifo_wrreq      => inst7_tx_smpl_fifo_wrreq,
      tx_smpl_fifo_wrfull     => inst6_tx_fifo_0_wrfull,
      tx_smpl_fifo_wrusedw    => inst6_tx_fifo_0_wrusedw,
      tx_smpl_fifo_data       => inst7_tx_smpl_fifo_data,
      --TX packet FIFO ports
      tx_in_pct_reset_n_req   => inst7_tx_in_pct_reset_n_req,
      tx_in_pct_rdreq         => inst7_tx_in_pct_rdreq,
      tx_in_pct_data          => inst2_H2F_S0_0_rdata,
      tx_in_pct_rdempty       => inst2_H2F_S0_0_rempty,
      tx_in_pct_rdusedw       => inst2_H2F_S0_0_rdusedw,     
      -- RX path
      rx_clk                  => inst1_lms1_rxpll_c1,
      rx_clk_reset_n          => inst1_lms1_rxpll_locked,
      --RX FIFO for IQ samples   
      rx_smpl_fifo_wrreq      => inst6_rx_data_valid,
      rx_smpl_fifo_data       => inst6_rx_data,
      rx_smpl_fifo_wrfull     => open,
      --RX Packet FIFO ports
      rx_pct_fifo_aclrn_req   => inst7_rx_pct_fifo_aclrn_req,
      rx_pct_fifo_wusedw      => inst2_F2H_S0_wrusedw,
      rx_pct_fifo_wrreq       => inst7_rx_pct_fifo_wrreq,
      rx_pct_fifo_wdata       => inst7_rx_pct_fifo_wdata  
   );   
	
-- ----------------------------------------------------------------------------
-- rxtx_top instance.
-- Receive and transmit interface for LMS7002 #2
-- ----------------------------------------------------------------------------
   -- Rx interface is enabled only when user_read_32 or user_write_32 port is opened from Host.
   process(inst0_from_fpgacfg_1, inst2_F2H_S1_open, inst2_H2F_S1_open)
   begin 
      inst0_from_fpgacfg_mod_1        <= inst0_from_fpgacfg_1;
      --inst0_from_fpgacfg_mod_1.rx_en  <= inst0_from_fpgacfg_1.rx_en AND inst2_F2H_S1_open;
      inst0_from_fpgacfg_mod_1.rx_en  <= inst0_from_fpgacfg_1.rx_en AND (inst2_F2H_S1_open OR inst2_H2F_S1_open);
  
   end process;

   inst8_lms7002_top : entity work.lms7002_top
   generic map(

   -- added by B.J. 
	-- LMS#2 does not contain CFR+FIR+DPD chain since it is not transmitting anything
	-- to save the FPGA resources, the chain is not generated in LMS#2 top file	
	-- LMS#2 Ch.A.and Ch.B Receive paths are used for LTE stack	   
		DPDTopWrapper_enable    =>  0,
      g_DEV_FAMILY            => g_DEV_FAMILY,
      g_IQ_WIDTH              => g_LMS_DIQ_WIDTH,
      g_INV_INPUT_CLK         => "ON",
      g_TX_SMPL_FIFO_0_WRUSEDW  => 9,
      g_TX_SMPL_FIFO_0_DATAW    => 128,
      g_TX_SMPL_FIFO_1_WRUSEDW  => 9,
      g_TX_SMPL_FIFO_1_DATAW    => 128
   ) 
   port map(  
      from_fpgacfg         => inst0_from_fpgacfg_mod_1,
      from_tstcfg          => inst0_from_tstcfg,
      from_memcfg          => inst0_from_memcfg,
      -- Momory module reset
      mem_reset_n          => reset_n,
      -- PORT1 interface
      MCLK1                => inst1_lms2_txpll_c1,
      MCLK1_2x             => inst1_lms2_txpll_c2,
      FCLK1                => open, 
      DIQ1                 => LMS2_DIQ1_D,
      ENABLE_IQSEL1        => LMS2_ENABLE_IQSEL1,
      TXNRX1               => LMS2_TXNRX1,
      -- PORT2 interface
      MCLK2                => inst1_lms2_rxpll_c1,
      FCLK2                => open, 
      DIQ2                 => LMS2_DIQ2_D,
      ENABLE_IQSEL2        => LMS2_ENABLE_IQSEL2,
      TXNRX2               => LMS2_TXNRX2,
      -- MISC
      RESET                => LMS2_RESET, 
      TXEN                 => LMS2_TXEN,
      RXEN                 => LMS2_RXEN,
      CORE_LDO_EN          => LMS2_CORE_LDO_EN,
      -- Internal TX ports
      tx_reset_n           => inst1_lms2_txpll_locked,
      tx_fifo_0_wrclk      => inst1_lms2_txpll_c1,
      tx_fifo_0_reset_n    => inst0_from_fpgacfg_mod_1.rx_en,
      tx_fifo_0_wrreq      => inst9_tx_smpl_fifo_wrreq,
      tx_fifo_0_data       => inst9_tx_smpl_fifo_data,
      tx_fifo_0_wrfull     => inst8_tx_fifo_0_wrfull,
      tx_fifo_0_wrusedw    => inst8_tx_fifo_0_wrusedw,
      tx_fifo_1_wrclk      => inst20_phy_clk,
      tx_fifo_1_reset_n    => inst20_wfm_0_outfifo_reset_n,
      tx_fifo_1_wrreq      => inst20_wfm_0_outfifo_wrreq,
      tx_fifo_1_data       => inst20_wfm_0_outfifo_data,
      tx_fifo_1_wrfull     => inst8_tx_fifo_1_wrfull,
      tx_fifo_1_wrusedw    => inst8_tx_fifo_1_wrusedw,
      tx_ant_en            => inst8_tx_ant_en, 
      -- Internal RX ports
      rx_reset_n           => inst1_lms2_rxpll_locked,
      rx_diq_h             => open, 
      rx_diq_l             => open,
      rx_data_valid        => inst8_rx_data_valid,
      rx_data              => inst8_rx_data,
      rx_smpl_cmp_start    => inst1_lms2_smpl_cmp_en,
      rx_smpl_cmp_length   => inst1_lms2_smpl_cmp_cnt,
      rx_smpl_cmp_done     => inst8_rx_smpl_cmp_done,
      rx_smpl_cmp_err      => inst8_rx_smpl_cmp_err,
            -- SPI for internal modules
      sdin                 => inst0_spi_0_MOSI,  -- Data in
      sclk                 => inst0_spi_0_SCLK,  -- Data clock
      sen                  => inst0_spi_0_SS_n(6),  -- Enable signal (active low)
      sdout                => inst8_sdout,  -- Data out
      
      --added by B.J.
      pcie_bus_clk  => pcie_bus_clk,	
      strm2_OUT_EXT_rdreq => '0', -- in
      strm2_OUT_EXT_q => open, -- out
      strm2_OUT_EXT_rdempty => open, -- out,
      PAEN0 => open,
      PAEN1 => open,
      DCEN0 => open,
      DCEN1 => open,
      rf_sw => open
   );
   
   inst9_rxtx_top : entity work.rxtx_top
   generic map(
      DEV_FAMILY              => g_DEV_FAMILY,
      -- TX parameters
      TX_IQ_WIDTH             => g_LMS_DIQ_WIDTH,
      TX_N_BUFF               => g_TX_N_BUFF,              -- 2,4 valid values
      TX_IN_PCT_SIZE          => g_TX_PCT_SIZE,
      TX_IN_PCT_HDR_SIZE      => g_TX_IN_PCT_HDR_SIZE,
      TX_IN_PCT_DATA_W        => c_H2F_S1_0_RWIDTH,      -- 
      TX_IN_PCT_RDUSEDW_W     => c_H2F_S1_0_RDUSEDW_WIDTH,
      
      -- RX parameters
      RX_IQ_WIDTH             => g_LMS_DIQ_WIDTH,
      RX_INVERT_INPUT_CLOCKS  => "ON",
      RX_PCT_BUFF_WRUSEDW_W   => c_F2H_S1_WRUSEDW_WIDTH --bus width in bits 
      
   )
   port map(                                             
      from_fpgacfg            => inst0_from_fpgacfg_mod_1,
      to_tstcfg_from_rxtx     => inst9_to_tstcfg_from_rxtx,
      from_tstcfg             => inst0_from_tstcfg,      
      -- TX module signals
      tx_clk                  => inst1_lms2_txpll_c1,
      tx_clk_reset_n          => inst1_lms2_txpll_locked,     
      tx_pct_loss_flg         => inst9_tx_pct_loss_flg,
      tx_txant_en             => inst9_tx_txant_en,  
      --Tx interface data 
      tx_smpl_fifo_wrreq      => inst9_tx_smpl_fifo_wrreq,
      tx_smpl_fifo_wrfull     => inst8_tx_fifo_0_wrfull,
      tx_smpl_fifo_wrusedw    => inst8_tx_fifo_0_wrusedw,
      tx_smpl_fifo_data       => inst9_tx_smpl_fifo_data,
      --TX packet FIFO ports
      tx_in_pct_reset_n_req   => inst9_tx_in_pct_reset_n_req,
      tx_in_pct_rdreq         => inst9_tx_in_pct_rdreq,
      tx_in_pct_data          => inst2_H2F_S1_0_rdata,
      tx_in_pct_rdempty       => inst2_H2F_S1_0_rempty,
      tx_in_pct_rdusedw       => inst2_H2F_S1_0_rdusedw,     
      -- RX path
      rx_clk                  => inst1_lms2_rxpll_c1,
      rx_clk_reset_n          => inst1_lms2_rxpll_locked,
      --RX FIFO for IQ samples   
      rx_smpl_fifo_wrreq      => inst8_rx_data_valid,
      rx_smpl_fifo_data       => inst8_rx_data,
      rx_smpl_fifo_wrfull     => open,
      --RX Packet FIFO ports
      rx_pct_fifo_aclrn_req   => inst9_rx_pct_fifo_aclrn_req,
      rx_pct_fifo_wusedw      => inst2_F2H_S1_wrusedw,
      rx_pct_fifo_wrreq       => inst9_rx_pct_fifo_wrreq,
      rx_pct_fifo_wdata       => inst9_rx_pct_fifo_wdata  
   );   
--   --Module for LMS7002 IC
--   inst8_lms7002_top : entity work.lms7002_top
--   generic map(
--      g_DEV_FAMILY            => g_DEV_FAMILY,
--      g_IQ_WIDTH              => g_LMS_DIQ_WIDTH,
--      g_INV_INPUT_CLK         => "ON",
--      g_TX_SMPL_FIFO_WRUSEDW  => 9,
--      g_TX_SMPL_FIFO_DATAW    => 128
--   ) 
--   port map(  
--      from_fpgacfg         => inst0_from_fpgacfg_mod_1,
--      from_tstcfg          => inst0_from_tstcfg,
--      from_memcfg          => inst0_from_memcfg,
--      -- Momory module reset
--      mem_reset_n          => reset_n,
--      -- PORT1 interface
--      MCLK1                => inst1_lms2_txpll_c1,
--      MCLK1_2x             => inst1_lms2_txpll_c2,
--      FCLK1                => open, 
--      DIQ1                 => LMS2_DIQ1_D,
--      ENABLE_IQSEL1        => LMS2_ENABLE_IQSEL1,
--      TXNRX1               => LMS2_TXNRX1,
--      -- PORT2 interface
--      MCLK2                => inst1_lms2_rxpll_c1,
--      FCLK2                => open, 
--      DIQ2                 => LMS2_DIQ2_D,
--      ENABLE_IQSEL2        => LMS2_ENABLE_IQSEL2,
--      TXNRX2               => LMS2_TXNRX2,
--      -- MISC
--      RESET                => LMS2_RESET, 
--      TXEN                 => LMS2_TXEN,
--      RXEN                 => LMS2_RXEN,
--      CORE_LDO_EN          => LMS2_CORE_LDO_EN,
--      -- Internal TX ports
--      tx_reset_n           => inst1_lms2_txpll_locked,
--      tx_src_sel           => (others => '0'),
--      tx_diq_h             => (others => '0'),
--      tx_diq_l             => (others => '0'),
--      tx_wrfull            => inst8_tx_wrfull,
--      tx_wrusedw           => inst8_tx_wrusedw,
--      tx_wrreq             => inst9_tx_smpl_fifo_wrreq,
--      tx_data              => inst9_tx_smpl_fifo_data,
--      -- Internal RX ports
--      rx_reset_n           => inst1_lms2_rxpll_locked,
--      rx_diq_h             => open, 
--      rx_diq_l             => open,
--      rx_data_valid        => inst8_rx_data_valid,
--      rx_data              => inst8_rx_data,
--      rx_smpl_cmp_start    => inst1_lms2_smpl_cmp_en,
--      rx_smpl_cmp_length   => inst1_lms2_smpl_cmp_cnt,
--      rx_smpl_cmp_done     => inst8_rx_smpl_cmp_done,
--      rx_smpl_cmp_err      => inst8_rx_smpl_cmp_err,
--                  -- SPI for internal modules
--      sdin                 => inst0_spi_0_MOSI,  -- Data in
--      sclk                 => inst0_spi_0_SCLK,  -- Data clock
--      sen                  => inst0_spi_0_SS_n(6),  -- Enable signal (active low)
--      sdout                => inst8_sdout  -- Data out 
--   
--   ); 
   
--   inst9_rxtx_top : entity work.rxtx_top
--   generic map(
--      DEV_FAMILY              => g_DEV_FAMILY,
--      -- TX parameters
--      TX_IQ_WIDTH             => g_LMS_DIQ_WIDTH,
--      TX_N_BUFF               => g_TX_N_BUFF,              -- 2,4 valid values
--      TX_IN_PCT_SIZE          => g_TX_PCT_SIZE,
--      TX_IN_PCT_HDR_SIZE      => g_TX_IN_PCT_HDR_SIZE,
--      TX_IN_PCT_DATA_W        => c_H2F_S1_0_RWIDTH,      -- 
--      TX_IN_PCT_RDUSEDW_W     => c_H2F_S1_0_RDUSEDW_WIDTH,
--      
--      -- RX parameters
--      RX_IQ_WIDTH             => g_LMS_DIQ_WIDTH,
--      RX_INVERT_INPUT_CLOCKS  => "ON",
--      RX_PCT_BUFF_WRUSEDW_W   => c_F2H_S1_WRUSEDW_WIDTH --bus width in bits 
--      
--   )
--   port map(                                             
--      from_fpgacfg            => inst0_from_fpgacfg_mod_1,
--      to_tstcfg_from_rxtx     => inst9_to_tstcfg_from_rxtx,
--      from_tstcfg             => inst0_from_tstcfg,      
--      -- TX module signals
--      tx_clk                  => inst1_lms2_txpll_c1,
--      tx_clk_reset_n          => inst1_lms2_txpll_locked,     
--      tx_pct_loss_flg         => inst9_tx_pct_loss_flg,
--      tx_txant_en             => inst9_tx_txant_en,  
--      --Tx interface data 
--      tx_smpl_fifo_wrreq      => inst9_tx_smpl_fifo_wrreq,
--      tx_smpl_fifo_wrfull     => inst8_tx_wrfull,
--      tx_smpl_fifo_wrusedw    => inst8_tx_wrusedw,
--      tx_smpl_fifo_data       => inst9_tx_smpl_fifo_data,
--      --TX packet FIFO ports
--      tx_in_pct_reset_n_req   => inst9_tx_in_pct_reset_n_req,
--      tx_in_pct_rdreq         => inst9_tx_in_pct_rdreq,
--      tx_in_pct_data          => inst2_H2F_S1_0_rdata,
--      tx_in_pct_rdempty       => inst2_H2F_S1_0_rempty,
--      tx_in_pct_rdusedw       => inst2_H2F_S1_0_rdusedw,     
--      -- RX path
--      rx_clk                  => inst1_lms2_rxpll_c1,
--      rx_clk_reset_n          => inst1_lms2_rxpll_locked,
--      --RX FIFO for IQ samples   
--      rx_smpl_fifo_wrreq      => inst8_rx_data_valid,
--      rx_smpl_fifo_data       => inst8_rx_data,
--      rx_smpl_fifo_wrfull     => open,
--      --RX Packet FIFO ports
--      rx_pct_fifo_aclrn_req   => inst9_rx_pct_fifo_aclrn_req,
--      rx_pct_fifo_wusedw      => inst2_F2H_S1_wrusedw,
--      rx_pct_fifo_wrreq       => inst9_rx_pct_fifo_wrreq,
--      rx_pct_fifo_wdata       => inst9_rx_pct_fifo_wdata  
--   );
   
-- ----------------------------------------------------------------------------
-- External DAC and ADC
-- ----------------------------------------------------------------------------
   -- Rx interface is enabled only when user_read_32 or user_write_32 port is opened from Host. 
   process(inst0_from_fpgacfg_2, inst2_F2H_S2_open, inst2_H2F_S2_open)
   begin 
      inst0_from_fpgacfg_mod_2        <= inst0_from_fpgacfg_2;
      --inst0_from_fpgacfg_mod_2.rx_en  <= inst0_from_fpgacfg_2.rx_en AND inst2_F2H_S2_open;
      inst0_from_fpgacfg_mod_2.rx_en  <= inst0_from_fpgacfg_2.rx_en AND (inst2_F2H_S2_open OR inst2_H2F_S2_open);   
   end process;
   
--   inst10_adc_top : entity work.adc_top
--   generic map( 
--      dev_family           => g_DEV_FAMILY,
--      data_width           => 7,
--      smpls_to_capture     => 4
--      )
--   port map(
--      clk               => ADC_CLKOUT,
--      reset_n           => inst1_pll_0_locked,
--      en                => inst0_from_fpgacfg_mod_2.rx_en OR inst0_from_fpgacfg_mod_2.dlb_en,      
--      ch_a              => ADC_DA,
--      ch_b              => ADC_DB,     
--      --SDR parallel output data
--      data_ch_a         => inst10_data_ch_a, 
--      data_ch_b         => inst10_data_ch_b,  
--      --Interleaved samples of both channels
--      data_ch_ab        => inst10_rx_data,
--      data_ch_ab_valid  => inst10_rx_data_valid,
--      test_out          => open,
--      to_rxtspcfg       => inst0_to_rxtspcfg,
--      from_rxtspcfg     => inst0_from_rxtspcfg
--   );
   
   -- RX and TX module
--   inst11_rxtx_top : entity work.rxtx_top
--   generic map(
--      DEV_FAMILY              => g_DEV_FAMILY,
--      -- TX parameters
--      TX_IQ_WIDTH             => 14,
--      TX_N_BUFF               => g_TX_N_BUFF,              -- 2,4 valid values
--      TX_IN_PCT_SIZE          => g_TX_PCT_SIZE,
--      TX_IN_PCT_HDR_SIZE      => g_TX_IN_PCT_HDR_SIZE,
--      TX_IN_PCT_DATA_W        => c_H2F_S2_0_RWIDTH,      -- 
--      TX_IN_PCT_RDUSEDW_W     => c_H2F_S2_0_RDUSEDW_WIDTH,
--      
--      -- RX parameters
--      RX_IQ_WIDTH             => 14,
--      RX_INVERT_INPUT_CLOCKS  => "ON",
--      RX_PCT_BUFF_WRUSEDW_W   => c_F2H_S2_WRUSEDW_WIDTH --bus width in bits 
--      
--   )
--   port map(                                             
--      from_fpgacfg            => inst0_from_fpgacfg_mod_2,
--      to_tstcfg_from_rxtx     => inst11_to_tstcfg_from_rxtx,
--      from_tstcfg             => inst0_from_tstcfg,      
--      -- TX module signals
--      tx_clk                  => inst1_pll_0_c1,
--      tx_clk_reset_n          => inst1_pll_0_locked,     
--      tx_pct_loss_flg         => inst11_tx_pct_loss_flg,
--      tx_txant_en             => inst11_tx_txant_en,  
--      --Tx interface data 
--      tx_smpl_fifo_wrreq      => inst11_tx_smpl_fifo_wrreq,
--      tx_smpl_fifo_wrfull     => inst12_tx0_wrfull,
--      tx_smpl_fifo_wrusedw    => inst12_tx0_wrusedw,
--      tx_smpl_fifo_data       => inst11_tx_smpl_fifo_data,
--      --TX packet FIFO ports
--      tx_in_pct_reset_n_req   => inst11_tx_in_pct_reset_n_req,
--      tx_in_pct_rdreq         => inst11_tx_in_pct_rdreq,
--      tx_in_pct_data          => inst2_H2F_S2_0_rdata,
--      tx_in_pct_rdempty       => inst2_H2F_S2_0_rempty,
--      tx_in_pct_rdusedw       => inst2_H2F_S2_0_rdusedw,     
--      -- RX path
--      rx_clk                  => ADC_CLKOUT,
--      rx_clk_reset_n          => inst1_pll_0_locked,
--      --RX FIFO for IQ samples   
--      rx_smpl_fifo_wrreq      => inst10_rx_data_valid,
--      rx_smpl_fifo_data       => inst10_rx_data,
--      rx_smpl_fifo_wrfull     => open,
--      --RX Packet FIFO ports
--      rx_pct_fifo_aclrn_req   => inst11_rx_pct_fifo_aclrn_req,
--      rx_pct_fifo_wusedw      => inst2_F2H_S2_wrusedw,
--      rx_pct_fifo_wrreq       => inst11_rx_pct_fifo_wrreq,
--      rx_pct_fifo_wdata       => inst11_rx_pct_fifo_wdata  
--   );
   
   inst12_tx1_data   <= inst10_data_ch_b & inst10_data_ch_a;
   inst12_tx1_wrreq  <= (not inst12_tx1_wrfull) AND (inst0_from_fpgacfg_mod_2.dlb_en AND inst1_pll_0_locked);
   
   inst12_tx_src_sel <= "00" when inst0_from_fpgacfg_mod_2.rx_en = '1' else 
                        "01" when inst0_from_fpgacfg_mod_2.dlb_en = '1' else 
                        "10";
   
   -- DAC module
--   inst12_dac5672_top : entity work.dac5672_top
--   generic map(
--      g_DEV_FAMILY            => g_DEV_FAMILY,
--      g_IQ_WIDTH              => g_EXT_DAC_D_WIDTH,
--      g_TX0_FIFO_WRUSEDW      => 9,
--      g_TX0_FIFO_DATAW        => 128,
--      g_TX1_FIFO_WRUSEDW      => 9,
--      g_TX1_FIFO_DATAW        => 2*g_EXT_ADC_D_WIDTH
--   )
--   port map(
--      clk                  => inst1_pll_0_c1,
--      reset_n              => inst1_pll_0_locked,
--      --DAC#1 Outputs
--      DAC1_SLEEP           => DAC1_SLEEP,
--      DAC1_MODE            => DAC1_MODE,
--      DAC1_DA              => DAC1_DA,
--      DAC1_DB              => DAC1_DB,
--      --DAC#2 Outputs
--      DAC2_SLEEP           => DAC2_SLEEP,
--      DAC2_MODE            => DAC2_MODE,
--      DAC2_DA              => DAC2_DA,
--      DAC2_DB              => DAC2_DB,
--      -- Internal TX ports
--      tx_reset_n           => inst1_pll_0_locked,
--      tx_src_sel           => inst12_tx_src_sel,
--      -- tx0 source for DAC
--      tx0_wrclk            => inst1_pll_0_c1,
--      tx0_reset_n          => inst1_pll_0_locked,
--      tx0_wrfull           => inst12_tx0_wrfull,
--      tx0_wrusedw          => inst12_tx0_wrusedw,
--      tx0_wrreq            => inst11_tx_smpl_fifo_wrreq,
--      tx0_data             => inst11_tx_smpl_fifo_data,
--      -- tx1 source for DAC
--      tx1_wrclk            => ADC_CLKOUT,
--      tx1_reset_n          => inst1_pll_0_locked AND inst0_from_fpgacfg_mod_2.dlb_en,   
--      tx1_wrfull           => inst12_tx1_wrfull,
--      tx1_wrusedw          => open,
--      tx1_wrreq            => inst12_tx1_wrreq,
--      tx1_data             => inst12_tx1_data,
--      -- tx2 FIFO source for DAC
--      tx2_dac1_da          => (others=>'0'),
--      tx2_dac1_db          => (others=>'0'),
--      tx2_dac2_da          => (others=>'0'),
--      tx2_dac2_db          => (others=>'0'),
--      -- Configuration data
--      from_fpgacfg         => inst0_from_fpgacfg_2,
--      from_txtspcfg_0      => inst0_from_txtspcfg_0,
--      to_txtspcfg_0        => inst0_to_txtspcfg_0,
--      from_txtspcfg_1      => inst0_from_txtspcfg_1,
--      to_txtspcfg_1        => inst0_to_txtspcfg_1
--   );
   
   
   inst18_IC_74HC595_top: entity work.IC_74HC595_top
   port map(

      clk      => CLK_LMK_FPGA_IN,
      reset_n  => reset_n,
      data     => inst0_from_fpgacfg_0.GPIO,
      busy     => open,
      
      SHCP     => SR_SCLK_LS,    -- shift register clock
      STCP     => SR_LATCH_LS,   -- storage register clock
      DS       => SR_DIN_LS      -- serial data
      );
      
  inst19_wfm_player_x2_top : entity work.wfm_player_x2_top
  generic map(
      dev_family                    => g_DEV_FAMILY,
      
      --External memory controller parameters
      mem_cntrl_rate                => 1, --1 - full rate, 2 - half rate
      mem_dq_width                  => 32,
      mem_dqs_width                 => 4,
      mem_addr_width                => 14,
      mem_ba_width                  => 3,
      mem_dm_width                  => 4,
      
      --Avalon 0 interface parameters
      avl_0_addr_width              => 26,
      avl_0_data_width              => 64,
      avl_0_burst_count_width       => 2,
      avl_0_be_width                => 8,
      avl_0_max_burst_count         => 2, -- only 2 is for now
      avl_0_rd_latency_words        => 64,
      avl_0_traffic_gen_buff_size   => 16,
      
      --Avalon 1 interface parameters
      avl_1_addr_width              => 26,
      avl_1_data_width              => 64,
      avl_1_burst_count_width       => 2,
      avl_1_be_width                => 8,
      avl_1_max_burst_count         => 2, -- only 2 is for now
      avl_1_rd_latency_words        => 64,
      avl_1_traffic_gen_buff_size   => 16,
      
      -- wfm 0 player parameters
      wfm_0_infifo_rdusedw_width    => c_H2F_S0_1_RDUSEDW_WIDTH,
      wfm_0_infifo_rdata_width      => c_H2F_S0_1_RWIDTH,      
      wfm_0_outfifo_wrusedw_width   => 9,
      
      -- wfm 1 player parameters
      wfm_1_infifo_rdusedw_width    => 11,
      wfm_1_infifo_rdata_width      => 64,      
      wfm_1_outfifo_wrusedw_width   => 10,
      
      wfm_0_iq_width                => 12,
      wfm_1_iq_width                => 14
           
   )
   port map(

      clk                     => CLK125_FPGA_BOT,    -- PLL reference clock
      reset_n                 => reset_n,
      from_fpgacfg_0          => inst0_from_fpgacfg_0,
      ----------------WFM port 0------------------
      --infifo 
      wfm_0_infifo_rdreq      => inst19_wfm_0_infifo_rdreq,
      wfm_0_infifo_rdata      => inst2_H2F_S0_1_rdata,
      wfm_0_infifo_rdempty    => inst2_H2F_S0_1_rempty,
      wfm_0_infifo_rdusedw    => inst2_H2F_S0_1_rdusedw,
      --outfifo   
      wfm_0_outfifo_reset_n   => inst19_wfm_0_outfifo_reset_n,
      wfm_0_outfifo_wrreq     => inst19_wfm_0_outfifo_wrreq,
      wfm_0_outfifo_data      => inst19_wfm_0_outfifo_data,
      wfm_0_outfifo_wrusedw   => inst6_tx_fifo_1_wrusedw,
      
      ----------------WFM port 1------------------
      from_fpgacfg_1          => inst0_from_fpgacfg_2,
      --infifo 
      wfm_1_infifo_rdreq      => inst19_wfm_1_infifo_rdreq,
      wfm_1_infifo_rdata      => (others=>'0'),
      wfm_1_infifo_rdempty    => '1',
      wfm_1_infifo_rdusedw    => (others=>'0'),
      --outfifo   
      wfm_1_outfifo_reset_n   => open,
      wfm_1_outfifo_wrreq     => open,
      wfm_1_outfifo_data      => open,
      wfm_1_outfifo_wrusedw   => (others=>'0'),

      ---------------------External memory signals
      mem_a                   => DDR3_BOT_A,       -- memory.mem_a
      mem_ba                  => DDR3_BOT_BA,      --       .mem_ba
      mem_ck                  => DDR3_BOT_CK_P,    --       .mem_ck
      mem_ck_n                => DDR3_BOT_CK_N,    --       .mem_ck_n
      mem_cke                 => DDR3_BOT_CKE,     --       .mem_cke
      mem_cs_n                => DDR3_BOT_CSn,     --       .mem_cs_n
      mem_dm                  => DDR3_BOT_DM,      --       .mem_dm
      mem_ras_n               => DDR3_BOT_RASn,    --       .mem_ras_n
      mem_cas_n               => DDR3_BOT_CASn,    --       .mem_cas_n
      mem_we_n                => DDR3_BOT_WEn,     --       .mem_we_n
      mem_reset_n             => DDR3_BOT_RESETn,  --       .mem_reset_n
      mem_dq                  => DDR3_BOT_DQ,      --       .mem_dq
      mem_dqs                 => DDR3_BOT_DQS_P,   --       .mem_dqs
      mem_dqs_n               => DDR3_BOT_DQS_N,   --       .mem_dqs_n
      mem_odt                 => DDR3_BOT_ODT,
      phy_clk                 => inst19_phy_clk,    
      oct_rzqin               => OCT_RZQIN0        --    oct.rzqin
      );    
      
  inst20_wfm_player_x2_top : entity work.wfm_player_x2_top
  generic map(
      dev_family                    => g_DEV_FAMILY,
      
      --External memory controller parameters
      mem_cntrl_rate                => 1, --1 - full rate, 2 - half rate
      mem_dq_width                  => 32,
      mem_dqs_width                 => 4,
      mem_addr_width                => 14,
      mem_ba_width                  => 3,
      mem_dm_width                  => 4,
      
      --Avalon 0 interface parameters
      avl_0_addr_width              => 26,
      avl_0_data_width              => 64,
      avl_0_burst_count_width       => 2,
      avl_0_be_width                => 8,
      avl_0_max_burst_count         => 2, -- only 2 is for now
      avl_0_rd_latency_words        => 64,
      avl_0_traffic_gen_buff_size   => 16,
      
      --Avalon 1 interface parameters
      avl_1_addr_width              => 26,
      avl_1_data_width              => 64,
      avl_1_burst_count_width       => 2,
      avl_1_be_width                => 8,
      avl_1_max_burst_count         => 2, -- only 2 is for now
      avl_1_rd_latency_words        => 64,
      avl_1_traffic_gen_buff_size   => 16,
      
      -- wfm 0 player parameters
      wfm_0_infifo_rdusedw_width    => c_H2F_S1_1_RDUSEDW_WIDTH,
      wfm_0_infifo_rdata_width      => c_H2F_S1_1_RWIDTH,      
      wfm_0_outfifo_wrusedw_width   => 9,
      
      -- wfm 1 player parameters
      wfm_1_infifo_rdusedw_width    => 11,
      wfm_1_infifo_rdata_width      => 64,      
      wfm_1_outfifo_wrusedw_width   => 10,
      
      wfm_0_iq_width                => 12,
      wfm_1_iq_width                => 14
           
   )
   port map(

      clk                     => CLK125_FPGA_TOP,    -- PLL reference clock
      reset_n                 => reset_n,
      from_fpgacfg_0          => inst0_from_fpgacfg_1,
      ----------------WFM port 0------------------
      --infifo 
      wfm_0_infifo_rdreq      => inst20_wfm_0_infifo_rdreq,
      wfm_0_infifo_rdata      => inst2_H2F_S1_1_rdata,
      wfm_0_infifo_rdempty    => inst2_H2F_S1_1_rempty,
      wfm_0_infifo_rdusedw    => inst2_H2F_S1_1_rdusedw,
      --outfifo   
      wfm_0_outfifo_reset_n   => inst20_wfm_0_outfifo_reset_n,
      wfm_0_outfifo_wrreq     => inst20_wfm_0_outfifo_wrreq,
      wfm_0_outfifo_data      => inst20_wfm_0_outfifo_data,
      wfm_0_outfifo_wrusedw   => inst8_tx_fifo_1_wrusedw,
      
      ----------------WFM port 1------------------
      from_fpgacfg_1          => inst0_from_fpgacfg_2,
      --infifo 
      wfm_1_infifo_rdreq      => inst20_wfm_1_infifo_rdreq,
      wfm_1_infifo_rdata      => (others=>'0'),
      wfm_1_infifo_rdempty    => '1',
      wfm_1_infifo_rdusedw    => (others=>'0'),
      --outfifo   
      wfm_1_outfifo_reset_n   => open,
      wfm_1_outfifo_wrreq     => open,
      wfm_1_outfifo_data      => open,
      wfm_1_outfifo_wrusedw   => (others=>'0'),

      ---------------------External memory signals
      mem_a                   => DDR3_TOP_A,       -- memory.mem_a
      mem_ba                  => DDR3_TOP_BA,      --       .mem_ba
      mem_ck                  => DDR3_TOP_CK_P,    --       .mem_ck
      mem_ck_n                => DDR3_TOP_CK_N,    --       .mem_ck_n
      mem_cke                 => DDR3_TOP_CKE,     --       .mem_cke
      mem_cs_n                => DDR3_TOP_CSn,     --       .mem_cs_n
      mem_dm                  => DDR3_TOP_DM,      --       .mem_dm
      mem_ras_n               => DDR3_TOP_RASn,    --       .mem_ras_n
      mem_cas_n               => DDR3_TOP_CASn,    --       .mem_cas_n
      mem_we_n                => DDR3_TOP_WEn,     --       .mem_we_n
      mem_reset_n             => DDR3_TOP_RESETn,  --       .mem_reset_n
      mem_dq                  => DDR3_TOP_DQ,      --       .mem_dq
      mem_dqs                 => DDR3_TOP_DQS_P,   --       .mem_dqs
      mem_dqs_n               => DDR3_TOP_DQS_N,   --       .mem_dqs_n
      mem_odt                 => DDR3_TOP_ODT,
      phy_clk                 => inst20_phy_clk,    
      oct_rzqin               => OCT_RZQIN1        --    oct.rzqin
      );
      
      
   inst21 : entity work.clock_div
   generic map(
      ndiv => 1000000
   )
   port map(

      clk      => clk100_FPGA,
      reset_n  => reset_n_clk100_fpga,
      divout   => inst21_10ms_toggle
   );
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
   
   FPGA_SPI0_MOSI    <= inst0_spi_0_MOSI;
   FPGA_SPI0_SCLK    <= inst0_spi_0_SCLK;
   FPGA_SPI0_LMS1_SS <= inst0_spi_0_SS_n(0);
   FPGA_SPI0_LMS2_SS <= inst0_spi_0_SS_n(1);
   
   inst0_OPNDRN : OPNDRN
	port map (a_in =>inst0_spi_0_SS_n(2), a_out => FPGA_SPI0_ADF_SS); 
   
   inst1_OPNDRN : OPNDRN
	port map (a_in =>inst0_spi_0_SS_n(8), a_out => FPGA_SPI0_DAC_SS);
   
   inst2_OPNDRN : OPNDRN
	port map (a_in => inst0_spi_0_SS_n(5), a_out => FPGA_SPI0_ADC_SS);
   
   --FPGA_AS_DCLK      <= '0';  -- inst0_spi_2_SCLK;
   --FPGA_AS_ASDO      <= '0';  -- inst0_spi_2_MOSI;
   --FPGA_AS_NCSO      <= '1';  -- inst0_spi_2_SS_n;
   
   inst3_OPNDRN : OPNDRN
	port map (a_in => inst0_gpo(0), a_out => FPGA_ADC_RESET);
   
   -- TRX1_TDD_SW (High = TX enbled, Low = RX Enabled)
   PMOD_A_PIN1 <= inst6_tx_ant_en                              when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(4)='0' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(8)='0' else 
                  inst0_from_periphcfg.PERIPH_OUTPUT_VAL_0(4)  when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(4)='1' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(8)='0' else 
                  inst21_10ms_toggle                           when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(4)='0' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(8)='1' else 
                  '0'; 
                  
   -- TRX2_TDD_SW (High = TX enbled, Low = RX Enabled)
   PMOD_A_PIN2 <= inst6_tx_ant_en                              when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(5)='0' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(9)='0' else  
                  inst0_from_periphcfg.PERIPH_OUTPUT_VAL_0(5)  when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(5)='1' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(9)='0' else  
                  inst21_10ms_toggle                           when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(5)='0' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(9)='1' else                
                  '0';
                  
   -- TRX1_TDD_SW (High = TX enbled, Low = RX Enabled)
   PMOD_A_PIN3 <= inst8_tx_ant_en                              when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(4)='0' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(8)='0' else 
                  inst0_from_periphcfg.PERIPH_OUTPUT_VAL_0(4)  when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(4)='1' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(8)='0' else
                  inst21_10ms_toggle                           when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(4)='0' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(8)='1' else
                  '0';
                  
                  
   -- TRX2_TDD_SW (High = TX enbled, Low = RX Enabled)
   PMOD_A_PIN4 <= inst8_tx_ant_en                              when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(5)='0' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(9)='0' else 
                  inst0_from_periphcfg.PERIPH_OUTPUT_VAL_0(5)  when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(5)='1' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(9)='0' else       
                  inst21_10ms_toggle                           when inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(5)='0' AND inst0_from_periphcfg.PERIPH_OUTPUT_OVRD_0(9)='1' else
                  '0';
                  
   PMOD_A_PIN7    <= '0'; 
   PMOD_A_PIN8    <= '0';
   PMOD_A_PIN9    <= '0';
   PMOD_A_PIN10   <= '0';

   -- added by B.J.	
	-- RF switch control
	-- selecting the DPD monitoring input
   -- one of trwo inputs is connected to Rx_W, Ch. A	
   inst_rf_sw0_OPNDRN : OPNDRN
	port map (a_in => rf_sw(0), a_out => RF_SW_V1);
	
	inst_rf_sw1_OPNDRN : OPNDRN
	port map (a_in => rf_sw(1), a_out => RF_SW_V2);
	
   inst_rf_sw2_OPNDRN : OPNDRN
	port map (a_in => rf_sw(2), a_out => RF_SW_V3);

end arch;   



