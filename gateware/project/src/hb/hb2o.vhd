-- ----------------------------------------------------------------------------	
-- FILE: 	hb2o.vhd
-- DESCRIPTION:	Odd part of HB2 filter. It is pure delay with the 
--		following filtering function: H(z) = z^-6. 11 extra 
--		delays are introduced in H(z) in order to compensate 
--		for the delays used to pipeline CSE calculator, CSD multipliers, 
--		tap adders and saturation logic. Therefore, final filter 
--		implements H(z) = z^-17.
-- DATE:	July 25, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library IEEE;
use IEEE.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity hb2o is
    port (
    	x: in std_logic_vector(24 downto 0); 	-- Input signal
	clk: in std_logic;			-- Clock and reset
	en: in std_logic;
	reset: in std_logic;
	y: out std_logic_vector(24 downto 0) 	-- Output signal
    );
end hb2o;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture hb2o_arch of hb2o is

	-- Delayed input samples
	signal  x1: std_logic_vector(24 downto 0);
	signal  x2: std_logic_vector(24 downto 0);
	signal  x3: std_logic_vector(24 downto 0);
	signal  x4: std_logic_vector(24 downto 0);
	signal  x5: std_logic_vector(24 downto 0);
	signal  x6: std_logic_vector(24 downto 0);
	signal  x7: std_logic_vector(24 downto 0);
	signal  x8: std_logic_vector(24 downto 0);
	signal  x9: std_logic_vector(24 downto 0);
	signal x10: std_logic_vector(24 downto 0);
	signal x11: std_logic_vector(24 downto 0);
	signal x12: std_logic_vector(24 downto 0);
	signal x13: std_logic_vector(24 downto 0);
	signal x14: std_logic_vector(24 downto 0);
	signal x15: std_logic_vector(24 downto 0);
	signal x16: std_logic_vector(24 downto 0);
	
begin
	-- Delay line
	delay: process(clk, reset)
	begin
		if reset = '0' then
			x1 <= (others => '0');
			x2 <= (others => '0');
			x3 <= (others => '0');
			x4 <= (others => '0');
			x5 <= (others => '0');
			x6 <= (others => '0');
			x7 <= (others => '0');
			x8 <= (others => '0');
			x9 <= (others => '0');
			x10 <= (others => '0');
			x11 <= (others => '0');
			x12 <= (others => '0');
			x13 <= (others => '0');
			x14 <= (others => '0');
			x15 <= (others => '0');
			x16 <= (others => '0');
			y <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				x1 <= x;
				x2 <= x1;
				x3 <= x2;
				x4 <= x3;
				x5 <= x4;
				x6 <= x5;
				x7 <= x6;
				x8 <= x7;
				x9 <= x8;
				x10 <= x9;
				x11 <= x10;
				x12 <= x11;
				x13 <= x12;
				x14 <= x13;
				x15 <= x14;
				x16 <= x15;
				y <= x16;
			end if;
		end if;
	end process delay;
end hb2o_arch;
