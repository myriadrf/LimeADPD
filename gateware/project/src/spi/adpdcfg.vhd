-- ----------------------------------------------------------------------------	
-- FILE:	adpdcfg.vhd
-- DESCRIPTION:	Serial configuration interface to control DPD, CFR modules
-- DATE:	Dec 20, 2018
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.mem_package.ALL;
-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
ENTITY adpdcfg IS
	PORT (
		maddress : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		mimo_en : IN STD_LOGIC;
		sdin : IN STD_LOGIC;
		sclk : IN STD_LOGIC;
		sen : IN STD_LOGIC;
		sdout : OUT STD_LOGIC;
		lreset : IN STD_LOGIC;
		mreset : IN STD_LOGIC;
		oen : OUT STD_LOGIC; --nc
		stateo : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		ADPD_BUFF_SIZE : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); --ADPD
		ADPD_CONT_CAP_EN : OUT STD_LOGIC;
		ADPD_CAP_EN : OUT STD_LOGIC;
		-- DPD
		adpd_config0, adpd_config1, adpd_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		-- CFR
		cfr0_bypass, cfr0_sleep, cfr1_bypass, cfr1_sleep, cfr0_odd, cfr1_odd : OUT STD_LOGIC;
		cfr0_interpolation, cfr1_interpolation : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		cfr0_threshold, cfr1_threshold : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		cfr0_order, cfr1_order : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		-- CFR GAIN
		gain_cfr0, gain_cfr1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		gain_cfr0_bypass, gain_cfr1_bypass : OUT STD_LOGIC;
		-- HB
		hb0_delay, hb1_delay : OUT STD_LOGIC;
		-- FIR
		gfir0_byp, gfir0_sleep, gfir0_odd, gfir1_byp, gfir1_sleep, gfir1_odd : OUT STD_LOGIC;
		PAEN0, PAEN1, DCEN0, DCEN1, reset_n_soft : OUT STD_LOGIC;
		rf_sw : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END adpdcfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE adpdcfg_arch OF adpdcfg IS

	SIGNAL inst_reg : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Instruction register
	SIGNAL inst_reg_en : STD_LOGIC;

	SIGNAL din_reg : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data in register
	SIGNAL din_reg_en : STD_LOGIC;

	SIGNAL dout_reg : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data out register
	SIGNAL dout_reg_sen, dout_reg_len : STD_LOGIC;

	SIGNAL mem : marray32x16; -- Config memory
	SIGNAL mem_we : STD_LOGIC;

	SIGNAL oe : STD_LOGIC; -- Tri state buffers control
	SIGNAL spi_config_data_rev : STD_LOGIC_VECTOR(143 DOWNTO 0);

	-- Components
	USE work.mcfg_components.mcfg32wm_fsm;
	FOR ALL : mcfg32wm_fsm USE ENTITY work.mcfg32wm_fsm(mcfg32wm_fsm_arch);

BEGIN
	-- ---------------------------------------------------------------------------------------------
	-- Finite state machines
	-- ---------------------------------------------------------------------------------------------
	fsm : mcfg32wm_fsm PORT MAP(
		address => maddress, mimo_en => mimo_en, inst_reg => inst_reg, sclk => sclk, sen => sen, reset => lreset,
		inst_reg_en => inst_reg_en, din_reg_en => din_reg_en, dout_reg_sen => dout_reg_sen,
		dout_reg_len => dout_reg_len, mem_we => mem_we, oe => oe, stateo => stateo);

	-- ---------------------------------------------------------------------------------------------
	-- Instruction register
	-- ---------------------------------------------------------------------------------------------
	inst_reg_proc : PROCESS (sclk, lreset)
		VARIABLE i : INTEGER;
	BEGIN
		IF lreset = '0' THEN
			inst_reg <= (OTHERS => '0');
		ELSIF sclk'event AND sclk = '1' THEN
			IF inst_reg_en = '1' THEN
				FOR i IN 15 DOWNTO 1 LOOP
					inst_reg(i) <= inst_reg(i - 1);
				END LOOP;
				inst_reg(0) <= sdin;
			END IF;
		END IF;
	END PROCESS inst_reg_proc;

	-- ---------------------------------------------------------------------------------------------
	-- Data input register
	-- ---------------------------------------------------------------------------------------------
	din_reg_proc : PROCESS (sclk, lreset)
		VARIABLE i : INTEGER;
	BEGIN
		IF lreset = '0' THEN
			din_reg <= (OTHERS => '0');
		ELSIF sclk'event AND sclk = '1' THEN
			IF din_reg_en = '1' THEN
				FOR i IN 15 DOWNTO 1 LOOP
					din_reg(i) <= din_reg(i - 1);
				END LOOP;
				din_reg(0) <= sdin;
			END IF;
		END IF;
	END PROCESS din_reg_proc;

	-- ---------------------------------------------------------------------------------------------
	-- Data output register
	-- ---------------------------------------------------------------------------------------------
	dout_reg_proc : PROCESS (sclk, lreset)
		VARIABLE i : INTEGER;
	BEGIN
		IF lreset = '0' THEN
			dout_reg <= (OTHERS => '0');
		ELSIF sclk'event AND sclk = '0' THEN
			-- Shift operation
			IF dout_reg_sen = '1' THEN
				FOR i IN 15 DOWNTO 1 LOOP
					dout_reg(i) <= dout_reg(i - 1);
				END LOOP;
				dout_reg(0) <= dout_reg(15);
				-- Load operation
			ELSIF dout_reg_len = '1' THEN
				CASE inst_reg(4 DOWNTO 0) IS -- mux read-only outputs
					WHEN OTHERS => dout_reg <= mem(to_integer(unsigned(inst_reg(4 DOWNTO 0))));
				END CASE;
			END IF;
		END IF;
	END PROCESS dout_reg_proc;

	-- Tri state buffer to connect multiple serial interfaces in parallel
	-- sdout <= dout_reg(7) when oe = '1' else 'Z';

	--	sdout <= dout_reg(7);
	--	oen <= oe;

	sdout <= dout_reg(15) AND oe;
	oen <= oe;
	-- ---------------------------------------------------------------------------------------------
	-- Configuration memory
	-- --------------------------------------------------------------------------------------------- 
	ram : PROCESS (sclk, mreset) --(remap)
	BEGIN
		-- Defaults
		IF mreset = '0' THEN
			--Read only registers
			mem(0) <= "0100000000000000"; -- ADPD_BUFF_SIZE
			mem(1) <= "0000100000000000"; -- 9 free, rf_sw(2:0),PAEN1,PAEN0,ADPD_CONT_CAP_EN,ADPD_CAP_EN
			mem(2) <= "0000000000000000"; -- adpd_config0(15:0) 
			mem(3) <= "0000000000000000"; -- adpd_config1(15:0)
			mem(4) <= "0000000000000000"; -- adpd_data(15:0)
			mem(5) <= "1110111011101110"; -- various CHB, CHA settings
			mem(6) <= "1111111111111111"; -- cfr0_threshold
			mem(7) <= "1111111111111111"; -- cfr1_threshold
			mem(8) <= "0010000000000000"; -- gain_cfr0 [-4..4]
			mem(9) <= "0010000000000000"; -- gain_cfr1	[-4..4]	

			mem(10) <= "0000000000000000"; -- spinCFR_ORDER_chB & spinCFR_ORDER (dummy)
			mem(11) <= "0000000000000000"; -- dummy, txtPllFreqTxMHz
			mem(12) <= "0000000000000000"; -- dummy, txtPllFreqRxMHz 
			mem(13) <= "0000000000000000"; -- 16 free, 
			mem(14) <= "0000000000000000"; -- 16 free, 
			mem(15) <= "0000000000000000"; -- 16 free, 
			mem(16) <= "0000000000000000"; -- 16 free, 
			mem(17) <= "0000000000000000"; -- 16 free,
			mem(18) <= "0000000000000000"; -- 16 free, 
			mem(19) <= "0000000000000000"; -- 16 free, 
			mem(20) <= "0000000000000000"; -- 16 free, 
			mem(21) <= "0000000000000000"; -- 16 free, 
			mem(22) <= "0000000000000000"; -- 16 free, 
			mem(23) <= "0000000000000000"; -- 16 free, 		

		ELSIF sclk'event AND sclk = '1' THEN
			IF mem_we = '1' THEN
				mem(to_integer(unsigned(inst_reg(4 DOWNTO 0)))) <= din_reg(14 DOWNTO 0) & sdin;
			END IF;

			IF dout_reg_len = '0' THEN
			END IF;

		END IF;
	END PROCESS ram;

	-- ---------------------------------------------------------------------------------------------
	-- Decoding logic
	-- ---------------------------------------------------------------------------------------------

	ADPD_BUFF_SIZE <= mem(0); -- not important		

	-- mem(1)
	ADPD_CAP_EN <= mem(1)(0);
	ADPD_CONT_CAP_EN <= mem(1)(1);

	PAEN0 <= mem(1)(2); -- PA amplifier enable  channel A
	PAEN1 <= mem(1)(3); -- PA amplifier enable  channel B

	rf_sw <= mem(1)(6 DOWNTO 4); -- RF_SW control		

	DCEN0 <= mem(1)(7); -- DC-DC enable  channel A
	DCEN1 <= mem(1)(8); -- DC-DC enable  channel B

	reset_n_soft <= mem(1)(11);

	cfr0_interpolation <= mem(1)(13 DOWNTO 12);
	cfr1_interpolation <= mem(1)(15 DOWNTO 14);

	adpd_config0 <= mem(2)(15 DOWNTO 0);
	adpd_config1 <= mem(3)(15 DOWNTO 0);
	adpd_data <= mem(4)(15 DOWNTO 0);

	-- mem(5) default:0xEEEE
	-- CH A		
	cfr0_sleep <= mem(5)(0); --0
	cfr0_bypass <= mem(5)(1); --1	
	cfr0_odd <= mem(5)(2); --1		

	gain_cfr0_bypass <= mem(5)(3); --1		

	gfir0_sleep <= mem(5)(4); --0	
	gfir0_byp <= mem(5)(5); --1
	gfir0_odd <= mem(5)(6); --1	

	hb0_delay <= mem(5)(7); --1

	-- CH B			
	cfr1_sleep <= mem(5)(8); --0
	cfr1_bypass <= mem(5)(9); --1
	cfr1_odd <= mem(5)(10); --1	

	gain_cfr1_bypass <= mem(5)(11); --1

	gfir1_sleep <= mem(5)(12); --0	
	gfir1_byp <= mem(5)(13); --1
	gfir1_odd <= mem(5)(14); --1		

	hb1_delay <= mem(5)(15); --1
	----------------		
	cfr0_threshold <= mem(6)(15 DOWNTO 0); --"1111111111111111"	
	cfr1_threshold <= mem(7)(15 DOWNTO 0); --"1111111111111111"	
	gain_cfr0 <= mem(8) (15 DOWNTO 0); --"0010000000000000"		
	gain_cfr1 <= mem(9) (15 DOWNTO 0); --"0010000000000000"

	cfr0_order <= mem(10) (7 DOWNTO 0); -- dodato
	cfr1_order <= mem(10) (15 DOWNTO 8); -- dodato
END adpdcfg_arch;