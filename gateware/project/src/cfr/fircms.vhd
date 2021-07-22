-- ----------------------------------------------------------------------------	
-- FILE:	fircms.vhd
-- DESCRIPTION:	Serial configuration interface FIR Coeffitient Memory.
--							Contains 5 RAM memory bloks of 8 bytes by 16 bits.
-- DATE:	2012.08.20
-- AUTHOR(s):	
-- REVISIONS:	
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fircms_bj is
	port (
		-- Address and location of this module
		-- These signals will be hard wired at the top level
		maddress: in std_logic_vector(8 downto 0);
		mimo_en: in std_logic; 	--
	
		-- Serial port A IOs
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
	
		-- Signals coming from the pins or top level serial interface
		hreset: in std_logic; 	-- Hard reset signal, resets everything
		
		oen: out std_logic;
		
		ai: in std_logic_vector(1 downto 0); -- Internal address
		
		di0: out mword16; -- Internal data bus
		di1: out mword16; -- Internal data bus
		di2: out mword16; -- Internal data bus
		di3: out mword16; -- Internal data bus
		di4: out mword16; -- Internal data bus
		di5: out mword16; -- Internal data bus
		di6: out mword16; -- Internal data bus
		di7: out mword16; -- Internal data bus
		di8: out mword16; -- Internal data bus
		di9: out mword16 -- Internal data bus		
	);
end fircms_bj;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture fircms_arch_bj of fircms_bj is
	signal inst_reg: std_logic_vector(15 downto 0);	-- Instruction register
	signal inst_reg_en: std_logic;

	signal din_reg: std_logic_vector(15 downto 0);		-- Data in register
	signal din_reg_en: std_logic;
	
	signal dout_reg: std_logic_vector(15 downto 0);	-- Data out register
	signal dout_reg_sen, dout_reg_len: std_logic;
	
	signal mem0, mem1, mem2, mem3, mem4, mem5, mem6, mem7, mem8, mem9: marray4x16;					-- RAM memory
	signal mem_we: std_logic;
	
	signal oe: std_logic;				-- Tri state buffers control 
	
	use work.mcfg_components.mcfg64wm_fsm;
	for all: mcfg64wm_fsm use entity work.mcfg64wm_fsm(mcfg64wm_fsm_arch);

begin
	-- ---------------------------------------------------------------------------------------------
	-- Finite state machines
	-- ---------------------------------------------------------------------------------------------
	fsm: mcfg64wm_fsm port map( 
		address => maddress, mimo_en => mimo_en, inst_reg => inst_reg, sclk => sclk, sen => sen, reset => hreset,
		inst_reg_en => inst_reg_en, din_reg_en => din_reg_en, dout_reg_sen => dout_reg_sen,
		dout_reg_len => dout_reg_len, mem_we => mem_we, oe => oe, stateo => open);
		
	-- ---------------------------------------------------------------------------------------------
	-- Instruction register
	-- ---------------------------------------------------------------------------------------------
	inst_reg_proc: process(sclk, hreset)
		variable i: integer;
	begin
		if hreset = '0' then
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
	din_reg_proc: process(sclk, hreset)
		variable i: integer;
	begin
		if hreset = '0' then
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
	dout_reg_proc: process(sclk, hreset)
		variable i: integer;
	begin
		if hreset = '0' then
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
			
				case inst_reg(5 downto 2) is
					when "0000" =>
						dout_reg <= mem0(to_integer(unsigned(inst_reg(1 downto 0))));
					when "0001" =>
						dout_reg <= mem1(to_integer(unsigned(inst_reg(1 downto 0))));
					when "0010" =>
						dout_reg <= mem2(to_integer(unsigned(inst_reg(1 downto 0))));
					when "0011" =>
						dout_reg <= mem3(to_integer(unsigned(inst_reg(1 downto 0))));
					when "0100" =>
						dout_reg <= mem4(to_integer(unsigned(inst_reg(1 downto 0))));
					when "0101" =>
						dout_reg <= mem5(to_integer(unsigned(inst_reg(1 downto 0))));
					when "0110" =>
						dout_reg <= mem6(to_integer(unsigned(inst_reg(1 downto 0))));
					when "0111" =>
						dout_reg <= mem7(to_integer(unsigned(inst_reg(1 downto 0))));
					when "1000" =>
						dout_reg <= mem8(to_integer(unsigned(inst_reg(1 downto 0))));
					when "1001" =>
						dout_reg <= mem9(to_integer(unsigned(inst_reg(1 downto 0))));
					when others =>
						null;
				end case;
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
	ram: process(sclk, hreset)
	begin
		if sclk'event and sclk = '1' then
			if mem_we = '1' then
				case inst_reg(5 downto 2) is
					when "0000" =>
						mem0(to_integer(unsigned(inst_reg(1 downto 0)))) <= din_reg(14 downto 0) & sdin;
					when "0001" =>
						mem1(to_integer(unsigned(inst_reg(1 downto 0)))) <= din_reg(14 downto 0) & sdin;
					when "0010" =>
						mem2(to_integer(unsigned(inst_reg(1 downto 0)))) <= din_reg(14 downto 0) & sdin;
					when "0011" =>
						mem3(to_integer(unsigned(inst_reg(1 downto 0)))) <= din_reg(14 downto 0) & sdin;
					when "0100" =>
						mem4(to_integer(unsigned(inst_reg(1 downto 0))))<= din_reg(14 downto 0) & sdin;						
					when "0101" =>
						mem5(to_integer(unsigned(inst_reg(1 downto 0)))) <= din_reg(14 downto 0) & sdin;
					when "0110" =>
						mem6(to_integer(unsigned(inst_reg(1 downto 0)))) <= din_reg(14 downto 0) & sdin;
					when "0111" =>
						mem7(to_integer(unsigned(inst_reg(1 downto 0)))) <= din_reg(14 downto 0) & sdin;
					when "1000" =>
						mem8(to_integer(unsigned(inst_reg(1 downto 0)))) <= din_reg(14 downto 0) & sdin;
					when "1001" =>
						mem9(to_integer(unsigned(inst_reg(1 downto 0))))<= din_reg(14 downto 0) & sdin;						
					when others =>
						null;
				end case;
			end if;
		end if;
	end process ram;

	-- Construct data outputs to the filter
	di0 <= mem0(to_integer(unsigned(ai)));
	di1 <= mem1(to_integer(unsigned(ai)));
	di2 <= mem2(to_integer(unsigned(ai)));
	di3 <= mem3(to_integer(unsigned(ai)));
	di4 <= mem4(to_integer(unsigned(ai)));
	di5 <= mem5(to_integer(unsigned(ai)));
	di6 <= mem6(to_integer(unsigned(ai)));
	di7 <= mem7(to_integer(unsigned(ai)));
	di8 <= mem8(to_integer(unsigned(ai)));
	di9 <= mem9(to_integer(unsigned(ai)));
	
end fircms_arch_bj;
