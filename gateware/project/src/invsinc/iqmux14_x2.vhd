-- ----------------------------------------------------------------------------	
-- FILE:        iqmux14_x2.vhd
-- DESCRIPTION:  14 bit multiplexer with registered output
-- DATE:	     
-- AUTHOR(s):	  Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity iqmux14_x2 is
    port (
			nrst: in std_logic;
			clk: in std_logic;
			en: in std_logic;
	      i0: in std_logic_vector(13 downto 0);	-- Input
			i1: in std_logic_vector(13 downto 0);	-- Input
	      q0: in std_logic_vector(13 downto 0);	-- Input
			q1: in std_logic_vector(13 downto 0);	-- Input
			sel: in std_logic;
	      yi: out std_logic_vector(13 downto 0);	-- Output
			yq: out std_logic_vector(13 downto 0)	-- Output
    );
end iqmux14_x2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture iqmux14_x2_arch of iqmux14_x2 is
	signal seli: std_logic_vector(13 downto 0);
	signal selq: std_logic_vector(13 downto 0);
begin
	
	seli <= i0 when sel = '0' else i1;
	selq <= q0 when sel = '0' else q1;

	dl: process(clk, nrst)
	begin
		if nrst = '0' then
			yi <= (others => '0');
			yq <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				yi <= seli;
				yq <= selq;
			end if;
		end if;
	end process dl;

end iqmux14_x2_arch;