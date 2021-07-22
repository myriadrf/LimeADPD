-- ----------------------------------------------------------------------------	
-- FILE: 	data_cap.vhd
-- DESCRIPTION:	captures number of samples 
-- DATE:	Dec 14, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity data_cap is
  port (
			clk					: in std_logic;
			reset_n				: in std_logic;
			data_valid			: in std_logic;
			--capture signalas
			cap_en				: in std_logic;
			cap_cont_en			: in std_logic;
			cap_size				: in std_logic_vector(15 downto 0);
			cap_done				: out std_logic;
        --external fifo signalas
			fifo_wrreq      	: out std_logic;
			fifo_wfull			: in std_logic;
			fifo_wrempty		: in std_logic      
        );
end data_cap;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of data_cap is
--declare signals,  components here

--synch registers
signal cap_en_reg			: std_logic_vector(1 downto 0);
signal cap_cont_en_reg	: std_logic_vector(1 downto 0);
signal cap_size_reg0,cap_size_reg1		: std_logic_vector(15 downto 0); 

--
signal cap_cnt				: unsigned (15 downto 0);
signal cap_done_int		: std_logic;

type state_type is (idle, check_fifo_wrempty, capture_data, capture_done, wait_cap_en_low );
signal current_state, next_state : state_type;

begin

-- ----------------------------------------------------------------------------
-- synch registers to synchronize external signals to clk domains
-- ----------------------------------------------------------------------------
process(clk, reset_n)begin
	if(reset_n = '0')then
		cap_en_reg		 <=(others=>'0');
		cap_cont_en_reg <=(others=>'0');
		cap_size_reg0	 <=(others=>'0');
		cap_size_reg1	 <=(others=>'0');
	elsif(clk'event and clk = '1')then 
		cap_en_reg		 <=cap_en_reg(0) & cap_en;
		cap_cont_en_reg <=cap_cont_en_reg(0) & cap_cont_en;
		cap_size_reg0	 <=cap_size;
		cap_size_reg1	 <=cap_size_reg0;
	end if;	
end process;

-- ----------------------------------------------------------------------------
-- capture data counter
-- ----------------------------------------------------------------------------
process(clk, reset_n)begin
	if(reset_n = '0')then
		cap_cnt <=(others=>'0');
	elsif(clk'event and clk = '1')then
		if current_state = capture_data then
			if data_valid='1' then 
				cap_cnt<=cap_cnt+1;
			else 
				cap_cnt<=cap_cnt;
			end if;
		else 
			cap_cnt<=(others=>'0');
		end if;
	end if;	
end process;

-- ----------------------------------------------------------------------------
-- write signal
-- ----------------------------------------------------------------------------
process(current_state, data_valid)begin
	if(current_state = capture_data AND data_valid='1')then
		fifo_wrreq <= '1';
	else 
		fifo_wrreq <= '0';
	end if;
end process;

-- ----------------------------------------------------------------------------
-- capture done
-- ----------------------------------------------------------------------------
process(current_state,cap_done_int)begin
	if(current_state = capture_done OR current_state = wait_cap_en_low )then
		cap_done_int <= '1';
	else 
		cap_done_int <= '0';
	end if;
end process;

cap_done<=cap_done_int;

-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------

fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_state <= next_state;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, cap_en_reg(1), cap_cont_en_reg(1), cap_cnt, cap_size_reg1, fifo_wrempty, data_valid) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => 						--idle state 
			if cap_en_reg(1)='1' then 
				next_state<=check_fifo_wrempty;
			else 
				next_state<=idle;
			end if;
			
		when check_fifo_wrempty => 	--check that buffer is ready to accept capture data
			if fifo_wrempty='1' then 
				next_state <= capture_data;
			else 
				if cap_en_reg(1)='1' then 
					next_state <= check_fifo_wrempty;
				else 
					next_state <= idle;
				end if;
			end if;
			
		when capture_data =>				--capture certain amount of samples
			if data_valid = '1' then 
				if cap_cnt < unsigned(cap_size_reg1)-1 then 
					next_state <= capture_data;
				else 
					next_state <= capture_done;
				end if;
			else 
				next_state <= capture_data;
			end if;
	
		when capture_done => 
			if cap_cont_en_reg(1) = '1' then 
				next_state <= check_fifo_wrempty;
			else 
				next_state <= wait_cap_en_low;
			end if;
			
		when wait_cap_en_low => 		--wait for cap_en to go low
			if cap_en_reg(1)='0' then 
				next_state<=idle;
			else 
				next_state<=wait_cap_en_low;
			end if;
		
		when others => 
			next_state<=idle;
	end case;
end process;

end arch; 