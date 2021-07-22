-- ----------------------------------------------------------------------------	
-- FILE:	lmlicfg_wrapp.vhd
-- DESCRIPTION:	wrapper file for fpgacfg.vhd
-- DATE:	June 15, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:	
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lmlicfg_wrapp is
   port (
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress             : in std_logic_vector(9 downto 0);
      mimo_en              : in std_logic;   -- MIMO enable, from TOP SPI (always 1)
   
      -- Serial port IOs
      sdin                 : in std_logic;   -- Data in
      sclk                 : in std_logic;   -- Data clock
      sen                  : in std_logic;   -- Enable signal (active low)
      sdout                : out std_logic;  -- Data out
   
      -- Signals coming from the pins or top level serial interface
      lreset               : in std_logic;   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset               : in std_logic;   -- Memory reset signal, resets configuration memory only (use only one reset)
      mac_en               : in std_logic := '1';
      
      --Interface Config   
      lmli_ch_en           : out std_logic_vector(1 downto 0);
      lmli_smpl_width      : out std_logic_vector(1 downto 0);
      lmli_mimo_int_en     : out std_logic;
      lmli_synch_dis       : out std_logic;
      lmli_dlb_en          : out std_logic;
      lmli_smpl_nr_clr     : out std_logic;
      lmli_txpct_loss_clr  : out std_logic;
      lmli_rx_en           : out std_logic;
      lmli_tx_en           : out std_logic;
      lmli_rx_ptrn_en		: out std_logic;
		lmli_tx_ptrn_en		: out std_logic;
		lmli_tx_cnt_en		   : out std_logic;
      wfm_play             : out std_logic;
      wfm_load             : out std_logic;
      wfm_ch_en            : out std_logic_vector(1 downto 0);
      wfm_smpl_width       : out std_logic_vector(1 downto 0)
   
   );
end lmlicfg_wrapp;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lmlicfg_wrapp is

signal fpgacfg_inst0_ch_en          : std_logic_vector(15 downto 0);    
signal fpgacfg_inst0_smpl_width     : std_logic_vector(1 downto 0);
signal fpgacfg_inst0_mimo_int_en    : std_logic;
signal fpgacfg_inst0_synch_dis      : std_logic;
signal fpgacfg_inst0_dlb_en         : std_logic;      
signal fpgacfg_inst0_smpl_nr_clr    : std_logic_vector(2 downto 0);
signal fpgacfg_inst0_txpct_loss_clr : std_logic_vector(2 downto 0);
signal fpgacfg_inst0_rx_en          : std_logic_vector(2 downto 0);
signal fpgacfg_inst0_tx_en          : std_logic_vector(2 downto 0);
signal fpgacfg_inst0_rx_ptrn_en     : std_logic;  
signal fpgacfg_inst0_tx_ptrn_en     : std_logic;  
signal fpgacfg_inst0_tx_cnt_en      : std_logic;  
signal fpgacfg_inst0_wfm_play       : std_logic_vector(2 downto 0);
signal fpgacfg_inst0_wfm_load       : std_logic_vector(2 downto 0);
signal fpgacfg_inst0_wfm0_ch_en     : std_logic_vector(15 downto 0);
signal fpgacfg_inst0_wfm0_smpl_width: std_logic_vector(1 downto 0);



begin


fpgacfg_inst0 :  entity work.fpgacfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress          => maddress,
      mimo_en           => mimo_en, -- MIMO enable, from TOP SPI (always 1)
   
      -- Serial port IOs
      sdin              => sdin,    -- Data in
      sclk              => sclk,    -- Data clock
      sen               => sen,     -- Enable signal (active low)
      sdout             => sdout,   -- Data out
   
      -- Signals coming from the pins or top level serial interface
      lreset            => lreset,  -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset            => mreset,  -- Memory reset signal, resets configuration memory only (use only one reset)
      mac_en            => mac_en,
      HW_VER            => (others=>'0'),
      BOM_VER           => (others=>'0'),
         
      oen               => open,
      stateo            => open,
      
      
      --FPGA direct clocking
      phase_reg_sel     => open,
      clk_ind           => open,
      cnt_ind           => open,
      load_phase_reg    => open,
      drct_clk_en       => open,
      --Interface Config   
      ch_en             => fpgacfg_inst0_ch_en,
      smpl_width        => fpgacfg_inst0_smpl_width,
      mimo_int_en       => fpgacfg_inst0_mimo_int_en,
      synch_dis         => fpgacfg_inst0_synch_dis,
      dlb_en            => fpgacfg_inst0_dlb_en,
      smpl_nr_clr       => fpgacfg_inst0_smpl_nr_clr,
      txpct_loss_clr    => fpgacfg_inst0_txpct_loss_clr,
      rx_en             => fpgacfg_inst0_rx_en,
      tx_en             => fpgacfg_inst0_tx_en,
      rx_ptrn_en		   => fpgacfg_inst0_rx_ptrn_en,
		tx_ptrn_en		   => fpgacfg_inst0_tx_ptrn_en,
		tx_cnt_en		   => fpgacfg_inst0_tx_cnt_en,
      wfm_play          => fpgacfg_inst0_wfm_play,
      wfm_load          => fpgacfg_inst0_wfm_load,
      wfm0_ch_en        => fpgacfg_inst0_wfm0_ch_en,
      wfm0_smpl_width   => fpgacfg_inst0_wfm0_smpl_width,
      wfm1_ch_en        => open,
      wfm1_smpl_width   => open,
      
      SPI_SS            => open,
         
      LMS1_SS           => open,
      LMS2_SS           => open,
--      ADF_SS             => open,
--      DAC_SS             => open,
--      POT1_SS            => open,
      
      LMS1_RESET        => open,
      LMS1_CORE_LDO_EN  => open,
      LMS1_TXNRX1       => open,
      LMS1_TXNRX2       => open,
      LMS1_TXEN         => open,
      LMS1_RXEN         => open,
      LMS2_RESET        => open,
      LMS2_CORE_LDO_EN  => open,
      LMS2_TXNRX1       => open,
      LMS2_TXNRX2       => open,
      LMS2_TXEN         => open,
      LMS2_RXEN         => open,
      GPIO              => open,
      FPGA_LED1_CTRL    => open,
      FPGA_LED2_CTRL    => open,
      FX3_LED_CTRL      => open,
      FCLK_ENA          => open,
      data_src          => open,
      mac               => open
   
   );
   
   lmli_ch_en           <= fpgacfg_inst0_ch_en(1 downto 0);	
   lmli_smpl_width      <= fpgacfg_inst0_smpl_width;
   lmli_mimo_int_en     <= fpgacfg_inst0_mimo_int_en;
   lmli_synch_dis       <= fpgacfg_inst0_synch_dis;
   lmli_dlb_en          <= fpgacfg_inst0_dlb_en;
   lmli_smpl_nr_clr     <= fpgacfg_inst0_smpl_nr_clr(0);
   lmli_txpct_loss_clr  <= fpgacfg_inst0_txpct_loss_clr(0);
   lmli_rx_en           <= fpgacfg_inst0_rx_en(0);
   lmli_tx_en           <= fpgacfg_inst0_tx_en(0);
   lmli_rx_ptrn_en		<= fpgacfg_inst0_rx_ptrn_en;
   lmli_tx_ptrn_en		<= fpgacfg_inst0_tx_ptrn_en;
   lmli_tx_cnt_en		   <= fpgacfg_inst0_tx_cnt_en;
   wfm_play             <= fpgacfg_inst0_wfm_play(0);
   wfm_load             <= fpgacfg_inst0_wfm_load(0);
   wfm_ch_en            <= fpgacfg_inst0_wfm0_ch_en(1 downto 0);
   wfm_smpl_width       <= fpgacfg_inst0_wfm0_smpl_width;
   
   


end arch;
