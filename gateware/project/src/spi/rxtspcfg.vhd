-- ----------------------------------------------------------------------------	
-- FILE:	mcfg_rx.vhd
-- DESCRIPTION:	Serial configuration interface to control RX modules
-- DATE:	2007.06.07
-- AUTHOR(s):	
-- REVISIONS:	
--		1. 07.01.2015: Output signal hbd_dly added.
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.rxtspcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rxtspcfg is
	port (
		-- Address and location of this module
		-- These signals will be hard wired at the top level
		maddress: in std_logic_vector(9 downto 0);
		mimo_en: in std_logic;	-- MIMO enable, from TOP SPI
	
		-- Serial port A IOs
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
	
		-- Signals coming from the pins or top level serial interface
		lreset: in std_logic; 	-- Logic reset signal, resets logic cells only
		mreset: in std_logic; 	-- Memory reset signal, resets configuration memory only
	
		oen: out std_logic;
		
		en		: buffer std_logic;
		stateo: out std_logic_vector(5 downto 0);
      
      to_rxtspcfg : in t_TO_RXTSPCFG;
      from_rxtspcfg : out t_FROM_RXTSPCFG

	);
end rxtspcfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture rxtspcfg_arch of rxtspcfg is
	signal inst_reg: std_logic_vector(15 downto 0);	-- Instruction register
	signal inst_reg_en: std_logic;

	signal din_reg: std_logic_vector(15 downto 0);		-- Data in register
	signal din_reg_en: std_logic;
	
	signal dout_reg: std_logic_vector(15 downto 0);	-- Data out register
	signal dout_reg_sen, dout_reg_len: std_logic;
	
	signal mem: marray16x16;					-- Config memory
	signal mem_we: std_logic;
	
	signal oe: std_logic;				-- Tri state buffers control 
	
	signal capsel_adc: std_logic;		-- Internal signal to select ADC values
	
	use work.mcfg_components.mcfg32wm_fsm;
	for all: mcfg32wm_fsm use entity work.mcfg32wm_fsm(mcfg32wm_fsm_arch);

begin
	-- ---------------------------------------------------------------------------------------------
	-- Finite state machines
	-- ---------------------------------------------------------------------------------------------
	fsm: mcfg32wm_fsm port map( 
		address => maddress, mimo_en => mimo_en, inst_reg => inst_reg, sclk => sclk, sen => sen, reset => lreset,
		inst_reg_en => inst_reg_en, din_reg_en => din_reg_en, dout_reg_sen => dout_reg_sen,
		dout_reg_len => dout_reg_len, mem_we => mem_we, oe => oe, stateo => stateo);
		
	-- ---------------------------------------------------------------------------------------------
	-- Instruction register
	-- ---------------------------------------------------------------------------------------------
	inst_reg_proc: process(sclk, lreset)
		variable i: integer;
	begin
		if lreset = '0' then
			inst_reg <= (others => '0');
		elsif sclk'event and sclk = '1' then
			if inst_reg_en = '1' then
				for i in 15 downto 1 loop
					inst_reg(i) <= inst_reg(i-1);
				end loop;
				inst_reg(0) <= sdin;
			end if;
		end if;
	end process inst_reg_proc;

	-- ---------------------------------------------------------------------------------------------
	-- Data input register
	-- ---------------------------------------------------------------------------------------------
	din_reg_proc: process(sclk, lreset)
		variable i: integer;
	begin
		if lreset = '0' then
			din_reg <= (others => '0');
		elsif sclk'event and sclk = '1' then
			if din_reg_en = '1' then
				for i in 15 downto 1 loop
					din_reg(i) <= din_reg(i-1);
				end loop;
				din_reg(0) <= sdin;
			end if;
		end if;
	end process din_reg_proc;

	-- ---------------------------------------------------------------------------------------------
	-- Data output register
	-- ---------------------------------------------------------------------------------------------
	dout_reg_proc: process(sclk, lreset)
		variable i: integer;
	begin
		if lreset = '0' then
			dout_reg <= (others => '0');
		elsif sclk'event and sclk = '0' then
			-- Shift operation
			if dout_reg_sen = '1' then
				for i in 15 downto 1 loop
					dout_reg(i) <= dout_reg(i-1);
				end loop;
				dout_reg(0) <= dout_reg(15);
			-- Load operation
			elsif dout_reg_len = '1' then
				dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
			end if;			      
		end if;
	end process dout_reg_proc;
	
	-- Tri state buffer to connect multiple serial interfaces in parallel
	--sdout <= dout_reg(7) when oe = '1' else 'Z';

--	sdout <= dout_reg(7);
--	oen <= oe;

	sdout <= dout_reg(15) and oe;
	oen <= oe;
	

	-- ---------------------------------------------------------------------------------------------
	-- Configuration memory
	-- --------------------------------------------------------------------------------------------- 
	ram: process(sclk, mreset)
	begin
		-- Defaults
		if mreset = '0' then
			mem(0)	<= "0000000010000001"; --  2 free, CAPTURE, CAPSEL[1:0], CAPSEL_ADC, UNUSED[1:0], TSGFC, TSGFCW[1:0], TSGDCLDQ, TSGDCLDI, TSGSWAPIQ, TSGMODE, INSEL, BSTART, EN
			mem(1)	<= "0000011111111111"; --  5 free, UNUSED[4:0], gcorrQ[10:0]
			mem(2)	<= "0000011111111111"; --  5 free, UNUSED[4:0], gcorrI[10:0]
			mem(3)	<= "0000000000000000"; --  1 free, UNUSED, HBD_OVR[2:0], IQcorr[11:0]
			mem(4)	<= "0000000000000000"; -- 10 free, HBD_DLY[2:0], UNUSED[9:0], DCCORR_AVG[2:0]
			mem(5)	<= "0000000000000000"; --  5 free, UNUSED[4:0], GFIR1_L[2:0] (def. 1) (Length of PHEQ - 1), GFIR1_N[7:0] (def. 1) (PHEQ Clock division ratio. Must be HBI interpolation ratio - 1)
			mem(6)	<= "0000000000000000"; --  5 free, UNUSED[4:0], GFIR2_L[2:0], GFIR2_N[7:0]
			mem(7)	<= "0000000000000000"; --  5 free, UNUSED[4:0], GFIR3_L[2:0], GFIR3_N[7:0]
			mem(8)	<= "0000000000000000"; --  0 free, AGC_K[15:0]											(Word Layout: KKKKKKKK KKKKKKKK)
			mem(9)	<= "0000000000000000"; --  2 free, AGC_ADESIRED[11:0], AGC_K[17:16]	(Word Layout: DDDDDDDD DDDDxxKK)
			mem(10)	<= "0000000000000000"; --  9 free, RSSI_MODE[1:0], AGC_MODE[1:0], UNUSED[8:0], AGC_AVG[2:0]			(Word Layout: xxMMAAAA AAAAAAAA)
			mem(11)	<= "0000000000000000"; --  0 free, DC_REG[15:0]
			mem(12)	<= "0000000000000000"; --  3 free, CMIX_GAIN[1:0], CMIX_SC, CMIX_GAIN[2], UNUSED[2:0], DCLOOP_BYP, CMIX_BYP, AGC_BYP, GFIR3_BYP, GFIR2_BYP, GFIR1_BYP, DC_BYP, GC_BYP, PH_BYP
			mem(13)	<= "0000000000000000"; -- 16 free, UNUSED[15:0]
			mem(14)	<= "0000000000000000"; --  0 free, CAPD[15:0]								(Read only register)
			mem(15)	<= "0000000000000000"; --  0 free, CAPD[31:16]							(Read only register)
		elsif sclk'event and sclk = '1' then
				if mem_we = '1' then
					mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
				end if;
				
				if dout_reg_len = '0' then
					if capsel_adc = '0' then
						mem(14) <= to_rxtspcfg.capd(15 downto 0);
						mem(15) <= to_rxtspcfg.capd(31 downto 16);
					else
						mem(14) <= to_rxtspcfg.rxtspout_i;
						mem(15) <= to_rxtspcfg.rxtspout_q;
					end if;
				end if;
				
		end if;
	end process ram;
	
	-- ---------------------------------------------------------------------------------------------
	-- Decoding logic
	-- ---------------------------------------------------------------------------------------------

   
   --0x0
   from_rxtspcfg.capture      <= mem(0)(15);
   from_rxtspcfg.capsel       <= mem(0)(14 downto 13);
   capsel_adc                 <= mem(0)(12);
   from_rxtspcfg.tsgfc        <= mem(0)(9);
   from_rxtspcfg.tsgfcw       <= mem(0)(8 downto 7);
   from_rxtspcfg.tsgdcldq     <= mem(0)(6);
   from_rxtspcfg.tsgdcldi     <= mem(0)(5);
   from_rxtspcfg.tsgswapiq    <= mem(0)(4);
   from_rxtspcfg.tsgmode      <= mem(0)(3);
   from_rxtspcfg.insel        <= mem(0)(2);
   from_rxtspcfg.bstart       <= mem(0)(1);
   from_rxtspcfg.en           <= mem(0)(0) and to_rxtspcfg.rxen;
   
   --0x1, 0x2
   from_rxtspcfg.gcorrq       <= mem(1)(10 downto 0);
   from_rxtspcfg.gcorri       <= mem(2)(10 downto 0);
   
   --0x3
   from_rxtspcfg.iqcorr       <= mem(3)(11 downto 0);
   from_rxtspcfg.ovr          <= mem(3)(14 downto 12);
   
   --0x4
   from_rxtspcfg.dccorr_avg   <= mem(4)(2 downto 0);
   from_rxtspcfg.hbd_dly      <= mem(4)(15 downto 13);
   
   --0x5
   from_rxtspcfg.gfir1l       <= mem(5)(10 downto 8);
   from_rxtspcfg.gfir1n       <= mem(5)(7 downto 0);
   
   --0x6
   from_rxtspcfg.gfir2l       <= mem(6)(10 downto 8);
   from_rxtspcfg.gfir2n       <= mem(6)(7 downto 0);
   
   --0x7
   from_rxtspcfg.gfir3l       <= mem(7)(10 downto 8);
   from_rxtspcfg.gfir3n       <= mem(7)(7 downto 0);
   
   --0x8
   from_rxtspcfg.agc_k        <= mem(8) & mem(9)(1 downto 0);
   
   --0x9
   from_rxtspcfg.agc_adesired <= mem(9)(15 downto 4);
   
   --0xA
   from_rxtspcfg.agc_avg      <= mem(10)(11 downto 0);
   from_rxtspcfg.agc_mode     <= mem(10)(13 downto 12);
   from_rxtspcfg.rssi_mode    <= not (mem(10)(15 downto 14));
   
   --0xB
   from_rxtspcfg.dc_reg       <= mem(11);
   
   --0xC
   from_rxtspcfg.ph_byp       <= mem(12)(0);
   from_rxtspcfg.gc_byp       <= mem(12)(1);
   from_rxtspcfg.dc_byp       <= mem(12)(2);
   from_rxtspcfg.gfir1_byp    <= mem(12)(3);
   from_rxtspcfg.gfir2_byp    <= mem(12)(4);
   from_rxtspcfg.gfir3_byp    <= mem(12)(5);
   from_rxtspcfg.agc_byp      <= mem(12)(6);
   from_rxtspcfg.cmix_byp     <= mem(12)(7);
   from_rxtspcfg.rxdcloop_en  <= not mem(12)(8); -- Inverted, to form oposite logic!
   from_rxtspcfg.cmix_sc      <= mem(12)(13);
   from_rxtspcfg.cmix_gain    <= mem(12)(12) & mem(12)(15 downto 14);
   
   --0xE, 0xF
   --CAPD, READ ONLY REGS
   
   
end rxtspcfg_arch;
