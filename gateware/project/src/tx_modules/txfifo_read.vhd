-- ----------------------------------------------------------------------------	
-- FILE: 	txfifo_read.vhd
-- DESCRIPTION:	describe
-- DATE:	July 14, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------

entity txfifo_read is
	generic(
			sample_width	: integer :=12
	);
  port (
        --input ports 
        clk         : in std_logic;
        reset_n     : in std_logic;
        fifo_empty  : in std_logic;        
        diq         : in std_logic_vector(31 downto 0);
        ch_en       : in std_logic_vector(1 downto 0); -- a chanel, b chanel
        fifo_rreq   : out std_logic;
        diq_h   : out std_logic_vector(15 downto 0); 
        diq_l   : out std_logic_vector(15 downto 0);
		  --diq_h_uns   : out std_logic_vector(15 downto 0); 
        --diq_l_uns  : out std_logic_vector(15 downto 0);
        data_out_valid  : out std_logic
        
        
        );
end txfifo_read;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of txfifo_read is

signal ch_select  : std_logic;

type read_states is (idle, read_A, read_B, const_B);
signal current_read_state, next_read_state, read_state_d : read_states;
signal fifo_rreq_sig  : std_logic;
signal diq_out_h : std_logic_vector(15 downto 0);
signal diq_out_l : std_logic_vector(15 downto 0);
  
begin
  
-- ----------------------------------------------------------------------------
-- Chanel select generation
-- ----------------------------------------------------------------------------   
process(read_state_d) begin
	if(read_state_d = read_A) then
      ch_select<='0';
	else
      ch_select<='1';
	end if;
end process;

-- ----------------------------------------------------------------------------
-- Mux 
-- ----------------------------------------------------------------------------  
process(read_state_d, diq, ch_select) begin
	if((read_state_d = read_A or read_state_d = read_B)) then
--    diq_out_h<="000" & ch_select & diq(27 downto 16);
--    diq_out_l<="000" & ch_select & diq(11 downto 0);

		diq_out_h(15 downto sample_width+1)<=(others=>'0');
		diq_out_h(sample_width)<=ch_select;
		--diq_out_h(sample_width-1 downto 0)<=diq(sample_width+15 downto 16);
		diq_out_h(sample_width-1 downto 0)<=diq(27 downto 16) & "00";
			
		diq_out_l(15 downto sample_width+1)<=(others=>'0');
		diq_out_l(sample_width)<=ch_select;
		--diq_out_l(sample_width-1 downto 0)<=diq(sample_width-1 downto 0);
		diq_out_l(sample_width-1 downto 0)<=diq(11 downto 0) & "00";
		
	elsif (read_state_d = const_B) then 
	 diq_out_h<="000" & ch_select & "000000000000";
    diq_out_l<="000" & ch_select & "000000000000";
	else
    diq_out_h<=(others=>'0');
    diq_out_l<=(others=>'0');
	end if;
end process;


diq_h<=diq_out_h;
diq_l<=diq_out_l;

--diq_h_uns(sample_width-1 downto 0)<=std_logic_vector(signed(diq_out_h(sample_width-1 downto 0))+8192);
--diq_l_uns(sample_width-1 downto 0)<=std_logic_vector(signed(diq_out_l(sample_width-1 downto 0))+8192);

-- ----------------------------------------------------------------------------
-- txfifo read signal 
-- ----------------------------------------------------------------------------
process(current_read_state, fifo_empty) begin
	if((current_read_state = read_A or current_read_state = read_B)and fifo_empty='0') then
    fifo_rreq_sig<='1';
	else
    fifo_rreq_sig<='0';
	end if;
end process;

fifo_rreq<=fifo_rreq_sig;

-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------

fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_read_state <= idle;
		read_state_d<=idle;
		data_out_valid<='0';
	elsif(clk'event and clk = '1')then 
		current_read_state <= next_read_state;
		read_state_d<=current_read_state;
		data_out_valid<=fifo_rreq_sig;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_read_state, fifo_empty, ch_en) begin
	next_read_state <= current_read_state;
	case current_read_state is
	  
		when idle => --idle state 
		  if fifo_empty='0' then 
		    next_read_state<=read_A;
		  else 
		    next_read_state<=idle;
		  end if;
		  
		when read_A =>
		 if fifo_empty='0' then
		    if  ch_en="11" then	         
		      next_read_state<=read_B;
		    else
		      next_read_state<=const_B;
		    end if;
		 else 
		     next_read_state<=read_A;
		 end if;
		  
		when read_B =>
		    if fifo_empty='0' then  
		      next_read_state<=read_A;
		    else
		      next_read_state<=read_B;
		    end if;  
		  
		when const_B =>
		  if fifo_empty='0' then
		     next_read_state<=read_A;
		  else 
		    	next_read_state<=const_B;
		  end if;
		when others => 
		  
	end case;
end process;


  
end arch;   





