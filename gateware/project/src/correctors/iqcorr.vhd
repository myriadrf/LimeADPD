-- ----------------------------------------------------------------------------	
-- FILE: 	iqcorr.vhd
-- DESCRIPTION:	iq corrector (Tx, Rx).
-- DATE:	Nov 25, 2012
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity iqcorr is
port
	(
		clk		: in std_logic;
		nrst	: in std_logic;
		en		: in std_logic;
		byp		: in std_logic;
		xi		: in signed (17 downto 0);
		xq		: in signed (17 downto 0);
		pcw		: in signed (11 downto 0);
		yi		: out signed (17 downto 0);
		yq		: out signed (17 downto 0)
	);
end iqcorr;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture iqcorr_arch of iqcorr is

		signal cos_i : signed (17 downto 0);
		signal cos_q : signed (17 downto 0);
		
		signal r_xi : signed (29 downto 0);
		signal r_xq : signed (29 downto 0);
		
		signal r_c_xi : signed (17 downto 0);
		signal r_c_xq : signed (17 downto 0);
		signal r_r_xi : signed (17 downto 0);
		signal r_r_xq : signed (17 downto 0);
		
		signal sumi	: signed (18 downto 0);
		signal sumq	: signed (18 downto 0);	
		
		signal muxi	: signed (17 downto 0);
		signal muxq	: signed (17 downto 0);
		
		signal r_mux1	: signed (17 downto 0);
		signal r_mux2	: signed (17 downto 0);
		

begin


   --	cos_i <= xi - resize (xi(17 downto 6),18);
   --	cos_q <= xq - resize (xq(17 downto 6),18);

   --cos_i and cos_q is inside clocked proc to meet timing 
	reg0: process (clk, nrst)
	begin
		if (nrst = '0') then
			cos_i <= (others => '0');
			cos_q <= (others => '0');
		elsif rising_edge(clk) then
			if (en = '1') then
            cos_i <= xi - resize (xi(17 downto 6),18);
            cos_q <= xq - resize (xq(17 downto 6),18);
			end if;
		end if;
	end process reg0;

	r_xi <= cos_i * pcw;
	r_xq <= cos_q * pcw;

	reg1: process (clk, nrst)
	begin
		if (nrst = '0') then
			r_c_xi <= (others => '0');
			r_c_xq <= (others => '0');
			r_r_xi <= (others => '0');
			r_r_xq <= (others => '0');
		elsif rising_edge(clk) then
			if (en = '1') then
				r_c_xi <= cos_i;
				r_c_xq <= cos_q;
				r_r_xi <= r_xi(28 downto 11);
				r_r_xq <= r_xq(28 downto 11);
			end if;
		end if;
	end process reg1;

   --to help timing
   process (clk, nrst)
	begin
		if rising_edge(clk) then
         sumi <= (r_c_xi(17) & r_c_xi) + (r_r_xq(17) & r_r_xq);
         sumq <= (r_c_xq(17) & r_c_xq) + (r_r_xi(17) & r_r_xi);
		end if;
	end process;
   
--	sumi <= (r_c_xi(17) & r_c_xi) + (r_r_xq(17) & r_r_xq);
--	sumq <= (r_c_xq(17) & r_c_xq) + (r_r_xi(17) & r_r_xi);

	--muxi <= sumi(18 downto 1) when byp = '0' else xi;
	--muxq <= sumq(18 downto 1) when byp = '0' else xq;
	muxi <= sumi(17 downto 0) when byp = '0' else xi;
	muxq <= sumq(17 downto 0) when byp = '0' else xq;

	reg2: process (clk, nrst)
	begin
		if (nrst = '0') then
			r_mux1 <= (others => '0');
			r_mux2 <= (others => '0');
		elsif rising_edge(clk) then
			if (en = '1') then
				r_mux1 <= muxi;
				r_mux2 <= muxq;
			end if;
		end if;
	end process reg2;

	yi <= r_mux1;
	yq <= r_mux2;

end iqcorr_arch;