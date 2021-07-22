-- ----------------------------------------------------------------------------
-- FILE:          pcie_top.vhd
-- DESCRIPTION:   Top module for PCIe connection
-- DATE:          11:11 AM Thursday, June 28, 2018
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
use work.FIFO_PACK.all;

LIBRARY altera_mf;
USE altera_mf.all;
-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pcie_top is
   generic(
      g_DEV_FAMILY               : string := "Cyclone V GX";
      g_S0_DATA_WIDTH            : integer := 32;
      g_S1_DATA_WIDTH            : integer := 32;
      g_S2_DATA_WIDTH            : integer := 32;
      g_C0_DATA_WIDTH            : integer := 8;
      -- Stream (Host->FPGA) 
      g_H2F_S0_0_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S0_0_RWIDTH          : integer := 32;
      g_H2F_S0_1_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S0_1_RWIDTH          : integer := 32;
      g_H2F_S1_0_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S1_0_RWIDTH          : integer := 32;
      g_H2F_S1_1_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S1_1_RWIDTH          : integer := 32;
      g_H2F_S2_0_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S2_0_RWIDTH          : integer := 32;
      g_H2F_S2_1_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S2_1_RWIDTH          : integer := 32;      
      -- Stream (FPGA->Host)
      g_F2H_S0_WRUSEDW_WIDTH     : integer := 10;
      g_F2H_S0_WWIDTH            : integer := 64;
      g_F2H_S1_WRUSEDW_WIDTH     : integer := 10;
      g_F2H_S1_WWIDTH            : integer := 64;
      g_F2H_S2_WRUSEDW_WIDTH     : integer := 10;
      g_F2H_S2_WWIDTH            : integer := 64;
      -- Control (Host->FPGA)
      g_H2F_C0_RDUSEDW_WIDTH     : integer := 11;
      g_H2F_C0_RWIDTH            : integer := 8;
      -- Control (FPGA->Host)
      g_F2H_C0_WRUSEDW_WIDTH     : integer := 11;
      g_F2H_C0_WWIDTH            : integer := 8
      
   );
   port (
      clk                  : in  std_logic;   -- Input clock for PLL; B.J.
      reset_n              : in  std_logic;
      --PCIE external pins
      pcie_perstn          : in  std_logic;
      pcie_refclk          : in  std_logic;
      pcie_rx              : in  std_logic_vector(3 downto 0);
      pcie_tx              : out std_logic_vector(3 downto 0);
      pcie_bus_clk         : out std_logic;  -- PCIe data clock output
      -- FIFO buffers
      H2F_S0_sel           : in std_logic;   -- 0 - S0_0, 1 - S0_1
      H2F_S1_sel           : in std_logic;   -- 0 - S1_0, 1 - S1_1
      H2F_S2_sel           : in std_logic;   -- 0 - S2_0, 1 - S2_1
      --Stream 0 endpoint FIFO 0 (Host->FPGA) 
      H2F_S0_0_rdclk       : in std_logic;
      H2F_S0_0_aclrn       : in std_logic;
      H2F_S0_0_rd          : in std_logic;
      H2F_S0_0_rdata       : out std_logic_vector(g_H2F_S0_0_RWIDTH-1 downto 0);
      H2F_S0_0_rempty      : out std_logic;
      H2F_S0_0_rdusedw     : out std_logic_vector(g_H2F_S0_0_RDUSEDW_WIDTH-1 downto 0);
      --Stream 0 endpoint FIFO 1 (Host->FPGA) 
      H2F_S0_1_rdclk       : in std_logic;
      H2F_S0_1_aclrn       : in std_logic;
      H2F_S0_1_rd          : in std_logic;
      H2F_S0_1_rdata       : out std_logic_vector(g_H2F_S0_1_RWIDTH-1 downto 0);
      H2F_S0_1_rempty      : out std_logic;
      H2F_S0_1_rdusedw     : out std_logic_vector(g_H2F_S0_1_RDUSEDW_WIDTH-1 downto 0);
      --Stream 1 endpoint FIFO 0 (Host->FPGA) 
      H2F_S1_0_rdclk       : in std_logic;
      H2F_S1_0_aclrn       : in std_logic;
      H2F_S1_0_rd          : in std_logic;
      H2F_S1_0_rdata       : out std_logic_vector(g_H2F_S1_0_RWIDTH-1 downto 0);
      H2F_S1_0_rempty      : out std_logic;
      H2F_S1_0_rdusedw     : out std_logic_vector(g_H2F_S1_0_RDUSEDW_WIDTH-1 downto 0);
      --Stream 1 endpoint FIFO 1 (Host->FPGA) 
      H2F_S1_1_rdclk       : in std_logic;
      H2F_S1_1_aclrn       : in std_logic;
      H2F_S1_1_rd          : in std_logic;
      H2F_S1_1_rdata       : out std_logic_vector(g_H2F_S1_1_RWIDTH-1 downto 0);
      H2F_S1_1_rempty      : out std_logic;
      H2F_S1_1_rdusedw     : out std_logic_vector(g_H2F_S1_1_RDUSEDW_WIDTH-1 downto 0);
      --Stream 2 endpoint FIFO 0 (Host->FPGA) 
      H2F_S2_0_rdclk       : in std_logic;
      H2F_S2_0_aclrn       : in std_logic;
      H2F_S2_0_rd          : in std_logic;
      H2F_S2_0_rdata       : out std_logic_vector(g_H2F_S2_0_RWIDTH-1 downto 0);
      H2F_S2_0_rempty      : out std_logic;
      H2F_S2_0_rdusedw     : out std_logic_vector(g_H2F_S2_0_RDUSEDW_WIDTH-1 downto 0);
      --Stream 2 endpoint FIFO 1 (Host->FPGA) 
      H2F_S2_1_rdclk       : in std_logic;
      H2F_S2_1_aclrn       : in std_logic;
      H2F_S2_1_rd          : in std_logic;
      H2F_S2_1_rdata       : out std_logic_vector(g_H2F_S2_1_RWIDTH-1 downto 0);
      H2F_S2_1_rempty      : out std_logic;
      H2F_S2_1_rdusedw     : out std_logic_vector(g_H2F_S2_1_RDUSEDW_WIDTH-1 downto 0);
      --Stream 0 endpoint FIFO (FPGA->Host)
      F2H_S0_wclk          : in std_logic;
      F2H_S0_aclrn         : in std_logic;
      F2H_S0_wr            : in std_logic;
      F2H_S0_wdata         : in std_logic_vector(g_F2H_S0_WWIDTH-1 downto 0);
      F2H_S0_wfull         : out std_logic;
      F2H_S0_wrusedw       : out std_logic_vector(g_F2H_S0_WRUSEDW_WIDTH-1 downto 0);
      --Stream 1 endpoint FIFO (FPGA->Host)
      F2H_S1_wclk          : in std_logic;
      F2H_S1_aclrn         : in std_logic;
      F2H_S1_wr            : in std_logic;
      F2H_S1_wdata         : in std_logic_vector(g_F2H_S1_WWIDTH-1 downto 0);
      F2H_S1_wfull         : out std_logic;
      F2H_S1_wrusedw       : out std_logic_vector(g_F2H_S1_WRUSEDW_WIDTH-1 downto 0);      
      
      --Stream 2 endpoint FIFO (FPGA->Host)
      --    modified by B.J.
	   strm2_OUT_EXT_rdreq	: out std_logic;
		strm2_OUT_EXT_rdempty: in std_logic;
		strm2_OUT_EXT_q		: in std_logic_vector(31 downto 0);

      --F2H_S2_wclk          : in std_logic;
      --F2H_S2_aclrn         : in std_logic;
      --F2H_S2_wr            : in std_logic;
      --F2H_S2_wdata         : in std_logic_vector(g_F2H_S2_WWIDTH-1 downto 0);
      --F2H_S2_wfull         : out std_logic;
      --F2H_S2_wrusedw       : out std_logic_vector(g_F2H_S2_WRUSEDW_WIDTH-1 downto 0);

      --Control endpoint FIFO (Host->FPGA)
      H2F_C0_rdclk         : in std_logic;
      H2F_C0_aclrn         : in std_logic;
      H2F_C0_rd            : in std_logic;
      H2F_C0_rdata         : out std_logic_vector(g_H2F_C0_RWIDTH-1 downto 0);
      H2F_C0_rempty        : out std_logic;
      --Control endpoint FIFO (FPGA->Host)
      F2H_C0_wclk          : in std_logic;
      F2H_C0_aclrn         : in std_logic;
      F2H_C0_wr            : in std_logic;
      F2H_C0_wdata         : in std_logic_vector(g_F2H_C0_WWIDTH-1 downto 0);
      F2H_C0_wfull         : out std_logic;
      
      S0_rx_en             : in std_logic;
      S1_rx_en             : in std_logic;
      S2_rx_en             : in std_logic;
      
      F2H_S0_open          : out std_logic;
      F2H_S1_open          : out std_logic;
      F2H_S2_open          : out std_logic;
      H2F_S0_open          : out std_logic;
      H2F_S1_open          : out std_logic;
      H2F_S2_open          : out std_logic
      
   );
end pcie_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pcie_top is
--declare signals,  components here
   -- Module constants
   constant c_H2F_S0_0_WRUSEDW_WIDTH   : integer := FIFOWR_SIZE (g_S0_DATA_WIDTH, g_H2F_S0_0_RWIDTH, g_H2F_S0_0_RDUSEDW_WIDTH);
   constant c_H2F_S0_0_RDUSEDW_WIDTH   : integer := g_H2F_S0_0_RDUSEDW_WIDTH; 
   constant c_H2F_S0_1_WRUSEDW_WIDTH   : integer := FIFOWR_SIZE (g_S0_DATA_WIDTH, g_H2F_S0_1_RWIDTH, g_H2F_S0_1_RDUSEDW_WIDTH);
   constant c_H2F_S0_1_RDUSEDW_WIDTH   : integer := g_H2F_S0_1_RDUSEDW_WIDTH;
  
   constant c_H2F_S1_0_WRUSEDW_WIDTH   : integer := FIFOWR_SIZE (g_S1_DATA_WIDTH, g_H2F_S1_0_RWIDTH, g_H2F_S1_0_RDUSEDW_WIDTH);
   constant c_H2F_S1_0_RDUSEDW_WIDTH   : integer := g_H2F_S1_0_RDUSEDW_WIDTH; 
   constant c_H2F_S1_1_WRUSEDW_WIDTH   : integer := FIFOWR_SIZE (g_S1_DATA_WIDTH, g_H2F_S1_1_RWIDTH, g_H2F_S1_1_RDUSEDW_WIDTH);
   constant c_H2F_S1_1_RDUSEDW_WIDTH   : integer := g_H2F_S1_1_RDUSEDW_WIDTH;
  
   constant c_H2F_S2_0_WRUSEDW_WIDTH   : integer := FIFOWR_SIZE (g_S2_DATA_WIDTH, g_H2F_S2_0_RWIDTH, g_H2F_S2_0_RDUSEDW_WIDTH);
   constant c_H2F_S2_0_RDUSEDW_WIDTH   : integer := g_H2F_S2_0_RDUSEDW_WIDTH; 
   constant c_H2F_S2_1_WRUSEDW_WIDTH   : integer := FIFOWR_SIZE (g_S2_DATA_WIDTH, g_H2F_S2_1_RWIDTH, g_H2F_S2_1_RDUSEDW_WIDTH);
   constant c_H2F_S2_1_RDUSEDW_WIDTH   : integer := g_H2F_S2_1_RDUSEDW_WIDTH; 

   constant c_H2F_C0_WRUSEDW_WIDTH     : integer := FIFOWR_SIZE (g_C0_DATA_WIDTH, g_H2F_C0_RWIDTH, g_H2F_C0_RDUSEDW_WIDTH);
   constant c_H2F_C0_RDUSEDW_WIDTH     : integer := g_H2F_C0_RDUSEDW_WIDTH; 
   
   constant c_F2H_S0_WRUSEDW_WIDTH     : integer := g_F2H_S0_WRUSEDW_WIDTH;
   constant c_F2H_S0_RDUSEDW_WIDTH     : integer := FIFORD_SIZE (g_F2H_S0_WWIDTH, g_S0_DATA_WIDTH, g_F2H_S0_WRUSEDW_WIDTH); 
   constant c_F2H_S1_WRUSEDW_WIDTH     : integer := g_F2H_S1_WRUSEDW_WIDTH;
   constant c_F2H_S1_RDUSEDW_WIDTH     : integer := FIFORD_SIZE (g_F2H_S1_WWIDTH, g_S1_DATA_WIDTH, g_F2H_S1_WRUSEDW_WIDTH);
   constant c_F2H_S2_WRUSEDW_WIDTH     : integer := g_F2H_S2_WRUSEDW_WIDTH;
   constant c_F2H_S2_RDUSEDW_WIDTH     : integer := FIFORD_SIZE (g_F2H_S2_WWIDTH, g_S2_DATA_WIDTH, g_F2H_S2_WRUSEDW_WIDTH);
   
   constant c_F2H_C0_WRUSEDW_WIDTH     : integer := g_F2H_C0_WRUSEDW_WIDTH;
   constant c_F2H_C0_RDUSEDW_WIDTH     : integer := FIFORD_SIZE (g_F2H_C0_WWIDTH, g_C0_DATA_WIDTH, g_F2H_C0_WRUSEDW_WIDTH);
  
   signal H2F_S0_sel_sync              : std_logic;
   signal H2F_S1_sel_sync              : std_logic;
   signal H2F_S2_sel_sync              : std_logic;
   
   signal S0_rx_en_sync                : std_logic;
   signal S1_rx_en_sync                : std_logic;
   signal S2_rx_en_sync                : std_logic;
   
   signal H2F_S0_0_sclrn               : std_logic;
   signal H2F_S0_1_sclrn               : std_logic;
   signal H2F_S0_0_sclrn_reg           : std_logic;
   signal H2F_S0_1_sclrn_reg           : std_logic;
	signal H2F_S1_0_sclrn               : std_logic;
   signal H2F_S1_1_sclrn               : std_logic;
   signal H2F_S2_0_sclrn               : std_logic;
   signal H2F_S2_1_sclrn               : std_logic;

   type demo_mem is array(0 TO 31) of std_logic_vector(7 DOWNTO 0);
   signal demoarray : demo_mem;
   
   signal bus_clk :  std_logic;
   signal quiesce : std_logic;
   
   signal control0_reset_32 : std_logic;
   signal stream0_reset_32 : std_logic;
   signal stream1_reset_32 : std_logic;
   
   signal ram_addr : integer range 0 to 31;
   
   -- inst1
   signal inst1_user_r_control0_read_32_rden    :  std_logic;
   signal inst1_user_r_control0_read_32_empty   :  std_logic;
   signal inst1_user_r_control0_read_32_data    :  std_logic_vector(g_C0_DATA_WIDTH-1 DOWNTO 0);
   signal inst1_user_r_control0_read_32_eof     :  std_logic;
   signal inst1_user_r_control0_read_32_open    :  std_logic;
   signal inst1_user_w_control0_write_32_wren   :  std_logic;
   signal inst1_user_w_control0_write_32_full   :  std_logic;
   signal inst1_user_w_control0_write_32_data   :  std_logic_vector(g_C0_DATA_WIDTH-1 DOWNTO 0);
   signal inst1_user_w_control0_write_32_open   :  std_logic;
   signal inst1_user_r_mem_8_rden               :  std_logic;
   signal inst1_user_r_mem_8_empty              :  std_logic;
   signal inst1_user_r_mem_8_data               :  std_logic_vector(7 DOWNTO 0);
   signal inst1_user_r_mem_8_eof                :  std_logic;
   signal inst1_user_r_mem_8_open               :  std_logic;
   signal inst1_user_w_mem_8_wren               :  std_logic;
   signal inst1_user_w_mem_8_full               :  std_logic;
   signal inst1_user_w_mem_8_data               :  std_logic_vector(7 DOWNTO 0);
   signal inst1_user_w_mem_8_open               :  std_logic;
   signal inst1_user_mem_8_addr                 :  std_logic_vector(4 DOWNTO 0);
   signal inst1_user_mem_8_addr_update          :  std_logic;
   signal inst1_user_r_stream0_read_32_rden     :  std_logic;
   signal inst1_user_r_stream0_read_32_empty    :  std_logic;
   signal inst1_user_r_stream0_read_32_data     :  std_logic_vector(31 DOWNTO 0);
   signal inst1_user_r_stream0_read_32_eof      :  std_logic;
   signal inst1_user_r_stream0_read_32_open     :  std_logic;
   signal inst1_user_w_stream0_write_32_wren    :  std_logic;
   signal inst1_user_w_stream0_write_32_full    :  std_logic;
   signal inst1_user_w_stream0_write_32_data    :  std_logic_vector(31 DOWNTO 0);
   signal inst1_user_w_stream0_write_32_open    :  std_logic;
   signal inst1_user_w_stream0_write_32_open_r  :  std_logic;
   signal inst1_user_r_stream1_read_32_rden     :  std_logic;
   signal inst1_user_r_stream1_read_32_empty    :  std_logic;
   signal inst1_user_r_stream1_read_32_data     :  std_logic_vector(31 DOWNTO 0);
   signal inst1_user_r_stream1_read_32_eof      :  std_logic;
   signal inst1_user_r_stream1_read_32_open     :  std_logic;
   signal inst1_user_w_stream1_write_32_wren    :  std_logic;
   signal inst1_user_w_stream1_write_32_full    :  std_logic;
   signal inst1_user_w_stream1_write_32_data    :  std_logic_vector(31 DOWNTO 0);
   signal inst1_user_w_stream1_write_32_open    :  std_logic;  
   signal inst1_user_r_stream2_read_32_rden     :  std_logic;
   signal inst1_user_r_stream2_read_32_empty    :  std_logic;
   signal inst1_user_r_stream2_read_32_data     :  std_logic_vector(31 DOWNTO 0);
   signal inst1_user_r_stream2_read_32_eof      :  std_logic;
   signal inst1_user_r_stream2_read_32_open     :  std_logic;
   signal inst1_user_w_stream2_write_32_wren    :  std_logic;
   signal inst1_user_w_stream2_write_32_full    :  std_logic;
   signal inst1_user_w_stream2_write_32_data    :  std_logic_vector(31 DOWNTO 0);
   signal inst1_user_w_stream2_write_32_open    :  std_logic;    
   signal inst1_user_led                        : std_logic_vector(3 downto 0);
  
   --inst2
   signal inst2_reset_n          : std_logic;
   signal inst2_wrreq            : std_logic;
   signal inst2_wrfull           : std_logic;
 
   --inst3
   signal inst3_reset_n          : std_logic;
   signal inst3_pct_wr           : std_logic;
   signal inst3_pct_payload_data : std_logic_vector(g_S0_DATA_WIDTH-1 downto 0);
   signal inst3_pct_payload_valid: std_logic;
   --inst4
   signal inst4_reset_n          : std_logic;
   signal inst4_wrreq            : std_logic;
   signal inst4_wrfull           : std_logic;
   
   --inst5
   signal inst5_reset_n          : std_logic;
   signal inst5_wrreq            : std_logic;
   signal inst5_wrfull           : std_logic;
 
   --inst6
   signal inst6_reset_n          : std_logic;
   signal inst6_pct_wr           : std_logic;
   signal inst6_pct_payload_data : std_logic_vector(g_S1_DATA_WIDTH-1 downto 0);
   signal inst6_pct_payload_valid: std_logic;
   --inst7
   signal inst7_reset_n          : std_logic;
   signal inst7_wrreq            : std_logic;
   signal inst7_wrfull           : std_logic;
   
   --inst8
   signal inst8_reset_n          : std_logic;
   signal inst8_wrreq            : std_logic;
   signal inst8_wrfull           : std_logic;
 
   --inst9
   signal inst9_reset_n          : std_logic;
   signal inst9_pct_wr           : std_logic;
   signal inst9_pct_payload_data : std_logic_vector(g_S2_DATA_WIDTH-1 downto 0);
   signal inst9_pct_payload_valid: std_logic;
   --inst10
   signal inst10_reset_n         : std_logic;
   signal inst10_wrreq           : std_logic;
   signal inst10_wrfull          : std_logic;
   
   --inst11
   signal inst11_reset_n         : std_logic;
   signal inst11_wrfull          : std_logic;
   
   --inst12
   signal inst12_reset_n          : std_logic;
   signal inst12_rdempty          : std_logic;
   signal inst12_q                : std_logic_vector(g_S0_DATA_WIDTH-1 downto 0);

   --inst13
   signal inst13_reset_n          : std_logic;
   signal inst13_rdempty          : std_logic;
   signal inst13_q                : std_logic_vector(g_S1_DATA_WIDTH-1 downto 0);  
   
   --inst14
   signal inst14_reset_n          : std_logic;
   signal inst14_rdempty          : std_logic;
   signal inst14_q                : std_logic_vector(g_S2_DATA_WIDTH-1 downto 0);
   
   --inst15
   signal inst15_reset_n          : std_logic;
   signal inst15_rdempty          : std_logic;
   signal inst15_q                : std_logic_vector(g_C0_DATA_WIDTH-1 downto 0);
   
  component xillybus
    port (
      pcie_perstn                   : IN std_logic;
      --clk100                        : IN std_logic;  B.J.
      pcie_refclk                   : IN std_logic;
      pcie_rx                       : IN std_logic_vector(3 DOWNTO 0);
      bus_clk                       : OUT std_logic;
      pcie_tx                       : OUT std_logic_vector(3 DOWNTO 0);
      quiesce                       : OUT std_logic;
      user_led                      : OUT std_logic_vector(3 DOWNTO 0);
      user_r_control0_read_32_rden  : OUT std_logic;
      user_r_control0_read_32_empty : IN std_logic;
      user_r_control0_read_32_data  : IN std_logic_vector(31 DOWNTO 0);
      user_r_control0_read_32_eof   : IN std_logic;
      user_r_control0_read_32_open  : OUT std_logic;
      user_w_control0_write_32_wren : OUT std_logic;
      user_w_control0_write_32_full : IN std_logic;
      user_w_control0_write_32_data : OUT std_logic_vector(31 DOWNTO 0);
      user_w_control0_write_32_open : OUT std_logic;
      user_r_mem_8_rden             : OUT std_logic;
      user_r_mem_8_empty            : IN std_logic;
      user_r_mem_8_data             : IN std_logic_vector(7 DOWNTO 0);
      user_r_mem_8_eof              : IN std_logic;
      user_r_mem_8_open             : OUT std_logic;
      user_w_mem_8_wren             : OUT std_logic;
      user_w_mem_8_full             : IN std_logic;
      user_w_mem_8_data             : OUT std_logic_vector(7 DOWNTO 0);
      user_w_mem_8_open             : OUT std_logic;
      user_mem_8_addr               : OUT std_logic_vector(4 DOWNTO 0);
      user_mem_8_addr_update        : OUT std_logic;
      user_r_stream0_read_32_rden   : OUT std_logic;
      user_r_stream0_read_32_empty  : IN std_logic;
      user_r_stream0_read_32_data   : IN std_logic_vector(31 DOWNTO 0);
      user_r_stream0_read_32_eof    : IN std_logic;
      user_r_stream0_read_32_open   : OUT std_logic;
      user_w_stream0_write_32_wren  : OUT std_logic;
      user_w_stream0_write_32_full  : IN std_logic;
      user_w_stream0_write_32_data  : OUT std_logic_vector(31 DOWNTO 0);
      user_w_stream0_write_32_open  : OUT std_logic;
      user_r_stream1_read_32_rden   : OUT std_logic;
      user_r_stream1_read_32_empty  : IN std_logic;
      user_r_stream1_read_32_data   : IN std_logic_vector(31 DOWNTO 0);
      user_r_stream1_read_32_eof    : IN std_logic;
      user_r_stream1_read_32_open   : OUT std_logic;
      user_w_stream1_write_32_wren  : OUT std_logic;
      user_w_stream1_write_32_full  : IN std_logic;
      user_w_stream1_write_32_data  : OUT std_logic_vector(31 DOWNTO 0);
      user_w_stream1_write_32_open  : OUT std_logic;
      user_r_stream2_read_32_rden   : OUT std_logic;
      user_r_stream2_read_32_empty  : IN std_logic;
      user_r_stream2_read_32_data   : IN std_logic_vector(31 DOWNTO 0);
      user_r_stream2_read_32_eof    : IN std_logic;
      user_r_stream2_read_32_open   : OUT std_logic;
      user_w_stream2_write_32_wren  : OUT std_logic;
      user_w_stream2_write_32_full  : IN std_logic;
      user_w_stream2_write_32_data  : OUT std_logic_vector(31 DOWNTO 0);
      user_w_stream2_write_32_open  : OUT std_logic   
      );
  end component;

  -- modified by B.J.
  signal user_r_stream2_read_32_rden 		:  std_logic;
  signal user_r_stream2_read_32_empty 		:  std_logic;
  signal user_r_stream2_read_32_data 		:  std_logic_vector(31 DOWNTO 0);
  
begin
-- ----------------------------------------------------------------------------
-- Reset logic
-- ----------------------------------------------------------------------------  
   -- Reset signal with synchronous removal to clk clock domain, 
   sync_reg0 : entity work.sync_reg 
   port map(bus_clk, H2F_S0_0_aclrn, '1', H2F_S0_0_sclrn);
   
   sync_reg1 : entity work.sync_reg 
   port map(bus_clk, H2F_S0_1_aclrn, '1', H2F_S0_1_sclrn); 
   
   sync_reg2 : entity work.sync_reg 
   port map(bus_clk, H2F_S1_0_aclrn, '1', H2F_S1_0_sclrn);
   
   sync_reg3 : entity work.sync_reg 
   port map(bus_clk, H2F_S1_1_aclrn, '1', H2F_S1_1_sclrn);
   
   sync_reg4 : entity work.sync_reg 
   port map(bus_clk, H2F_S2_0_aclrn, '1', H2F_S2_0_sclrn);
   
   sync_reg5 : entity work.sync_reg 
   port map(bus_clk, H2F_S2_1_aclrn, '1', H2F_S2_1_sclrn);
     
-- ----------------------------------------------------------------------------
-- Sync registers
-- ----------------------------------------------------------------------------   
   sync_reg6 : entity work.sync_reg 
   port map(bus_clk, reset_n, H2F_S0_sel, H2F_S0_sel_sync);
   
   sync_reg7 : entity work.sync_reg 
   port map(bus_clk, reset_n, H2F_S1_sel, H2F_S1_sel_sync);
   
   sync_reg8 : entity work.sync_reg 
   port map(bus_clk, reset_n, H2F_S2_sel, H2F_S2_sel_sync);
     
   sync_reg9 : entity work.sync_reg 
   port map(bus_clk, '1', S0_rx_en, S0_rx_en_sync);
   
   sync_reg10 : entity work.sync_reg 
   port map(bus_clk, '1', S1_rx_en, S1_rx_en_sync);
   
   sync_reg11 : entity work.sync_reg 
   port map(bus_clk, '1', S2_rx_en, S2_rx_en_sync);

   -- added by B.J.
	strm2_OUT_EXT_rdreq				<= user_r_stream2_read_32_rden;   
   user_r_stream2_read_32_empty	<= strm2_OUT_EXT_rdempty;
   user_r_stream2_read_32_data	<= strm2_OUT_EXT_q;
   
-- ----------------------------------------------------------------------------
-- Xillybus instance
-- ----------------------------------------------------------------------------    
   inst1_xillybus : xillybus
   port map (
      -- Ports related to /dev/xillybus_control0_read_32
      -- FPGA to CPU signals:
      user_r_control0_read_32_rden     => inst1_user_r_control0_read_32_rden,
      user_r_control0_read_32_empty    => inst15_rdempty,
      user_r_control0_read_32_data     => inst15_q,
      user_r_control0_read_32_eof      => inst1_user_r_control0_read_32_eof,
      user_r_control0_read_32_open     => inst1_user_r_control0_read_32_open,
   
      -- Ports related to /dev/xillybus_control0_write_32
      -- CPU to FPGA signals:
      user_w_control0_write_32_wren    => inst1_user_w_control0_write_32_wren,
      user_w_control0_write_32_full    => inst11_wrfull,
      user_w_control0_write_32_data    => inst1_user_w_control0_write_32_data,
      user_w_control0_write_32_open    => inst1_user_w_control0_write_32_open,
   
      -- Ports related to /dev/xillybus_mem_8
      -- FPGA to CPU signals:
      user_r_mem_8_rden                => inst1_user_r_mem_8_rden,
      user_r_mem_8_empty               => inst1_user_r_mem_8_empty,
      user_r_mem_8_data                => inst1_user_r_mem_8_data,
      user_r_mem_8_eof                 => inst1_user_r_mem_8_eof,
      user_r_mem_8_open                => inst1_user_r_mem_8_open,
      -- CPU to FPGA signals:
      user_w_mem_8_wren                => inst1_user_w_mem_8_wren,
      user_w_mem_8_full                => inst1_user_w_mem_8_full,
      user_w_mem_8_data                => inst1_user_w_mem_8_data,
      user_w_mem_8_open                => inst1_user_w_mem_8_open,
      -- Address signals:
      user_mem_8_addr                  => inst1_user_mem_8_addr,
      user_mem_8_addr_update           => inst1_user_mem_8_addr_update,
   
      -- Ports related to /dev/xillybus_stream0_read_32
      -- FPGA to CPU signals:
      user_r_stream0_read_32_rden      => inst1_user_r_stream0_read_32_rden,
      user_r_stream0_read_32_empty     => inst12_rdempty,
      user_r_stream0_read_32_data      => inst12_q,
      user_r_stream0_read_32_eof       => inst1_user_r_stream0_read_32_eof,
      user_r_stream0_read_32_open      => inst1_user_r_stream0_read_32_open,
   
      -- Ports related to /dev/xillybus_stream0_write_32
      -- CPU to FPGA signals:
      user_w_stream0_write_32_wren     => inst1_user_w_stream0_write_32_wren,
      user_w_stream0_write_32_full     => inst1_user_w_stream0_write_32_full,
      user_w_stream0_write_32_data     => inst1_user_w_stream0_write_32_data,
      user_w_stream0_write_32_open     => inst1_user_w_stream0_write_32_open,
   
      -- Ports related to /dev/xillybus_stream1_read_32
      -- FPGA to CPU signals:
      user_r_stream1_read_32_rden      => inst1_user_r_stream1_read_32_rden,
      user_r_stream1_read_32_empty     => inst13_rdempty,
      user_r_stream1_read_32_data      => inst13_q,
      user_r_stream1_read_32_eof       => inst1_user_r_stream1_read_32_eof,
      user_r_stream1_read_32_open      => inst1_user_r_stream1_read_32_open,
   
      -- Ports related to /dev/xillybus_stream1_write_32
      -- CPU to FPGA signals:
      user_w_stream1_write_32_wren     => inst1_user_w_stream1_write_32_wren,
      user_w_stream1_write_32_full     => inst1_user_w_stream1_write_32_full,
      user_w_stream1_write_32_data     => inst1_user_w_stream1_write_32_data,
      user_w_stream1_write_32_open     => inst1_user_w_stream1_write_32_open,
      
      -- Ports related to /dev/xillybus_stream2_read_32
      -- FPGA to CPU signals:
   -- modified by B.J. 
   --   user_r_stream2_read_32_rden      => inst1_user_r_stream2_read_32_rden,
   --  user_r_stream2_read_32_empty     => inst14_rdempty,
   --  user_r_stream2_read_32_data      => inst14_q,
    user_r_stream2_read_32_rden 	   => user_r_stream2_read_32_rden,
    user_r_stream2_read_32_empty    => user_r_stream2_read_32_empty,
    user_r_stream2_read_32_data 	   => user_r_stream2_read_32_data,
    
      user_r_stream2_read_32_eof       => inst1_user_r_stream2_read_32_eof,
      user_r_stream2_read_32_open      => inst1_user_r_stream2_read_32_open,
   
      -- Ports related to /dev/xillybus_stream2_write_32
      -- CPU to FPGA signals:
      user_w_stream2_write_32_wren     => inst1_user_w_stream2_write_32_wren,
      user_w_stream2_write_32_full     => inst1_user_w_stream2_write_32_full,
      user_w_stream2_write_32_data     => inst1_user_w_stream2_write_32_data,
      user_w_stream2_write_32_open     => inst1_user_w_stream2_write_32_open,
   
      -- General signals
      pcie_perstn                      => pcie_perstn,
      pcie_refclk                      => pcie_refclk,
      -- clk100                           => clk, B.J.
      pcie_rx                          => pcie_rx,
      bus_clk                          => bus_clk,
      pcie_tx                          => pcie_tx,
      quiesce                          => quiesce,
      user_led                         => inst1_user_led
   );
   
   
   -- internal Xillybus registers
   proc_xillybus_regs : process(bus_clk, reset_n)
   begin
      if reset_n = '0' then 
         inst1_user_w_stream0_write_32_open_r <= '0';
      elsif (bus_clk'event AND bus_clk='1') then 
         inst1_user_w_stream0_write_32_open_r <= inst1_user_w_stream0_write_32_open;
      end if;
   end process;
   
   
   pcie_bus_clk<=bus_clk;
	
	inst1_user_w_stream0_write_32_full <= inst2_wrfull when H2F_S0_sel_sync = '0' else inst4_wrfull;
	inst1_user_w_stream1_write_32_full <= inst5_wrfull when H2F_S0_sel_sync = '0' else inst7_wrfull;
	inst1_user_w_stream2_write_32_full <= inst8_wrfull when H2F_S0_sel_sync = '0' else inst10_wrfull;
   
-- ----------------------------------------------------------------------------
--  A simple inferred RAM for Xillybus
-- ----------------------------------------------------------------------------
--  ram_addr <= to_integer(unsigned(user_mem_8_addr));
  
--  process (bus_clk)
--  begin
--    if (bus_clk'event and bus_clk = '1') then
--      if (user_w_mem_8_wren = '1') then 
--        demoarray(ram_addr) <= user_w_mem_8_data;
--      end if;
--      if (user_r_mem_8_rden = '1') then
--        user_r_mem_8_data <= demoarray(ram_addr);
--      end if;
--    end if;
--  end process;

  inst1_user_r_mem_8_empty <= '0';
  inst1_user_r_mem_8_eof   <= '0';
  inst1_user_w_mem_8_full  <= '0';		

-- ----------------------------------------------------------------------------
-- For Stream S0 endpoint, Host->FPGA
-- There are two FIFO buffers for this endpoint. Buffer is selected with H2F_S0_0_sel
-- ----------------------------------------------------------------------------
   inst2_reset_n  <= H2F_S0_0_sclrn;
   inst2_wrreq    <= inst1_user_w_stream0_write_32_wren when H2F_S0_sel_sync = '0' else '0';
 
   -- First FIFO, dedicated for TX stream
   inst2_H2F_S0_0_FIFO : entity work.two_fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_S0_DATA_WIDTH,
      wrusedw_witdth => 10,  
      rdwidth        => g_H2F_S0_0_RWIDTH,
      rdusedw_width  => c_H2F_S0_0_RDUSEDW_WIDTH,
      show_ahead     => "OFF",
      TRNSF_SIZE     => 512, 
      TRNSF_N        => 8
   )
   port map(
      --input ports 
      reset_0_n   => inst1_user_w_stream0_write_32_open,
      reset_1_n   => inst2_reset_n,
      wrclk       => bus_clk,
      wrreq       => inst2_wrreq,
      data        => inst1_user_w_stream0_write_32_data,
      wrfull      => inst2_wrfull,
      wrempty     => open,
      wrusedw     => open,
      rdclk       => H2F_S0_0_rdclk,
      rdreq       => H2F_S0_0_rd,
      q           => H2F_S0_0_rdata,
      rdempty     => H2F_S0_0_rempty,
      rdusedw     => H2F_S0_0_rdusedw   
   );
   
   --For Stream endpoint, Host->FPGA
   proc_inst3_reset : process(bus_clk, reset_n)
   begin
      if reset_n = '0' then 
         inst3_reset_n <= '0';
      elsif (bus_clk'event AND bus_clk='1') then 
         if inst1_user_w_stream0_write_32_open_r = '0' AND 
            inst1_user_w_stream0_write_32_open = '1' then 
            inst3_reset_n <= '0';
         else
            inst3_reset_n <= '1';
         end if;
      end if;
   end process;
    
   inst3_pct_wr   <= inst1_user_w_stream0_write_32_wren when H2F_S0_sel_sync = '1' else '0'; 
   
   -- This module takes only IQ data from packet, and discards packet header
   pct_payload_extrct_inst3 : entity work.pct_payload_extrct
   generic map(
      data_w         => g_S0_DATA_WIDTH,
      header_size    => 16, 
      pct_size       => 4096
   ) 
   port map(
      clk               => bus_clk,
      reset_n           => inst3_reset_n,
      pct_data          => inst1_user_w_stream0_write_32_data, 
      pct_wr            => inst3_pct_wr,
      pct_payload_data  => inst3_pct_payload_data,
      pct_payload_valid => inst3_pct_payload_valid,
      pct_payload_dest  => open
   );
   
   -- Second FIFO, dedicated for WFM player
   inst4_reset_n <= inst3_reset_n;
   
   inst4_H2F_S0_1_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_S0_DATA_WIDTH,
      wrusedw_witdth => c_H2F_S0_1_WRUSEDW_WIDTH,  
      rdwidth        => g_H2F_S0_1_RWIDTH,
      rdusedw_width  => c_H2F_S0_1_RDUSEDW_WIDTH,
      show_ahead     => "ON"
   )
   port map(
      --input ports 
      reset_n  => inst4_reset_n,
      wrclk    => bus_clk,
      wrreq    => inst3_pct_payload_valid,
      data     => inst3_pct_payload_data,
      wrfull   => inst4_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => H2F_S0_1_rdclk,
      rdreq    => H2F_S0_1_rd,
      q        => H2F_S0_1_rdata,
      rdempty  => H2F_S0_1_rempty,
      rdusedw  => H2F_S0_1_rdusedw   
   );
   
-- ----------------------------------------------------------------------------
-- For Stream S1 endpoint, Host->FPGA
-- There are two FIFO buffers for this endpoint. Buffer is selected with H2F_S1_0_sel
-- ----------------------------------------------------------------------------
   inst5_reset_n  <= H2F_S1_0_sclrn;
   inst5_wrreq    <= inst1_user_w_stream1_write_32_wren when H2F_S1_sel_sync = '0' else '0';
 
   -- First FIFO, dedicated for TX stream
   inst5_H2F_S1_0_FIFO : entity work.two_fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_S1_DATA_WIDTH,
      wrusedw_witdth => 10,  
      rdwidth        => g_H2F_S1_0_RWIDTH,
      rdusedw_width  => c_H2F_S1_0_RDUSEDW_WIDTH,
      show_ahead     => "OFF",
      TRNSF_SIZE     => 512, 
      TRNSF_N        => 8
   )
   port map(
      --input ports 
      reset_0_n   => inst1_user_w_stream1_write_32_open,
      reset_1_n   => inst5_reset_n,
      wrclk       => bus_clk,
      wrreq       => inst5_wrreq,
      data        => inst1_user_w_stream1_write_32_data,
      wrfull      => inst5_wrfull,
      wrempty     => open,
      wrusedw     => open,
      rdclk       => H2F_S1_0_rdclk,
      rdreq       => H2F_S1_0_rd,
      q           => H2F_S1_0_rdata,
      rdempty     => H2F_S1_0_rempty,
      rdusedw     => H2F_S1_0_rdusedw   
   );
   
   inst6_reset_n  <= inst1_user_w_stream1_write_32_open OR H2F_S1_1_sclrn;
   inst6_pct_wr   <= inst1_user_w_stream1_write_32_wren when H2F_S1_sel_sync = '1' else '0'; 
   
   -- This module takes only IQ data from packet, and discards packet header
   pct_payload_extrct_inst6 : entity work.pct_payload_extrct
   generic map(
      data_w         => g_S1_DATA_WIDTH,
      header_size    => 16, 
      pct_size       => 4096
   ) 
   port map(
      clk               => bus_clk,
      reset_n           => inst6_reset_n,
      pct_data          => inst1_user_w_stream1_write_32_data, 
      pct_wr            => inst6_pct_wr,
      pct_payload_data  => inst6_pct_payload_data,
      pct_payload_valid => inst6_pct_payload_valid,
      pct_payload_dest  => open
   );
   
   inst7_reset_n <= inst1_user_w_stream1_write_32_open OR H2F_S1_1_sclrn;
   
   -- Second FIFO, dedicated for WFM player
   inst7_H2F_S1_1_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_S1_DATA_WIDTH,
      wrusedw_witdth => c_H2F_S1_1_WRUSEDW_WIDTH,  
      rdwidth        => g_H2F_S1_1_RWIDTH,
      rdusedw_width  => c_H2F_S1_1_RDUSEDW_WIDTH,
      show_ahead     => "ON"
   )
   port map(
      --input ports 
      reset_n  => inst7_reset_n,
      wrclk    => bus_clk,
      wrreq    => inst6_pct_payload_valid,
      data     => inst6_pct_payload_data,
      wrfull   => inst7_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => H2F_S1_1_rdclk,
      rdreq    => H2F_S1_1_rd,
      q        => H2F_S1_1_rdata,
      rdempty  => H2F_S1_1_rempty,
      rdusedw  => H2F_S1_1_rdusedw   
   );	
 
 -- ----------------------------------------------------------------------------
-- For Stream S2 endpoint, Host->FPGA
-- There are two FIFO buffers for this endpoint. Buffer is selected with H2F_S2_0_sel
-- ----------------------------------------------------------------------------
   inst8_reset_n  <= H2F_S2_0_sclrn;
   inst8_wrreq    <= inst1_user_w_stream2_write_32_wren when H2F_S2_sel_sync = '0' else '0';
 
   -- First FIFO, dedicated for TX stream
   inst8_H2F_S2_0_FIFO : entity work.two_fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_S2_DATA_WIDTH,
      wrusedw_witdth => 10,  
      rdwidth        => g_H2F_S2_0_RWIDTH,
      rdusedw_width  => c_H2F_S2_0_RDUSEDW_WIDTH,
      show_ahead     => "OFF",
      TRNSF_SIZE     => 512, 
      TRNSF_N        => 8
   )
   port map(
      --input ports 
      reset_0_n   => inst1_user_w_stream2_write_32_open,
      reset_1_n   => inst8_reset_n,
      wrclk       => bus_clk,
      wrreq       => inst8_wrreq,
      data        => inst1_user_w_stream2_write_32_data,
      wrfull      => inst8_wrfull,
      wrempty     => open,
      wrusedw     => open,
      rdclk       => H2F_S2_0_rdclk,
      rdreq       => H2F_S2_0_rd,
      q           => H2F_S2_0_rdata,
      rdempty     => H2F_S2_0_rempty,
      rdusedw     => H2F_S2_0_rdusedw   
   );
   
   inst9_reset_n  <= inst1_user_w_stream2_write_32_open OR H2F_S2_1_sclrn;
   inst9_pct_wr   <= inst1_user_w_stream2_write_32_wren when H2F_S2_sel_sync = '1' else '0'; 
   
   -- This module takes only IQ data from packet, and discards packet header
   pct_payload_extrct_inst9 : entity work.pct_payload_extrct
   generic map(
      data_w         => g_S2_DATA_WIDTH,
      header_size    => 16, 
      pct_size       => 4096
   ) 
   port map(
      clk               => bus_clk,
      reset_n           => inst9_reset_n,
      pct_data          => inst1_user_w_stream2_write_32_data, 
      pct_wr            => inst9_pct_wr,
      pct_payload_data  => inst9_pct_payload_data,
      pct_payload_valid => inst9_pct_payload_valid,
      pct_payload_dest  => open
   );
   
   inst10_reset_n <= inst1_user_w_stream2_write_32_open OR H2F_S2_1_sclrn;
   -- Second FIFO, dedicated for WFM player
   inst10_H2F_S2_1_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_S2_DATA_WIDTH,
      wrusedw_witdth => c_H2F_S2_1_WRUSEDW_WIDTH,  
      rdwidth        => g_H2F_S2_1_RWIDTH,
      rdusedw_width  => c_H2F_S2_1_RDUSEDW_WIDTH,
      show_ahead     => "ON"
   )
   port map(
      --input ports 
      reset_n  => inst10_reset_n,
      wrclk    => bus_clk,
      wrreq    => inst9_pct_payload_valid,
      data     => inst9_pct_payload_data,
      wrfull   => inst10_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => H2F_S2_1_rdclk,
      rdreq    => H2F_S2_1_rd,
      q        => H2F_S2_1_rdata,
      rdempty  => H2F_S2_1_rempty,
      rdusedw  => H2F_S2_1_rdusedw   
   );	
   
-- ----------------------------------------------------------------------------
-- For C0 Control endpoint, Host->FPGA
-- ---------------------------------------------------------------------------- 
   inst11_H2F_C0_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_C0_DATA_WIDTH,
      wrusedw_witdth => c_H2F_C0_WRUSEDW_WIDTH,  
      rdwidth        => g_H2F_C0_RWIDTH,
      rdusedw_width  => c_H2F_C0_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   )
   port map(
      --input ports 
      reset_n  => inst1_user_w_control0_write_32_open,
      wrclk    => bus_clk,
      wrreq    => inst1_user_w_control0_write_32_wren,
      data     => inst1_user_w_control0_write_32_data,
      wrfull   => inst11_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => H2F_C0_rdclk,
      rdreq    => H2F_C0_rd,
      q        => H2F_C0_rdata,
      rdempty  => H2F_C0_rempty,
      rdusedw  => open     
   );
   
-- ----------------------------------------------------------------------------
-- For S0 stream endpoint, FPGA->Host
-- ---------------------------------------------------------------------------- 
   inst12_reset_n <= inst1_user_r_stream0_read_32_open;
   
   inst12_F2H_S0_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_F2H_S0_WWIDTH,
      wrusedw_witdth => c_F2H_S0_WRUSEDW_WIDTH,  
      rdwidth        => g_S0_DATA_WIDTH,
      rdusedw_width  => c_F2H_S0_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   ) 
   port map(
      --input ports 
      reset_n  => inst12_reset_n,
      wrclk    => F2H_S0_wclk,
      wrreq    => F2H_S0_wr,
      data     => F2H_S0_wdata,
      wrfull   => F2H_S0_wfull,
      wrempty  => open,
      wrusedw  => F2H_S0_wrusedw,
      rdclk    => bus_clk,
      rdreq    => inst1_user_r_stream0_read_32_rden,
      q        => inst12_q,
      rdempty  => inst12_rdempty,
      rdusedw  => open    
   );  
   
-- ----------------------------------------------------------------------------
-- For S1 stream endpoint, FPGA->Host
-- ----------------------------------------------------------------------------
   inst13_reset_n <= inst1_user_r_stream1_read_32_open;

   inst13_F2H_S1_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_F2H_S1_WWIDTH,
      wrusedw_witdth => c_F2H_S1_WRUSEDW_WIDTH,  
      rdwidth        => g_S1_DATA_WIDTH,
      rdusedw_width  => c_F2H_S1_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   ) 
   port map(
      --input ports 
      reset_n  => inst13_reset_n,
      wrclk    => F2H_S1_wclk,
      wrreq    => F2H_S1_wr,
      data     => F2H_S1_wdata,
      wrfull   => F2H_S1_wfull,
      wrempty  => open,
      wrusedw  => F2H_S1_wrusedw,
      rdclk    => bus_clk,
      rdreq    => inst1_user_r_stream1_read_32_rden,
      q        => inst13_q,
      rdempty  => inst13_rdempty,
      rdusedw  => open    
   );
   
-- ----------------------------------------------------------------------------
-- For S2 stream endpoint, FPGA->Host
-- commented by B.J.: now this is obsolete:
-- ---------------------------------------------------------------------------- 
--   inst14_reset_n <= inst1_user_r_stream2_read_32_open;
   
--   inst14_F2H_S2_FIFO : entity work.fifo_inst 
--   generic map(
--      dev_family     => g_DEV_FAMILY,
--      wrwidth        => g_F2H_S2_WWIDTH,
--      wrusedw_witdth => c_F2H_S2_WRUSEDW_WIDTH,  
--      rdwidth        => g_S2_DATA_WIDTH,
--      rdusedw_width  => c_F2H_S2_RDUSEDW_WIDTH,
--     show_ahead     => "OFF"
--   ) 
--  port map(
--      --input ports 
--      reset_n  => inst14_reset_n,
--      wrclk    => F2H_S2_wclk,
--      wrreq    => F2H_S2_wr,
--      data     => F2H_S2_wdata,
--      wrfull   => F2H_S2_wfull,
--      wrempty  => open,
--      wrusedw  => F2H_S2_wrusedw,
--     rdclk    => bus_clk,
--      rdreq    => inst1_user_r_stream2_read_32_rden,
--      q        => inst14_q,
--     rdempty  => inst14_rdempty,
--     rdusedw  => open    
--  );

-- ----------------------------------------------------------------------------
-- For C0 control endpoint, FPGA->Host
-- ---------------------------------------------------------------------------- 
   inst15_F2H_C0_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_F2H_C0_WWIDTH,
      wrusedw_witdth => c_F2H_C0_WRUSEDW_WIDTH,  
      rdwidth        => g_C0_DATA_WIDTH,
      rdusedw_width  => c_F2H_C0_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   ) 
   port map(
      --input ports 
      reset_n  => inst1_user_r_control0_read_32_open,
      wrclk    => F2H_C0_wclk,
      wrreq    => F2H_C0_wr,
      data     => F2H_C0_wdata,
      wrfull   => F2H_C0_wfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => bus_clk,
      rdreq    => inst1_user_r_control0_read_32_rden,
      q        => inst15_q,
      rdempty  => inst15_rdempty,
      rdusedw  => open    
   );   
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
   F2H_S0_open <= inst1_user_r_stream0_read_32_open;
   F2H_S1_open <= inst1_user_r_stream1_read_32_open;
   F2H_S2_open <= inst1_user_r_stream2_read_32_open;

   -- modified by B.J.
   H2F_S0_open <= inst1_user_w_stream0_write_32_open;
   H2F_S1_open <= inst1_user_w_stream1_write_32_open;
   H2F_S2_open <= inst1_user_w_stream2_write_32_open;
   
end arch;





