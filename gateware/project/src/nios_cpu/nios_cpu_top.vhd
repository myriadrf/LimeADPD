-- ----------------------------------------------------------------------------
-- FILE:          nios_cpu_top.vhd
-- DESCRIPTION:   NIOS CPU top level
-- DATE:          10:52 AM Friday, May 11, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
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

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity nios_cpu_top is
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
      clk                  : in     std_logic;
      reset_n              : in     std_logic;
      -- Control data FIFO
      exfifo_if_d          : in     std_logic_vector(31 downto 0);
      exfifo_if_rd         : out    std_logic;
      exfifo_if_rdempty    : in     std_logic;
      exfifo_of_d          : out    std_logic_vector(31 downto 0);
      exfifo_of_wr         : out    std_logic;
      exfifo_of_wrfull     : in     std_logic;
      exfifo_of_rst        : out    std_logic;
      -- SPI 0
      spi_0_MISO           : in     std_logic;
      spi_0_MOSI           : out    std_logic;
      spi_0_SCLK           : out    std_logic;
      spi_0_SS_n           : out    std_logic_vector(8 downto 0);
      -- SPI 1
      spi_1_MISO           : in     std_logic;
      spi_1_MOSI           : out    std_logic;
      spi_1_SCLK           : out    std_logic;
      spi_1_SS_n           : out    std_logic;
      -- SPI 2 
      spi_2_MISO           : in     std_logic;
      spi_2_MOSI           : out    std_logic;
      spi_2_SCLK           : out    std_logic;
      spi_2_SS_n           : out    std_logic; 
      -- I2C
      i2c_scl              : inout  std_logic;
      i2c_sda              : inout  std_logic;
      -- Genral purpose I/O
      gpi                  : in     std_logic_vector(7 downto 0);
      gpo                  : out    std_logic_vector(7 downto 0);
      -- LMS7002 control
      lms_ctr_gpio         : out    std_logic_vector(3 downto 0);
      -- VCTCXO tamer control
      vctcxo_tune_en       : in     std_logic;
      vctcxo_irq           : in     std_logic;
      -- PLL reconfiguration
      pll_rst              : out    std_logic_vector(31 downto 0);
      pll_rcfg_from_pll_0  : in     std_logic_vector(63 downto 0) := (others => '0');
      pll_rcfg_to_pll_0    : out    std_logic_vector(63 downto 0);
      pll_rcfg_from_pll_1  : in     std_logic_vector(63 downto 0) := (others => '0');
      pll_rcfg_to_pll_1    : out    std_logic_vector(63 downto 0);
      pll_rcfg_from_pll_2  : in     std_logic_vector(63 downto 0) := (others => '0');
      pll_rcfg_to_pll_2    : out    std_logic_vector(63 downto 0);
      pll_rcfg_from_pll_3  : in     std_logic_vector(63 downto 0) := (others => '0');
      pll_rcfg_to_pll_3    : out    std_logic_vector(63 downto 0);
      pll_rcfg_from_pll_4  : in     std_logic_vector(63 downto 0) := (others => '0');
      pll_rcfg_to_pll_4    : out    std_logic_vector(63 downto 0);
      pll_rcfg_from_pll_5  : in     std_logic_vector(63 downto 0) := (others => '0');
      pll_rcfg_to_pll_5    : out    std_logic_vector(63 downto 0);
      -- Avalon Slave port 0
      avmm_s0_address      : in     std_logic_vector(8 downto 0) := (others => 'X');  -- address
      avmm_s0_read         : in     std_logic                     := 'X';             -- read
      avmm_s0_readdata     : out    std_logic_vector(31 downto 0);                    -- readdata
      avmm_s0_write        : in     std_logic                     := 'X';             -- write
      avmm_s0_writedata    : in     std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
      avmm_s0_waitrequest  : out    std_logic;                                        -- waitrequest
      -- Avalon Slave port 1
      avmm_s1_address      : in     std_logic_vector(8 downto 0) := (others => 'X');  -- address
      avmm_s1_read         : in     std_logic                     := 'X';             -- read
      avmm_s1_readdata     : out    std_logic_vector(31 downto 0);                    -- readdata
      avmm_s1_write        : in     std_logic                     := 'X';             -- write
      avmm_s1_writedata    : in     std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
      avmm_s1_waitrequest  : out    std_logic;                                        -- waitrequest
      -- Avalon master
      avmm_m0_address      : out    std_logic_vector(7 downto 0);                     -- avmm_m0.address
      avmm_m0_read         : out    std_logic;                                        --       .read
      avmm_m0_waitrequest  : in     std_logic                     := '0';             --       .waitrequest
      avmm_m0_readdata     : in     std_logic_vector(7 downto 0)  := (others => '0'); --       .readdata
      avmm_m0_readdatavalid: in     std_logic                     := '0';             --       .readdatavalid
      avmm_m0_write        : out    std_logic;                                        --       .write
      avmm_m0_writedata    : out    std_logic_vector(7 downto 0);                     --       .writedata
      avmm_m0_clk_clk      : out    std_logic;                                        -- avm_m0_clk.clk
      avmm_m0_reset_reset  : out    std_logic;
      -- Configuration registers
      from_fpgacfg_0       : out    t_FROM_FPGACFG;
      to_fpgacfg_0         : in     t_TO_FPGACFG;
      from_fpgacfg_1       : out    t_FROM_FPGACFG;
      to_fpgacfg_1         : in     t_TO_FPGACFG;
      from_fpgacfg_2       : out    t_FROM_FPGACFG;
      to_fpgacfg_2         : in     t_TO_FPGACFG;
      from_pllcfg          : out    t_FROM_PLLCFG;
      to_pllcfg            : in     t_TO_PLLCFG;
      from_tstcfg          : out    t_FROM_TSTCFG;
      to_tstcfg            : in     t_TO_TSTCFG;
      to_tstcfg_from_rxtx  : in     t_TO_TSTCFG_FROM_RXTX;
      to_txtspcfg_0        : in     t_TO_TXTSPCFG;
      from_txtspcfg_0      : out    t_FROM_TXTSPCFG;
      to_txtspcfg_1        : in     t_TO_TXTSPCFG;
      from_txtspcfg_1      : out    t_FROM_TXTSPCFG;
      to_rxtspcfg          : in     t_TO_RXTSPCFG;
      from_rxtspcfg        : out    t_FROM_RXTSPCFG;
      to_periphcfg         : in     t_TO_PERIPHCFG;
      from_periphcfg       : out    t_FROM_PERIPHCFG;
      to_tamercfg          : in     t_TO_TAMERCFG;
      from_tamercfg        : out    t_FROM_TAMERCFG;
      to_gnsscfg           : in     t_TO_GNSSCFG;
      from_gnsscfg         : out    t_FROM_GNSSCFG;
      to_memcfg            : in     t_TO_MEMCFG;
      from_memcfg          : out    t_FROM_MEMCFG
      

   );
end nios_cpu_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of nios_cpu_top is
--declare signals,  components here
   constant c_SPI_NR_FPGA           : integer := 6;

   signal to_pllcfg_int             : t_TO_PLLCFG;

   -- inst0
   signal inst0_fpga_spi0_MISO      : std_logic;
   signal inst0_dac_spi1_SS_n       : std_logic;
   signal inst0_dac_spi1_MOSI       : std_logic;
   signal inst0_dac_spi1_SCLK       : std_logic;
   signal inst0_fpga_spi0_MOSI      : std_logic;
   signal inst0_fpga_spi0_SCLK      : std_logic;
   signal inst0_fpga_spi0_SS_n      : std_logic_vector(7 downto 0);
   signal inst0_pllcfg_spi_MOSI     : std_logic;
   signal inst0_pllcfg_spi_SCLK     : std_logic;
   signal inst0_pllcfg_spi_SS_n     : std_logic;
   signal inst0_pllcfg_cmd_export   : std_logic_vector(3 downto 0);
   signal inst0_pllcfg_stat_export  : std_logic_vector(9 downto 0);
   signal inst0_spi_2_MISO          : std_logic;
   signal inst0_spi_2_MOSI          : std_logic;
   signal inst0_spi_2_SCLK          : std_logic;
   signal inst0_spi_2_SS_n          : std_logic;
   
   
   --inst1
   signal inst1_sdout            : std_logic;
   signal inst1_pllcfg_sdout     : std_logic;
   
   signal avmm_s0_address_int    : std_logic_vector(31 downto 0);
   signal avmm_s1_address_int    : std_logic_vector(31 downto 0);
   
   signal vctcxo_tune_en_sync    : std_logic;
   signal vctcxo_irq_sync        : std_logic;
   
   signal vctcxo_tamer_0_irq_out_irq   : std_logic;
   signal vctcxo_tamer_0_ctrl_export   : std_logic_vector(3 downto 0);
   
   component nios_cpu is
   port (
      clk_clk                                : in    std_logic                     := 'X';             -- clk
      dac_spi1_MISO                          : in    std_logic                     := 'X';             -- MISO
      dac_spi1_MOSI                          : out   std_logic;                                        -- MOSI
      dac_spi1_SCLK                          : out   std_logic;                                        -- SCLK
      dac_spi1_SS_n                          : out   std_logic;                                        -- SS_n
      exfifo_if_d_export                     : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
      exfifo_if_rd_export                    : out   std_logic;                                        -- export
      exfifo_if_rdempty_export               : in    std_logic                     := 'X';             -- export
      exfifo_of_d_export                     : out   std_logic_vector(31 downto 0);                    -- export
      exfifo_of_wr_export                    : out   std_logic;                                        -- export
      exfifo_of_wrfull_export                : in    std_logic                     := 'X';             -- export
      exfifo_rst_export                      : out   std_logic;                                        -- export
      fpga_spi0_MISO                         : in    std_logic                     := 'X';             -- MISO
      fpga_spi0_MOSI                         : out   std_logic;                                        -- MOSI
      fpga_spi0_SCLK                         : out   std_logic;                                        -- SCLK
      fpga_spi0_SS_n                         : out   std_logic_vector(7 downto 0);                     -- SS_n
      gpi0_export                            : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
      gpio0_export                           : out   std_logic_vector(7 downto 0);                     -- export
      pll_recfg_from_pll_0_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
      pll_recfg_from_pll_1_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
      pll_recfg_from_pll_2_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
      pll_recfg_from_pll_3_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
      pll_recfg_from_pll_4_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
      pll_recfg_from_pll_5_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
      pll_recfg_to_pll_0_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
      pll_recfg_to_pll_1_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
      pll_recfg_to_pll_2_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
      pll_recfg_to_pll_3_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
      pll_recfg_to_pll_4_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
      pll_recfg_to_pll_5_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
      pll_rst_export                         : out   std_logic_vector(31 downto 0);                    -- export
      pllcfg_cmd_export                      : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
      pllcfg_spi_MISO                        : in    std_logic                     := 'X';             -- MISO
      pllcfg_spi_MOSI                        : out   std_logic;                                        -- MOSI
      pllcfg_spi_SCLK                        : out   std_logic;                                        -- SCLK
      pllcfg_spi_SS_n                        : out   std_logic;                                        -- SS_n
      pllcfg_stat_export                     : out   std_logic_vector(9 downto 0);                     -- export
      scl_export                             : inout std_logic                     := 'X';             -- export
      sda_export                             : inout std_logic                     := 'X';              -- export
      avmm_s0_address                        : in    std_logic_vector(31 downto 0) := (others => 'X'); -- address
      avmm_s0_read                           : in    std_logic                     := 'X';             -- read
      avmm_s0_readdata                       : out   std_logic_vector(31 downto 0);                    -- readdata
      avmm_s0_write                          : in    std_logic                     := 'X';             -- write
      avmm_s0_writedata                      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
      avmm_s0_waitrequest                    : out   std_logic;                                        -- waitrequest
      avmm_s1_address                        : in    std_logic_vector(31 downto 0) := (others => 'X'); -- address
      avmm_s1_read                           : in    std_logic                     := 'X';             -- read
      avmm_s1_readdata                       : out   std_logic_vector(31 downto 0);                    -- readdata
      avmm_s1_write                          : in    std_logic                     := 'X';             -- write
      avmm_s1_writedata                      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
      avmm_s1_waitrequest                    : out   std_logic;                                        -- waitrequest
      vctcxo_tamer_0_ctrl_export             : in    std_logic_vector(3 downto 0)  := (others=>'0');   -- vctcxo_tamer_0_irq_in.export
      avmm_m0_address                        : out   std_logic_vector(7 downto 0);                     --                avm_m0.address
      avmm_m0_read                           : out   std_logic;                                        --                      .read
      avmm_m0_waitrequest                    : in    std_logic                     := '0';             --                      .waitrequest
      avmm_m0_readdata                       : in    std_logic_vector(7 downto 0)  := (others => '0'); --                      .readdata
      avmm_m0_readdatavalid                  : in    std_logic                     := '0';             --                      .readdatavalid
      avmm_m0_write                          : out   std_logic;                                        --                      .write
      avmm_m0_writedata                      : out   std_logic_vector(7 downto 0);                     --                      .writedata
      avmm_m0_clk_clk                        : out   std_logic;                                        --            avm_m0_clk.clk
      avmm_m0_reset_reset                    : out   std_logic;
      spi_2_MISO                             : in    std_logic                     := 'X';             -- MISO
      spi_2_MOSI                             : out   std_logic;                                        -- MOSI
      spi_2_SCLK                             : out   std_logic;                                        -- SCLK
      spi_2_SS_n                             : out   std_logic                                         -- SS_n  
   );
   end component nios_cpu;



begin
-- ----------------------------------------------------------------------------
-- Synchronization registers
-- ---------------------------------------------------------------------------- 
   sync_reg0 : entity work.sync_reg 
   port map(clk, '1', vctcxo_tune_en, vctcxo_tune_en_sync);
   
   sync_reg1 : entity work.sync_reg 
   port map(clk, '1', vctcxo_irq, vctcxo_irq_sync);
   
   
   -- byte oriented address is shifted to be word aligned
   avmm_s0_address_int <=  "00000000000000000000000" & 
                           avmm_s0_address(8) & 
                           avmm_s0_address(5 downto 0) & 
                           "00"; -- address range   0 - 1FF
   avmm_s1_address_int <=  "00000000000000000000001" & 
                           avmm_s1_address(8) & 
                           avmm_s1_address(5 downto 0) & 
                           "00"; -- address range 200 - 3FF
   
-- ----------------------------------------------------------------------------
-- NIOS instance
-- ----------------------------------------------------------------------------
   
   inst0_nios_cpu : component nios_cpu
   port map (
      clk_clk                                => clk,
      dac_spi1_MISO                          => spi_0_MISO,
      dac_spi1_MOSI                          => inst0_dac_spi1_MOSI,
      dac_spi1_SCLK                          => inst0_dac_spi1_SCLK,
      dac_spi1_SS_n                          => inst0_dac_spi1_SS_n,
      exfifo_if_d_export                     => exfifo_if_d,
      exfifo_if_rd_export                    => exfifo_if_rd,
      exfifo_if_rdempty_export               => exfifo_if_rdempty,
      exfifo_of_d_export                     => exfifo_of_d,
      exfifo_of_wr_export                    => exfifo_of_wr,
      exfifo_of_wrfull_export                => exfifo_of_wrfull,
      exfifo_rst_export                      => exfifo_of_rst,
      fpga_spi0_MISO                         => spi_0_MISO OR inst1_sdout,
      fpga_spi0_MOSI                         => inst0_fpga_spi0_MOSI,
      fpga_spi0_SCLK                         => inst0_fpga_spi0_SCLK,
      fpga_spi0_SS_n                         => inst0_fpga_spi0_SS_n,
      gpi0_export                            => gpi,
      gpio0_export                           => gpo,
      pll_recfg_from_pll_0_reconfig_from_pll => pll_rcfg_from_pll_0,
      pll_recfg_to_pll_0_reconfig_to_pll     => pll_rcfg_to_pll_0,
      pll_recfg_from_pll_1_reconfig_from_pll => pll_rcfg_from_pll_1,
      pll_recfg_to_pll_1_reconfig_to_pll     => pll_rcfg_to_pll_1,
      pll_recfg_from_pll_2_reconfig_from_pll => pll_rcfg_from_pll_2,
      pll_recfg_to_pll_2_reconfig_to_pll     => pll_rcfg_to_pll_2,
      pll_recfg_from_pll_3_reconfig_from_pll => pll_rcfg_from_pll_3,
      pll_recfg_to_pll_3_reconfig_to_pll     => pll_rcfg_to_pll_3,
      pll_recfg_from_pll_4_reconfig_from_pll => pll_rcfg_from_pll_4,
      pll_recfg_to_pll_4_reconfig_to_pll     => pll_rcfg_to_pll_4,
      pll_recfg_from_pll_5_reconfig_from_pll => pll_rcfg_from_pll_5,
      pll_recfg_to_pll_5_reconfig_to_pll     => pll_rcfg_to_pll_5,
      pll_rst_export                         => pll_rst,
      pllcfg_cmd_export                      => inst0_pllcfg_cmd_export,
      pllcfg_stat_export                     => inst0_pllcfg_stat_export,
      pllcfg_spi_MISO                        => inst1_pllcfg_sdout,
      pllcfg_spi_MOSI                        => inst0_pllcfg_spi_MOSI,
      pllcfg_spi_SCLK                        => inst0_pllcfg_spi_SCLK, 
      pllcfg_spi_SS_n                        => inst0_pllcfg_spi_SS_n,
      scl_export                             => i2c_scl,
      sda_export                             => i2c_sda,
      avmm_s0_address                        => avmm_s0_address_int,    
      avmm_s0_read                           => avmm_s0_read,       
      avmm_s0_readdata                       => avmm_s0_readdata,   
      avmm_s0_write                          => avmm_s0_write,      
      avmm_s0_writedata                      => avmm_s0_writedata,  
      avmm_s0_waitrequest                    => avmm_s0_waitrequest,
      avmm_s1_address                        => avmm_s1_address_int,    
      avmm_s1_read                           => avmm_s1_read,       
      avmm_s1_readdata                       => avmm_s1_readdata,   
      avmm_s1_write                          => avmm_s1_write,      
      avmm_s1_writedata                      => avmm_s1_writedata,  
      avmm_s1_waitrequest                    => avmm_s1_waitrequest,
      vctcxo_tamer_0_ctrl_export             => vctcxo_tamer_0_ctrl_export,
      avmm_m0_address                        => avmm_m0_address,
      avmm_m0_read                           => avmm_m0_read,
      avmm_m0_waitrequest                    => avmm_m0_waitrequest,
      avmm_m0_readdata                       => avmm_m0_readdata,
      avmm_m0_readdatavalid                  => avmm_m0_readdatavalid,
      avmm_m0_write                          => avmm_m0_write,
      avmm_m0_writedata                      => avmm_m0_writedata,
      avmm_m0_clk_clk                        => avmm_m0_clk_clk,
      avmm_m0_reset_reset                    => avmm_m0_reset_reset,
      spi_2_MISO                             => spi_0_MISO,
      spi_2_MOSI                             => inst0_spi_2_MOSI,
      spi_2_SCLK                             => inst0_spi_2_SCLK,
      spi_2_SS_n                             => inst0_spi_2_SS_n
   );
   
   inst0_pllcfg_cmd_export <= from_pllcfg.phcfg_mode & from_pllcfg.pllrst_start & 
                              from_pllcfg.phcfg_start & from_pllcfg.pllcfg_start;
                              
   process(to_pllcfg, inst0_pllcfg_stat_export)
   begin 
      to_pllcfg_int <= to_pllcfg;
      to_pllcfg_int.pllcfg_done  <= inst0_pllcfg_stat_export(0);
      to_pllcfg_int.pllcfg_busy  <= inst0_pllcfg_stat_export(1);
      to_pllcfg_int.pllcfg_err   <= inst0_pllcfg_stat_export(9 downto 2);
   end process;
   
-- ----------------------------------------------------------------------------
-- cfg_top instance
-- ----------------------------------------------------------------------------    
   cfg_top_inst1 : entity work.cfg_top
   generic map (
      FPGACFG_START_ADDR   => FPGACFG_START_ADDR,
      PLLCFG_START_ADDR    => PLLCFG_START_ADDR,
      TSTCFG_START_ADDR    => TSTCFG_START_ADDR,
      TXTSPCFG_START_ADDR  => TXTSPCFG_START_ADDR,
      RXTSPCFG_START_ADDR  => RXTSPCFG_START_ADDR,
      PERIPHCFG_START_ADDR => PERIPHCFG_START_ADDR,
      TAMERCFG_START_ADDR  => TAMERCFG_START_ADDR,
      GNSSCFG_START_ADDR   => GNSSCFG_START_ADDR
      )
   port map(
      -- Serial port IOs
      sdin                 => inst0_fpga_spi0_MOSI,
      sclk                 => inst0_fpga_spi0_SCLK,
      sen                  => inst0_fpga_spi0_SS_n(c_SPI_NR_FPGA),
      sdout                => inst1_sdout, 
      pllcfg_sdin          => inst0_pllcfg_spi_MOSI,
      pllcfg_sclk          => inst0_pllcfg_spi_SCLK,
      pllcfg_sen           => inst0_pllcfg_spi_SS_n,
      pllcfg_sdout         => inst1_pllcfg_sdout, 
      -- Signals coming from the pins or top level serial interface
      lreset               => reset_n,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset               => reset_n,   -- Memory reset signal, resets configuration memory only (use only one reset)          
      to_fpgacfg_0         => to_fpgacfg_0,
      from_fpgacfg_0       => from_fpgacfg_0,
      to_fpgacfg_1         => to_fpgacfg_1,
      from_fpgacfg_1       => from_fpgacfg_1,
      to_fpgacfg_2         => to_fpgacfg_2,
      from_fpgacfg_2       => from_fpgacfg_2,
      to_pllcfg            => to_pllcfg_int,
      from_pllcfg          => from_pllcfg,
      to_tstcfg            => to_tstcfg,
      from_tstcfg          => from_tstcfg,
      to_tstcfg_from_rxtx  => to_tstcfg_from_rxtx,
      to_txtspcfg_0        => to_txtspcfg_0,
      from_txtspcfg_0      => from_txtspcfg_0,
      to_txtspcfg_1        => to_txtspcfg_1,
      from_txtspcfg_1      => from_txtspcfg_1,
      to_rxtspcfg          => to_rxtspcfg,
      from_rxtspcfg        => from_rxtspcfg,
      to_periphcfg         => to_periphcfg,
      from_periphcfg       => from_periphcfg,
      to_tamercfg          => to_tamercfg,
      from_tamercfg        => from_tamercfg,
      to_gnsscfg           => to_gnsscfg,
      from_gnsscfg         => from_gnsscfg,
      to_memcfg            => to_memcfg,
      from_memcfg          => from_memcfg
   );
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ---------------------------------------------------------------------------- 
   spi_0_SS_n(4 downto 0)  <= inst0_fpga_spi0_SS_n(4 downto 0);
   spi_0_SS_n(5)           <= inst0_spi_2_SS_n;
   spi_0_SS_n(7 downto 6)  <= inst0_fpga_spi0_SS_n(7 downto 6);
   spi_0_SS_n(8)           <= inst0_dac_spi1_SS_n;
   
   -- SPI MUX
--   spi_0_MOSI <= inst0_fpga_spi0_MOSI when inst0_dac_spi1_SS_n = '1' else inst0_dac_spi1_MOSI;
--   spi_0_SCLK <= inst0_fpga_spi0_SCLK when inst0_dac_spi1_SS_n = '1' else inst0_dac_spi1_SCLK;
   
   spi_0_MOSI  <= inst0_dac_spi1_MOSI  when inst0_dac_spi1_SS_n = '0' else 
                  inst0_spi_2_MOSI     when inst0_spi_2_SS_n = '0' else 
                  inst0_fpga_spi0_MOSI;
                  
   spi_0_SCLK  <= inst0_dac_spi1_SCLK  when inst0_dac_spi1_SS_n = '0' else
                  inst0_spi_2_SCLK     when inst0_spi_2_SS_n = '0' else 
                  inst0_fpga_spi0_SCLK;
   
   vctcxo_tamer_0_ctrl_export(0) <= vctcxo_tune_en_sync;
   vctcxo_tamer_0_ctrl_export(1) <= vctcxo_irq_sync;
   vctcxo_tamer_0_ctrl_export(2) <= '0';
   vctcxo_tamer_0_ctrl_export(3) <= '0';
   
end arch;   

