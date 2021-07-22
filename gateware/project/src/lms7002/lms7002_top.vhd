-- ----------------------------------------------------------------------------
-- FILE:          lms7002_top.vhd
-- DESCRIPTION:   Top file for LMS7002M IC
-- DATE:          9:16 AM Wednesday, August 29, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:     modified by B.J.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.fpgacfg_pkg.ALL;
USE work.tstcfg_pkg.ALL;
USE work.memcfg_pkg.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
ENTITY lms7002_top IS
   GENERIC (

      -- added by B.J.
      DPDTopWrapper_enable : INTEGER := 1;

      g_DEV_FAMILY : STRING := "Cyclone IV E";
      g_IQ_WIDTH : INTEGER := 12;
      g_INV_INPUT_CLK : STRING := "ON";
      g_TX_SMPL_FIFO_0_WRUSEDW : INTEGER := 9;
      g_TX_SMPL_FIFO_0_DATAW : INTEGER := 128;
      g_TX_SMPL_FIFO_1_WRUSEDW : INTEGER := 9;
      g_TX_SMPL_FIFO_1_DATAW : INTEGER := 128
   );
   PORT (
      from_fpgacfg : IN t_FROM_FPGACFG;
      from_tstcfg : IN t_FROM_TSTCFG;
      from_memcfg : IN t_FROM_MEMCFG;
      -- Momory module reset
      mem_reset_n : IN STD_LOGIC;
      -- PORT1 interface
      MCLK1 : IN STD_LOGIC; -- TX interface clock
      MCLK1_2x : IN STD_LOGIC;
      FCLK1 : OUT STD_LOGIC; -- TX interface feedback clock
      DIQ1 : OUT STD_LOGIC_VECTOR(g_IQ_WIDTH - 1 DOWNTO 0);
      ENABLE_IQSEL1 : OUT STD_LOGIC;
      TXNRX1 : OUT STD_LOGIC;
      -- PORT2 interface
      MCLK2 : IN STD_LOGIC; -- RX interface clock
      FCLK2 : OUT STD_LOGIC; -- RX interface feedback clock
      DIQ2 : IN STD_LOGIC_VECTOR(g_IQ_WIDTH - 1 DOWNTO 0);
      ENABLE_IQSEL2 : IN STD_LOGIC;
      TXNRX2 : OUT STD_LOGIC;
      -- MISC
      RESET : OUT STD_LOGIC;
      TXEN : OUT STD_LOGIC;
      RXEN : OUT STD_LOGIC;
      CORE_LDO_EN : OUT STD_LOGIC;
      -- Internal TX ports
      tx_reset_n : IN STD_LOGIC;
      tx_fifo_0_wrclk : IN STD_LOGIC;
      tx_fifo_0_reset_n : IN STD_LOGIC;
      tx_fifo_0_wrreq : IN STD_LOGIC;
      tx_fifo_0_data : IN STD_LOGIC_VECTOR(g_TX_SMPL_FIFO_0_DATAW - 1 DOWNTO 0);
      tx_fifo_0_wrfull : OUT STD_LOGIC;
      tx_fifo_0_wrusedw : OUT STD_LOGIC_VECTOR(g_TX_SMPL_FIFO_0_WRUSEDW - 1 DOWNTO 0);
      tx_fifo_1_wrclk : IN STD_LOGIC;
      tx_fifo_1_reset_n : IN STD_LOGIC;
      tx_fifo_1_wrreq : IN STD_LOGIC;
      tx_fifo_1_data : IN STD_LOGIC_VECTOR(g_TX_SMPL_FIFO_1_DATAW - 1 DOWNTO 0);
      tx_fifo_1_wrfull : OUT STD_LOGIC;
      tx_fifo_1_wrusedw : OUT STD_LOGIC_VECTOR(g_TX_SMPL_FIFO_1_WRUSEDW - 1 DOWNTO 0);
      tx_ant_en : OUT STD_LOGIC;
      -- Internal RX ports
      rx_reset_n : IN STD_LOGIC;
      rx_diq_h : OUT STD_LOGIC_VECTOR(g_IQ_WIDTH DOWNTO 0);
      rx_diq_l : OUT STD_LOGIC_VECTOR(g_IQ_WIDTH DOWNTO 0);
      rx_data_valid : OUT STD_LOGIC;
      rx_data : OUT STD_LOGIC_VECTOR(g_IQ_WIDTH * 4 - 1 DOWNTO 0);
      --sample compare
      rx_smpl_cmp_start : IN STD_LOGIC;
      rx_smpl_cmp_length : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_smpl_cmp_done : OUT STD_LOGIC;
      rx_smpl_cmp_err : OUT STD_LOGIC;
      -- SPI for internal modules
      sdin : IN STD_LOGIC; -- Data in
      sclk : IN STD_LOGIC; -- Data clock
      sen : IN STD_LOGIC; -- Enable signal (active low)
      sdout : OUT STD_LOGIC; -- Data out

      -- added by B.J. 
      pcie_bus_clk : IN STD_LOGIC;
      strm2_OUT_EXT_rdreq : IN STD_LOGIC;
      strm2_OUT_EXT_rdempty : OUT STD_LOGIC;
      strm2_OUT_EXT_q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      PAEN0, PAEN1, DCEN0, DCEN1 : OUT STD_LOGIC;
      rf_sw : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
   );
END lms7002_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE arch OF lms7002_top IS
   --declare signals,  components here
   SIGNAL inst2_diq_h : STD_LOGIC_VECTOR (g_IQ_WIDTH DOWNTO 0);
   SIGNAL inst2_diq_l : STD_LOGIC_VECTOR (g_IQ_WIDTH DOWNTO 0);

   SIGNAL rx_smpl_cmp_start_sync : STD_LOGIC;
   --inst0
   SIGNAL inst0_reset_n : STD_LOGIC;

   --inst1
   SIGNAL inst1_fifo_0_reset_n : STD_LOGIC;
   SIGNAL inst1_fifo_1_reset_n : STD_LOGIC;
   SIGNAL inst1_clk_2x_reset_n : STD_LOGIC;
   SIGNAL inst1_txant_en : STD_LOGIC;

   SIGNAL int_mode : STD_LOGIC;
   SIGNAL int_trxiqpulse : STD_LOGIC;
   SIGNAL int_ddr_en : STD_LOGIC;
   SIGNAL int_mimo_en : STD_LOGIC;
   SIGNAL int_ch_en : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL int_fidm : STD_LOGIC;
   SIGNAL lms_txen_int : STD_LOGIC;
   SIGNAL lms_rxen_int : STD_LOGIC;

   --added by B.J. 
   SIGNAL xp_ai, xp_aq, xp_bi, xp_bq : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL yp_ai, yp_aq, yp_bi, yp_bq : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL x_ai, x_aq : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xp_data_valid : STD_LOGIC;
   SIGNAL cap_en, cap_cont_en : STD_LOGIC;
   SIGNAL cap_size : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL x_ai_prim, x_aq_prim : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL x_ai_sec, x_aq_sec : STD_LOGIC_VECTOR(11 DOWNTO 0);

   --added by B.J. 
   COMPONENT data_cap_buffer IS
      PORT (
         wclk0 : IN STD_LOGIC;
         wclk1 : IN STD_LOGIC;
         wclk2 : IN STD_LOGIC;
         wclk3 : IN STD_LOGIC;
         wclk4 : IN STD_LOGIC;
         rdclk : IN STD_LOGIC;
         clk : IN STD_LOGIC;
         reset_n : IN STD_LOGIC;
         XP_valid : IN STD_LOGIC;
         XPI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         XPQ : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         YP_valid : IN STD_LOGIC;
         YPI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         YPQ : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         X_valid : IN STD_LOGIC;
         XI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         XQ : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         XP_1_valid : IN STD_LOGIC;
         XPI_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         XPQ_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         YP_1_valid : IN STD_LOGIC;
         YPI_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         YPQ_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         cap_en : IN STD_LOGIC;
         cap_cont_en : IN STD_LOGIC;
         cap_size : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         cap_done : OUT STD_LOGIC;
         fifo_rdreq : IN STD_LOGIC;
         fifo_q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         fifo_rdempty : OUT STD_LOGIC;
         test_data_en : IN STD_LOGIC
      );
   END COMPONENT data_cap_buffer;

   --added by B.J. 
   COMPONENT ddr2rxiq IS
      PORT (
         reset_n : IN STD_LOGIC;
         clk : IN STD_LOGIC;
         dil : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
         dih : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
         rxiqsel : OUT STD_LOGIC;
         rxdA : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
         rxdB : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
         AI : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
         AQ : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
         BI : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
         BQ : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
      );
   END COMPONENT ddr2rxiq;

   --added by B.J. 
   SIGNAL inst2_diq_out_h : STD_LOGIC_VECTOR (g_IQ_WIDTH DOWNTO 0);
   SIGNAL inst2_diq_out_l : STD_LOGIC_VECTOR (g_IQ_WIDTH DOWNTO 0);
   SIGNAL inst2_reset_n, rxiqsel, tx_reset_n1 : STD_LOGIC;
BEGIN

   sync_reg0 : ENTITY work.sync_reg
      PORT MAP(MCLK2, rx_reset_n, from_fpgacfg.rx_en, inst0_reset_n);

   sync_reg1 : ENTITY work.sync_reg
      PORT MAP(MCLK2, '1', rx_smpl_cmp_start, rx_smpl_cmp_start_sync);

   sync_reg2 : ENTITY work.sync_reg
      PORT MAP(tx_fifo_0_wrclk, tx_fifo_0_reset_n, '1', inst1_fifo_0_reset_n);

   sync_reg3 : ENTITY work.sync_reg
      PORT MAP(tx_fifo_1_wrclk, tx_fifo_1_reset_n, '1', inst1_fifo_1_reset_n);

   -- clk_2x is held in reset only when both fifos are in reset
   sync_reg4 : ENTITY work.sync_reg
      PORT MAP(MCLK1_2x, (inst1_fifo_0_reset_n OR inst1_fifo_1_reset_n), '1', inst1_clk_2x_reset_n);

   -- added by B.J.
   sync_reg5 : ENTITY work.sync_reg
      PORT MAP(MCLK2, tx_reset_n, '1', tx_reset_n1);
   -- ----------------------------------------------------------------------------
   -- RX interface
   -- ----------------------------------------------------------------------------
   inst0_diq2fifo : ENTITY work.diq2fifo
      GENERIC MAP(
         -- added by B.J. 	
         DPDTopWrapper_enable => DPDTopWrapper_enable,
         dev_family => g_DEV_FAMILY,
         iq_width => g_IQ_WIDTH,
         invert_input_clocks => g_INV_INPUT_CLK
      )
      PORT MAP(
         clk => MCLK2,
         reset_n => inst0_reset_n,
         -- added  by B.J.
         cap_en => tx_reset_n1,

         test_ptrn_en => from_fpgacfg.rx_ptrn_en,
         --Mode settings
         mode => from_fpgacfg.mode, -- JESD207: 1; TRXIQ: 0
         trxiqpulse => from_fpgacfg.trxiq_pulse, -- trxiqpulse on: 1; trxiqpulse off: 0
         ddr_en => from_fpgacfg.ddr_en, -- DDR: 1; SDR: 0
         mimo_en => from_fpgacfg.mimo_int_en, -- SISO: 1; MIMO: 0
         ch_en => from_fpgacfg.ch_en(1 DOWNTO 0), --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
         fidm => '0', -- Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
         --Rx interface data 
         DIQ => DIQ2,
         fsync => ENABLE_IQSEL2,
         --fifo ports 
         fifo_wfull => '0',
         fifo_wrreq => rx_data_valid,
         fifo_wdata => rx_data,
         --sample compare
         smpl_cmp_start => rx_smpl_cmp_start_sync,
         smpl_cmp_length => rx_smpl_cmp_length,
         smpl_cmp_done => rx_smpl_cmp_done,
         smpl_cmp_err => rx_smpl_cmp_err,

         -- added by B.J.
         diq_h => inst2_diq_out_h,
         diq_l => inst2_diq_out_l
      );

   -- to collect Receive data x_ai, x_aq for DPD monitoring path
   -- added by B.J.
   inst2_reset_n <= cap_en WHEN rx_smpl_cmp_start_sync = '0' ELSE
      '1';

   -- added by B.J.
   inst3_ddr2rxiq : ddr2rxiq
   PORT MAP(
      reset_n => '1', --'1', was inst2_reset_n
      clk => MCLK2,
      dil => inst2_diq_out_l,
      dih => inst2_diq_out_h,
      rxiqsel => rxiqsel,
      rxdA => OPEN,
      rxdB => OPEN,
      AI => x_ai_prim, -- CH A, # LMS1, I,Q
      AQ => x_aq_prim,
      BI => OPEN,
      BQ => OPEN
   );

   x_ai <= x_ai_prim & "0000";
   x_aq <= x_aq_prim & "0000";

   -- ----------------------------------------------------------------------------
   -- TX interface
   -- ----------------------------------------------------------------------------
   -- Internal DIQ mode settings for TX interface
   -- (Workaround for WFM player)
   int_mode <= from_fpgacfg.mode WHEN from_fpgacfg.wfm_play = '0' ELSE
      '0';
   int_trxiqpulse <= from_fpgacfg.trxiq_pulse WHEN from_fpgacfg.wfm_play = '0' ELSE
      '0';
   int_ddr_en <= from_fpgacfg.ddr_en WHEN from_fpgacfg.wfm_play = '0' ELSE
      '1';
   int_mimo_en <= from_fpgacfg.mimo_int_en WHEN from_fpgacfg.wfm_play = '0' ELSE
      '1';
   int_ch_en <= from_fpgacfg.ch_en(1 DOWNTO 0) WHEN from_fpgacfg.wfm_play = '0' ELSE
      "11";
   inst1_lms7002_tx : ENTITY work.lms7002_tx
      GENERIC MAP(

         -- added by B.J.
         DPDTopWrapper_enable => DPDTopWrapper_enable,

         g_DEV_FAMILY => g_DEV_FAMILY,
         g_IQ_WIDTH => g_IQ_WIDTH,
         g_SMPL_FIFO_0_WRUSEDW => g_TX_SMPL_FIFO_0_WRUSEDW,
         g_SMPL_FIFO_0_DATAW => g_TX_SMPL_FIFO_0_DATAW,
         g_SMPL_FIFO_1_WRUSEDW => g_TX_SMPL_FIFO_1_WRUSEDW,
         g_SMPL_FIFO_1_DATAW => g_TX_SMPL_FIFO_1_DATAW
      )
      PORT MAP(
         clk => MCLK1,
         reset_n => tx_reset_n,
         clk_2x => MCLK1_2x,
         clk_2x_reset_n => inst1_clk_2x_reset_n,
         mem_reset_n => mem_reset_n,
         from_memcfg => from_memcfg,

         --Mode settings
         mode => int_mode, -- JESD207: 1; TRXIQ: 0
         trxiqpulse => int_trxiqpulse, -- trxiqpulse on: 1; trxiqpulse off: 0
         ddr_en => int_ddr_en, -- DDR: 1; SDR: 0
         mimo_en => int_mimo_en, -- SISO: 0; MIMO: 1
         ch_en => int_ch_en, --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
         fidm => '0', -- Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
         --TX testing
         test_ptrn_en => from_fpgacfg.tx_ptrn_en,
         test_ptrn_I => from_tstcfg.TX_TST_I,
         test_ptrn_Q => from_tstcfg.TX_TST_Q,
         test_cnt_en => from_fpgacfg.tx_cnt_en,
         txant_cyc_before_en => from_fpgacfg.txant_pre,
         txant_cyc_after_en => from_fpgacfg.txant_post,
         txant_en => inst1_txant_en,
         --Tx interface data 
         DIQ => DIQ1,
         fsync => ENABLE_IQSEL1,
         -- Source select
         tx_src_sel => from_fpgacfg.wfm_play, -- 0 - FIFO, 1 - diq_h/diq_l
         --TX sample FIFO ports 
         fifo_0_wrclk => tx_fifo_0_wrclk,
         fifo_0_reset_n => inst1_fifo_0_reset_n,
         fifo_0_wrreq => tx_fifo_0_wrreq,
         fifo_0_data => tx_fifo_0_data,
         fifo_0_wrfull => tx_fifo_0_wrfull,
         fifo_0_wrusedw => tx_fifo_0_wrusedw,
         fifo_1_wrclk => tx_fifo_1_wrclk,
         fifo_1_reset_n => inst1_fifo_1_reset_n,
         fifo_1_wrreq => tx_fifo_1_wrreq,
         fifo_1_data => tx_fifo_1_data,
         fifo_1_wrfull => tx_fifo_1_wrfull,
         fifo_1_wrusedw => tx_fifo_1_wrusedw,
         --TX sample ports (direct access to DDR cells)
         sdin => sdin,
         sclk => sclk,
         sen => sen,
         sdout => sdout,

         -- added by B.J.  
         xp_ai => xp_ai,
         xp_aq => xp_aq,
         xp_bi => xp_bi,
         xp_bq => xp_bq,
         yp_ai => yp_ai,
         yp_aq => yp_aq,
         yp_bi => yp_bi,
         yp_bq => yp_bq,
         xp_data_valid => xp_data_valid,
         cap_en => cap_en,
         cap_cont_en => cap_cont_en,
         cap_size => cap_size,
         PAEN0 => PAEN0,
         PAEN1 => PAEN1,
         DCEN0 => DCEN0,
         DCEN1 => DCEN1,
         rf_sw => rf_sw
      );

   -- ----------------------------------------------------------------------------
   -- Output ports
   -- ----------------------------------------------------------------------------
   lms_txen_int <= from_fpgacfg.LMS1_TXEN WHEN from_fpgacfg.LMS_TXRXEN_MUX_SEL = '0' ELSE
      inst1_txant_en;
   lms_rxen_int <= from_fpgacfg.LMS1_RXEN WHEN from_fpgacfg.LMS_TXRXEN_MUX_SEL = '0' ELSE
      NOT inst1_txant_en;
   RESET <= from_fpgacfg.LMS1_RESET;
   TXEN <= lms_txen_int WHEN from_fpgacfg.LMS_TXRXEN_INV = '0' ELSE
      NOT lms_txen_int;
   RXEN <= lms_rxen_int WHEN from_fpgacfg.LMS_TXRXEN_INV = '0' ELSE
      NOT lms_rxen_int;
   CORE_LDO_EN <= from_fpgacfg.LMS1_CORE_LDO_EN;
   TXNRX1 <= from_fpgacfg.LMS1_TXNRX1;
   TXNRX2 <= from_fpgacfg.LMS1_TXNRX2;

   tx_ant_en <= inst1_txant_en;

   -- added B.J.
   -- FIFO for DPD data streams
   -- goes to PCIe

   lab0 : IF (DPDTopWrapper_enable = 1) GENERATE

      inst_data_cap_buffer : data_cap_buffer
      PORT MAP(
         wclk0 => MCLK1_2x,
         wclk1 => MCLK1_2x,
         wclk2 => MCLK2, --MCLK1_2x
         wclk3 => MCLK1_2x,
         wclk4 => MCLK1_2x,
         rdclk => pcie_bus_clk,
         clk => MCLK1,
         reset_n => cap_en,
         XP_valid => xp_data_valid, -- 61.44 MHz	
         XPI => xp_ai,
         XPQ => xp_aq,
         YP_valid => xp_data_valid, -- 61.44 MHz
         YPI => yp_ai,
         YPQ => yp_aq,
         X_valid => rxiqsel, --xp_data_valid,
         XI => x_ai,
         XQ => x_aq,
         XP_1_valid => xp_data_valid, -- 61.44 MHz	
         XPI_1 => xp_bi,
         XPQ_1 => xp_bq,
         YP_1_valid => xp_data_valid,
         YPI_1 => yp_bi,
         YPQ_1 => yp_bq,

         cap_en => cap_en,
         cap_cont_en => cap_cont_en,
         cap_size => cap_size,
         cap_done => OPEN,

         --external fifo signals
         fifo_rdreq => strm2_OUT_EXT_rdreq, -- in
         fifo_q => strm2_OUT_EXT_q, -- out
         fifo_rdempty => strm2_OUT_EXT_rdempty, -- out
         test_data_en => '0'
      );

   END GENERATE;

   -- added by B.J.
   -- dummy, when not used 
   lab1 : IF (DPDTopWrapper_enable = 0) GENERATE
      strm2_OUT_EXT_rdempty <= '0';
      strm2_OUT_EXT_q <= (OTHERS => '0');
   END GENERATE;
END arch;