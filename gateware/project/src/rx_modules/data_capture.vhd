-- ----------------------------------------------------------------------------	
-- FILE: 	data_capture.vhd
-- DESCRIPTION:	waits compresed data frame beginning and writes to fifo
-- DATE:	Dec 9, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity data_capture is
	generic(
		sampl_width	: integer := 12
	);
  port (
        --input ports 
        clk           : in std_logic;
        reset_n       : in std_logic;
        cap_en        : in std_logic;
		  cont_cap		 : in std_logic;
        data_in_valid : in std_logic;
        compr_status  : in std_logic;
        ram_buff_rdy  : in std_logic;
        buff_size     : in std_logic_vector(15 downto 0);
        fifo_wreq     : out std_logic;
		  limt_std		 : out std_logic_vector(18 downto 0)

        --output ports 
        
        );
end data_capture;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of data_capture is
--declare signals,  components here
signal cap_en_reg0, cap_en_reg1 : std_logic;
signal wr_cnt   			: unsigned(15 downto 0);
signal fifo_wreq_sig  	: std_logic;
signal limit				: unsigned(18 downto 0);
signal limit_in			: integer;
signal ram_buff_rdy_reg0, ram_buff_rdy_reg1 : std_logic;
 
type wr_states is (idle, wait_compr, wait_beginning, wr, wait_en);
signal current_wr_state, next_wr_state : wr_states;


  
begin

--to count buffer size
limit_in	<=to_integer(unsigned(buff_size))*(sampl_width*4)/64-1;
limit		<=to_unsigned(limit_in, limit'length);
limt_std	<=std_logic_vector(limit); --only for testing purposes


-- ----------------------------------------------------------------------------
-- data write state machine 
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_wr_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_wr_state <= next_wr_state;
	end if;	
end process;

-- ----------------------------------------------------------------------------
-- data write state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_wr_state, cap_en_reg1, wr_cnt, compr_status, cont_cap, ram_buff_rdy_reg0, limit) begin
  next_wr_state<=current_wr_state;
  
  case current_wr_state is
  
  when idle => 				--waits enable and when buffer is ready
    if cap_en_reg1='1' and ram_buff_rdy_reg0='1' then 
      next_wr_state<=wait_compr;
    else 
      next_wr_state<=idle;
    end if;
    
	 
  when wait_compr =>			--wait compression
	if compr_status='1' then 
     next_wr_state<=wait_beginning;
   else 
     next_wr_state<=wait_compr;
  end if;
  
  when wait_beginning=> 	--wait compression begining
   if compr_status='0' then 
     next_wr_state<=wr;
   else 
     next_wr_state<=wait_beginning;
  end if;
  
  when wr => 					-- write samples until limit
    if wr_cnt<=limit then 
      next_wr_state<=wr;
    else 
		if cont_cap='1' then 
			next_wr_state<=idle;
		else 
			next_wr_state<=wait_en;
		end if;
    end if;
	 
	when wait_en => 			-- executed when continous capture (cont_cap='0'), and waits cap_en='0'. 
		if cap_en_reg1='0' then 
			next_wr_state<=idle;
		else 
			next_wr_state<=wait_en;
		end if;
    
  when others=>
    next_wr_state<=idle;
  end case;
end process;
  

  
-- ----------------------------------------------------------------------------
-- sync registers
-- ---------------------------------------------------------------------------- 
  process(reset_n, clk)
    begin
      if reset_n='0' then
        cap_en_reg0<='0';
        cap_en_reg1<='0'; 
		  ram_buff_rdy_reg0<='0';
		  ram_buff_rdy_reg1<='0'; 
 	    elsif (clk'event and clk = '1') then
 	      cap_en_reg0<=cap_en;
 	      cap_en_reg1<=cap_en_reg0;
			ram_buff_rdy_reg0<=ram_buff_rdy;
			ram_buff_rdy_reg1<=ram_buff_rdy_reg0;
 	    end if;
    end process;
	 
-- ----------------------------------------------------------------------------
-- wr limit counter
-- ----------------------------------------------------------------------------   
      process(reset_n, clk)
    begin
      if reset_n='0' then
        wr_cnt<=(others=>'0'); 
 	    elsif (clk'event and clk = '1') then
			if fifo_wreq_sig='1' then 
				if wr_cnt<=limit then 
					wr_cnt<=wr_cnt+1;
				else
					wr_cnt<=(others=>'0');
				end if;
			elsif current_wr_state=idle then 
				wr_cnt<=(others=>'0');
			else 
           wr_cnt<=wr_cnt;
         end if;
 	    end if;
    end process;
	 
	 
-- ----------------------------------------------------------------------------
-- comb logic for external signals
-- ----------------------------------------------------------------------------     
    fifo_wreq_sig<=data_in_valid when current_wr_state=wr else '0';
    
    fifo_wreq<=fifo_wreq_sig;
  
end arch;   




