-- ----------------------------------------------------------------------------	
-- FILE:	qpsmc19x14.vhd
-- DESCRIPTION:	Quadrature Phase to Sine Magnitude Converter. It converts
--		19 bits phase into two 14 bit quadrature outputs. Outputs
--		can take two's complement or binary offset formats.
-- DATE: 	Dec 14, 1999.
-- AUTHOR(s):	Microelectronics Centre Design Team
--		MUMEC
--		Bounds Green Road
--		London N11 2NQ
-- REVISIONS:	Jan 02, 2000:	Phase latching stage moved to phase accumulator.
--		Jan 07, 2000:	Problem with adders width fixed.
--		Jan 08, 2000:	Sine phase control added.
--		Jan 09, 2000:	Multiplication by -1 changed.
--		Aug 02, 2001:	Enable signal added. Removed on Nov 27, 2001
--				due to huge load on sleep/enable signals.
-- TO DO:
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity qpsmc19x14 is
    port (
	phase: in std_logic_vector(18 downto 0); -- Input phase
	sin: out std_logic_vector(13 downto 0); -- In phase output signal
	cos: out std_logic_vector(13 downto 0); -- Quadrature output signal 
	ofc: in std_logic; 	-- Output Format Control 
	clk: in std_logic;	-- Clock, enable and reset
	reset: in std_logic;
	spc: in std_logic	-- Sine Phase Control signal
    );
end qpsmc19x14;

-- ----------------------------------------------------------------------------
-- Architecture of qpsmc19x14								
-- ----------------------------------------------------------------------------
architecture qpsmc19x14_arch of qpsmc19x14 is
	signal ph: std_logic_vector(15 downto 0); -- 16 bit input to Walsh processors
	signal pha, phb, phc: std_logic_vector(2 downto 0); -- Three MSB of phase
	signal phd: std_logic_vector(3 downto 0);

	-- Walsh signals
	-- --------------------------------------------------------------------
	signal
		wal_0, wal_1, wal_2, wal_3, wal_4, wal_5, wal_6, 
		wal_7, wal_8, wal_9, wal_10, wal_11, wal_12, 
		wal_13, wal_14, wal_15, wal_16, wal_17, wal_18, 
		wal_19, wal_20, wal_21, wal_22, wal_23, wal_24, 
		wal_25, wal_26, wal_28, wal_32, wal_33, wal_34, 
		wal_35, wal_36, wal_37, wal_38, wal_40, wal_41, 
		wal_42, wal_44, wal_48, wal_49, wal_50, wal_52, 
		wal_64, wal_65, wal_66, wal_67, wal_68, wal_69, 
		wal_70, wal_72, wal_73, wal_74, wal_76, wal_80, 
		wal_81, wal_82, wal_96, wal_97, wal_128, wal_129, 
		wal_130, wal_131, wal_132, wal_133, wal_134, wal_136, 
		wal_137, wal_138, wal_144, wal_145, wal_160, wal_256, 
		wal_257, wal_258, wal_259, wal_260, wal_261, wal_262, 
		wal_264, wal_265, wal_272, wal_512, wal_513, wal_514, 
		wal_515, wal_516, wal_517, wal_520, wal_1024, wal_1025, 
		wal_1026, wal_1027, wal_1028, wal_2048, wal_2049, wal_2050, 
		wal_4096, wal_4097, wal_8192, wal_16384, wal_32768
		:std_logic;						       

	-- Extra wal-s for cosine 
	signal wal_27, wal_39, wal_192, wal_288, wal_528, wal_1032,
		wal_2052, wal_4098, wal_8193: std_logic;
			
	-- Terms of the sine sum
	-- --------------------------------------------------------------------
	signal
		sine_wt_0, sine_wt_1, sine_wt_2, sine_wt_3, sine_wt_4, 
		sine_wt_5, sine_wt_6, sine_wt_7, sine_wt_8, 
		sine_wt_9, sine_wt_10, sine_wt_11, sine_wt_12, 
		sine_wt_13, sine_wt_14, sine_wt_15, sine_wt_16, 
		sine_wt_17, sine_wt_18, sine_wt_19, sine_wt_20, 
		sine_wt_21, sine_wt_22, sine_wt_23, sine_wt_24, 
		sine_wt_25, sine_wt_26, sine_wt_28, sine_wt_32, 
		sine_wt_33, sine_wt_34, sine_wt_35, sine_wt_36, 
		sine_wt_37, sine_wt_38, sine_wt_40, sine_wt_41, 
		sine_wt_42, sine_wt_44, sine_wt_48, sine_wt_49, 
		sine_wt_50, sine_wt_52, sine_wt_64, sine_wt_65, 
		sine_wt_66, sine_wt_67, sine_wt_68, sine_wt_69, 
		sine_wt_70, sine_wt_72, sine_wt_73, sine_wt_74, 
		sine_wt_76, sine_wt_80, sine_wt_81, sine_wt_82, 
		sine_wt_96, sine_wt_97, sine_wt_128, sine_wt_129, 
		sine_wt_130, sine_wt_131, sine_wt_132, sine_wt_133, 
		sine_wt_134, sine_wt_136, sine_wt_137, sine_wt_138, 
		sine_wt_144, sine_wt_145, sine_wt_160, sine_wt_256, 
		sine_wt_257, sine_wt_258, sine_wt_259, sine_wt_260, 
		sine_wt_261, sine_wt_262, sine_wt_264, sine_wt_265, 
		sine_wt_272, sine_wt_512, sine_wt_513, sine_wt_514, 
		sine_wt_515, sine_wt_516, sine_wt_517, sine_wt_520, 
		sine_wt_1024, sine_wt_1025, sine_wt_1026, sine_wt_1027, 
		sine_wt_1028, sine_wt_2048, sine_wt_2049, sine_wt_2050, 
		sine_wt_4096, sine_wt_4097, sine_wt_8192, sine_wt_16384, 
		sine_wt_32768
		:std_logic_vector(19 downto 0);
			
	-- Terms of the cosine sum
	-- --------------------------------------------------------------------
	signal
		cosine_wt_0, cosine_wt_1, cosine_wt_2, cosine_wt_3, cosine_wt_4, 
		cosine_wt_5, cosine_wt_6, cosine_wt_7, cosine_wt_8, 
		cosine_wt_9, cosine_wt_10, cosine_wt_11, cosine_wt_12, 
		cosine_wt_13, cosine_wt_14, cosine_wt_15, cosine_wt_16, 
		cosine_wt_17, cosine_wt_18, cosine_wt_19, cosine_wt_20, 
		cosine_wt_21, cosine_wt_22, cosine_wt_23, cosine_wt_24, 
		cosine_wt_25, cosine_wt_26, cosine_wt_27, cosine_wt_28, 
		cosine_wt_32, cosine_wt_33, cosine_wt_34, cosine_wt_35, 
		cosine_wt_36, cosine_wt_37, cosine_wt_38, cosine_wt_39, 
		cosine_wt_40, cosine_wt_41, cosine_wt_42, cosine_wt_48, 
		cosine_wt_49, cosine_wt_64, cosine_wt_65, cosine_wt_66, 
		cosine_wt_67, cosine_wt_68, cosine_wt_69, cosine_wt_70, 
		cosine_wt_72, cosine_wt_73, cosine_wt_80, cosine_wt_96, 
		cosine_wt_128, cosine_wt_129, cosine_wt_130, cosine_wt_131, 
		cosine_wt_132, cosine_wt_133, cosine_wt_136, cosine_wt_144, 
		cosine_wt_160, cosine_wt_192, cosine_wt_256, cosine_wt_257, 
		cosine_wt_258, cosine_wt_259, cosine_wt_260, cosine_wt_264, 
		cosine_wt_272, cosine_wt_288, cosine_wt_512, cosine_wt_513, 
		cosine_wt_514, cosine_wt_516, cosine_wt_520, cosine_wt_528, 
		cosine_wt_1024, cosine_wt_1025, cosine_wt_1026, cosine_wt_1028, 
		cosine_wt_1032, cosine_wt_2048, cosine_wt_2049, cosine_wt_2050, 
		cosine_wt_2052, cosine_wt_4096, cosine_wt_4097, cosine_wt_4098, 
		cosine_wt_8192, cosine_wt_8193, cosine_wt_16384
		:std_logic_vector(19 downto 0);

	-- Output signals of the first stage sine adders
	signal s_s1a0s, s_s1a0c: std_logic_vector(19 downto 0);
	signal s_s1a1s, s_s1a1c: std_logic_vector(16 downto 0);
	signal s_s1a2s, s_s1a2c: std_logic_vector(14 downto 0);
	signal s_s1a3s, s_s1a3c: std_logic_vector(12 downto 0);
	signal s_s1a4s, s_s1a4c: std_logic_vector(11 downto 0);
	signal s_s1a5s, s_s1a5c: std_logic_vector(10 downto 0);
	signal s_s1a6s, s_s1a6c: std_logic_vector(9 downto 0);
	signal s_s1a7s, s_s1a7c: std_logic_vector(9 downto 0);
	signal s_s1a8s, s_s1a8c: std_logic_vector(8 downto 0);
	signal s_s1a9s, s_s1a9c: std_logic_vector(8 downto 0);
	signal s_s1a10s, s_s1a10c: std_logic_vector(7 downto 0);
	signal s_s1a11s, s_s1a11c: std_logic_vector(7 downto 0);
	signal s_s1a12s, s_s1a12c: std_logic_vector(7 downto 0);
	signal s_s1a13s, s_s1a13c: std_logic_vector(7 downto 0);
	signal s_s1a14s, s_s1a14c: std_logic_vector(6 downto 0);
	signal s_s1a15s, s_s1a15c: std_logic_vector(6 downto 0);
	signal s_s1a16s, s_s1a16c: std_logic_vector(6 downto 0);

	-- Output signals of the first stage cosine adders
	signal c_s1a0s, c_s1a0c: std_logic_vector(19 downto 0);
	signal c_s1a1s, c_s1a1c: std_logic_vector(17 downto 0);
	signal c_s1a2s, c_s1a2c: std_logic_vector(15 downto 0);
	signal c_s1a3s, c_s1a3c: std_logic_vector(13 downto 0);
	signal c_s1a4s, c_s1a4c: std_logic_vector(12 downto 0);
	signal c_s1a5s, c_s1a5c: std_logic_vector(11 downto 0);
	signal c_s1a6s, c_s1a6c: std_logic_vector(10 downto 0);
	signal c_s1a7s, c_s1a7c: std_logic_vector(9 downto 0);
	signal c_s1a8s, c_s1a8c: std_logic_vector(9 downto 0);
	signal c_s1a9s, c_s1a9c: std_logic_vector(8 downto 0);
	signal c_s1a10s, c_s1a10c: std_logic_vector(8 downto 0);
	signal c_s1a11s, c_s1a11c: std_logic_vector(7 downto 0);
	signal c_s1a12s, c_s1a12c: std_logic_vector(7 downto 0);
	signal c_s1a13s, c_s1a13c: std_logic_vector(6 downto 0);
	signal c_s1a14s, c_s1a14c: std_logic_vector(6 downto 0);

	-- Input signals to the second stage sine adders
	signal s_s2a0in1, s_s2a0in2: std_logic_vector(19 downto 0);
	signal s_s2a0in3, s_s2a0in4: std_logic_vector(16 downto 0);
	signal s_s2a0in5, s_s2a0in6: std_logic_vector(14 downto 0);
	signal s_s2a0in7, s_s2a0in8: std_logic_vector(12 downto 0);
	signal s_s2a0in9: std_logic_vector(6 downto 0);
	
	signal s_s2a1in1, s_s2a1in2: std_logic_vector(11 downto 0);
	signal s_s2a1in3, s_s2a1in4: std_logic_vector(10 downto 0);
	signal s_s2a1in5, s_s2a1in6: std_logic_vector(9 downto 0);
	signal s_s2a1in7, s_s2a1in8: std_logic_vector(9 downto 0);

	signal s_s2a2in1, s_s2a2in2: std_logic_vector(8 downto 0);
	signal s_s2a2in3, s_s2a2in4: std_logic_vector(8 downto 0);
	signal s_s2a2in5, s_s2a2in6: std_logic_vector(7 downto 0);
	signal s_s2a2in7, s_s2a2in8: std_logic_vector(7 downto 0);

	signal s_s2a3in1, s_s2a3in2: std_logic_vector(7 downto 0);
	signal s_s2a3in3, s_s2a3in4: std_logic_vector(7 downto 0);
	signal s_s2a3in5, s_s2a3in6: std_logic_vector(6 downto 0);
	signal s_s2a3in7, s_s2a3in8: std_logic_vector(6 downto 0);

	signal s_s2for: std_logic_vector(6 downto 0); -- Forward to the next stage
	
	-- Input signals to the second stage cosine adders
	signal c_s2a0in1, c_s2a0in2: std_logic_vector(19 downto 0);
	signal c_s2a0in3, c_s2a0in4: std_logic_vector(17 downto 0);
	signal c_s2a0in5, c_s2a0in6: std_logic_vector(15 downto 0);
	signal c_s2a0in7, c_s2a0in8: std_logic_vector(13 downto 0);

	signal c_s2a1in1, c_s2a1in2: std_logic_vector(12 downto 0);
	signal c_s2a1in3, c_s2a1in4: std_logic_vector(11 downto 0);
	signal c_s2a1in5, c_s2a1in6: std_logic_vector(10 downto 0);
	signal c_s2a1in7, c_s2a1in8: std_logic_vector(9 downto 0);

	signal c_s2a2in1, c_s2a2in2: std_logic_vector(9 downto 0);
	signal c_s2a2in3, c_s2a2in4: std_logic_vector(8 downto 0);
	signal c_s2a2in5, c_s2a2in6: std_logic_vector(8 downto 0);
	signal c_s2a2in7, c_s2a2in8: std_logic_vector(7 downto 0);

	signal c_s2a3in1, c_s2a3in2: std_logic_vector(7 downto 0);
	signal c_s2a3in3, c_s2a3in4: std_logic_vector(6 downto 0);
	signal c_s2a3in5, c_s2a3in6: std_logic_vector(6 downto 0);
	signal c_s2a3in7, c_s2a3in8: std_logic_vector(3 downto 0);

	-- Output signals of the second stage sine adders
	signal s_s2a0s, s_s2a0c: std_logic_vector(19 downto 0);
	signal s_s2a1s, s_s2a1c: std_logic_vector(17 downto 0);
	signal s_s2a2s, s_s2a2c: std_logic_vector(13 downto 0);
	signal s_s2a3s, s_s2a3c: std_logic_vector(11 downto 0);

	-- Output signals of the second stage cosine adders
	signal c_s2a0s, c_s2a0c: std_logic_vector(19 downto 0);
	signal c_s2a1s, c_s2a1c: std_logic_vector(16 downto 0);
	signal c_s2a2s, c_s2a2c: std_logic_vector(13 downto 0);
	signal c_s2a3s, c_s2a3c: std_logic_vector(11 downto 0);
	
	-- Input signals to the third stage sine adder
	signal s_s3a0in1, s_s3a0in2: std_logic_vector(19 downto 0);
	signal s_s3a0in3, s_s3a0in4: std_logic_vector(17 downto 0);
	signal s_s3a0in5, s_s3a0in6: std_logic_vector(13 downto 0);
	signal s_s3a0in7, s_s3a0in8: std_logic_vector(11 downto 0);
	signal s_s3a0in9: std_logic_vector(6 downto 0);
	
	-- Input signals to the third stage cosine adder
	signal c_s3a0in1, c_s3a0in2: std_logic_vector(19 downto 0);
	signal c_s3a0in3, c_s3a0in4: std_logic_vector(16 downto 0);
	signal c_s3a0in5, c_s3a0in6: std_logic_vector(13 downto 0);
	signal c_s3a0in7, c_s3a0in8: std_logic_vector(11 downto 0);

	-- Output signals of the third stage sine adder
	signal s_s3a0s, s_s3a0c: std_logic_vector(19 downto 0);

	-- Output signals of the third stage cosine adder
	signal c_s3a0s, c_s3a0c: std_logic_vector(19 downto 0);

	-- Signals used in stage 4
	signal s_s4a0in1, s_s4a0in2: std_logic_vector(19 downto 0); 
	signal c_s4a0in1, c_s4a0in2: std_logic_vector(19 downto 0);
	signal s_s4a0s, c_s4a0s: std_logic_vector(9 downto 0);
	signal s_s4a0c, c_s4a0c: std_logic;

	-- Stage 5 signals
	signal ssign, csign, cmux: std_logic;
	
	signal s_s5a0in1, s_s5a0in2: std_logic_vector(9 downto 0);
	signal s_s5a0cin: std_logic;
	signal s_s5a0s, s_s5a0si: std_logic_vector(9 downto 0);
	
	signal s_s5a1in1i, s_s5a1in1: std_logic_vector(3 downto 0);
	signal s_s5a1s: std_logic_vector(3 downto 0);
	signal s_s5a1c: std_logic;
	
	signal c_s5a0in1, c_s5a0in2: std_logic_vector(9 downto 0);
	signal c_s5a0cin: std_logic;
	signal c_s5a0s, c_s5a0si: std_logic_vector(9 downto 0);

	signal c_s5a1in1i, c_s5a1in1: std_logic_vector(3 downto 0);
	signal c_s5a1s: std_logic_vector(3 downto 0);
	signal c_s5a1c: std_logic;

	-- Stage 6 signals
	signal cmuxa: std_logic;
	
	signal s_s6a0in1: std_logic_vector(9 downto 0);
	signal s_s6a0cin: std_logic;
	
	signal c_s6a0in1: std_logic_vector(9 downto 0);
	signal c_s6a0cin: std_logic;
	
	signal s, c: std_logic_vector(13 downto 0);
	signal si, co: std_logic_vector(13 downto 0);
	signal s13, c13: std_logic;
	
	-- Logic signals
	signal one, zero: std_logic;
	signal zero4: std_logic_vector(3 downto 0);
	signal zero10: std_logic_vector(9 downto 0);
	
	-- Component declarations
	use work.components.bcla4;
	use work.components.csa10;
	use work.components.csava20x6;
	use work.components.csava18x6;
	use work.components.csava17x6;
	use work.components.csava16x6;
	use work.components.csava15x6;
	use work.components.csava14x6;
	use work.components.csava13x6;
	use work.components.csava12x6;
	use work.components.csava11x6;
	use work.components.csava10x6;
	use work.components.csava9x6;
	use work.components.csava8x6;
	use work.components.csava7x6;
	use work.components.csava20x8;
	use work.components.csava18x8;
	use work.components.csava17x8;
	use work.components.csava14x8;
	use work.components.csava12x8;
	use work.components.csava20x9;
	
	for all:bcla4 use entity work.bcla4(bcla4_arch);
	for all:csa10 use entity work.csa10(csa10_arch);
	for all:csava20x6 use entity work.csava20x6(csava20x6_arch);
	for all:csava18x6 use entity work.csava18x6(csava18x6_arch);
	for all:csava17x6 use entity work.csava17x6(csava17x6_arch);
	for all:csava16x6 use entity work.csava16x6(csava16x6_arch);
	for all:csava15x6 use entity work.csava15x6(csava15x6_arch);
	for all:csava14x6 use entity work.csava14x6(csava14x6_arch);
	for all:csava13x6 use entity work.csava13x6(csava13x6_arch);
	for all:csava12x6 use entity work.csava12x6(csava12x6_arch);
	for all:csava11x6 use entity work.csava11x6(csava11x6_arch);
	for all:csava10x6 use entity work.csava10x6(csava10x6_arch);
	for all:csava9x6 use entity work.csava9x6(csava9x6_arch);
	for all:csava8x6 use entity work.csava8x6(csava8x6_arch);
	for all:csava7x6 use entity work.csava7x6(csava7x6_arch);
	for all:csava20x8 use entity work.csava20x8(csava20x8_arch);
	for all:csava18x8 use entity work.csava18x8(csava18x8_arch);
	for all:csava17x8 use entity work.csava17x8(csava17x8_arch);
	for all:csava14x8 use entity work.csava14x8(csava14x8_arch);
	for all:csava12x8 use entity work.csava12x8(csava12x8_arch);
	for all:csava20x9 use entity work.csava20x9(csava20x9_arch);
	
begin	
	-- Set logic signals
	one <= '1';
	zero <= '0';
	zero4 <= "0000";
	zero10 <= "0000000000";
	
	-- Invert phase(15 downto 0) for every second octant
	ph <= 	phase(15 downto 0) when phase(16) = '0' else
		not phase(15 downto 0);

	-- Convert Rademacher to Walsh signals
	-- --------------------------------------------------------------------
	wal_0 <= '0';
	wal_1 <= ph(15);
	wal_2 <= ph(14);
	wal_3 <= ph(15) xor ph(14);
	wal_4 <= ph(13);
	wal_5 <= ph(15) xor ph(13);
	wal_6 <= ph(14) xor ph(13);
	wal_7 <= ph(15) xor ph(14) xor ph(13);
	wal_8 <= ph(12);
	wal_9 <= ph(15) xor ph(12);
	wal_10 <= ph(14) xor ph(12);
	wal_11 <= ph(15) xor ph(14) xor ph(12);
	wal_12 <= ph(13) xor ph(12);
	wal_13 <= ph(15) xor ph(13) xor ph(12);
	wal_14 <= ph(14) xor ph(13) xor ph(12);
	wal_15 <= ph(15) xor ph(14) xor ph(13) xor ph(12);
	wal_16 <= ph(11);
	wal_17 <= ph(15) xor ph(11);
	wal_18 <= ph(14) xor ph(11);
	wal_19 <= ph(15) xor ph(14) xor ph(11);
	wal_20 <= ph(13) xor ph(11);
	wal_21 <= ph(15) xor ph(13) xor ph(11);
	wal_22 <= ph(14) xor ph(13) xor ph(11);
	wal_23 <= ph(15) xor ph(14) xor ph(13) xor ph(11);
	wal_24 <= ph(12) xor ph(11);
	wal_25 <= ph(15) xor ph(12) xor ph(11);
	wal_26 <= ph(14) xor ph(12) xor ph(11);	     
	wal_27 <= ph(15) xor ph(14) xor ph(12) xor ph(11);
	wal_28 <= ph(13) xor ph(12) xor ph(11);
	wal_32 <= ph(10);
	wal_33 <= ph(15) xor ph(10);
	wal_34 <= ph(14) xor ph(10);
	wal_35 <= ph(15) xor ph(14) xor ph(10);
	wal_36 <= ph(13) xor ph(10);
	wal_37 <= ph(15) xor ph(13) xor ph(10);
	wal_38 <= ph(14) xor ph(13) xor ph(10);			      
	wal_39 <= ph(15) xor ph(14) xor ph(13) xor ph(10);
	wal_40 <= ph(12) xor ph(10);
	wal_41 <= ph(15) xor ph(12) xor ph(10);
	wal_42 <= ph(14) xor ph(12) xor ph(10);
	wal_44 <= ph(13) xor ph(12) xor ph(10);
	wal_48 <= ph(11) xor ph(10);
	wal_49 <= ph(15) xor ph(11) xor ph(10);
	wal_50 <= ph(14) xor ph(11) xor ph(10);
	wal_52 <= ph(13) xor ph(11) xor ph(10);
	wal_64 <= ph(9);
	wal_65 <= ph(15) xor ph(9);
	wal_66 <= ph(14) xor ph(9);
	wal_67 <= ph(15) xor ph(14) xor ph(9);
	wal_68 <= ph(13) xor ph(9);
	wal_69 <= ph(15) xor ph(13) xor ph(9);
	wal_70 <= ph(14) xor ph(13) xor ph(9);
	wal_72 <= ph(12) xor ph(9);
	wal_73 <= ph(15) xor ph(12) xor ph(9);
	wal_74 <= ph(14) xor ph(12) xor ph(9);
	wal_76 <= ph(13) xor ph(12) xor ph(9);
	wal_80 <= ph(11) xor ph(9);
	wal_81 <= ph(15) xor ph(11) xor ph(9);
	wal_82 <= ph(14) xor ph(11) xor ph(9);
	wal_96 <= ph(10) xor ph(9);
	wal_97 <= ph(15) xor ph(10) xor ph(9);
	wal_128 <= ph(8);
	wal_129 <= ph(15) xor ph(8);
	wal_130 <= ph(14) xor ph(8);
	wal_131 <= ph(15) xor ph(14) xor ph(8);
	wal_132 <= ph(13) xor ph(8);
	wal_133 <= ph(15) xor ph(13) xor ph(8);
	wal_134 <= ph(14) xor ph(13) xor ph(8);
	wal_136 <= ph(12) xor ph(8);
	wal_137 <= ph(15) xor ph(12) xor ph(8);
	wal_138 <= ph(14) xor ph(12) xor ph(8);
	wal_144 <= ph(11) xor ph(8);
	wal_145 <= ph(15) xor ph(11) xor ph(8);
	wal_160 <= ph(10) xor ph(8);
	wal_192 <= ph(9) xor ph(8);
	wal_256 <= ph(7);
	wal_257 <= ph(15) xor ph(7);
	wal_258 <= ph(14) xor ph(7);
	wal_259 <= ph(15) xor ph(14) xor ph(7);
	wal_260 <= ph(13) xor ph(7);
	wal_261 <= ph(15) xor ph(13) xor ph(7);
	wal_262 <= ph(14) xor ph(13) xor ph(7);
	wal_264 <= ph(12) xor ph(7);
	wal_265 <= ph(15) xor ph(12) xor ph(7);
	wal_272 <= ph(11) xor ph(7);
	wal_288 <= ph(10) xor ph(7);
	wal_512 <= ph(6);
	wal_513 <= ph(15) xor ph(6);
	wal_514 <= ph(14) xor ph(6);
	wal_515 <= ph(15) xor ph(14) xor ph(6);
	wal_516 <= ph(13) xor ph(6);
	wal_517 <= ph(15) xor ph(13) xor ph(6);
	wal_520 <= ph(12) xor ph(6);
	wal_528 <= ph(11) xor ph(6);
	wal_1024 <= ph(5);
	wal_1025 <= ph(15) xor ph(5);
	wal_1026 <= ph(14) xor ph(5);
	wal_1027 <= ph(15) xor ph(14) xor ph(5);
	wal_1028 <= ph(13) xor ph(5);
	wal_1032 <= ph(12) xor ph(5);
	wal_2048 <= ph(4);
	wal_2049 <= ph(15) xor ph(4);
	wal_2050 <= ph(14) xor ph(4);
	wal_2052 <= ph(13) xor ph(4);
	wal_4096 <= ph(3);
	wal_4097 <= ph(15) xor ph(3);
	wal_4098 <= ph(14) xor ph(3);
	wal_8192 <= ph(2);	   
	wal_8193 <= ph(15) xor ph(2);
	wal_16384 <= ph(1);
	wal_32768 <= ph(0);

	-- Calculate the product of Walsh signals and WFT coefficients       
	-- --------------------------------------------------------------------
	sine_wt_0 <= 	"11010000010001000010" when wal_0 = '1' else
			"00101111101110111110";
	sine_wt_1 <= 	"00010110111010110100" when wal_1 = '1' else
			"11101001000101001100";
	sine_wt_2 <= 	"00001011010110010010" when wal_2 = '1' else
			"11110100101001101110";
	sine_wt_3 <= 	"00000000111011110110" when wal_3 = '1' else
			"11111111000100001010";
	sine_wt_4 <= 	"00000101101010010001" when wal_4 = '1' else
			"11111010010101101111";
	sine_wt_5 <= 	"00000000011101110110" when wal_5 = '1' else
			"11111111100010001010";
	sine_wt_6 <= 	"00000000001110110010" when wal_6 = '1' else
			"11111111110001001110";
	sine_wt_7 <= 	"11111111111000111010" when wal_7 = '1' else
			"00000000000111000110";
	sine_wt_8 <= 	"00000010110101000010" when wal_8 = '1' else
			"11111101001010111110";
	sine_wt_9 <= 	"00000000001110111011" when wal_9 = '1' else
			"11111111110001000101";
	sine_wt_10 <= 	"00000000000111011001" when wal_10 = '1' else
			"11111111111000100111";
	sine_wt_11 <= 	"11111111111100011101" when wal_11 = '1' else
			"00000000000011100011";
	sine_wt_12 <= 	"00000000000011101100" when wal_12 = '1' else
			"11111111111100010100";
	sine_wt_13 <= 	"11111111111110001111" when wal_13 = '1' else
			"00000000000001110001";
	sine_wt_14 <= 	"11111111111111001000" when wal_14 = '1' else
			"00000000000000111000";
	sine_wt_15 <= 	"11111111111111111011" when wal_15 = '1' else
			"00000000000000000101";
	sine_wt_16 <= 	"00000001011010100000" when wal_16 = '1' else
			"11111110100101100000";
	sine_wt_17 <= 	"00000000000111011101" when wal_17 = '1' else
			"11111111111000100011";
	sine_wt_18 <= 	"00000000000011101100" when wal_18 = '1' else
			"11111111111100010100";
	sine_wt_19 <= 	"11111111111110001111" when wal_19 = '1' else
			"00000000000001110001";
	sine_wt_20 <= 	"00000000000001110110" when wal_20 = '1' else
			"11111111111110001010";
	sine_wt_21 <= 	"11111111111111000111" when wal_21 = '1' else
			"00000000000000111001";
	sine_wt_22 <= 	"11111111111111100100" when wal_22 = '1' else
			"00000000000000011100";
	sine_wt_23 <= 	"11111111111111111110" when wal_23 = '1' else
			"00000000000000000010";
	sine_wt_24 <= 	"00000000000000111011" when wal_24 = '1' else
			"11111111111111000101";
	sine_wt_25 <= 	"11111111111111100100" when wal_25 = '1' else
			"00000000000000011100";
	sine_wt_26 <= 	"11111111111111110010" when wal_26 = '1' else
			"00000000000000001110";
	sine_wt_28 <= 	"11111111111111111001" when wal_28 = '1' else
			"00000000000000000111";
	sine_wt_32 <= 	"00000000101101010000" when wal_32 = '1' else
			"11111111010010110000";
	sine_wt_33 <= 	"00000000000011101111" when wal_33 = '1' else
			"11111111111100010001";
	sine_wt_34 <= 	"00000000000001110110" when wal_34 = '1' else
			"11111111111110001010";
	sine_wt_35 <= 	"11111111111111000111" when wal_35 = '1' else
			"00000000000000111001";
	sine_wt_36 <= 	"00000000000000111011" when wal_36 = '1' else
			"11111111111111000101";
	sine_wt_37 <= 	"11111111111111100100" when wal_37 = '1' else
			"00000000000000011100";
	sine_wt_38 <= 	"11111111111111110010" when wal_38 = '1' else
			"00000000000000001110";
	sine_wt_40 <= 	"00000000000000011101" when wal_40 = '1' else
			"11111111111111100011";
	sine_wt_41 <= 	"11111111111111110010" when wal_41 = '1' else
			"00000000000000001110";
	sine_wt_42 <= 	"11111111111111111001" when wal_42 = '1' else
			"00000000000000000111";
	sine_wt_44 <= 	"11111111111111111101" when wal_44 = '1' else
			"00000000000000000011";
	sine_wt_48 <= 	"00000000000000001111" when wal_48 = '1' else
			"11111111111111110001";
	sine_wt_49 <= 	"11111111111111111001" when wal_49 = '1' else
			"00000000000000000111";
	sine_wt_50 <= 	"11111111111111111100" when wal_50 = '1' else
			"00000000000000000100";
	sine_wt_52 <= 	"11111111111111111110" when wal_52 = '1' else
			"00000000000000000010";
	sine_wt_64 <= 	"00000000010110101000" when wal_64 = '1' else
			"11111111101001011000";
	sine_wt_65 <= 	"00000000000001110111" when wal_65 = '1' else
			"11111111111110001001";
	sine_wt_66 <= 	"00000000000000111011" when wal_66 = '1' else
			"11111111111111000101";
	sine_wt_67 <= 	"11111111111111100100" when wal_67 = '1' else
			"00000000000000011100";
	sine_wt_68 <= 	"00000000000000011101" when wal_68 = '1' else
			"11111111111111100011";
	sine_wt_69 <= 	"11111111111111110010" when wal_69 = '1' else
			"00000000000000001110";
	sine_wt_70 <= 	"11111111111111111001" when wal_70 = '1' else
			"00000000000000000111";
	sine_wt_72 <= 	"00000000000000001111" when wal_72 = '1' else
			"11111111111111110001";
	sine_wt_73 <= 	"11111111111111111001" when wal_73 = '1' else
			"00000000000000000111";
	sine_wt_74 <= 	"11111111111111111100" when wal_74 = '1' else
			"00000000000000000100";
	sine_wt_76 <= 	"11111111111111111110" when wal_76 = '1' else
			"00000000000000000010";
	sine_wt_80 <= 	"00000000000000000111" when wal_80 = '1' else
			"11111111111111111001";
	sine_wt_81 <= 	"11111111111111111100" when wal_81 = '1' else
			"00000000000000000100";
	sine_wt_82 <= 	"11111111111111111110" when wal_82 = '1' else
			"00000000000000000010";
	sine_wt_96 <= 	"00000000000000000100" when wal_96 = '1' else
			"11111111111111111100";
	sine_wt_97 <= 	"11111111111111111110" when wal_97 = '1' else
			"00000000000000000010";
	sine_wt_128 <= 	"00000000001011010100" when wal_128 = '1' else
			"11111111110100101100";
	sine_wt_129 <= 	"00000000000000111100" when wal_129 = '1' else
			"11111111111111000100";
	sine_wt_130 <= 	"00000000000000011110" when wal_130 = '1' else
			"11111111111111100010";
	sine_wt_131 <= 	"11111111111111110010" when wal_131 = '1' else
			"00000000000000001110";
	sine_wt_132 <= 	"00000000000000001111" when wal_132 = '1' else
			"11111111111111110001";
	sine_wt_133 <= 	"11111111111111111001" when wal_133 = '1' else
			"00000000000000000111";
	sine_wt_134 <= 	"11111111111111111100" when wal_134 = '1' else
			"00000000000000000100";
	sine_wt_136 <= 	"00000000000000000111" when wal_136 = '1' else
			"11111111111111111001";
	sine_wt_137 <= 	"11111111111111111100" when wal_137 = '1' else
			"00000000000000000100";
	sine_wt_138 <= 	"11111111111111111110" when wal_138 = '1' else
			"00000000000000000010";
	sine_wt_144 <= 	"00000000000000000100" when wal_144 = '1' else
			"11111111111111111100";
	sine_wt_145 <= 	"11111111111111111110" when wal_145 = '1' else
			"00000000000000000010";
	sine_wt_160 <= 	"00000000000000000010" when wal_160 = '1' else
			"11111111111111111110";
	sine_wt_256 <= 	"00000000000101101010" when wal_256 = '1' else
			"11111111111010010110";
	sine_wt_257 <= 	"00000000000000011110" when wal_257 = '1' else
			"11111111111111100010";
	sine_wt_258 <= 	"00000000000000001111" when wal_258 = '1' else
			"11111111111111110001";
	sine_wt_259 <= 	"11111111111111111001" when wal_259 = '1' else
			"00000000000000000111";
	sine_wt_260 <= 	"00000000000000000111" when wal_260 = '1' else
			"11111111111111111001";
	sine_wt_261 <= 	"11111111111111111100" when wal_261 = '1' else
			"00000000000000000100";
	sine_wt_262 <= 	"11111111111111111110" when wal_262 = '1' else
			"00000000000000000010";
	sine_wt_264 <= 	"00000000000000000100" when wal_264 = '1' else
			"11111111111111111100";
	sine_wt_265 <= 	"11111111111111111110" when wal_265 = '1' else
			"00000000000000000010";
	sine_wt_272 <= 	"00000000000000000010" when wal_272 = '1' else
			"11111111111111111110";
	sine_wt_512 <= 	"00000000000010110101" when wal_512 = '1' else
			"11111111111101001011";
	sine_wt_513 <= 	"00000000000000001111" when wal_513 = '1' else
			"11111111111111110001";
	sine_wt_514 <= 	"00000000000000000111" when wal_514 = '1' else
			"11111111111111111001";
	sine_wt_515 <= 	"11111111111111111100" when wal_515 = '1' else
			"00000000000000000100";
	sine_wt_516 <= 	"00000000000000000100" when wal_516 = '1' else
			"11111111111111111100";
	sine_wt_517 <= 	"11111111111111111110" when wal_517 = '1' else
			"00000000000000000010";
	sine_wt_520 <= 	"00000000000000000010" when wal_520 = '1' else
			"11111111111111111110";
	sine_wt_1024 <= "00000000000001011010" when wal_1024 = '1' else
			"11111111111110100110";
	sine_wt_1025 <= "00000000000000000111" when wal_1025 = '1' else
			"11111111111111111001";
	sine_wt_1026 <= "00000000000000000100" when wal_1026 = '1' else
			"11111111111111111100";
	sine_wt_1027 <= "11111111111111111110" when wal_1027 = '1' else
			"00000000000000000010";
	sine_wt_1028 <= "00000000000000000010" when wal_1028 = '1' else
			"11111111111111111110";
	sine_wt_2048 <= "00000000000000101101" when wal_2048 = '1' else
			"11111111111111010011";
	sine_wt_2049 <= "00000000000000000100" when wal_2049 = '1' else
			"11111111111111111100";
	sine_wt_2050 <= "00000000000000000010" when wal_2050 = '1' else
			"11111111111111111110";
	sine_wt_4096 <= "00000000000000010111" when wal_4096 = '1' else
			"11111111111111101001";
	sine_wt_4097 <= "00000000000000000010" when wal_4097 = '1' else
			"11111111111111111110";
	sine_wt_8192 <= "00000000000000001011" when wal_8192 = '1' else
			"11111111111111110101";
	sine_wt_16384 <= "00000000000000000110" when wal_16384 = '1' else
			"11111111111111111010";
	sine_wt_32768 <= "00000000000000000011" when wal_32768 = '1' else
			"11111111111111111101";

	-- The same for cosine function					       
	-- --------------------------------------------------------------------
	cosine_wt_0 <= 	"10001100110001010111" when wal_0 = '1' else
			"01110011001110101001";
	cosine_wt_1 <= 	"11110110100000011011" when wal_1 = '1' else
			"00001001011111100101";
	cosine_wt_2 <= 	"11111011010011001010" when wal_2 = '1' else
			"00000100101100110110";
	cosine_wt_3 <= 	"00000010010000011110" when wal_3 = '1' else
			"11111101101111100010";
	cosine_wt_4 <= 	"11111101101001111100" when wal_4 = '1' else
			"00000010010110000100";
	cosine_wt_5 <= 	"00000001001000000100" when wal_5 = '1' else
			"11111110110111111100";
	cosine_wt_6 <= 	"00000000100011101100" when wal_6 = '1' else
			"11111111011100010100";
	cosine_wt_7 <= 	"00000000000010111100" when wal_7 = '1' else
			"11111111111101000100";
	cosine_wt_8 <= 	"11111110110101000001" when wal_8 = '1' else
			"00000001001010111111";
	cosine_wt_9 <= 	"00000000100100000001" when wal_9 = '1' else
			"11111111011011111111";
	cosine_wt_10 <= "00000000010001110101" when wal_10 = '1' else
			"11111111101110001011";
	cosine_wt_11 <= "00000000000001011110" when wal_11 = '1' else
			"11111111111110100010";
	cosine_wt_12 <= "00000000001000111001" when wal_12 = '1' else
			"11111111110111000111";
	cosine_wt_13 <= "00000000000000101111" when wal_13 = '1' else
			"11111111111111010001";
	cosine_wt_14 <= "00000000000000010111" when wal_14 = '1' else
			"11111111111111101001";
	cosine_wt_15 <= "11111111111111110101" when wal_15 = '1' else
			"00000000000000001011";
	cosine_wt_16 <= "11111111011010100001" when wal_16 = '1' else
			"00000000100101011111";
	cosine_wt_17 <= "00000000010010000000" when wal_17 = '1' else
			"11111111101110000000";
	cosine_wt_18 <= "00000000001000111010" when wal_18 = '1' else
			"11111111110111000110";
	cosine_wt_19 <= "00000000000000101111" when wal_19 = '1' else
			"11111111111111010001";
	cosine_wt_20 <= "00000000000100011101" when wal_20 = '1' else
			"11111111111011100011";
	cosine_wt_21 <= "00000000000000010111" when wal_21 = '1' else
			"11111111111111101001";
	cosine_wt_22 <= "00000000000000001100" when wal_22 = '1' else
			"11111111111111110100";
	cosine_wt_23 <= "11111111111111111010" when wal_23 = '1' else
			"00000000000000000110";
	cosine_wt_24 <= "00000000000010001110" when wal_24 = '1' else
			"11111111111101110010";
	cosine_wt_25 <= "00000000000000001100" when wal_25 = '1' else
			"11111111111111110100";
	cosine_wt_26 <= "00000000000000000110" when wal_26 = '1' else
			"11111111111111111010";
	cosine_wt_27 <= "11111111111111111101" when wal_27 = '1' else
			"00000000000000000011";
	cosine_wt_28 <= "00000000000000000011" when wal_28 = '1' else
			"11111111111111111101";
	cosine_wt_32 <= "11111111101101010000" when wal_32 = '1' else
			"00000000010010110000";
	cosine_wt_33 <= "00000000001001000000" when wal_33 = '1' else
			"11111111110111000000";
	cosine_wt_34 <= "00000000000100011101" when wal_34 = '1' else
			"11111111111011100011";
	cosine_wt_35 <= "00000000000000010111" when wal_35 = '1' else
			"11111111111111101001";
	cosine_wt_36 <= "00000000000010001110" when wal_36 = '1' else
			"11111111111101110010";
	cosine_wt_37 <= "00000000000000001100" when wal_37 = '1' else
			"11111111111111110100";
	cosine_wt_38 <= "00000000000000000110" when wal_38 = '1' else
			"11111111111111111010";
	cosine_wt_39 <= "11111111111111111101" when wal_39 = '1' else
			"00000000000000000011";
	cosine_wt_40 <= "00000000000001000111" when wal_40 = '1' else
			"11111111111110111001";
	cosine_wt_41 <= "00000000000000000110" when wal_41 = '1' else
			"11111111111111111010";
	cosine_wt_42 <= "00000000000000000011" when wal_42 = '1' else
			"11111111111111111101";
	cosine_wt_48 <= "00000000000000100100" when wal_48 = '1' else
			"11111111111111011100";
	cosine_wt_49 <= "00000000000000000011" when wal_49 = '1' else
			"11111111111111111101";
	cosine_wt_64 <= "11111111110110101000" when wal_64 = '1' else
			"00000000001001011000";
	cosine_wt_65 <= "00000000000100100000" when wal_65 = '1' else
			"11111111111011100000";
	cosine_wt_66 <= "00000000000010001111" when wal_66 = '1' else
			"11111111111101110001";
	cosine_wt_67 <= "00000000000000001100" when wal_67 = '1' else
			"11111111111111110100";
	cosine_wt_68 <= "00000000000001000111" when wal_68 = '1' else
			"11111111111110111001";
	cosine_wt_69 <= "00000000000000000110" when wal_69 = '1' else
			"11111111111111111010";
	cosine_wt_70 <= "00000000000000000011" when wal_70 = '1' else
			"11111111111111111101";
	cosine_wt_72 <= "00000000000000100100" when wal_72 = '1' else
			"11111111111111011100";
	cosine_wt_73 <= "00000000000000000011" when wal_73 = '1' else
			"11111111111111111101";
	cosine_wt_80 <= "00000000000000010010" when wal_80 = '1' else
			"11111111111111101110";
	cosine_wt_96 <= "00000000000000001001" when wal_96 = '1' else
			"11111111111111110111";
	cosine_wt_128 <= "11111111111011010100" when wal_128 = '1' else
			"00000000000100101100";
	cosine_wt_129 <= "00000000000010010000" when wal_129 = '1' else
			"11111111111101110000";
	cosine_wt_130 <= "00000000000001000111" when wal_130 = '1' else
			"11111111111110111001";
	cosine_wt_131 <= "00000000000000000110" when wal_131 = '1' else
			"11111111111111111010";
	cosine_wt_132 <= "00000000000000100100" when wal_132 = '1' else
			"11111111111111011100";
	cosine_wt_133 <= "00000000000000000011" when wal_133 = '1' else
			"11111111111111111101";
	cosine_wt_136 <= "00000000000000010010" when wal_136 = '1' else
			"11111111111111101110";
	cosine_wt_144 <= "00000000000000001001" when wal_144 = '1' else
			"11111111111111110111";
	cosine_wt_160 <= "00000000000000000100" when wal_160 = '1' else
			"11111111111111111100";
	cosine_wt_192 <= "00000000000000000010" when wal_192 = '1' else
			"11111111111111111110";
	cosine_wt_256 <= "11111111111101101010" when wal_256 = '1' else
			"00000000000010010110";
	cosine_wt_257 <= "00000000000001001000" when wal_257 = '1' else
			"11111111111110111000";
	cosine_wt_258 <= "00000000000000100100" when wal_258 = '1' else
			"11111111111111011100";
	cosine_wt_259 <= "00000000000000000011" when wal_259 = '1' else
			"11111111111111111101";
	cosine_wt_260 <= "00000000000000010010" when wal_260 = '1' else
			"11111111111111101110";
	cosine_wt_264 <= "00000000000000001001" when wal_264 = '1' else
			"11111111111111110111";
	cosine_wt_272 <= "00000000000000000100" when wal_272 = '1' else
			"11111111111111111100";
	cosine_wt_288 <= "00000000000000000010" when wal_288 = '1' else
			"11111111111111111110";
	cosine_wt_512 <= "11111111111110110101" when wal_512 = '1' else
			"00000000000001001011";
	cosine_wt_513 <= "00000000000000100100" when wal_513 = '1' else
			"11111111111111011100";
	cosine_wt_514 <= "00000000000000010010" when wal_514 = '1' else
			"11111111111111101110";
	cosine_wt_516 <= "00000000000000001001" when wal_516 = '1' else
			"11111111111111110111";
	cosine_wt_520 <= "00000000000000000100" when wal_520 = '1' else
			"11111111111111111100";
	cosine_wt_528 <= "00000000000000000010" when wal_528 = '1' else
			"11111111111111111110";
	cosine_wt_1024 <= "11111111111111011011" when wal_1024 = '1' else
			"00000000000000100101";
	cosine_wt_1025 <= "00000000000000010010" when wal_1025 = '1' else
			"11111111111111101110";
	cosine_wt_1026 <= "00000000000000001001" when wal_1026 = '1' else
			"11111111111111110111";
	cosine_wt_1028 <= "00000000000000000100" when wal_1028 = '1' else
			"11111111111111111100";
	cosine_wt_1032 <= "00000000000000000010" when wal_1032 = '1' else
			"11111111111111111110";
	cosine_wt_2048 <= "11111111111111101101" when wal_2048 = '1' else
			"00000000000000010011";
	cosine_wt_2049 <= "00000000000000001001" when wal_2049 = '1' else
			"11111111111111110111";
	cosine_wt_2050 <= "00000000000000000100" when wal_2050 = '1' else
			"11111111111111111100";
	cosine_wt_2052 <= "00000000000000000010" when wal_2052 = '1' else
			"11111111111111111110";
	cosine_wt_4096 <= "11111111111111110111" when wal_4096 = '1' else
			"00000000000000001001";
	cosine_wt_4097 <= "00000000000000000101" when wal_4097 = '1' else
			"11111111111111111011";
	cosine_wt_4098 <= "00000000000000000010" when wal_4098 = '1' else
			"11111111111111111110";
	cosine_wt_8192 <= "11111111111111111011" when wal_8192 = '1' else
			"00000000000000000101";
	cosine_wt_8193 <= "00000000000000000010" when wal_8193 = '1' else
			"11111111111111111110";
	cosine_wt_16384 <= "11111111111111111110" when wal_16384 = '1' else
			"00000000000000000010";

	-- First stage of sine adders
	-- --------------------------------------------------------------------------------
	s_s1a0: csava20x6
		port map (in1 => sine_wt_0(19 downto 0), in2 => sine_wt_1(19 downto 0),
			in3 => sine_wt_2(19 downto 0), in4 => sine_wt_4(19 downto 0),
			in5 => sine_wt_8(19 downto 0), in6 => sine_wt_16(19 downto 0),
			s => s_s1a0s, c => s_s1a0c);
	s_s1a1: csava17x6
		port map (in1 => sine_wt_3(16 downto 0), in2 => sine_wt_32(16 downto 0),
			in3 => sine_wt_5(16 downto 0), in4 => sine_wt_64(16 downto 0),
			in5 => sine_wt_6(16 downto 0), in6 => sine_wt_9(16 downto 0),
			s => s_s1a1s, c => s_s1a1c);
	s_s1a2: csava15x6
		port map (in1 => sine_wt_128(14 downto 0), in2 => sine_wt_7(14 downto 0),
			in3 => sine_wt_10(14 downto 0), in4 => sine_wt_17(14 downto 0),
			in5 => sine_wt_256(14 downto 0), in6 => sine_wt_11(14 downto 0),
			s => s_s1a2s, c => s_s1a2c);
	s_s1a3: csava13x6
		port map (in1 => sine_wt_12(12 downto 0), in2 => sine_wt_18(12 downto 0),
			in3 => sine_wt_33(12 downto 0), in4 => sine_wt_512(12 downto 0),
			in5 => sine_wt_13(12 downto 0), in6 => sine_wt_19(12 downto 0),
			s => s_s1a3s, c => s_s1a3c);
	s_s1a4: csava12x6
		port map (in1 => sine_wt_20(11 downto 0), in2 => sine_wt_34(11 downto 0),
			in3 => sine_wt_65(11 downto 0), in4 => sine_wt_1024(11 downto 0),
			in5 => sine_wt_14(11 downto 0), in6 => sine_wt_21(11 downto 0),
			s => s_s1a4s, c => s_s1a4c);
	s_s1a5: csava11x6
		port map (in1 => sine_wt_24(10 downto 0), in2 => sine_wt_35(10 downto 0),
			in3 => sine_wt_36(10 downto 0), in4 => sine_wt_66(10 downto 0),
			in5 => sine_wt_129(10 downto 0), in6 => sine_wt_2048(10 downto 0),
			s => s_s1a5s, c => s_s1a5c);
	s_s1a6: csava10x6
		port map (in1 => sine_wt_22(9 downto 0), in2 => sine_wt_25(9 downto 0),
			in3 => sine_wt_37(9 downto 0), in4 => sine_wt_40(9 downto 0),
			in5 => sine_wt_67(9 downto 0), in6 => sine_wt_68(9 downto 0),
			s => s_s1a6s, c => s_s1a6c);
	s_s1a7: csava10x6
		port map (in1 => sine_wt_130(9 downto 0), in2 => sine_wt_257(9 downto 0),
			in3 => sine_wt_4096(9 downto 0), in4 => sine_wt_26(9 downto 0),
			in5 => sine_wt_38(9 downto 0), in6 => sine_wt_41(9 downto 0),
			s => s_s1a7s, c => s_s1a7c);
	s_s1a8: csava9x6
		port map (in1 => sine_wt_48(8 downto 0), in2 => sine_wt_69(8 downto 0),
			in3 => sine_wt_72(8 downto 0), in4 => sine_wt_131(8 downto 0),
			in5 => sine_wt_132(8 downto 0), in6 => sine_wt_258(8 downto 0),
			s => s_s1a8s, c => s_s1a8c);
	s_s1a9: csava9x6
		port map (in1 => sine_wt_513(8 downto 0), in2 => sine_wt_8192(8 downto 0),
			in3 => sine_wt_15(8 downto 0), in4 => sine_wt_28(8 downto 0),
			in5 => sine_wt_42(8 downto 0), in6 => sine_wt_49(8 downto 0),
			s => s_s1a9s, c => s_s1a9c);
	s_s1a10: csava8x6
		port map (in1 => sine_wt_50(7 downto 0), in2 => sine_wt_70(7 downto 0),
			in3 => sine_wt_73(7 downto 0), in4 => sine_wt_74(7 downto 0),
			in5 => sine_wt_80(7 downto 0), in6 => sine_wt_81(7 downto 0),
			s => s_s1a10s, c => s_s1a10c);
	s_s1a11: csava8x6
		port map (in1 => sine_wt_96(7 downto 0), in2 => sine_wt_133(7 downto 0),
			in3 => sine_wt_134(7 downto 0), in4 => sine_wt_136(7 downto 0),
			in5 => sine_wt_137(7 downto 0), in6 => sine_wt_144(7 downto 0),
			s => s_s1a11s, c => s_s1a11c);
	s_s1a12: csava8x6
		port map (in1 => sine_wt_259(7 downto 0), in2 => sine_wt_260(7 downto 0),
			in3 => sine_wt_261(7 downto 0), in4 => sine_wt_264(7 downto 0),
			in5 => sine_wt_514(7 downto 0), in6 => sine_wt_515(7 downto 0),
			s => s_s1a12s, c => s_s1a12c);
	s_s1a13: csava8x6
		port map (in1 => sine_wt_516(7 downto 0), in2 => sine_wt_1025(7 downto 0),
			in3 => sine_wt_1026(7 downto 0), in4 => sine_wt_2049(7 downto 0),
			in5 => sine_wt_16384(7 downto 0), in6 => sine_wt_23(7 downto 0),
			s => s_s1a13s, c => s_s1a13c);
	s_s1a14: csava7x6
		port map (in1 => sine_wt_44(6 downto 0), in2 => sine_wt_52(6 downto 0),
			in3 => sine_wt_76(6 downto 0), in4 => sine_wt_82(6 downto 0),
			in5 => sine_wt_97(6 downto 0), in6 => sine_wt_138(6 downto 0),
			s => s_s1a14s, c => s_s1a14c);
	s_s1a15: csava7x6
		port map (in1 => sine_wt_145(6 downto 0), in2 => sine_wt_160(6 downto 0),
			in3 => sine_wt_262(6 downto 0), in4 => sine_wt_265(6 downto 0),
			in5 => sine_wt_272(6 downto 0), in6 => sine_wt_517(6 downto 0),
			s => s_s1a15s, c => s_s1a15c);
	s_s1a16: csava7x6
		port map (in1 => sine_wt_520(6 downto 0), in2 => sine_wt_1027(6 downto 0),
			in3 => sine_wt_1028(6 downto 0), in4 => sine_wt_2050(6 downto 0),
			in5 => sine_wt_4097(6 downto 0), in6 => sine_wt_32768(6 downto 0),
			s => s_s1a16s, c => s_s1a16c);

	-- First stage of cosine adders
	-- --------------------------------------------------------------------------------
	c_s1a0: csava20x6
		port map (in1 => cosine_wt_0(19 downto 0), in2 => cosine_wt_1(19 downto 0),
			in3 => cosine_wt_2(19 downto 0), in4 => cosine_wt_3(19 downto 0),
			in5 => cosine_wt_4(19 downto 0), in6 => cosine_wt_5(19 downto 0),
			s => c_s1a0s, c => c_s1a0c);
	c_s1a1: csava18x6
		port map (in1 => cosine_wt_8(17 downto 0), in2 => cosine_wt_6(17 downto 0),
			in3 => cosine_wt_9(17 downto 0), in4 => cosine_wt_16(17 downto 0),
			in5 => cosine_wt_10(17 downto 0), in6 => cosine_wt_17(17 downto 0),
			s => c_s1a1s, c => c_s1a1c);
	c_s1a2: csava16x6
		port map (in1 => cosine_wt_32(15 downto 0), in2 => cosine_wt_12(15 downto 0),
			in3 => cosine_wt_18(15 downto 0), in4 => cosine_wt_33(15 downto 0),
			in5 => cosine_wt_64(15 downto 0), in6 => cosine_wt_20(15 downto 0),
			s => c_s1a2s, c => c_s1a2c);
	c_s1a3: csava14x6
		port map (in1 => cosine_wt_34(13 downto 0), in2 => cosine_wt_65(13 downto 0),
			in3 => cosine_wt_128(13 downto 0), in4 => cosine_wt_7(13 downto 0),
			in5 => cosine_wt_24(13 downto 0), in6 => cosine_wt_36(13 downto 0),
			s => c_s1a3s, c => c_s1a3c);
	c_s1a4: csava13x6
		port map (in1 => cosine_wt_66(12 downto 0), in2 => cosine_wt_129(12 downto 0),
			in3 => cosine_wt_256(12 downto 0), in4 => cosine_wt_11(12 downto 0),
			in5 => cosine_wt_40(12 downto 0), in6 => cosine_wt_68(12 downto 0),
			s => c_s1a4s, c => c_s1a4c);
	c_s1a5: csava12x6
		port map (in1 => cosine_wt_130(11 downto 0), in2 => cosine_wt_257(11 downto 0),
			in3 => cosine_wt_512(11 downto 0), in4 => cosine_wt_13(11 downto 0),
			in5 => cosine_wt_19(11 downto 0), in6 => cosine_wt_48(11 downto 0),
			s => c_s1a5s, c => c_s1a5c);
	c_s1a6: csava11x6
		port map (in1 => cosine_wt_72(10 downto 0), in2 => cosine_wt_132(10 downto 0),
			in3 => cosine_wt_258(10 downto 0), in4 => cosine_wt_513(10 downto 0),
			in5 => cosine_wt_1024(10 downto 0), in6 => cosine_wt_14(10 downto 0),
			s => c_s1a6s, c => c_s1a6c);
	c_s1a7: csava10x6
		port map (in1 => cosine_wt_21(9 downto 0), in2 => cosine_wt_35(9 downto 0),
			in3 => cosine_wt_80(9 downto 0), in4 => cosine_wt_136(9 downto 0),
			in5 => cosine_wt_260(9 downto 0), in6 => cosine_wt_514(9 downto 0),
			s => c_s1a7s, c => c_s1a7c);
	c_s1a8: csava10x6
		port map (in1 => cosine_wt_1025(9 downto 0), in2 => cosine_wt_2048(9 downto 0),
			in3 => cosine_wt_15(9 downto 0), in4 => cosine_wt_22(9 downto 0),
			in5 => cosine_wt_25(9 downto 0), in6 => cosine_wt_37(9 downto 0),
			s => c_s1a8s, c => c_s1a8c);
	c_s1a9: csava9x6
		port map (in1 => cosine_wt_67(8 downto 0), in2 => cosine_wt_96(8 downto 0),
			in3 => cosine_wt_144(8 downto 0), in4 => cosine_wt_264(8 downto 0),
			in5 => cosine_wt_516(8 downto 0), in6 => cosine_wt_1026(8 downto 0),
			s => c_s1a9s, c => c_s1a9c);
	c_s1a10: csava9x6
		port map (in1 => cosine_wt_2049(8 downto 0), in2 => cosine_wt_4096(8 downto 0),
			in3 => cosine_wt_23(8 downto 0), in4 => cosine_wt_26(8 downto 0),
			in5 => cosine_wt_38(8 downto 0), in6 => cosine_wt_41(8 downto 0),
			s => c_s1a10s, c => c_s1a10c);
	c_s1a11: csava8x6
		port map (in1 => cosine_wt_69(7 downto 0), in2 => cosine_wt_131(7 downto 0),
			in3 => cosine_wt_160(7 downto 0), in4 => cosine_wt_272(7 downto 0),
			in5 => cosine_wt_520(7 downto 0), in6 => cosine_wt_1028(7 downto 0),
			s => c_s1a11s, c => c_s1a11c);
	c_s1a12: csava8x6
		port map (in1 => cosine_wt_2050(7 downto 0), in2 => cosine_wt_4097(7 downto 0),
			in3 => cosine_wt_8192(7 downto 0), in4 => cosine_wt_27(7 downto 0),
			in5 => cosine_wt_28(7 downto 0), in6 => cosine_wt_39(7 downto 0),
			s => c_s1a12s, c => c_s1a12c);
	c_s1a13: csava7x6
		port map (in1 => cosine_wt_42(6 downto 0), in2 => cosine_wt_49(6 downto 0),
			in3 => cosine_wt_70(6 downto 0), in4 => cosine_wt_73(6 downto 0),
			in5 => cosine_wt_133(6 downto 0), in6 => cosine_wt_192(6 downto 0),
			s => c_s1a13s, c => c_s1a13c);
	c_s1a14: csava7x6
		port map (in1 => cosine_wt_259(6 downto 0), in2 => cosine_wt_288(6 downto 0),
			in3 => cosine_wt_528(6 downto 0), in4 => cosine_wt_1032(6 downto 0),
			in5 => cosine_wt_2052(6 downto 0), in6 => cosine_wt_4098(6 downto 0),
			s => c_s1a14s, c => c_s1a14c);

	-- That is enough for the first stage. Let us move to the next one
	-- ----------------------------------------------------------------------------------
	
	-- Latch sine adders' outputs
	s_latchb: process(clk, reset)
	begin
		if reset = '0' then
 			s_s2a0in1 <= (others => '0');
 			s_s2a0in2 <= (others => '0');
 			s_s2a0in3 <= (others => '0');
 			s_s2a0in4 <= (others => '0');
 			s_s2a0in5 <= (others => '0');
 			s_s2a0in6 <= (others => '0');
			s_s2a0in7 <= (others => '0');
 			s_s2a0in8 <= (others => '0');
 			s_s2a0in9 <= (others => '0');

 			s_s2a1in1 <= (others => '0');
 			s_s2a1in2 <= (others => '0');
 			s_s2a1in3 <= (others => '0');
 			s_s2a1in4 <= (others => '0');
 			s_s2a1in5 <= (others => '0');
 			s_s2a1in6 <= (others => '0');
 			s_s2a1in7 <= (others => '0');
 			s_s2a1in8 <= (others => '0');

 			s_s2a2in1 <= (others => '0');
 			s_s2a2in2 <= (others => '0');
 			s_s2a2in3 <= (others => '0');
 			s_s2a2in4 <= (others => '0');
 			s_s2a2in5 <= (others => '0');
 			s_s2a2in6 <= (others => '0');
 			s_s2a2in7 <= (others => '0');
 			s_s2a2in8 <= (others => '0');

 			s_s2a3in1 <= (others => '0');
 			s_s2a3in2 <= (others => '0');
 			s_s2a3in3 <= (others => '0');
 			s_s2a3in4 <= (others => '0');
 			s_s2a3in5 <= (others => '0');
 			s_s2a3in6 <= (others => '0');
 			s_s2a3in7 <= (others => '0');
 			s_s2a3in8 <= (others => '0');
 
 			s_s2for <= (others => '0');

		elsif clk'event and clk = '1' then
	 		s_s2a0in1 <= s_s1a0s;
 			s_s2a0in2 <= s_s1a0c;
 			s_s2a0in3 <= s_s1a1s;
 			s_s2a0in4 <= s_s1a1c;
	 		s_s2a0in5 <= s_s1a2s;
 			s_s2a0in6 <= s_s1a2c; 
			s_s2a0in7 <= s_s1a3s;
 			s_s2a0in8 <= s_s1a3c;
	 		s_s2a0in9 <= s_s1a16s;

 			s_s2a1in1 <= s_s1a4s;
 			s_s2a1in2 <= s_s1a4c;
 			s_s2a1in3 <= s_s1a5s;
	 		s_s2a1in4 <= s_s1a5c;
 			s_s2a1in5 <= s_s1a6s; 
 			s_s2a1in6 <= s_s1a6c;
 			s_s2a1in7 <= s_s1a7s;
	 		s_s2a1in8 <= s_s1a7c;
	
 			s_s2a2in1 <= s_s1a8s;
 			s_s2a2in2 <= s_s1a8c;
 			s_s2a2in3 <= s_s1a9s;
	 		s_s2a2in4 <= s_s1a9c;
 			s_s2a2in5 <= s_s1a10s;
 			s_s2a2in6 <= s_s1a10c;
 			s_s2a2in7 <= s_s1a11s;
	 		s_s2a2in8 <= s_s1a11c;

			s_s2a3in1 <= s_s1a12s;
			s_s2a3in2 <= s_s1a12c;
 			s_s2a3in3 <= s_s1a13s;
			s_s2a3in4 <= s_s1a13c;
 			s_s2a3in5 <= s_s1a14s;
 			s_s2a3in6 <= s_s1a14c;
 			s_s2a3in7 <= s_s1a15s;
			s_s2a3in8 <= s_s1a15c;
 
 			s_s2for <= s_s1a16c;
		end if;
		
	end process s_latchb;

	-- Latch cosine adders' outputs
	c_latchb: process(clk, reset)
	begin
		if reset = '0' then
 			c_s2a0in1 <= (others => '0');
 			c_s2a0in2 <= (others => '0');
 			c_s2a0in3 <= (others => '0');
 			c_s2a0in4 <= (others => '0');
 			c_s2a0in5 <= (others => '0');
 			c_s2a0in6 <= (others => '0');
			c_s2a0in7 <= (others => '0');
 			c_s2a0in8 <= (others => '0');

 			c_s2a1in1 <= (others => '0');
 			c_s2a1in2 <= (others => '0');
 			c_s2a1in3 <= (others => '0');
 			c_s2a1in4 <= (others => '0');
 			c_s2a1in5 <= (others => '0');
 			c_s2a1in6 <= (others => '0');
 			c_s2a1in7 <= (others => '0');
 			c_s2a1in8 <= (others => '0');

 			c_s2a2in1 <= (others => '0');
 			c_s2a2in2 <= (others => '0');
 			c_s2a2in3 <= (others => '0');
 			c_s2a2in4 <= (others => '0');
 			c_s2a2in5 <= (others => '0');
 			c_s2a2in6 <= (others => '0');
 			c_s2a2in7 <= (others => '0');
 			c_s2a2in8 <= (others => '0');

 			c_s2a3in1 <= (others => '0');
 			c_s2a3in2 <= (others => '0');
 			c_s2a3in3 <= (others => '0');
 			c_s2a3in4 <= (others => '0');
 			c_s2a3in5 <= (others => '0');
 			c_s2a3in6 <= (others => '0');
 			c_s2a3in7 <= (others => '0');
 			c_s2a3in8 <= (others => '0');
		elsif clk'event and clk = '1' then
 			c_s2a0in1 <= c_s1a0s;
			c_s2a0in2 <= c_s1a0c;
			c_s2a0in3 <= c_s1a1s;
			c_s2a0in4 <= c_s1a1c;
 			c_s2a0in5 <= c_s1a2s;
			c_s2a0in6 <= c_s1a2c; 
			c_s2a0in7 <= c_s1a3s;
			c_s2a0in8 <= c_s1a3c;

 			c_s2a1in1 <= c_s1a4s;
			c_s2a1in2 <= c_s1a4c;
			c_s2a1in3 <= c_s1a5s;
			c_s2a1in4 <= c_s1a5c;
 			c_s2a1in5 <= c_s1a6s; 
			c_s2a1in6 <= c_s1a6c;
			c_s2a1in7 <= c_s1a7s;
			c_s2a1in8 <= c_s1a7c;

 			c_s2a2in1 <= c_s1a8s;
			c_s2a2in2 <= c_s1a8c;
			c_s2a2in3 <= c_s1a9s;
			c_s2a2in4 <= c_s1a9c;
 			c_s2a2in5 <= c_s1a10s;
			c_s2a2in6 <= c_s1a10c;
			c_s2a2in7 <= c_s1a11s;
			c_s2a2in8 <= c_s1a11c;

 			c_s2a3in1 <= c_s1a12s;
			c_s2a3in2 <= c_s1a12c;
			c_s2a3in3 <= c_s1a13s;
			c_s2a3in4 <= c_s1a13c;
 			c_s2a3in5 <= c_s1a14s;
			c_s2a3in6 <= c_s1a14c;
			c_s2a3in7 <= cosine_wt_8193(3 downto 0);
			c_s2a3in8 <= cosine_wt_16384(3 downto 0);
		end if;
	end process c_latchb;

	-- Second stage of sine adders
	-- --------------------------------------------------------------------------------
	s_s2a0: csava20x9
		port map(in1 => s_s2a0in1, in2 => s_s2a0in2,
			in3(19) => s_s2a0in3(16), -- <============
			in3(18) => s_s2a0in3(16),
			in3(17) => s_s2a0in3(16),
			in3(16 downto 0) => s_s2a0in3,
			in4(19) => s_s2a0in4(16), -- <============
			in4(18) => s_s2a0in4(16),
			in4(17) => s_s2a0in4(16),
			in4(16 downto 0) => s_s2a0in4,
			in5(19) => s_s2a0in5(14), -- <============
			in5(18) => s_s2a0in5(14), 
			in5(17) => s_s2a0in5(14), 
			in5(16) => s_s2a0in5(14), 
			in5(15) => s_s2a0in5(14), 
			in5(14 downto 0) => s_s2a0in5, 
			in6(19) => s_s2a0in6(14), -- <============
			in6(18) => s_s2a0in6(14),
			in6(17) => s_s2a0in6(14),
			in6(16) => s_s2a0in6(14),
			in6(15) => s_s2a0in6(14),
			in6(14 downto 0) => s_s2a0in6,
			in7(19) => s_s2a0in7(12), -- <============
			in7(18) => s_s2a0in7(12),
			in7(17) => s_s2a0in7(12),
			in7(16) => s_s2a0in7(12),
			in7(15) => s_s2a0in7(12),
			in7(14) => s_s2a0in7(12),
			in7(13) => s_s2a0in7(12),
			in7(12 downto 0) => s_s2a0in7, 
			in8(19) => s_s2a0in8(12), -- <============
			in8(18) => s_s2a0in8(12),
			in8(17) => s_s2a0in8(12),
			in8(16) => s_s2a0in8(12),
			in8(15) => s_s2a0in8(12),
			in8(14) => s_s2a0in8(12),
			in8(13) => s_s2a0in8(12),
			in8(12 downto 0) => s_s2a0in8,
			in9(19) => s_s2a0in9(6), -- <============
			in9(18) => s_s2a0in9(6),
			in9(17) => s_s2a0in9(6),
			in9(16) => s_s2a0in9(6),
			in9(15) => s_s2a0in9(6),
			in9(14) => s_s2a0in9(6),
			in9(13) => s_s2a0in9(6),
			in9(12) => s_s2a0in9(6),
			in9(11) => s_s2a0in9(6),
			in9(10) => s_s2a0in9(6),
			in9(9) => s_s2a0in9(6),
			in9(8) => s_s2a0in9(6),
			in9(7) => s_s2a0in9(6),
			in9(6 downto 0) => s_s2a0in9,
			s => s_s2a0s, c => s_s2a0c);

	s_s2a1: csava18x8
		port map(in1(17) => s_s2a1in1(11), -- <===========
			in1(16) => s_s2a1in1(11),
			in1(15) => s_s2a1in1(11),
			in1(14) => s_s2a1in1(11),
			in1(13) => s_s2a1in1(11),
			in1(12) => s_s2a1in1(11),
			in1(11 downto 0) => s_s2a1in1,
			in2(17) => s_s2a1in2(11), -- <===========
			in2(16) => s_s2a1in2(11),
			in2(15) => s_s2a1in2(11),
			in2(14) => s_s2a1in2(11),
			in2(13) => s_s2a1in2(11),
			in2(12) => s_s2a1in2(11),
			in2(11 downto 0) => s_s2a1in2,
			in3(17) => s_s2a1in3(10), -- <===========
			in3(16) => s_s2a1in3(10),
			in3(15) => s_s2a1in3(10),
			in3(14) => s_s2a1in3(10),
			in3(13) => s_s2a1in3(10),
			in3(12) => s_s2a1in3(10),
			in3(11) => s_s2a1in3(10),
			in3(10 downto 0) => s_s2a1in3,
			in4(17) => s_s2a1in4(10), -- <===========
			in4(16) => s_s2a1in4(10),
			in4(15) => s_s2a1in4(10),
			in4(14) => s_s2a1in4(10),
			in4(13) => s_s2a1in4(10),
			in4(12) => s_s2a1in4(10),
			in4(11) => s_s2a1in4(10),
			in4(10 downto 0) => s_s2a1in4,
			in5(17) => s_s2a1in5(9), -- <===========
			in5(16) => s_s2a1in5(9),
			in5(15) => s_s2a1in5(9),
			in5(14) => s_s2a1in5(9),
			in5(13) => s_s2a1in5(9),
			in5(12) => s_s2a1in5(9),
			in5(11) => s_s2a1in5(9),
			in5(10) => s_s2a1in5(9),			
			in5(9 downto 0) => s_s2a1in5,
			in6(17) => s_s2a1in6(9), -- <===========
			in6(16) => s_s2a1in6(9),
			in6(15) => s_s2a1in6(9),
			in6(14) => s_s2a1in6(9),
			in6(13) => s_s2a1in6(9),
			in6(12) => s_s2a1in6(9),
			in6(11) => s_s2a1in6(9),
			in6(10) => s_s2a1in6(9),			
			in6(9 downto 0) => s_s2a1in6,
			in7(17) => s_s2a1in7(9), -- <===========
			in7(16) => s_s2a1in7(9),
			in7(15) => s_s2a1in7(9),
			in7(14) => s_s2a1in7(9),
			in7(13) => s_s2a1in7(9),
			in7(12) => s_s2a1in7(9),
			in7(11) => s_s2a1in7(9),
			in7(10) => s_s2a1in7(9),			
			in7(9 downto 0) => s_s2a1in7,
			in8(17) => s_s2a1in8(9), -- <===========
			in8(16) => s_s2a1in8(9),
			in8(15) => s_s2a1in8(9),
			in8(14) => s_s2a1in8(9),
			in8(13) => s_s2a1in8(9),
			in8(12) => s_s2a1in8(9),
			in8(11) => s_s2a1in8(9),
			in8(10) => s_s2a1in8(9),			
			in8(9 downto 0) => s_s2a1in8,
			s => s_s2a1s, c => s_s2a1c);

	s_s2a2: csava14x8
		port map(in1(13) => s_s2a2in1(8), -- <===========
			in1(12) => s_s2a2in1(8),
			in1(11) => s_s2a2in1(8),
			in1(10) => s_s2a2in1(8),
			in1(9) => s_s2a2in1(8),
			in1(8 downto 0) => s_s2a2in1, 
			in2(13) => s_s2a2in2(8), -- <===========
			in2(12) => s_s2a2in2(8),
			in2(11) => s_s2a2in2(8),
			in2(10) => s_s2a2in2(8),
			in2(9) => s_s2a2in2(8),
			in2(8 downto 0) => s_s2a2in2, 
			in3(13) => s_s2a2in3(8), -- <===========
			in3(12) => s_s2a2in3(8),
			in3(11) => s_s2a2in3(8),
			in3(10) => s_s2a2in3(8),
			in3(9) => s_s2a2in3(8),
			in3(8 downto 0) => s_s2a2in3, 
			in4(13) => s_s2a2in4(8), -- <===========
			in4(12) => s_s2a2in4(8),
			in4(11) => s_s2a2in4(8),
			in4(10) => s_s2a2in4(8),
			in4(9) => s_s2a2in4(8),
			in4(8 downto 0) => s_s2a2in4, 
			in5(13) => s_s2a2in5(7), -- <===========
			in5(12) => s_s2a2in5(7),
			in5(11) => s_s2a2in5(7),
			in5(10) => s_s2a2in5(7),
			in5(9) => s_s2a2in5(7),
			in5(8) => s_s2a2in5(7),
			in5(7 downto 0) => s_s2a2in5, 
			in6(13) => s_s2a2in6(7), -- <===========
			in6(12) => s_s2a2in6(7),
			in6(11) => s_s2a2in6(7),
			in6(10) => s_s2a2in6(7),
			in6(9) => s_s2a2in6(7),
			in6(8) => s_s2a2in6(7),
			in6(7 downto 0) => s_s2a2in6, 
			in7(13) => s_s2a2in7(7), -- <===========
			in7(12) => s_s2a2in7(7),
			in7(11) => s_s2a2in7(7),
			in7(10) => s_s2a2in7(7),
			in7(9) => s_s2a2in7(7),
			in7(8) => s_s2a2in7(7),
			in7(7 downto 0) => s_s2a2in7, 
			in8(13) => s_s2a2in8(7), -- <===========
			in8(12) => s_s2a2in8(7),
			in8(11) => s_s2a2in8(7),
			in8(10) => s_s2a2in8(7),
			in8(9) => s_s2a2in8(7),
			in8(8) => s_s2a2in8(7),
			in8(7 downto 0) => s_s2a2in8, 
			s => s_s2a2s, c => s_s2a2c);

	s_s2a3: csava12x8
		port map(in1(11) => s_s2a3in1(7), -- <===========
			in1(10) => s_s2a3in1(7),
			in1(9) => s_s2a3in1(7),
			in1(8) => s_s2a3in1(7),
			in1(7 downto 0) => s_s2a3in1, 
			in2(11) => s_s2a3in2(7), -- <===========
			in2(10) => s_s2a3in2(7),
			in2(9) => s_s2a3in2(7),
			in2(8) => s_s2a3in2(7),
			in2(7 downto 0) => s_s2a3in2, 
			in3(11) => s_s2a3in3(7), -- <===========
			in3(10) => s_s2a3in3(7),
			in3(9) => s_s2a3in3(7),
			in3(8) => s_s2a3in3(7),
			in3(7 downto 0) => s_s2a3in3, 
			in4(11) => s_s2a3in4(7), -- <===========
			in4(10) => s_s2a3in4(7),
			in4(9) => s_s2a3in4(7),
			in4(8) => s_s2a3in4(7),
			in4(7 downto 0) => s_s2a3in4, 
			in5(11) => s_s2a3in5(6), -- <===========
			in5(10) => s_s2a3in5(6),
			in5(9) => s_s2a3in5(6),
			in5(8) => s_s2a3in5(6),
			in5(7) => s_s2a3in5(6),
			in5(6 downto 0) => s_s2a3in5, 
			in6(11) => s_s2a3in6(6), -- <===========
			in6(10) => s_s2a3in6(6),
			in6(9) => s_s2a3in6(6),
			in6(8) => s_s2a3in6(6),
			in6(7) => s_s2a3in6(6),
			in6(6 downto 0) => s_s2a3in6, 
			in7(11) => s_s2a3in7(6), -- <===========
			in7(10) => s_s2a3in7(6),
			in7(9) => s_s2a3in7(6),
			in7(8) => s_s2a3in7(6),
			in7(7) => s_s2a3in7(6),
			in7(6 downto 0) => s_s2a3in7, 
			in8(11) => s_s2a3in8(6), -- <===========
			in8(10) => s_s2a3in8(6),
			in8(9) => s_s2a3in8(6),
			in8(8) => s_s2a3in8(6),
			in8(7) => s_s2a3in8(6),
			in8(6 downto 0) => s_s2a3in8, 
			s => s_s2a3s, c => s_s2a3c);

	-- Second stage of cosine adders
	-- --------------------------------------------------------------------------------
	c_s2a0: csava20x8
		port map(in1 => c_s2a0in1, in2 => c_s2a0in2,
			in3(19) => c_s2a0in3(17), -- <============
			in3(18) => c_s2a0in3(17),
			in3(17 downto 0) => c_s2a0in3,
			in4(19) => c_s2a0in4(17), -- <============
			in4(18) => c_s2a0in4(17),
			in4(17 downto 0) => c_s2a0in4,
			in5(19) => c_s2a0in5(15), -- <============
			in5(18) => c_s2a0in5(15), 
			in5(17) => c_s2a0in5(15), 
			in5(16) => c_s2a0in5(15), 
			in5(15 downto 0) => c_s2a0in5, 
			in6(19) => c_s2a0in6(15), -- <============
			in6(18) => c_s2a0in6(15),
			in6(17) => c_s2a0in6(15),
			in6(16) => c_s2a0in6(15),
			in6(15 downto 0) => c_s2a0in6,
			in7(19) => c_s2a0in7(13), -- <============
			in7(18) => c_s2a0in7(13),
			in7(17) => c_s2a0in7(13),
			in7(16) => c_s2a0in7(13),
			in7(15) => c_s2a0in7(13),
			in7(14) => c_s2a0in7(13),
			in7(13 downto 0) => c_s2a0in7, 
			in8(19) => c_s2a0in8(13), -- <============
			in8(18) => c_s2a0in8(13),
			in8(17) => c_s2a0in8(13),
			in8(16) => c_s2a0in8(13),
			in8(15) => c_s2a0in8(13),
			in8(14) => c_s2a0in8(13),
			in8(13 downto 0) => c_s2a0in8,
			s => c_s2a0s, c => c_s2a0c);

	c_s2a1: csava17x8
		port map(in1(16) => c_s2a1in1(12), -- <===========
			in1(15) => c_s2a1in1(12),
			in1(14) => c_s2a1in1(12),
			in1(13) => c_s2a1in1(12),
			in1(12 downto 0) => c_s2a1in1, 
			in2(16) => c_s2a1in2(12), -- <===========
			in2(15) => c_s2a1in2(12),
			in2(14) => c_s2a1in2(12),
			in2(13) => c_s2a1in2(12),
			in2(12 downto 0) => c_s2a1in2, 
			in3(16) => c_s2a1in3(11), -- <===========
			in3(15) => c_s2a1in3(11),
			in3(14) => c_s2a1in3(11),
			in3(13) => c_s2a1in3(11),
			in3(12) => c_s2a1in3(11),
			in3(11 downto 0) => c_s2a1in3, 
			in4(16) => c_s2a1in4(11), -- <===========
			in4(15) => c_s2a1in4(11),
			in4(14) => c_s2a1in4(11),
			in4(13) => c_s2a1in4(11),
			in4(12) => c_s2a1in4(11),
			in4(11 downto 0) => c_s2a1in4, 
			in5(16) => c_s2a1in5(10), -- <===========
			in5(15) => c_s2a1in5(10),
			in5(14) => c_s2a1in5(10),
			in5(13) => c_s2a1in5(10),
			in5(12) => c_s2a1in5(10),
			in5(11) => c_s2a1in5(10),
			in5(10 downto 0) => c_s2a1in5, 
			in6(16) => c_s2a1in6(10), -- <===========
			in6(15) => c_s2a1in6(10),
			in6(14) => c_s2a1in6(10),
			in6(13) => c_s2a1in6(10),
			in6(12) => c_s2a1in6(10),
			in6(11) => c_s2a1in6(10),
			in6(10 downto 0) => c_s2a1in6, 
			in7(16) => c_s2a1in7(9), -- <===========
			in7(15) => c_s2a1in7(9),
			in7(14) => c_s2a1in7(9),
			in7(13) => c_s2a1in7(9),
			in7(12) => c_s2a1in7(9),
			in7(11) => c_s2a1in7(9),
			in7(10) => c_s2a1in7(9),
			in7(9 downto 0) => c_s2a1in7, 
			in8(16) => c_s2a1in8(9), -- <===========
			in8(15) => c_s2a1in8(9),
			in8(14) => c_s2a1in8(9),
			in8(13) => c_s2a1in8(9),
			in8(12) => c_s2a1in8(9),
			in8(11) => c_s2a1in8(9),
			in8(10) => c_s2a1in8(9),
			in8(9 downto 0) => c_s2a1in8, 
			s => c_s2a1s, c => c_s2a1c);

	c_s2a2: csava14x8
		port map(in1(13) => c_s2a2in1(9), -- <===========
			in1(12) => c_s2a2in1(9),
			in1(11) => c_s2a2in1(9),
			in1(10) => c_s2a2in1(9),
			in1(9 downto 0) => c_s2a2in1, 
			in2(13) => c_s2a2in2(9), -- <===========
			in2(12) => c_s2a2in2(9),
			in2(11) => c_s2a2in2(9),
			in2(10) => c_s2a2in2(9),
			in2(9 downto 0) => c_s2a2in2, 
			in3(13) => c_s2a2in3(8), -- <===========
			in3(12) => c_s2a2in3(8),
			in3(11) => c_s2a2in3(8),
			in3(10) => c_s2a2in3(8),
			in3(9) => c_s2a2in3(8),			
			in3(8 downto 0) => c_s2a2in3, 
			in4(13) => c_s2a2in4(8), -- <===========
			in4(12) => c_s2a2in4(8),
			in4(11) => c_s2a2in4(8),
			in4(10) => c_s2a2in4(8),
			in4(9) => c_s2a2in4(8),			
			in4(8 downto 0) => c_s2a2in4, 
			in5(13) => c_s2a2in5(8), -- <===========
			in5(12) => c_s2a2in5(8),
			in5(11) => c_s2a2in5(8),
			in5(10) => c_s2a2in5(8),
			in5(9) => c_s2a2in5(8),			
			in5(8 downto 0) => c_s2a2in5, 
			in6(13) => c_s2a2in6(8), -- <===========
			in6(12) => c_s2a2in6(8),
			in6(11) => c_s2a2in6(8),
			in6(10) => c_s2a2in6(8),
			in6(9) => c_s2a2in6(8),			
			in6(8 downto 0) => c_s2a2in6, 
			in7(13) => c_s2a2in7(7), -- <===========
			in7(12) => c_s2a2in7(7),
			in7(11) => c_s2a2in7(7),
			in7(10) => c_s2a2in7(7),
			in7(9) => c_s2a2in7(7),	
			in7(8) => c_s2a2in7(7),				
			in7(7 downto 0) => c_s2a2in7, 
			in8(13) => c_s2a2in8(7), -- <===========
			in8(12) => c_s2a2in8(7),
			in8(11) => c_s2a2in8(7),
			in8(10) => c_s2a2in8(7),
			in8(9) => c_s2a2in8(7),	
			in8(8) => c_s2a2in8(7),				
			in8(7 downto 0) => c_s2a2in8, 
			s => c_s2a2s, c => c_s2a2c);

	c_s2a3: csava12x8
		port map(in1(11) => c_s2a3in1(7), -- <===========
			in1(10) => c_s2a3in1(7),
			in1(9) => c_s2a3in1(7),
			in1(8) => c_s2a3in1(7),
			in1(7 downto 0) => c_s2a3in1, 
			in2(11) => c_s2a3in2(7), -- <===========
			in2(10) => c_s2a3in2(7),
			in2(9) => c_s2a3in2(7),
			in2(8) => c_s2a3in2(7),
			in2(7 downto 0) => c_s2a3in2, 
			in3(11) => c_s2a3in3(6), -- <===========
			in3(10) => c_s2a3in3(6),
			in3(9) => c_s2a3in3(6),
			in3(8) => c_s2a3in3(6),
			in3(7) => c_s2a3in3(6),			
			in3(6 downto 0) => c_s2a3in3, 
			in4(11) => c_s2a3in4(6), -- <===========
			in4(10) => c_s2a3in4(6),
			in4(9) => c_s2a3in4(6),
			in4(8) => c_s2a3in4(6),
			in4(7) => c_s2a3in4(6),			
			in4(6 downto 0) => c_s2a3in4, 
			in5(11) => c_s2a3in5(6), -- <===========
			in5(10) => c_s2a3in5(6),
			in5(9) => c_s2a3in5(6),
			in5(8) => c_s2a3in5(6),
			in5(7) => c_s2a3in5(6),			
			in5(6 downto 0) => c_s2a3in5, 
			in6(11) => c_s2a3in6(6), -- <===========
			in6(10) => c_s2a3in6(6),
			in6(9) => c_s2a3in6(6),
			in6(8) => c_s2a3in6(6),
			in6(7) => c_s2a3in6(6),			
			in6(6 downto 0) => c_s2a3in6, 
			in7(11) => c_s2a3in7(3), -- <===========
			in7(10) => c_s2a3in7(3),
			in7(9) => c_s2a3in7(3),
			in7(8) => c_s2a3in7(3),
			in7(7) => c_s2a3in7(3),
			in7(6) => c_s2a3in7(3),
			in7(5) => c_s2a3in7(3),
			in7(4) => c_s2a3in7(3),
			in7(3 downto 0) => c_s2a3in7, 
			in8(11) => c_s2a3in8(3), -- <===========
			in8(10) => c_s2a3in8(3),
			in8(9) => c_s2a3in8(3),
			in8(8) => c_s2a3in8(3),
			in8(7) => c_s2a3in8(3),
			in8(6) => c_s2a3in8(3),
			in8(5) => c_s2a3in8(3),
			in8(4) => c_s2a3in8(3),
			in8(3 downto 0) => c_s2a3in8, 
			s => c_s2a3s, c => c_s2a3c);

	-- STAGE 3 ---------------------------------------------------------------
	
	-- Latch sine adder outputs
	s_latchc: process(clk, reset)
	begin
		if reset = '0' then
 			s_s3a0in1 <= (others => '0');
 			s_s3a0in2 <= (others => '0');
 			s_s3a0in3 <= (others => '0');
 			s_s3a0in4 <= (others => '0');
 			s_s3a0in5 <= (others => '0');
 			s_s3a0in6 <= (others => '0');
			s_s3a0in7 <= (others => '0');
 			s_s3a0in8 <= (others => '0');
			s_s3a0in9 <= (others => '0');
		elsif clk'event and clk = '1' then
 			s_s3a0in1 <= s_s2a0s;
			s_s3a0in2 <= s_s2a0c;
			s_s3a0in3 <= s_s2a1s;
			s_s3a0in4 <= s_s2a1c;
 			s_s3a0in5 <= s_s2a2s;
			s_s3a0in6 <= s_s2a2c; 
			s_s3a0in7 <= s_s2a3s;
			s_s3a0in8 <= s_s2a3c;
			s_s3a0in9 <= s_s2for;
		end if;
	end process s_latchc;

	-- Latch cosine adder outputs
	c_latchc: process(clk, reset)
	begin
		if reset = '0' then
 			c_s3a0in1 <= (others => '0');
 			c_s3a0in2 <= (others => '0');
 			c_s3a0in3 <= (others => '0');
 			c_s3a0in4 <= (others => '0');
 			c_s3a0in5 <= (others => '0');
 			c_s3a0in6 <= (others => '0');
			c_s3a0in7 <= (others => '0');
 			c_s3a0in8 <= (others => '0');
		elsif clk'event and clk = '1' then
 			c_s3a0in1 <= c_s2a0s;
			c_s3a0in2 <= c_s2a0c;
			c_s3a0in3 <= c_s2a1s;
			c_s3a0in4 <= c_s2a1c;
 			c_s3a0in5 <= c_s2a2s;
			c_s3a0in6 <= c_s2a2c; 
			c_s3a0in7 <= c_s2a3s;
			c_s3a0in8 <= c_s2a3c;
		end if;
	end process c_latchc;

	-- Third stage sine adder
	-- --------------------------------------------------------------------------------
	s_s3a0: csava20x9
		port map(in1 => s_s3a0in1, in2 => s_s3a0in2,
			in3(19) => s_s3a0in3(17), -- <============
			in3(18) => s_s3a0in3(17),
			in3(17 downto 0) => s_s3a0in3,
			in4(19) => s_s3a0in4(17), -- <============
			in4(18) => s_s3a0in4(17),
			in4(17 downto 0) => s_s3a0in4,
			in5(19) => s_s3a0in5(13), -- <============
			in5(18) => s_s3a0in5(13), 
			in5(17) => s_s3a0in5(13), 
			in5(16) => s_s3a0in5(13), 
			in5(15) => s_s3a0in5(13), 
			in5(14) => s_s3a0in5(13), 
			in5(13 downto 0) => s_s3a0in5, 
			in6(19) => s_s3a0in6(13), -- <============
			in6(18) => s_s3a0in6(13),
			in6(17) => s_s3a0in6(13),
			in6(16) => s_s3a0in6(13),
			in6(15) => s_s3a0in6(13),
			in6(14) => s_s3a0in6(13),
			in6(13 downto 0) => s_s3a0in6,
			in7(19) => s_s3a0in7(11), -- <============
			in7(18) => s_s3a0in7(11),
			in7(17) => s_s3a0in7(11),
			in7(16) => s_s3a0in7(11),
			in7(15) => s_s3a0in7(11),
			in7(14) => s_s3a0in7(11),
			in7(13) => s_s3a0in7(11),
			in7(12) => s_s3a0in7(11),
			in7(11 downto 0) => s_s3a0in7, 
			in8(19) => s_s3a0in8(11), -- <============
			in8(18) => s_s3a0in8(11),
			in8(17) => s_s3a0in8(11),
			in8(16) => s_s3a0in8(11),
			in8(15) => s_s3a0in8(11),
			in8(14) => s_s3a0in8(11),
			in8(13) => s_s3a0in8(11),
			in8(12) => s_s3a0in8(11),
			in8(11 downto 0) => s_s3a0in8,
			in9(19) => s_s3a0in9(6), -- <============
			in9(18) => s_s3a0in9(6),
			in9(17) => s_s3a0in9(6),
			in9(16) => s_s3a0in9(6),
			in9(15) => s_s3a0in9(6),
			in9(14) => s_s3a0in9(6),
			in9(13) => s_s3a0in9(6),
			in9(12) => s_s3a0in9(6),
			in9(11) => s_s3a0in9(6),
			in9(10) => s_s3a0in9(6),
			in9(9) => s_s3a0in9(6),
			in9(8) => s_s3a0in9(6),
			in9(7) => s_s3a0in9(6),
			in9(6 downto 0) => s_s3a0in9,
			s => s_s3a0s, c => s_s3a0c);

	-- Third stage cosine adder
	-- --------------------------------------------------------------------------------
	c_s3a0: csava20x8
		port map(in1 => c_s3a0in1, in2 => c_s3a0in2,
			in3(19) => c_s3a0in3(16), -- <============
			in3(18) => c_s3a0in3(16),
			in3(17) => c_s3a0in3(16),
			in3(16 downto 0) => c_s3a0in3,
			in4(19) => c_s3a0in4(16), -- <============
			in4(18) => c_s3a0in4(16),
			in4(17) => c_s3a0in4(16),
			in4(16 downto 0) => c_s3a0in4,
			in5(19) => c_s3a0in5(13), -- <============
			in5(18) => c_s3a0in5(13), 
			in5(17) => c_s3a0in5(13), 
			in5(16) => c_s3a0in5(13), 
			in5(15) => c_s3a0in5(13), 
			in5(14) => c_s3a0in5(13), 
			in5(13 downto 0) => c_s3a0in5, 
			in6(19) => c_s3a0in6(13), -- <============
			in6(18) => c_s3a0in6(13),
			in6(17) => c_s3a0in6(13),
			in6(16) => c_s3a0in6(13),
			in6(15) => c_s3a0in6(13),
			in6(14) => c_s3a0in6(13),
			in6(13 downto 0) => c_s3a0in6,
			in7(19) => c_s3a0in7(11), -- <============
			in7(18) => c_s3a0in7(11),
			in7(17) => c_s3a0in7(11),
			in7(16) => c_s3a0in7(11),
			in7(15) => c_s3a0in7(11),
			in7(14) => c_s3a0in7(11),
			in7(13) => c_s3a0in7(11),
			in7(12) => c_s3a0in7(11),
			in7(11 downto 0) => c_s3a0in7, 
			in8(19) => c_s3a0in8(11), -- <============
			in8(18) => c_s3a0in8(11),
			in8(17) => c_s3a0in8(11),
			in8(16) => c_s3a0in8(11),
			in8(15) => c_s3a0in8(11),
			in8(14) => c_s3a0in8(11),
			in8(13) => c_s3a0in8(11),
			in8(12) => c_s3a0in8(11),
			in8(11 downto 0) => c_s3a0in8,
			s => c_s3a0s, c => c_s3a0c);

	-- Latch D
	latchd: process(clk, reset)
	begin
		if reset = '0' then
			s_s4a0in1 <= (others => '0');
			s_s4a0in2 <= (others => '0');
			c_s4a0in1 <= (others => '0');
			c_s4a0in2 <= (others => '0');
		elsif clk'event and clk = '1' then
			s_s4a0in1 <= s_s3a0s;
			s_s4a0in2 <= s_s3a0c;
			c_s4a0in1 <= c_s3a0s;
			c_s4a0in2 <= c_s3a0c;
		end if;
	end process latchd;
	
	-- Two CSA adders of stage 4
	s_s4a0: csa10
		port map(a => s_s4a0in1(9 downto 0), b => s_s4a0in2(9 downto 0), 
			cin => zero, cout => s_s4a0c, s => s_s4a0s);
	c_s4a0: csa10
		port map(a => c_s4a0in1(9 downto 0), b => c_s4a0in2(9 downto 0), 
			cin => zero, cout => c_s4a0c, s => c_s4a0s);

	-- Latch E
	latche: process(clk, reset)
	begin
		if reset = '0' then
			s_s5a0in1 <= (others => '0');
			s_s5a0in2 <= (others => '0');
			s_s5a0cin <= '0';
			s_s5a1in1i <= (others => '0');
			c_s5a0in1 <= (others => '0');
			c_s5a0in2 <= (others => '0');
			c_s5a0cin <= '0';
			c_s5a1in1i <= (others => '0');
		elsif clk'event and clk = '1' then
			s_s5a0in1 <= s_s4a0in1(19 downto 10);
			s_s5a0in2 <= s_s4a0in2(19 downto 10);
			s_s5a0cin <= s_s4a0c;
			s_s5a1in1i <= s_s4a0s(9 downto 6);
			c_s5a0in1 <= c_s4a0in1(19 downto 10);
			c_s5a0in2 <= c_s4a0in2(19 downto 10);
			c_s5a0cin <= c_s4a0c;
			c_s5a1in1i <= c_s4a0s(9 downto 6);
		end if;
	end process latche;
	
	-- STAGE 5 ------------------------------------------------------------

	-- Construct phd signal
	latchph: process(clk, reset)
	begin
		if reset = '0' then
			pha <= (others => '0');
			phb <= (others => '0');
			phc <= (others => '0');
			phd(2 downto 0) <= "000";
		elsif clk'event and clk = '1' then
			pha <= phase(18 downto 16);
			phb <= pha;
			phc <= phb;
			phd(2 downto 0) <= phc;
		end if;
	end process latchph;
	phd(3) <= spc;
	
	-- Construct control signals
	with phd select
		ssign <= '0' when "0000" | "0001" | "0011" | "0110" |
				  "1001" | "1100" | "1110" | "1111",
			 '1' when others;

	with phd select
		csign <= '0' when "0000" | "0001" | "0010" | "0111" |
				  "1000" | "1101" | "1110" | "1111",
			 '1' when others;

	with phd(2 downto 0) select
		cmux <=  '1' when "000" | "011" | "100" | "111",
			 '0' when others;

	-- Sine sca10 adder
	s_s5a0: csa10
		port map(a => s_s5a0in1, b => s_s5a0in2, 
			cin => s_s5a0cin, cout => open, s => s_s5a0s);

	-- Invert the result if ssign is negative
	s_s5a0si <= s_s5a0s when ssign = '0' else not s_s5a0s;

	-- Also, invert the input to the bcla4 if ssign is negative
	s_s5a1in1 <= s_s5a1in1i when ssign = '0' else not s_s5a1in1i;

	-- Sine bcla4 adder
	s_s5a1: bcla4
		port map(a => s_s5a1in1, b => zero4, 
			cin => ssign, cout => s_s5a1c, s => s_s5a1s);

	-- Cosine csa10 adder
	c_s5a0: csa10
		port map(a => c_s5a0in1, b => c_s5a0in2, 
			cin => c_s5a0cin, cout => open, s => c_s5a0s);

	-- Invert the result if csign is negative
	c_s5a0si <= c_s5a0s when csign = '0' else not c_s5a0s;

	-- Also, invert the input to the bcla4 if csign is negative
	c_s5a1in1 <= c_s5a1in1i when csign = '0' else not c_s5a1in1i;

	-- Cosine bcla4 adder
	c_s5a1: bcla4
		port map(a => c_s5a1in1, b => zero4, 
			cin => csign, cout => c_s5a1c, s => c_s5a1s);

	-- Latch F
	latchf: process(clk, reset)
	begin		     
		if reset = '0' then
			cmuxa <= '0';
			s_s6a0in1 <= (others => '0');
			s_s6a0cin <= '0';
			s(3 downto 0) <= "0000";
			c_s6a0in1 <= (others => '0');
			c_s6a0cin <= '0';
			c(3 downto 0) <= "0000";
		elsif clk'event and clk = '1' then
			cmuxa <= cmux;
			s_s6a0in1 <= s_s5a0si;
			s_s6a0cin <= s_s5a1c;
			s(3 downto 0) <= s_s5a1s;
			c_s6a0in1 <= c_s5a0si;
			c_s6a0cin <= c_s5a1c;
			c(3 downto 0) <= c_s5a1s;
		end if;
	end process latchf;

	-- STAGE 6 -----------------------------------------------------------

	-- Two csa10 adders of stage 6
	s_s6a0: csa10
		port map(a => s_s6a0in1, b => zero10, 
			cin => s_s6a0cin, cout => open, s => s(13 downto 4));
	c_s6a0: csa10
		port map(a => c_s6a0in1, b => zero10, 
			cin => c_s6a0cin, cout => open, s => c(13 downto 4));

	-- Select proper outputs for sine and cosine waveforms
	mux: process(cmuxa, s, c)
	begin
		if cmuxa = '1' then 	-- Sine goes to sine, cosine to cosine
			s13 <= s(13);
			si(12 downto 0) <= s(12 downto 0);
			c13 <= c(13);
			co(12 downto 0) <= c(12 downto 0);
		else			-- Twist them ------------------------
			s13 <= c(13);
			si(12 downto 0) <= c(12 downto 0);
			c13 <= s(13);
			co(12 downto 0) <= s(12 downto 0);
		end if;
	end process mux;
	
	-- Invert MSB for sine and cosine if binary offset output is required
	si(13) <= s13 when ofc = '1' else not s13;
	co(13) <= c13 when ofc = '1' else not c13;
	
	-- Laaaaaaaaaast latch
	latchg: process(clk, reset)
	begin
		if reset = '0' then
			sin <= (others => '0');
			cos <= (others => '0');
		elsif clk'event and clk = '1' then
			sin <= si;
			cos <= co;
		end if;
	end process latchg;
	
end qpsmc19x14_arch;
