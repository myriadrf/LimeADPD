-- ----------------------------------------------------------------------------	
-- FILE: 	ba16x16x26.vhd
-- DESCRIPTION:	This file implements only array of adders required for
--		Booth multiplier design. Booth array is truncated to
--		26 bits in order to save some hardware.
-- DATE:	Aug 24, 2001
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
entity ba16x16x26mac is
	port (
		x: in std_logic_vector (15 downto 0);
		y: in std_logic_vector (15 downto 0);
		c: out std_logic_vector (25 downto 0);
		s: out std_logic_vector (25 downto 0);
		clk: in std_logic;	   
		en: in std_logic;
		reset: in std_logic
	);
end ba16x16x26mac;

-- ----------------------------------------------------------------------------	
-- Architecture
-- ----------------------------------------------------------------------------	
architecture ba16x16x26mac_arch of ba16x16x26mac is

	-- Latched x and y
	signal xl1, xl2, xl3, xl4: std_logic_vector(15 downto 0); 
	signal yl1, yl2, yl3, yl4: std_logic_vector(15 downto 0);
	
	-- Partial sums, carries and latces
	signal a1, b1: std_logic_vector(14 downto 0);
	signal a2, b2: std_logic_vector(16 downto 0);
	signal a2l, b2l: std_logic_vector(16 downto 0);	-- Latch B
	signal a3, b3: std_logic_vector(18 downto 0);
	signal a4, b4: std_logic_vector(18 downto 0);
	signal a4l, b4l: std_logic_vector(18 downto 0); -- Latch C
	signal a5, b5: std_logic_vector(18 downto 0);
	signal a6, b6: std_logic_vector(18 downto 0);
	signal a6l, b6l: std_logic_vector(18 downto 0); --  Latch D
	signal a7, b7: std_logic_vector(18 downto 0);
	
	signal al1, bl1: std_logic_vector(3 downto 0);
	signal al2, bl2: std_logic_vector(7 downto 0);
	  
	-- Logic connstants
	signal zero: std_logic;

	-- Component declarations
	use work.components.rowfirstt12;
	use work.components.row14;
	use work.components.row16;

	for all:rowfirstt12 use entity work.rowfirstt12(rowfirstt12_arch);
	for all:row14 use entity work.row14(row14_arch);
	for all:row16 use entity work.row16(row16_arch);
begin

	zero <= '0';
	
	-- Latches
	latch: process(clk, reset)
	begin
		if reset = '0' then
			xl1 <= (others => '0');
			yl1 <= (others => '0');
			xl2 <= (others => '0');
			yl2 <= (others => '0');
			xl3 <= (others => '0');
			yl3 <= (others => '0');
			xl4 <= (others => '0');
			yl4 <= (others => '0');
			a2l <= (others => '0');
			b2l <= (others => '0');
			a4l <= (others => '0');
			b4l <= (others => '0');
			a6l <= (others => '0');
			b6l <= (others => '0');
			al1 <= (others => '0');
			bl1 <= (others => '0');
			al2 <= (others => '0');
			bl2 <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xl1 <= x;
				yl1 <= y;
				xl2 <= xl1;
				yl2 <= yl1;
				xl3 <= xl2;
				yl3 <= yl2;
				xl4 <= xl3;
				yl4 <= yl3;

				a2l <= a2;
				b2l <= b2;
				a4l <= a4;
				b4l <= b4;
				a6l <= a6;
				b6l <= b6;

				al1 <= a4(1 downto 0) & a3(1 downto 0);
				bl1 <= b4(1 downto 0) & b3(1 downto 0);
				al2 <= a6(1 downto 0) & a5(1 downto 0) & al1;
				bl2 <= b6(1 downto 0) & b5(1 downto 0) & bl1;
			end if;
		end if;
	end process latch;
	      
	-- Rows of adders
	-- Latch A
	row1: rowfirstt12
		port map(x => xl1(15 downto 4), y => yl1(3 downto 0), 
			sbit => zero, s => a1, c => b1);

	row2: row14
		port map(x => xl1(15 downto 2), y => yl1(5 downto 3), 
			a => a1, b => b1, s => a2, c => b2);
	-- Latch B
	row3: row16
		port map(x => xl2, y => yl2(7 downto 5), 
			a => a2l, b => b2l, s => a3, c => b3);

	row4: row16
		port map(x => xl2, y => yl2(9 downto 7), 
			a => a3(18 downto 2), b => b3(18 downto 2), s => a4, c => b4);
	-- Latch C
	row5: row16
		port map(x => xl3, y => yl3(11 downto 9), 
			a => a4l(18 downto 2), b => b4l(18 downto 2), s => a5, c => b5);

	row6: row16
		port map(x => xl3, y => yl3(13 downto 11), 
			a => a5(18 downto 2), b => b5(18 downto 2), s => a6, c => b6);
	-- Latch D
	row7: row16
		port map(x => xl4, y => yl4(15 downto 13), 
			a => a6l(18 downto 2), b => b6l(18 downto 2), s => a7, c => b7);
			
	c <= a7(17 downto 0) & al2;
	s <= b7(17 downto 0) & bl2;

end ba16x16x26mac_arch;
