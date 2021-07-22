-- ----------------------------------------------------------------------------
-- FILE:          lms7002_tx.vhd
-- DESCRIPTION:   Transmit interface for LMS7002 IC
-- DATE:          11:32 AM Friday, August 31, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:     modified by B.J.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- 
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.FIFO_PACK.ALL;
USE work.memcfg_pkg.ALL;

--   added by B.J.
USE ieee.std_logic_unsigned.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
ENTITY lms7002_tx IS
   GENERIC (

      --   added by  B.J. 
      DPDTopWrapper_enable : INTEGER := 1;

      g_DEV_FAMILY : STRING := "Cyclone IV E";
      g_IQ_WIDTH : INTEGER := 12;
      g_SMPL_FIFO_0_WRUSEDW : INTEGER := 9;
      g_SMPL_FIFO_0_DATAW : INTEGER := 128; -- Must be multiple of four IQ samples, minimum four IQ samples
      g_SMPL_FIFO_1_WRUSEDW : INTEGER := 9;
      g_SMPL_FIFO_1_DATAW : INTEGER := 128 -- Must be multiple of four IQ samples, minimum four IQ samples
   );
   PORT (
      clk : IN STD_LOGIC;
      reset_n : IN STD_LOGIC;
      clk_2x : IN STD_LOGIC;
      clk_2x_reset_n : IN STD_LOGIC;
      mem_reset_n : IN STD_LOGIC;
      from_memcfg : IN t_FROM_MEMCFG;
      --Mode settings
      mode : IN STD_LOGIC; -- JESD207: 1; TRXIQ: 0
      trxiqpulse : IN STD_LOGIC; -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en : IN STD_LOGIC; -- DDR: 1; SDR: 0
      mimo_en : IN STD_LOGIC; -- SISO: 1; MIMO: 0
      ch_en : IN STD_LOGIC_VECTOR(1 DOWNTO 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      fidm : IN STD_LOGIC; -- Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --TX testing
      test_ptrn_en : IN STD_LOGIC;
      test_ptrn_I : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      test_ptrn_Q : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      test_cnt_en : IN STD_LOGIC;
      txant_cyc_before_en : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      txant_cyc_after_en : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      txant_en : OUT STD_LOGIC;
      --Tx interface data 
      DIQ : OUT STD_LOGIC_VECTOR(g_IQ_WIDTH - 1 DOWNTO 0);
      fsync : OUT STD_LOGIC;
      -- Source select
      tx_src_sel : IN STD_LOGIC; -- 0 - FIFO_0 , 1 - FIFO_1
      --TX sample FIFO ports
      fifo_0_wrclk : IN STD_LOGIC;
      fifo_0_reset_n : IN STD_LOGIC;
      fifo_0_wrreq : IN STD_LOGIC;
      fifo_0_data : IN STD_LOGIC_VECTOR(g_SMPL_FIFO_0_DATAW - 1 DOWNTO 0);
      fifo_0_wrfull : OUT STD_LOGIC;
      fifo_0_wrusedw : OUT STD_LOGIC_VECTOR(g_SMPL_FIFO_0_WRUSEDW - 1 DOWNTO 0);
      fifo_1_wrclk : IN STD_LOGIC;
      fifo_1_reset_n : IN STD_LOGIC;
      fifo_1_wrreq : IN STD_LOGIC;
      fifo_1_data : IN STD_LOGIC_VECTOR(g_SMPL_FIFO_0_DATAW - 1 DOWNTO 0);
      fifo_1_wrfull : OUT STD_LOGIC;
      fifo_1_wrusedw : OUT STD_LOGIC_VECTOR(g_SMPL_FIFO_0_WRUSEDW - 1 DOWNTO 0);
      -- SPI for internal modules
      sdin : IN STD_LOGIC; -- Data in
      sclk : IN STD_LOGIC; -- Data clock
      sen : IN STD_LOGIC; -- Enable signal (active low)
      sdout : OUT STD_LOGIC; -- Data out

      -- added by B.J. 
      xp_ai, xp_aq, xp_bi, xp_bq : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      yp_ai, yp_aq, yp_bi, yp_bq : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      xp_data_valid : OUT STD_LOGIC;

      cap_en, cap_cont_en : OUT STD_LOGIC;
      cap_size : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      PAEN0, PAEN1, DCEN0, DCEN1 : OUT STD_LOGIC;
      rf_sw : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
   );
END lms7002_tx;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE arch OF lms7002_tx IS
   --declare signals,  components here

   -- added by B.J. 
   COMPONENT DPDTopWrapper IS
      PORT (
         clk : IN STD_LOGIC;
         reset_n : IN STD_LOGIC;
         sleep : IN std_logic;
         mem_reset_n : IN STD_LOGIC;
         from_memcfg : IN t_FROM_MEMCFG;

         ch_en : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         sdin : IN STD_LOGIC;
         sclk : IN STD_LOGIC;
         sen : IN STD_LOGIC;
         sdout : OUT STD_LOGIC;

         data_req : OUT STD_LOGIC;
         data_valid : OUT STD_LOGIC;
         diq_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         diq_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);

         xp_ai, xp_aq, xp_bi, xp_bq : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         yp_ai, yp_aq, yp_bi, yp_bq : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

         cap_en, cap_cont_en : OUT STD_LOGIC;
         cap_size : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         PAEN0, PAEN1, DCEN0, DCEN1 : OUT STD_LOGIC;
         rf_sw : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         reset_n_soft : OUT STD_LOGIC
      );

   END COMPONENT DPDTopWrapper;

   --inst0
   CONSTANT c_INST0_RDUSEDW : INTEGER := FIFORD_SIZE (g_SMPL_FIFO_0_DATAW, 64, g_SMPL_FIFO_0_WRUSEDW);
   SIGNAL inst0_q : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL inst0_rdreq : STD_LOGIC;
   SIGNAL inst0_rdempty : STD_LOGIC;
   SIGNAL inst0_rdusedw : STD_LOGIC_VECTOR(c_INST0_RDUSEDW - 1 DOWNTO 0);

   --inst1
   CONSTANT c_INST1_RDUSEDW : INTEGER := FIFORD_SIZE (g_SMPL_FIFO_1_DATAW, 64, g_SMPL_FIFO_1_WRUSEDW);
   SIGNAL inst1_q : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL inst1_rdreq : STD_LOGIC;
   SIGNAL inst1_rdempty : STD_LOGIC;
   SIGNAL inst1_rdusedw : STD_LOGIC_VECTOR(c_INST1_RDUSEDW - 1 DOWNTO 0);

   --inst2
   SIGNAL inst2_diq_in : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL inst2_diq_out : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL inst2_data_req : STD_LOGIC;
   SIGNAL inst2_data_valid : STD_LOGIC;
   SIGNAL inst2_sleep : STD_LOGIC;

   --inst3
   SIGNAL inst3_wrfull : STD_LOGIC;
   SIGNAL inst3_q : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL inst3_rdempty : STD_LOGIC;
   SIGNAL inst3_rdusedw : STD_LOGIC_VECTOR(c_INST0_RDUSEDW - 1 DOWNTO 0);

   --inst4
   SIGNAL inst4_fifo_rdreq : STD_LOGIC;
   SIGNAL inst4_DIQ_h : STD_LOGIC_VECTOR(g_IQ_WIDTH DOWNTO 0);
   SIGNAL inst4_DIQ_l : STD_LOGIC_VECTOR(g_IQ_WIDTH DOWNTO 0);
   SIGNAL inst4_fifo_q : STD_LOGIC_VECTOR(g_IQ_WIDTH * 4 - 1 DOWNTO 0);

   --inst5 
   SIGNAL inst5_diq_h : STD_LOGIC_VECTOR(g_IQ_WIDTH DOWNTO 0);
   SIGNAL inst5_diq_l : STD_LOGIC_VECTOR(g_IQ_WIDTH DOWNTO 0);
   SIGNAL reset_n_cfir_top : STD_LOGIC;

   -- added by B.J. 
   SIGNAL cnt : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL reset_n_DPDTOP, reset_n_soft : STD_LOGIC;
BEGIN

   -- ----------------------------------------------------------------------------
   -- FIFO for storing TX samples
   -- ----------------------------------------------------------------------------
   -- FIFO_0

   --clk_2x_1 <= not clk_2x;

   inst0_fifo_inst : ENTITY work.fifo_inst
      GENERIC MAP(
         dev_family => g_DEV_FAMILY,
         wrwidth => g_SMPL_FIFO_0_DATAW,
         wrusedw_witdth => g_SMPL_FIFO_0_WRUSEDW,
         rdwidth => 64,
         rdusedw_width => c_INST0_RDUSEDW,
         show_ahead => "OFF"
      )
      PORT MAP(
         reset_n => fifo_0_reset_n,
         wrclk => fifo_0_wrclk,
         wrreq => fifo_0_wrreq,
         data => fifo_0_data,
         wrfull => fifo_0_wrfull,
         wrempty => OPEN,
         wrusedw => fifo_0_wrusedw,
         rdclk => clk_2x,
         rdreq => inst0_rdreq,
         q => inst0_q,
         rdempty => inst0_rdempty,
         rdusedw => inst0_rdusedw
      );

   inst0_rdreq <= inst2_data_req AND (NOT inst0_rdempty) AND (NOT tx_src_sel);

   -- FIFO_1
   inst1_fifo_inst : ENTITY work.fifo_inst
      GENERIC MAP(
         dev_family => g_DEV_FAMILY,
         wrwidth => g_SMPL_FIFO_1_DATAW,
         wrusedw_witdth => g_SMPL_FIFO_1_WRUSEDW,
         rdwidth => 64,
         rdusedw_width => c_INST1_RDUSEDW,
         show_ahead => "OFF"
      )
      PORT MAP(
         reset_n => fifo_1_reset_n,
         wrclk => fifo_1_wrclk,
         wrreq => fifo_1_wrreq,
         data => fifo_1_data,
         wrfull => fifo_1_wrfull,
         wrempty => OPEN,
         wrusedw => fifo_1_wrusedw,
         rdclk => clk_2x,
         rdreq => inst1_rdreq,
         q => inst1_q,
         rdempty => inst1_rdempty,
         rdusedw => inst1_rdusedw
      );

   inst1_rdreq <= inst2_data_req AND (NOT inst1_rdempty) AND tx_src_sel;

   --  added by B.J. 
   xp_data_valid <= inst2_data_valid; -- 61.44 MHz

   -- ----------------------------------------------------------------------------
   -- Sample Filters
   -- ----------------------------------------------------------------------------
   inst2_diq_in <= inst0_q WHEN tx_src_sel = '0' ELSE
      inst1_q;
		
   inst2_sleep <= inst0_rdempty WHEN tx_src_sel = '0' ELSE
      inst1_rdempty;
		
	--inst2_sleep <= '0'; -- OVO OVDE PROVERITI

   --  added by B.J.  
   lab0 : IF (DPDTopWrapper_enable = 1) GENERATE

      reset_n_DPDTOP <= clk_2x_reset_n AND reset_n;

      inst2_DPDTopWrapper : ENTITY work.DPDTopWrapper
         PORT MAP(
            clk => clk_2x,

            reset_n => reset_n_DPDTOP, -- reset_n,
            sleep => inst2_sleep, -- OVO OVDE PROVERITI

            mem_reset_n => mem_reset_n,
            from_memcfg => from_memcfg,

            ch_en => ch_en,

            sdin => sdin, -- Data in
            sclk => sclk, -- Data clock
            sen => sen, -- Enable signal (active low)
            sdout => sdout, -- Data out

            data_req => inst2_data_req,
            data_valid => inst2_data_valid,
            diq_in => inst2_diq_in,
            diq_out => inst2_diq_out,

            xp_ai => xp_ai,
            xp_aq => xp_aq,
            xp_bi => xp_bi,
            xp_bq => xp_bq,
            yp_ai => yp_ai,
            yp_aq => yp_aq,
            yp_bi => yp_bi,
            yp_bq => yp_bq,

            cap_en => cap_en,
            cap_cont_en => cap_cont_en,
            cap_size => cap_size,
            PAEN0 => PAEN0,
            PAEN1 => PAEN1,
            DCEN0 => DCEN0,
            DCEN1 => DCEN1,
            rf_sw => rf_sw,

            reset_n_soft => reset_n_soft
         );
   END GENERATE;

   -- to save the FPGA resources, when not used 
   lab1 : IF (DPDTopWrapper_enable = 0) GENERATE
      reset_n_DPDTOP <= reset_n; -- modified by B.J.

      PAEN0 <= '0'; -- disable PA
      PAEN1 <= '0'; -- diasble PA
      DCEN0 <= '0'; -- disable DC-DC
      DCEN1 <= '0'; -- diasble DC-DC

      inst2_diq_out <= inst2_diq_in;

      PROCESS (clk_2x_reset_n, clk_2x) IS
      BEGIN
         IF clk_2x_reset_n = '0' THEN
            cnt <= "00";
         ELSIF clk_2x'event AND clk_2x = '1' THEN -- 122.88 MHz
            cnt <= cnt + '1';
         END IF;
      END PROCESS;

      inst2_data_req <= '1' WHEN cnt = "00" ELSE
         '0';
      inst2_data_valid <= '1' WHEN cnt = "00" ELSE
         '0';

      xp_ai <= (OTHERS => '0');
      xp_aq <= (OTHERS => '0');
      xp_bi <= (OTHERS => '0');
      xp_bq <= (OTHERS => '0');
      yp_ai <= (OTHERS => '0');
      yp_aq <= (OTHERS => '0');
      yp_bi <= (OTHERS => '0');
      yp_bq <= (OTHERS => '0');
      cap_en <= '0';
      cap_cont_en <= '0';
      cap_size <= (OTHERS => '0');
      rf_sw <= (OTHERS => '0');

      sdout <= '0';
      reset_n_soft <= '1';

   END GENERATE;

   -- ----------------------------------------------------------------------------
   -- FIFO for storing TX samples
   -- ----------------------------------------------------------------------------    
   inst3_fifo_inst : ENTITY work.fifo_inst
      GENERIC MAP(
         dev_family => g_DEV_FAMILY,
         wrwidth => 64,
         wrusedw_witdth => 10,
         rdwidth => 64,
         rdusedw_width => 10,
         show_ahead => "OFF"
      )
      PORT MAP(

         --reset_n => clk_2x_reset_n, 
         reset_n  => reset_n_DPDTOP and reset_n_soft, -- modified by B.J.
         wrclk => clk_2x,

         wrreq => inst2_data_valid AND (NOT inst3_wrfull),
         data => inst2_diq_out,
         wrfull => inst3_wrfull,
         wrempty => OPEN,
         wrusedw => OPEN,

         --rdclk => clk,
         rdclk => clk_2X, -- modified by B.J.

         rdreq => inst4_fifo_rdreq,
         q => inst3_q,
         rdempty => inst3_rdempty,
         rdusedw => inst3_rdusedw
      );

   -- ----------------------------------------------------------------------------
   -- FIFO2DIQ module
   -- ----------------------------------------------------------------------------                      
   inst4_fifo_q <= inst3_q(63 DOWNTO 64 - g_IQ_WIDTH) &
      inst3_q(47 DOWNTO 48 - g_IQ_WIDTH) &
      inst3_q(31 DOWNTO 32 - g_IQ_WIDTH) &
      inst3_q(15 DOWNTO 16 - g_IQ_WIDTH);

   inst4_fifo2diq : ENTITY work.fifo2diq
      GENERIC MAP(
         dev_family => g_DEV_FAMILY,
         iq_width => g_IQ_WIDTH
      )
      PORT MAP(
         -- clk => clk,         
         -- to LimeLight, at transmit, 61.44 MSps is the data rate
         clk => clk_2X, -- modified by B.J.;

         --reset_n => reset_n,
         reset_n => reset_n_DPDTOP AND reset_n_soft, -- modified by B.J.

         --Mode settings
         mode => mode, -- JESD207: 1; TRXIQ: 0
         trxiqpulse => trxiqpulse, -- trxiqpulse on: 1; trxiqpulse off: 0
         ddr_en => ddr_en, -- DDR: 1; SDR: 0
         mimo_en => mimo_en, -- SISO: 1; MIMO: 0
         ch_en => ch_en, --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
         fidm => fidm, -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
         pct_sync_mode => '0', -- 0 - timestamp, 1 - external pulse 
         pct_sync_pulse => '0', -- external packet synchronisation pulse signal
         pct_sync_size => (OTHERS => '0'), -- valid in external pulse mode only
         pct_buff_rdy => '0',
         --txant
			
			-- modified B.J.
         txant_cyc_before_en => (others=>'0'),  --txant_cyc_before_en, -- valid in external pulse sync mode only
         txant_cyc_after_en => (others=>'0'),  --txant_cyc_after_en, -- valid in external pulse sync mode only
         
			txant_en => txant_en,
         --Tx interface data 
         DIQ => OPEN,
         fsync => OPEN,
         DIQ_h => inst4_DIQ_h,
         DIQ_l => inst4_DIQ_l,
         --fifo ports 
         fifo_rdempty => inst3_rdempty,
         fifo_rdreq => inst4_fifo_rdreq,
         fifo_q => inst4_fifo_q
      );

   -- ----------------------------------------------------------------------------
   -- TX MUX
   -- ----------------------------------------------------------------------------  
   inst5_txiqmux : ENTITY work.txiqmux
      GENERIC MAP(
         diq_width => g_IQ_WIDTH
      )
      PORT MAP(
         -- clk => clk,         
         -- to LimeLight, at transmit, 61.44 MSps is the data rate
         -- necessary for DPD	
         clk => clk_2X, -- modified by B.J. 

         --reset_n => reset_n,
         reset_n => reset_n_DPDTOP AND reset_n_soft, -- modified by B.J.

         test_ptrn_en => test_ptrn_en, -- Enables test pattern
         test_ptrn_fidm => '0', -- Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
         test_ptrn_I => test_ptrn_I,
         test_ptrn_Q => test_ptrn_Q,
         test_data_en => test_cnt_en,
         test_data_mimo_en => '1',
         mux_sel => '0', -- Mux select: 0 - tx, 1 - wfm
         tx_diq_h => inst4_DIQ_h,
         tx_diq_l => inst4_DIQ_l,
         wfm_diq_h => (OTHERS => '0'),
         wfm_diq_l => (OTHERS => '0'),
         diq_h => inst5_diq_h,
         diq_l => inst5_diq_l
      );

   -- ----------------------------------------------------------------------------
   -- lms7002_ddout instance. Double data rate cells
   -- ----------------------------------------------------------------------------     
   inst6_lms7002_ddout : ENTITY work.lms7002_ddout
      GENERIC MAP(
         dev_family => g_DEV_FAMILY,
         iq_width => g_IQ_WIDTH
      )
      PORT MAP(
         --input ports 

         -- clk => clk,
         clk => clk_2X, -- modified by B.J.

         --reset_n => reset_n,
         reset_n => reset_n_DPDTOP AND reset_n_soft, -- modified by B.J.

         data_in_h => inst5_diq_h,
         data_in_l => inst5_diq_l,
         --output ports 
         txiq => DIQ,
         txiqsel => fsync
      );

END arch;