-- ----------------------------------------------------------------------------	
-- FILE: 	hb1.vhd
-- DESCRIPTION:	HB1 implemented as interleaved polyphase filter
--		with programmable clock rate.
-- DATE:	July 26, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- TO DO:	Change enable signal generation circuitry by clkdev module.
-- REVISIONS:	Sep 12, 2001:	Clock division circuitry substituted by
--				clkdiv module.
-- ----------------------------------------------------------------------------	

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity hb1d is
    port (
    	xi1: in std_logic_vector(17 downto 0); 	-- I input signal
    	xq1: in std_logic_vector(17 downto 0); 	-- Q input signal
	   n: in std_logic_vector(7 downto 0);	-- Clock division ratio is n+1
	   sleep: in std_logic;			-- Sleep mode control
	   clk: in std_logic;			-- Clock and reset
	   reset: in std_logic;
	   yen: out std_logic;			-- HBI output enable
	   yi1: out std_logic_vector(17 downto 0); 	-- I output signal
	   yq1: out std_logic_vector(17 downto 0) 	-- Q output signal
    );
end hb1d;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture hb1d_arch of hb1d is

	signal Lei, Loi, Li: std_logic_vector(24 downto 0);    -- Input stage latches, I
	signal Leq, Loq, Lq: std_logic_vector(24 downto 0);    -- Input stage latches, Q
	signal La, Lb, Lc, Ld: std_logic_vector(24 downto 0);      -- Output stage latches, Q
	signal xe, xo: std_logic_vector(24 downto 0);          -- Multiplexed data
	signal ye:  std_logic_vector(24 downto 0);             -- Even output
	signal yo:  std_logic_vector(24 downto 0);             -- Odd output
	
	signal yrez: std_logic_vector(25 downto 0);
	signal y: std_logic_vector(24 downto 0);
	
	-- Enable and MUX select signal
	signal en, sel: std_logic;

	
   component add26 is
    port (
    	a: in std_logic_vector(25 downto 0); -- Inputs
    	b: in std_logic_vector(25 downto 0);
	   cin: std_logic;
	   clk: in std_logic;	-- Clock and reset
	   en: in std_logic;	-- Enable
	   reset: in std_logic;
	   s: out std_logic_vector(25 downto 0); -- Output signal
	   cout: out std_logic
    );
   end component add26;
	
	component hb1e is
    port (
    	x: in std_logic_vector(24 downto 0); 	-- Input signal
		clk: in std_logic;			-- Clock and reset
		en: in std_logic;
		reset: in std_logic;
		y: out std_logic_vector(24 downto 0) 	-- Output signal
    );
	end component hb1e;
	
	component clkdiv is
    port (
		n: in std_logic_vector(7 downto 0);	-- Clock division ratio is n+1
		sleep: in std_logic;			-- Sleep signal
		clk: in std_logic;			-- Clock and reset
		reset: in std_logic;
		en: out std_logic			-- Output enable signal
    );
	end component clkdiv;
	
	component hb1o is
    port (
    	x: in std_logic_vector(24 downto 0); -- Input signal
		clk: in std_logic;	-- Clock and reset
		en: in std_logic;
		reset: in std_logic;
		y: out std_logic_vector(24 downto 0) -- Output signal
    );	 
	end component hb1o;
	
	signal  	xi: std_logic_vector(24 downto 0); 	-- I input signal
        signal 	xq: std_logic_vector(24 downto 0); 	-- Q input signal
		
	signal	yi: std_logic_vector(24 downto 0); 	-- I output signal
	signal   yq: std_logic_vector(24 downto 0);	-- Q output signal

begin

   xi<= xi1(17 downto 0) & "0000000";
	xq<= xq1(17 downto 0) & "0000000";
	
	yi1<= yi(24 downto 7);
	yq1<= yq(24 downto 7);
	
	-- Clock division
	clkd: clkdiv port map(n => n, clk => clk, reset => reset, 
		sleep => sleep,	en => en);

	-- MUX select signal
	dff: process(clk, reset)
	begin
		if reset = '0' then			
			sel <= '1';
		elsif clk'event and clk = '1' then
			if en = '1' then
				sel <= not sel;
			end if;
		end if;
	end process dff;
	
	yen <= sel;


	-- Arrange input I
	lai: process(clk, reset)
	begin
		if reset = '0' then
			Lei <= (others => '0');
			Loi <= (others => '0');
			Li <= (others => '0');
		elsif clk'event and clk = '1' then
		  if en = '1' then
		    Li <= xi;
        if sel = '1' then
				  Lei <= xi;
				  Loi <= Li;
        end if;
		  end if;
		end if;
	end process lai;

	-- Even filter input
	xe <= Lei when sel = '1' else Leq;

	-- Arrange input Q
	laq: process(clk, reset)
	begin
		if reset = '0' then
			Leq <= (others => '0');
			Loq <= (others => '0');
			Lq <= (others => '0');
		elsif clk'event and clk = '1' then
		  if en = '1' then
		    Lq <= xq;
        if sel = '1' then
				  Leq <= xq;
				  Loq <= Lq;
        end if;
		  end if;
		end if;
	end process laq;

	-- Odd filter input
	xo <= Loi when sel = '1' else Loq;


	-- Even HB1 filter
	even: hb1e
		port map( x => xe, clk => clk, en => en, reset => reset, y => ye);

	-- Odd HB1 filter
	odd: hb1o
		port map( x => xo, clk => clk, en => en, reset => reset, y => yo);

	-- Adder
	add: add26 port map( a(25) => ye(24), a(24 downto 0) => ye, b(25) => yo(24), b(24 downto 0) => yo, cin => '0', clk => clk, en => en, reset => reset, s => yrez, cout => open);
	y <= yrez(25 downto 1);


	-- Arrange Output
	lao: process(clk, reset)
	begin
		if reset = '0' then
			La <= (others => '0');
			Lb <= (others => '0');
			Lc <= (others => '0');
			Ld <= (others => '0');
		elsif clk'event and clk = '1' then
		  if en = '1' then
		    La <= y;
        if sel = '1' then
				  Lb <= La;
				  Ld <= Lc;
				  Lc <= y;
        end if;
		  end if;
		end if;
	end process lao;

  yi <= Lb;
  --yq <= Lc;
  yq <= Ld;
	
end hb1d_arch;












