-- ----------------------------------------------------------------------------	
-- FILE: 	rx_fifo_ctrl.vhd
-- DESCRIPTION:	controls when to write to fifo. 
-- DATE:	June 3, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rx_fifo_ctrl is
  generic (
        fifo_wsize        : integer := 15;
		  cycles_per_sample	: integer :=2
        );
  port (
        --input ports 
        clk             : in std_logic;
        reset_n         : in std_logic;
        frame_start     : in std_logic;
		  cap_en				: in std_logic;
		  cont_cap			: in std_logic;
        ram_buffer_rdy  : in std_logic;
        fifo_wfull      : in std_logic;
        iq_sel          : in std_logic;

        --output ports 

        fifo_wreq      : out std_logic;
		  buff_size      : in std_logic_vector(15 downto 0);
		  fifo_wrusedw	  : in std_logic_vector(fifo_wsize-1 downto 0);
		  limit_std		  : out std_logic_vector(18 downto 0);
		  dis_iqsel			: in std_logic -- disable when data comes without iqselect
        
        );
end rx_fifo_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rx_fifo_ctrl is
--declare signals,  components here
signal wr_cnt      	: unsigned(16 downto 0);
signal wr_cnt_rst 	: std_logic;
signal wreq				: std_logic;
signal ram_buffer_rdy_reg	: std_logic;
signal ram_buffer_rdy_reg1	: std_logic;
signal ram_buffer_rdy_reg2	: std_logic;
signal iq_sel_reg		: std_logic;
signal limit_in		: integer;
signal limit			: unsigned(18 downto 0);


type fifo_states    is (idle, wait_frame_start, fill_fifo, wait_buffer, wait_en);
signal fifo_state  : fifo_states;

begin


--to count buffer size
limit_in<=to_integer(unsigned(buff_size))*cycles_per_sample-1;
limit<=to_unsigned(limit_in, limit'length);

limit_std<=std_logic_vector(limit); --just for testing
  
fifo_wreq <= wreq and not fifo_wfull;
  
-- ----------------------------------------------------------------------------
-- Main state machine
-- ----------------------------------------------------------------------------
main_fsm_f : process(clk, reset_n) begin
	if(reset_n = '0')then
      fifo_state <= idle;
      wreq<='0';
      wr_cnt_rst<='0';
	elsif(clk'event and clk = '1')then 
	
	     case fifo_state is				--wait for capture enable
	       when idle =>
	         wreq<='0';
	         wr_cnt_rst<='1';
	         if ram_buffer_rdy_reg2='1' and cap_en='1' then 
					if dis_iqsel='1' then 
						fifo_state <= fill_fifo; --when data comes without iqselect
					else 
						fifo_state <= wait_frame_start; 
					end if;
	         else
	         	fifo_state <= idle;
	         end if;
				
	       when wait_frame_start =>	--wait frame start
	           wr_cnt_rst<='0';
	           wreq<='0';  
	           if iq_sel_reg=frame_start then 
	              fifo_state <= fill_fifo;
	           else 
	             	fifo_state <= wait_frame_start;
	           end if;
	                         
	       when fill_fifo =>			--fill fifo until limit
					wr_cnt_rst<='0';
	         if fifo_wfull='0' then
	            if  wr_cnt < limit then 
	                 wreq<='1';
	                 fifo_state <= fill_fifo;
	            else 
	                 wreq<='0';
	                 fifo_state <= wait_buffer;
	            end if;    
	         else
	            wreq<='0';
	            fifo_state <=fill_fifo;
	         end if;
				
	       when wait_buffer => 
	         	  wreq<='0';
					  wr_cnt_rst<='0';
	            if  ram_buffer_rdy_reg2='0' and cont_cap='1' then
	              fifo_state <= idle;
					  --fifo_state <= wait_buffer;
					elsif ram_buffer_rdy_reg2='0' and cont_cap='0' then 
						fifo_state <= wait_en;
	            else 
	              fifo_state <= wait_buffer;
	            end if;
					
			when wait_en => 
					if cap_en='0' then 
						fifo_state <= idle;
					else 
						fifo_state <= wait_en;
					end if;
	       when others =>
					fifo_state <= idle;
			 
	     end case; 
	end if;	
end process;


-- ----------------------------------------------------------------------------
-- write counter and sync registers
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
        wr_cnt<=(others=>'0'); 
		  ram_buffer_rdy_reg<='0';
		  ram_buffer_rdy_reg1<='0';
		  ram_buffer_rdy_reg2<='0';
		  iq_sel_reg<='0';
 	    elsif (clk'event and clk = '1') then
		 ram_buffer_rdy_reg<=ram_buffer_rdy;
		 ram_buffer_rdy_reg1<=ram_buffer_rdy_reg;
		 ram_buffer_rdy_reg2<=ram_buffer_rdy_reg1;
		 iq_sel_reg<=not iq_sel; --because iq sel wil be delayed so we want to invert it
 	      if wr_cnt_rst='1' then
	        wr_cnt<=(others=>'0');
	      else 
	           if wreq='1' and fifo_wfull='0' then
 	            wr_cnt<=wr_cnt+1;
 	           else 
 	            wr_cnt<=wr_cnt;
 	           end if;
        end if;
 	    end if;
    end process;
  
end arch;  