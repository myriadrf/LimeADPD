-- ----------------------------------------------------------------------------	
-- FILE: 	hb2e.vhd
-- DESCRIPTION:	Even part of HB2 filter.
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
entity hb2e is
    port (
    	x: in std_logic_vector(24 downto 0); 	-- Input signal
	clk: in std_logic;			-- Clock and reset
	en: in std_logic;
	reset: in std_logic;
	y: out std_logic_vector(24 downto 0) 	-- Output signal
    );
end hb2e;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture hb2e_arch of hb2e is
					  
	-- Common sub-expression signals
	signal xp: std_logic_vector(25 downto 0);
	signal xo: std_logic_vector(25 downto 0);
	signal xm: std_logic_vector(25 downto 0);

	-- Outputs from CSD multipliers
	signal xh0: std_logic_vector(25 downto 0);
	signal xh2: std_logic_vector(25 downto 0);
	signal xh4: std_logic_vector(25 downto 0);
	signal xh6: std_logic_vector(25 downto 0);
	
	-- Outputs from the tap adders
	signal s0: std_logic_vector(25 downto 0);
	signal s2: std_logic_vector(25 downto 0);
	signal s4: std_logic_vector(25 downto 0);
	signal s6: std_logic_vector(25 downto 0);
	signal s8: std_logic_vector(25 downto 0);
	signal s10: std_logic_vector(25 downto 0);
	signal s12: std_logic_vector(25 downto 0);

	-- Outputs from the delay elements	
	signal b0: std_logic_vector(25 downto 0);
	signal b1: std_logic_vector(25 downto 0);
	signal b2: std_logic_vector(25 downto 0);
	signal b3: std_logic_vector(25 downto 0);
	signal b4: std_logic_vector(25 downto 0);
	signal b5: std_logic_vector(25 downto 0);
	signal b6: std_logic_vector(25 downto 0);
	signal b7: std_logic_vector(25 downto 0);
	signal b8: std_logic_vector(25 downto 0);
	signal b9: std_logic_vector(25 downto 0);
	signal b10: std_logic_vector(25 downto 0);
	signal b11: std_logic_vector(25 downto 0);
	signal b12: std_logic_vector(25 downto 0);
	signal b13: std_logic_vector(25 downto 0);

	-- Logic signals
	signal zeroes: std_logic_vector(25 downto 0);
	signal zero: std_logic;
	signal one: std_logic;
	 
	-- Component declarations
	--use work.components.csec;
	--use work.components.csdm26x4;
	--use work.components.ta26;
	--use work.components.tt;
	--for all:csec use entity work.csec(csec_arch);
	--for all:csdm26x4 use entity work.csdm26x4(csdm26x4_arch);
	--for all:ta26 use entity work.ta26(ta26_arch);
	--for all:tt use entity work.tt(tt_arch);
	
	 component csec is
    port (
		x: in std_logic_vector(24 downto 0);
		clk: in std_logic;	-- Clock and reset
		en: in std_logic;	-- Enable
		reset: in std_logic;
		xp: out std_logic_vector(25 downto 0); 	-- x*(1+1/4)
		xo: out std_logic_vector(25 downto 0);	-- just delayed x
		xm: out std_logic_vector(25 downto 0)	-- x*(1-1/4)
    );
    end component csec;	
	 component tt is
    port (
      x: in std_logic_vector(25 downto 0); 	-- Input signal
	  clk: in std_logic;	-- Clock and reset
	  en: in std_logic;		-- Enable
	  reset: in std_logic;
	  y: out std_logic_vector(24 downto 0) 	-- Output signal
    );
    end component tt;
    component ta26 is
    port (
    	a: in std_logic_vector(25 downto 0); -- Inputs
    	b: in std_logic_vector(25 downto 0);
	    sign: in std_logic;	 -- Sign bit for 'a'
	    clk: in std_logic;	 -- Clock and reset
	    en: in std_logic;	 -- Enable
	    reset: in std_logic;
	    s: buffer std_logic_vector(25 downto 0) -- Output signal
    );
    end component ta26;	
	 component csdm26x4 is
    port (
    	x0: in std_logic_vector(25 downto 0); -- Inputs
    	x1: in std_logic_vector(25 downto 0);
    	x2: in std_logic_vector(25 downto 0);
    	x3: in std_logic_vector(25 downto 0);
    	d1: in std_logic;			-- Sign bits for x1, ... x3
    	d2: in std_logic;
    	d3: in std_logic;
    	clk: in std_logic;			-- Clock signal
	    en: in std_logic;			-- Enable
    	reset: in std_logic;			-- Reset signal
    	sout: out std_logic_vector(25 downto 0)
    );
    end component csdm26x4;
	
begin
	-- Set logic signals
	zeroes <= "00000000000000000000000000";
	zero <= '0';
	one <= '1';
					  
	-- Common sub-expressions calculation
	csecb: csec port map(x => x, clk => clk, en => en, reset => reset,
				xp => xp, xo => xo, xm => xm);

	-- Delay line
	delay: process(clk, reset)
	begin
		if reset = '0' then
			b0 <= (others => '0');
			b1 <= (others => '0');
			b2 <= (others => '0');
			b3 <= (others => '0');
			b4 <= (others => '0');
			b5 <= (others => '0');
			b6 <= (others => '0');
			b7 <= (others => '0');
			b8 <= (others => '0');
			b9 <= (others => '0');
			b10 <= (others => '0');
			b11 <= (others => '0');
			b12 <= (others => '0');
			b13 <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				b0 <= b1;
				b1 <= s2;
				b2 <= b3;
				b3 <= s4;
				b4 <= b5;
				b5 <= s6;
				b6 <= b7;
				b7 <= s8;
				b8 <= b9;
				b9 <= s10;
				b10 <= b11;
				b11 <= s12;
				b12 <= b13;
				b13 <= xh0;
			end if;
		end if;
	end process delay;

	-- CSD multiplier h(0)
	h0: csdm26x4
		port map(
		    	x0(25) => xp(25), -- xp >> 11 ----------------------------
			x0(24) => xp(25),
			x0(23) => xp(25),
			x0(22) => xp(25),
			x0(21) => xp(25),
			x0(20) => xp(25),
			x0(19) => xp(25),
			x0(18) => xp(25),
			x0(17) => xp(25),
			x0(16) => xp(25),
			x0(15) => xp(25),
			x0(14 downto 0) => xp(25 downto 11),

		    	x1(25) => xo(25), -- xo >> 8 ----------------------------
			x1(24) => xo(25),
			x1(23) => xo(25),
			x1(22) => xo(25),
			x1(21) => xo(25),
			x1(20) => xo(25),
			x1(19) => xo(25),
			x1(18) => xo(25),
			x1(17 downto 0) => xo(25 downto 8),

		    	x2(25) => xo(25), -- xo >> 16 ----------------------------
			x2(24) => xo(25),
			x2(23) => xo(25),
			x2(22) => xo(25),
			x2(21) => xo(25),
			x2(20) => xo(25),
			x2(19) => xo(25),
			x2(18) => xo(25),
			x2(17) => xo(25),
			x2(16) => xo(25),
			x2(15) => xo(25),
			x2(14) => xo(25),
			x2(13) => xo(25),
			x2(12) => xo(25),
			x2(11)  => xo(25),
			x2(10)  => xo(25),
			x2(9 downto 0) => xo(25 downto 16),
		    	x3 => zeroes,
		    	d1 => one,
		    	d2 => zero,
		    	d3 => zero,
		    	clk => clk,
			en => en,
		    	reset => reset,
		    	sout => xh0 );

	-- CSD multiplier h(2)
	h2: csdm26x4
		port map(
		    	x0(25) => xo(25), -- xo >> 5 ----------------------------
			x0(24) => xo(25),
			x0(23) => xo(25),
			x0(22) => xo(25),
			x0(21) => xo(25),
			x0(20 downto 0) => xo(25 downto 5),

		    	x1(25) => xo(25), -- xo >> 8 ----------------------------
			x1(24) => xo(25),
			x1(23) => xo(25),
			x1(22) => xo(25),
			x1(21) => xo(25),
			x1(20) => xo(25),
			x1(19) => xo(25),
			x1(18) => xo(25),
			x1(17 downto 0) => xo(25 downto 8),

		    	x2(25) => xo(25), -- xo >> 11 ----------------------------
			x2(24) => xo(25),
			x2(23) => xo(25),
			x2(22) => xo(25),
			x2(21) => xo(25),
			x2(20) => xo(25),
			x2(19) => xo(25),
			x2(18) => xo(25),
			x2(17) => xo(25),
			x2(16) => xo(25),
			x2(15) => xo(25),
			x2(14 downto 0) => xo(25 downto 11),

		    	x3(25) => xo(25), -- xo >> 14 ----------------------------
			x3(24) => xo(25),
			x3(23) => xo(25),
			x3(22) => xo(25),
			x3(21) => xo(25),
			x3(20) => xo(25),
			x3(19) => xo(25),
			x3(18) => xo(25),
			x3(17) => xo(25),
			x3(16) => xo(25),
			x3(15) => xo(25),
			x3(14) => xo(25),
			x3(13) => xo(25),
			x3(12) => xo(25),
			x3(11 downto 0) => xo(25 downto 14),

		    	d1 => one,
		    	d2 => zero,
		    	d3 => one,
		    	clk => clk,
			en => en,
		    	reset => reset,
		    	sout => xh2 );

	-- CSD multiplier h(4)
	h4: csdm26x4
		port map(
		    	x0(25) => xm(25), -- xm >> 14 ----------------------------
			x0(24) => xm(25),
			x0(23) => xm(25),
			x0(22) => xm(25),
			x0(21) => xm(25),
			x0(20) => xm(25),
			x0(19) => xm(25),
			x0(18) => xm(25),
			x0(17) => xm(25),
			x0(16) => xm(25),
			x0(15) => xm(25),
			x0(14) => xm(25),
			x0(13) => xm(25),
			x0(12) => xm(25),
			x0(11 downto 0) => xm(25 downto 14),

		    	x1(25) => xp(25), -- xp >> 10 ----------------------------
			x1(24) => xp(25),
			x1(23) => xp(25),
			x1(22) => xp(25),
			x1(21) => xp(25),
			x1(20) => xp(25),
			x1(19) => xp(25),
			x1(18) => xp(25),
			x1(17) => xp(25),
			x1(16) => xp(25),
			x1(15 downto 0) => xp(25 downto 10),

		    	x2(25) => xo(25), -- xo >> 3 ----------------------------
			x2(24) => xo(25),
			x2(23) => xo(25),
			x2(22 downto 0) => xo(25 downto 3),

			x3 => zeroes,
		    	d1 => one,
		    	d2 => one,
		    	d3 => zero,
		    	clk => clk,
			en => en,
		    	reset => reset,
		    	sout => xh4 );
	
	-- CSD multiplier h(6)
	h6: csdm26x4
		port map(
		    	x0(25) => xp(25), -- xp >> 1 ----------------------------
			x0(24 downto 0) => xp(25 downto 1),

		    	x1(25) => xm(25), -- xm >> 5 ----------------------------
			x1(24) => xm(25),
			x1(23) => xm(25),
			x1(22) => xm(25),
			x1(21) => xm(25),
			x1(20 downto 0) => xm(25 downto 5),

		    	x2(25) => xo(25), -- xo >> 13 ----------------------------
			x2(24) => xo(25),
			x2(23) => xo(25),
			x2(22) => xo(25),
			x2(21) => xo(25),
			x2(20) => xo(25),
			x2(19) => xo(25),
			x2(18) => xo(25),
			x2(17) => xo(25),
			x2(16) => xo(25),
			x2(15) => xo(25),
			x2(14) => xo(25),
			x2(13) => xo(25),
			x2(12 downto 0) => xo(25 downto 13),

			x3 => zeroes,
		    	d1 => one,
		    	d2 => zero,
		    	d3 => zero,
		    	clk => clk,
			en => en,
		    	reset => reset,
		    	sout => xh6 );

	-- Tap adder 0
	tadder0: ta26
		port map (a=> xh0, b => b0, sign => zero, clk => clk,
			  en => en, reset => reset, s => s0);

	-- Tap adder 2
	tadder2: ta26
		port map (a=> xh2, b => b2, sign => zero, clk => clk,
			  en => en, reset => reset, s => s2);

	-- Tap adder 4
	tadder4: ta26
		port map (a=> xh4, b => b4, sign => zero, clk => clk,
			  en => en, reset => reset, s => s4);

	-- Tap adder 6
	tadder6: ta26
		port map (a=> xh6, b => b6, sign => zero, clk => clk,
			  en => en, reset => reset, s => s6);

	-- Tap adder 8
	tadder8: ta26
		port map (a=> xh6, b => b8, sign => zero, clk => clk,
			  en => en, reset => reset, s => s8);
			
	-- Tap adder 10
	tadder10: ta26
		port map (a=> xh4, b => b10, sign => zero, clk => clk,
			  en => en, reset => reset, s => s10);

	-- Tap adder 12
	tadder12: ta26
		port map (a=> xh2, b => b12, sign => zero, clk => clk,
			  en => en, reset => reset, s => s12);


	-- Tap termination cell
	terminator: tt port map (x => s0, clk => clk, en => en, reset => reset, y => y);

end hb2e_arch;
