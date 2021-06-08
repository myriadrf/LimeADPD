-- ----------------------------------------------------------------------------	
-- FILE: 	buffer_rd_seq.vhd.vhd
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
entity buffer_rd_seq is
  port (
        --input ports 
        clk       		: in std_logic;
        reset_n   		: in std_logic;
		  ram_rd_done		: in std_logic;
		  ram_data			: in std_logic_vector(31 downto 0);
		  ram_data_valid	: in std_logic;
		  fifo_data			: in std_logic_vector(31 downto 0);
		  buff_size 		: in std_logic_vector(15 downto 0);
		  
        --output ports 
		  fifo_read		  	: out std_logic;
		  fx3_buff_wr		: out std_logic;
		  fx3_buff_data	: out std_logic_vector(31 downto 0);
		  fx3_buff_wusedw	: in std_logic_vector(10 downto 0)

        
        );
end buffer_rd_seq;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of buffer_rd_seq is

--state type declaration
type state_type is (idle, wait_ramrd, wait_ramrd_done, begin_rd_fifo);
signal current_state, next_state : state_type;
signal fifo_rd_cnt	: unsigned(15 downto 0);
signal ram_wr_cnt		: unsigned(15 downto 0);

  
begin


--state machine
fsm_f : process(clk, reset_n) begin
	if (reset_n = '0') then
		current_state <= idle;
	elsif (clk'event and clk = '1') then 
		current_state <= next_state;
	end if;	
end process;

--state machine combo
fsm : process (current_state) begin
	next_state <= current_state;
	case current_state is
		when idle => --idle state
			if ram_rd_done='1' then 
				next_state<=wait_ramrd;
			else 
				next_state<=idle;
			end if;
			
		when wait_ramrd	=>
			if ram_rd_done='0' then 
				next_state<=wait_ramrd_done;
			else 
				next_state<=wait_ramrd;
			end if;
			
		when wait_ramrd_done	=> 
			if ram_rd_done='1' then 
				next_state<=begin_rd_fifo;
			else 
				next_state<=wait_ramrd_done;
			end if;
		
		when begin_rd_fifo => 
			
		when others =>
			next_state<=idle;
	end case;
end process;


  process(reset_n, clk)
    begin
      if reset_n='0' then
        --reset  
 	    elsif (clk'event and clk = '1') then
 	      --in process
 	    end if;
    end process;
  
end arch;   




