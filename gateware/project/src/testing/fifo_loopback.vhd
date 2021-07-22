-- ----------------------------------------------------------------------------	
-- FILE: 	file_name.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fifo_loopback is
	generic ( data_width	: integer := 32
	);
  port (
        --input ports 
        clk       		: in std_logic;
        reset_n   		: in std_logic;
		  src_fifo_empty	: in std_logic;
		  src_fifo_rdreq	: out std_logic;
		  src_fifo_q		: in std_logic_vector(data_width-1 downto 0);
		  dst_fifo_aclr	: out std_logic;
		  dst_fifo_aclr_n	: out std_logic;
		  dst_fifo_full	: in std_logic;
		  dst_fifo_wrreq	: out std_logic;
		  dst_fifo_data	: out std_logic_vector(data_width-1 downto 0)

        
        );
end fifo_loopback;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of fifo_loopback is
--declare signals,  components here
signal src_fifo_rdreq_int	: std_logic;
signal dst_fifo_wrreq_int 	: std_logic;
  
begin

src_fifo_rdreq_int<= (not src_fifo_empty) and (not dst_fifo_full);

  process(reset_n, clk)
    begin
      if reset_n='0' then
			dst_fifo_wrreq_int<='0';
			dst_fifo_aclr<='1';
			dst_fifo_aclr_n<='0';
 	    elsif (clk'event and clk = '1') then
			dst_fifo_wrreq_int<=src_fifo_rdreq_int;
			dst_fifo_aclr<='0';
			dst_fifo_aclr_n<='1';
 	    end if;
    end process;
	 
src_fifo_rdreq<=src_fifo_rdreq_int;
dst_fifo_wrreq<=dst_fifo_wrreq_int; 
dst_fifo_data<=src_fifo_q;

end arch;





