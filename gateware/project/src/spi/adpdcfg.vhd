-- ----------------------------------------------------------------------------	
-- FILE:	fpgacfg.vhd
-- DESCRIPTION:	Serial configuration interface to control TX modules
-- DATE:	June 07, 2007
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
entity adpdcfg is
	port (
		-- Address and location of this module
		-- Will be hard wired at the top level
		maddress	: in std_logic_vector(9 downto 0);
		mimo_en	: in std_logic;	-- MIMO enable, from TOP SPI (always 1)
	
		-- Serial port IOs
		sdin	: in std_logic; 	-- Data in
		sclk	: in std_logic; 	-- Data clock
		sen	: in std_logic;	-- Enable signal (active low)
		sdout	: out std_logic; 	-- Data out
	
		-- Signals coming from the pins or top level serial interface
		lreset	: in std_logic; 	-- Logic reset signal, resets logic cells only  (use only one reset)
		mreset	: in std_logic; 	-- Memory reset signal, resets configuration memory only (use only one reset)
		
		oen: out std_logic; --nc
		stateo: out std_logic_vector(5 downto 0);
		
		
		--ADPD
		ADPD_BUFF_SIZE 	: out std_logic_vector(15 downto 0);
		ADPD_CONT_CAP_EN	: out std_logic;
		ADPD_CAP_EN			: out std_logic;
		
		--  Borisav Jovanovic: 11.09.2016
		adpd_config			: out std_logic_vector(15 downto 0);
		adpd_data			: out std_logic_vector(15 downto 0);
		
	   -- power amplifier control signals
		pa1_ctrl1, pa1_ctrl2, pa1_ven, pa1_vmode0, pa1_vmode1: out std_logic;
		pa2_ctrl1, pa2_ctrl2, pa2_ven, pa2_vmode0, pa2_vmode1: out std_logic;
		RF_SW_V3, RF_SW_V2, RF_SW_V1: out std_logic

	);
end adpdcfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture adpdcfg_arch of adpdcfg is

	signal inst_reg: std_logic_vector(15 downto 0);		-- Instruction register
	signal inst_reg_en: std_logic;

	signal din_reg: std_logic_vector(15 downto 0);		-- Data in register
	signal din_reg_en: std_logic;
	
	signal dout_reg: std_logic_vector(15 downto 0);		-- Data out register
	signal dout_reg_sen, dout_reg_len: std_logic;
	
	signal mem: marray32x16;									-- Config memory
	signal mem_we: std_logic;
	
	signal oe: std_logic;										-- Tri state buffers control
	signal spi_config_data_rev	: std_logic_vector(143 downto 0);
	
	-- Components
	use work.mcfg_components.mcfg32wm_fsm;
	for all: mcfg32wm_fsm use entity work.mcfg32wm_fsm(mcfg32wm_fsm_arch);
	
	signal pa2mode, pa1mode, rfsw : std_logic_vector(2 downto 0);	
   signal pa2sw, pa1sw : std_logic_vector(1 downto 0);

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
				case inst_reg(4 downto 0) is	-- mux read-only outputs
					when others  => dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
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
	ram: process(sclk, mreset) --(remap)
	begin
		-- Defaults
		if mreset = '0' then	
			--Read only registers
			mem(0)	<= "0100000000000000"; -- 00 free, ADPD_BUFF_SIZE
			mem(1)	<= "0000000000000000"; -- 14 free, ADPD_CONT_CAP_EN, ADPD_CAP_EN
			--FREE for use 
			mem(2)	<= "0000000000000000"; -- 16 free, 
			mem(3)	<= "0000000000000000"; -- 16 free, 
			mem(4)	<= "0000000000000000"; -- 16 free,
			mem(5)	<= "0000000000000000"; -- 16 free, 
			mem(6)	<= "0000000000000000"; -- 16 free,
			mem(7)	<= "0000000000000000"; -- 16 free, 
			mem(8)	<= "0000000000000000"; -- 16 free, 
			mem(9)	<= "0000000000000000"; -- 16 free,			
			mem(10)	<= "0000000000000000"; -- 16 free, 
			mem(11)	<= "0000000000000000"; -- 16 free, 
			mem(12)	<= "0000000000000000"; -- 16 free, 
			mem(13)	<= "0000000000000000"; -- 16 free, 
			mem(14)	<= "0000000000000000"; -- 16 free, 
			mem(15)	<= "0000000000000000"; -- 16 free, 
			mem(16)	<= "0000000000000000"; -- 16 free, 
			mem(17)	<= "0000000000000000"; -- rfsw(2:0)&"000"&pa2mode(2:0)&pa2sw(1:0)&pa1mode(2:0)&pa1sw(1:0)
			mem(18)  <= "0000000000000000"; -- adpd_config(15:0)  
			mem(19)	<= "0000000000000000"; -- 16 free, 
			mem(20)	<= "0000000000000000"; -- 16 free, 
			mem(21)	<= "0000000000000000"; -- 16 free, 
			mem(22)	<= "0000000000000000"; -- adpd_data(15:0), 
			mem(23)	<= "0000000000000000"; -- 16 free, 		

		elsif sclk'event and sclk = '1' then
				if mem_we = '1' then
					mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
				end if;
				
				if dout_reg_len = '0' then
				end if;
				
		end if;
	end process ram;
	
	-- ---------------------------------------------------------------------------------------------
	-- Decoding logic
	-- ---------------------------------------------------------------------------------------------
		ADPD_BUFF_SIZE 	<=mem(0);
		ADPD_CAP_EN			<=mem(1)(0);
		ADPD_CONT_CAP_EN	<=mem(1)(1);
		
		
		-- Borisav Jovanovic: 11.09.2016
		-- ADPD_CONFIG			<=mem(2);
		adpd_config		<= mem(18)(15 downto 0); 
	   adpd_data		<= mem(22)(15 downto 0);
	
	
		-- registar 0x51=0b 010 (10001)
		rfsw(2 downto 0)<=  mem(17)(15 downto 13);
		-- three free bits
		
		pa2mode(2 downto 0)<= mem(17)(9 downto 7);
		pa2sw(1 downto 0)<= mem(17)(6 downto 5);

		pa1mode(2 downto 0)<= mem(17)(4 downto 2);
		pa1sw(1 downto 0)<= mem(17)(1 downto 0);
		
		
		rf_sw: process (rfsw) is
		begin
		   RF_SW_V3<='0'; RF_SW_V2<='0'; RF_SW_V1<='0';
		   case rfsw is
			  when "000" => RF_SW_V3<='1'; RF_SW_V2<='0'; RF_SW_V1<='1'; -- ALL OFF
			  when "001" => RF_SW_V3<='0'; RF_SW_V2<='0'; RF_SW_V1<='1'; -- EXT CPL IN1
			  when "010" => RF_SW_V3<='0'; RF_SW_V2<='1'; RF_SW_V1<='0'; -- PA1 coupler out
			  when "011" => RF_SW_V3<='0'; RF_SW_V2<='1'; RF_SW_V1<='1'; -- EXT CPL IN2 
			  when "100" => RF_SW_V3<='1'; RF_SW_V2<='0'; RF_SW_V1<='0'; -- PA2 coupler out
			  when others => RF_SW_V3<='1'; RF_SW_V2<='0'; RF_SW_V1<='1';  -- ALL OFF
			end case;
	   end process;	
		
		pa1_sw: process (pa1sw) is
		begin
		   pa1_ctrl1<='0'; pa1_ctrl2<='0';
		   case pa1sw is
			  when "00" => pa1_ctrl1<='0'; pa1_ctrl2<='0'; -- off
			  when "01" => pa1_ctrl1<='0'; pa1_ctrl2<='1'; -- RF1->RFC
			  when "10" => pa1_ctrl1<='1'; pa1_ctrl2<='0'; -- RF2->RFC
			  when others => pa1_ctrl1<='0'; pa1_ctrl2<='0';
			end case;
	   end process;

      pa1_mode: process (pa1mode) is
		begin
		   pa1_ven<='0'; pa1_vmode0<='0'; pa1_vmode1<='0'; 
		   case pa1mode is
			  when "000" => pa1_ven<='0'; pa1_vmode0<='0'; pa1_vmode1<='0'; -- OFF
			  when "001" => pa1_ven<='1'; pa1_vmode0<='1'; pa1_vmode1<='1'; -- ON
			  
			  --when "001" => pa1_ven<='0'; pa1_vmode0<='1'; pa1_vmode1<='1'; -- Standby
			  --when "010" => pa1_ven<='1'; pa1_vmode0<='1'; pa1_vmode1<='1'; -- Low power
			  --when "011" => pa1_ven<='1'; pa1_vmode0<='1'; pa1_vmode1<='0'; -- Medium power
			  --when "100" => pa1_ven<='1'; pa1_vmode0<='0'; pa1_vmode1<='0'; -- High power
			  when others => pa1_ven<='0'; pa1_vmode0<='0'; pa1_vmode1<='0';  -- OFF
			end case;
	   end process;	

      pa2_sw: process (pa2sw) is
		begin
		   pa2_ctrl1<='0'; pa2_ctrl2<='0';
		   case pa2sw is
			  when "00" => pa2_ctrl1<='0'; pa2_ctrl2<='0';  -- OFF
			  when "01" => pa2_ctrl1<='0'; pa2_ctrl2<='1'; -- RF1->RFC
			  when "10" => pa2_ctrl1<='1'; pa2_ctrl2<='0'; -- RF2->RFC
			  when others => pa2_ctrl1<='0'; pa2_ctrl2<='0';
			end case;
	   end process;

      pa2_mode: process (pa2mode) is
		begin
		   pa2_ven<='0'; pa2_vmode0<='0'; pa2_vmode1<='0'; 
		   case pa2mode is
			  when "000" => pa2_ven<='0'; pa2_vmode0<='0'; pa2_vmode1<='0'; -- OFF
			  when "001" => pa2_ven<='1'; pa2_vmode0<='1'; pa2_vmode1<='1'; -- ON
			  -- when "001" => pa2_ven<='0'; pa2_vmode0<='1'; pa2_vmode1<='1'; -- Standby
			  --when "010" => pa2_ven<='1'; pa2_vmode0<='1'; pa2_vmode1<='1'; -- Low power
			  --when "011" => pa2_ven<='1'; pa2_vmode0<='1'; pa2_vmode1<='0'; -- Medium power
			  --when "100" => pa2_ven<='1'; pa2_vmode0<='0'; pa2_vmode1<='0'; -- High power
			  when others => pa2_ven<='0'; pa2_vmode0<='0'; pa2_vmode1<='0';  -- OFF
			end case;
	   end process;		



end adpdcfg_arch;
