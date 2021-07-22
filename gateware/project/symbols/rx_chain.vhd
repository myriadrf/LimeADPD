-- Copyright (C) 2016  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 16.1.1 Build 200 11/30/2016 SJ Lite Edition"
-- CREATED		"Wed May 24 09:24:42 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all;


LIBRARY work;
use work.rxtspcfg_pkg.all; 

ENTITY rx_chain IS 
	PORT
	(
      clk            : IN  STD_LOGIC;
      nrst           : IN  STD_LOGIC;
      HBD_ratio      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      RXI            : IN  STD_LOGIC_VECTOR(17 DOWNTO 0);
      RXQ            : IN  STD_LOGIC_VECTOR(17 DOWNTO 0);
      xen            : OUT STD_LOGIC;
      RYI            : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
      RYQ            : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
      to_rxtspcfg    : out t_TO_RXTSPCFG;
      from_rxtspcfg  : in  t_FROM_RXTSPCFG
      
	);
END rx_chain;

ARCHITECTURE bdf_type OF rx_chain IS 

COMPONENT gcorr
	PORT(clk : IN STD_LOGIC;
		 nrst : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 byp : IN STD_LOGIC;
		 gc : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		 x : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 y : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
	);
END COMPONENT;

COMPONENT iqcorr
	PORT(clk : IN STD_LOGIC;
		 nrst : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 byp : IN STD_LOGIC;
		 pcw : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 xi : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 xq : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 yi : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		 yq : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dccorra
	PORT(clk : IN STD_LOGIC;
		 nrst : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 bypass : IN STD_LOGIC;
		 avg : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 xi : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 xq : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 yi : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		 yq : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
	);
END COMPONENT;

COMPONENT rxtspcfg
	PORT(mimo_en : IN STD_LOGIC;
		 sdin : IN STD_LOGIC;
		 sclk : IN STD_LOGIC;
		 sen : IN STD_LOGIC;
		 lreset : IN STD_LOGIC;
		 mreset : IN STD_LOGIC;
		 rxen : IN STD_LOGIC;
		 capd : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 maddress : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 rxtspout_i : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rxtspout_q : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 sdout : OUT STD_LOGIC;
		 oen : OUT STD_LOGIC;
		 en : OUT STD_LOGIC;
		 insel : OUT STD_LOGIC;
		 gc_byp : OUT STD_LOGIC;
		 ph_byp : OUT STD_LOGIC;
		 dc_byp : OUT STD_LOGIC;
		 agc_byp : OUT STD_LOGIC;
		 gfir1_byp : OUT STD_LOGIC;
		 gfir2_byp : OUT STD_LOGIC;
		 gfir3_byp : OUT STD_LOGIC;
		 cmix_byp : OUT STD_LOGIC;
		 cmix_sc : OUT STD_LOGIC;
		 bstart : OUT STD_LOGIC;
		 capture : OUT STD_LOGIC;
		 tsgdcldq : OUT STD_LOGIC;
		 tsgdcldi : OUT STD_LOGIC;
		 tsgswapiq : OUT STD_LOGIC;
		 tsgmode : OUT STD_LOGIC;
		 tsgfc : OUT STD_LOGIC;
		 rxdcloop_en : OUT STD_LOGIC;
		 agc_adesired : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 agc_avg : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 agc_k : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		 agc_mode : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 capsel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 cmix_gain : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 dc_reg : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 dccorr_avg : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 gcorri : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
		 gcorrq : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
		 gfir1l : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 gfir1n : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 gfir2l : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 gfir2n : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 gfir3l : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 gfir3n : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 hbd_dly : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 iqcorr : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 ovr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 rssi_mode : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 stateo : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 tsgfcw : OUT STD_LOGIC_VECTOR(8 DOWNTO 7)
	);
END COMPONENT;

COMPONENT pulse_gen
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 n : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 pulse_out : OUT STD_LOGIC
	);
END COMPONENT;

signal   sen_int : std_logic; 

SIGNAL	dc_byp :  STD_LOGIC;
SIGNAL	dccorr :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	gc_byp :  STD_LOGIC;
SIGNAL	gci :  STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL	gcq :  STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL	H :  STD_LOGIC;
SIGNAL	i_dccorr :  STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL	i_iqcorr :  STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL	iqcorrctr :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	L :  STD_LOGIC;
SIGNAL	mod_en :  STD_LOGIC;
SIGNAL	ph_byp :  STD_LOGIC;
SIGNAL	q_dccorr :  STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL	q_iqcorr :  STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(0 TO 31);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(0 TO 15);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(0 TO 15);

SIGNAL	GDFX_TEMP_SIGNAL_0 :  STD_LOGIC_VECTOR(9 DOWNTO 0);


signal mod_en_sync     : std_logic;
signal gc_byp_sync     : std_logic;
signal ph_byp_sync     : std_logic;
signal dc_byp_sync     : std_logic;
signal dccorr_sync     : std_logic_vector(2 downto 0);
signal gci_sync        : std_logic_vector(10 DOWNTO 0);
signal gcq_sync        : std_logic_vector(10 DOWNTO 0);
signal iqcorrctr_sync  : std_logic_vector(11 DOWNTO 0);







BEGIN 

sync_reg0 : entity work.sync_reg 
port map(clk, '1', mod_en, mod_en_sync);

sync_reg1 : entity work.sync_reg 
port map(clk, '1', gc_byp, gc_byp_sync);

sync_reg2 : entity work.sync_reg 
port map(clk, '1', ph_byp, ph_byp_sync);

sync_reg3 : entity work.sync_reg 
port map(clk, '1', dc_byp, dc_byp_sync);

bus_sync_reg0 : entity work.bus_sync_reg
   generic map(
      bus_width   => 3
   )
   port map(
      clk         => clk,
      reset_n     => '1',
      async_in    => dccorr,
      sync_out    => dccorr_sync
        );
        
bus_sync_reg1 : entity work.bus_sync_reg
   generic map(
      bus_width   => 11
   )
   port map(
      clk         => clk,
      reset_n     => '1',
      async_in    => gci,
      sync_out    => gci_sync
        );
        
bus_sync_reg2 : entity work.bus_sync_reg
   generic map(
      bus_width   => 11
   )
   port map(
      clk         => clk,
      reset_n     => '1',
      async_in    => gcq,
      sync_out    => gcq_sync
        );
        
bus_sync_reg3 : entity work.bus_sync_reg
   generic map(
      bus_width   => 12
   )
   port map(
      clk         => clk,
      reset_n     => '1',
      async_in    => iqcorrctr,
      sync_out    => iqcorrctr_sync
        );

--sen_int <= sen when mac_en = '1' else '1';

SYNTHESIZED_WIRE_0 <= "00000000000000000000000000000000";
SYNTHESIZED_WIRE_1 <= "0000000000000000";
SYNTHESIZED_WIRE_2 <= "0000000000000000";

GDFX_TEMP_SIGNAL_0 <= (L & L & L & L & L & L & L & H & L & H);


b2v_inst : gcorr
PORT MAP(clk => clk,
		 nrst => nrst,
		 en => mod_en_sync,
		 byp => gc_byp_sync,
		 gc => gci_sync,
		 x => RXI,
		 y => i_iqcorr);


b2v_inst1 : gcorr
PORT MAP(clk => clk,
		 nrst => nrst,
		 en => mod_en_sync,
		 byp => gc_byp_sync,
		 gc => gcq_sync,
		 x => RXQ,
		 y => q_iqcorr);





b2v_inst2 : iqcorr
PORT MAP(clk => clk,
		 nrst => nrst,
		 en => mod_en_sync,
		 byp => ph_byp_sync,
		 pcw => iqcorrctr_sync,
		 xi => i_iqcorr,
		 xq => q_iqcorr,
		 yi => i_dccorr,
		 yq => q_dccorr);


b2v_inst3 : dccorra
PORT MAP(clk => clk,
		 nrst => nrst,
		 en => mod_en_sync,
		 bypass => dc_byp_sync,
		 avg => dccorr_sync,
		 xi => i_dccorr,
		 xq => q_dccorr,
		 yi => RYI,
		 yq => RYQ);


--b2v_inst4 : rxtspcfg
--PORT MAP(mimo_en => H,
--		 sdin => sdin,
--		 sclk => sclk,
--		 sen => sen_int,
--		 lreset => memrstn,
--		 mreset => memrstn,
--		 rxen => H,
--		 capd => SYNTHESIZED_WIRE_0,
--		 maddress => GDFX_TEMP_SIGNAL_0,
--		 rxtspout_i => SYNTHESIZED_WIRE_1,
--		 rxtspout_q => SYNTHESIZED_WIRE_2,
--		 sdout => sdout,
--		 en => mod_en,
--		 gc_byp => gc_byp,
--		 ph_byp => ph_byp,
--		 dc_byp => dc_byp,
--		 dccorr_avg => dccorr,
--		 gcorri => gci,
--		 gcorrq => gcq,
--		 iqcorr => iqcorrctr);
       
      to_rxtspcfg.rxen        <= '1';
      to_rxtspcfg.capd        <= SYNTHESIZED_WIRE_0;
      to_rxtspcfg.rxtspout_i  <= SYNTHESIZED_WIRE_1;
      to_rxtspcfg.rxtspout_q  <= SYNTHESIZED_WIRE_2;
      
      mod_en   <= from_rxtspcfg.en;
      gc_byp   <= from_rxtspcfg.gc_byp; 
      ph_byp   <= from_rxtspcfg.ph_byp;
      dc_byp   <= from_rxtspcfg.dc_byp;
      dccorr   <= from_rxtspcfg.dccorr_avg;
      gci      <= from_rxtspcfg.gcorri;
      gcq      <= from_rxtspcfg.gcorrq;
      iqcorrctr<= from_rxtspcfg.iqcorr; 

--b2v_inst47 : pulse_gen
--PORT MAP(clk => clk,
--		 reset_n => nrst,
--		 n => HBD_ratio,
--		 pulse_out => xen);




H <= '1';
L <= '0';
END bdf_type;