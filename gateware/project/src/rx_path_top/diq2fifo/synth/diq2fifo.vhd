-- ----------------------------------------------------------------------------	
-- FILE:    diq2fifo.vhd
-- DESCRIPTION:   Writes DIQ data to FIFO, FIFO word size = 4  DIQ samples 
-- DATE: Jan 13, 2016
-- AUTHOR(s): Lime Microsystems
-- REVISIONS: modified by B.J.
-- ----------------------------------------------------------------------------	
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
ENTITY diq2fifo IS
   GENERIC (
      -- added by B.J.
      DPDTopWrapper_enable : INTEGER := 1;

      dev_family : STRING := "Cyclone IV E";
      iq_width : INTEGER := 12;
      invert_input_clocks : STRING := "ON"
   );
   PORT (
      clk : IN STD_LOGIC;
      reset_n : IN STD_LOGIC;
      test_ptrn_en : IN STD_LOGIC;
      --Mode settings
      mode : IN STD_LOGIC; -- JESD207: 1; TRXIQ: 0
      trxiqpulse : IN STD_LOGIC; -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en : IN STD_LOGIC; -- DDR: 1; SDR: 0
      mimo_en : IN STD_LOGIC; -- SISO: 1; MIMO: 0
      ch_en : IN STD_LOGIC_VECTOR(1 DOWNTO 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      fidm : IN STD_LOGIC; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --Rx interface data 
      DIQ : IN STD_LOGIC_VECTOR(iq_width - 1 DOWNTO 0);
      fsync : IN STD_LOGIC;
      --fifo ports 
      fifo_wfull : IN STD_LOGIC;
      fifo_wrreq : OUT STD_LOGIC;
      fifo_wdata : OUT STD_LOGIC_VECTOR(iq_width * 4 - 1 DOWNTO 0);
      --sample compare
      smpl_cmp_start : IN STD_LOGIC;
      smpl_cmp_length : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      smpl_cmp_done : OUT STD_LOGIC;
      smpl_cmp_err : OUT STD_LOGIC;

      --added by B.J. 
      diq_h : OUT STD_LOGIC_VECTOR (iq_width DOWNTO 0);
      diq_l : OUT STD_LOGIC_VECTOR (iq_width DOWNTO 0);
      cap_en : IN STD_LOGIC

   );
END diq2fifo;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE arch OF diq2fifo IS
   --declare signals,  components here
   SIGNAL inst0_diq_out_h : STD_LOGIC_VECTOR (iq_width DOWNTO 0);
   SIGNAL inst0_diq_out_l : STD_LOGIC_VECTOR (iq_width DOWNTO 0);
   SIGNAL inst0_reset_n : STD_LOGIC;

   SIGNAL inst2_data_h : STD_LOGIC_VECTOR (iq_width DOWNTO 0);
   SIGNAL inst2_data_l : STD_LOGIC_VECTOR (iq_width DOWNTO 0);

   SIGNAL inst3_reset_n : STD_LOGIC;

   SIGNAL mux0_diq_h : STD_LOGIC_VECTOR (iq_width DOWNTO 0);
   SIGNAL mux0_diq_l : STD_LOGIC_VECTOR (iq_width DOWNTO 0);

   SIGNAL mux0_diq_h_reg : STD_LOGIC_VECTOR (iq_width DOWNTO 0);
   SIGNAL mux0_diq_l_reg : STD_LOGIC_VECTOR (iq_width DOWNTO 0);

BEGIN

   -- added by B.J.
   diq_h <= inst0_diq_out_h;
   diq_l <= inst0_diq_out_l;

   -- inst0_reset_n <= reset_n WHEN smpl_cmp_start = '0' ELSE  '1';
   -- modified by B.J.

   lab0: if  DPDTopWrapper_enable=1 generate
      inst0_reset_n <= cap_en when smpl_cmp_start = '0' else '1';  
   end generate;     
   
   lab1: if  DPDTopWrapper_enable=0 generate
      inst0_reset_n <= reset_n when smpl_cmp_start = '0' else '1';   
   end generate;

   inst0_lms7002_ddin : ENTITY work.lms7002_ddin
      GENERIC MAP(
         dev_family => dev_family,
         iq_width => iq_width,
         invert_input_clocks => invert_input_clocks
      )
      PORT MAP(
         clk => clk,
         reset_n => inst0_reset_n,
         rxiq => DIQ,
         rxiqsel => fsync,
         data_out_h => inst0_diq_out_h,
         data_out_l => inst0_diq_out_l
      );

   inst1_rxiq : ENTITY work.rxiq
      GENERIC MAP(
         dev_family => dev_family,
         iq_width => iq_width
      )
      PORT MAP(
         clk => clk,
         reset_n => reset_n,
         trxiqpulse => trxiqpulse,
         ddr_en => ddr_en,
         mimo_en => mimo_en,
         ch_en => ch_en,
         fidm => fidm,
         DIQ_h => mux0_diq_h_reg,
         DIQ_l => mux0_diq_l_reg,
         fifo_wfull => fifo_wfull,
         fifo_wrreq => fifo_wrreq,
         fifo_wdata => fifo_wdata
      );

   int2_test_data_dd : ENTITY work.test_data_dd
      PORT MAP(

         clk => clk,
         reset_n => reset_n,
         fr_start => fidm,
         mimo_en => mimo_en,
         data_h => inst2_data_h,
         data_l => inst2_data_l

      );

   mux0_diq_h <= inst0_diq_out_h WHEN test_ptrn_en = '0' ELSE
      inst2_data_h;
   mux0_diq_l <= inst0_diq_out_l WHEN test_ptrn_en = '0' ELSE
      inst2_data_l;

   PROCESS (clk, reset_n)
   BEGIN
      IF reset_n = '0' THEN
         mux0_diq_h_reg <= (OTHERS => '0');
         mux0_diq_l_reg <= (OTHERS => '0');
      ELSIF (clk'event AND clk = '1') THEN
         mux0_diq_h_reg <= mux0_diq_h;
         mux0_diq_l_reg <= mux0_diq_l;
      END IF;
   END PROCESS;

   inst3_reset_n <= smpl_cmp_start;

   inst3_smpl_cmp : ENTITY work.smpl_cmp
      GENERIC MAP(
         smpl_width => iq_width
      )
      PORT MAP(

         clk => clk,
         reset_n => inst3_reset_n,
         
         --Mode settings
         mode => mode,
         trxiqpulse => trxiqpulse,
         ddr_en => ddr_en,
         mimo_en => mimo_en,
         ch_en => ch_en,
         fidm => fidm,
         
         --control and status
         cmp_start => smpl_cmp_start,
         cmp_length => smpl_cmp_length,
         cmp_AI => x"AAA",
         cmp_AQ => x"555",
         cmp_BI => x"AAA",
         cmp_BQ => x"555",
         cmp_done => smpl_cmp_done,
         cmp_error => smpl_cmp_err,
         --DIQ bus
         diq_h => inst0_diq_out_h,
         diq_l => inst0_diq_out_l
      );

END arch;