-- ----------------------------------------------------------------------------	
-- FILE: 	fifo_buff.vhd
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
entity fifo_buff is
  generic(dev_family	     : string  := "Cyclone IV E";
          wrwidth         : integer := 32;
          wrusedw_witdth  : integer := 15; --15=32768 words 
          rdwidth         : integer := 32;
          rdusedw_width   : integer := 15;
          show_ahead      : string  := "OFF"
  );  

  port (
      --fifo 0 ports
      fifo_0_reset_n       : in std_logic;
      fifo_0_wrclk         : in std_logic;
      fifo_0_wrreq         : in std_logic;
      fifo_0_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_0_wrfull        : out std_logic;
		fifo_0_wrempty		  	: out std_logic;
		--fifo 1 ports
      fifo_1_reset_n       : in std_logic;
      fifo_1_wrclk         : in std_logic;
      fifo_1_wrreq         : in std_logic;
      fifo_1_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_1_wrfull        : out std_logic;
		fifo_1_wrempty		  	: out std_logic;
      --fifo 2 ports
      fifo_2_reset_n       : in std_logic;
      fifo_2_wrclk         : in std_logic;
      fifo_2_wrreq         : in std_logic;
      fifo_2_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_2_wrfull        : out std_logic;
		fifo_2_wrempty		  	: out std_logic;
      --fifo 3 ports
      fifo_3_reset_n       : in std_logic;
      fifo_3_wrclk         : in std_logic;
      fifo_3_wrreq         : in std_logic;
      fifo_3_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_3_wrfull        : out std_logic;
		fifo_3_wrempty		  	: out std_logic;
      --fifo 4 ports
      fifo_4_reset_n       : in std_logic;
      fifo_4_wrclk         : in std_logic;
      fifo_4_wrreq         : in std_logic;
      fifo_4_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_4_wrfull        : out std_logic;
		fifo_4_wrempty		  	: out std_logic;		
		--rd port for all fifo
      fifo_rdclk 	    		: in std_logic;
		fifo_rdclk_reset_n	: in std_logic;
		fifo_cap_size			: in std_logic_vector(15 downto 0);
      fifo_rdreq         	: in std_logic;
      fifo_q             	: out std_logic_vector(rdwidth-1 downto 0);
      fifo_rdempty       	: out std_logic

        );
end fifo_buff;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of fifo_buff is
--declare signals,  components here

-- inst0 signals
signal inst0_rdreq	: std_logic;
signal inst0_q			: std_logic_vector(rdwidth-1 downto 0);
signal inst0_rdempty	: std_logic;

-- inst1 signals
signal inst1_rdreq	: std_logic;
signal inst1_q			: std_logic_vector(rdwidth-1 downto 0);
signal inst1_rdempty	: std_logic;

-- inst2 signals
signal inst2_rdreq	: std_logic;
signal inst2_q			: std_logic_vector(rdwidth-1 downto 0);
signal inst2_rdempty	: std_logic;

-- inst3 signals
signal inst3_rdreq	: std_logic;
signal inst3_q			: std_logic_vector(rdwidth-1 downto 0);
signal inst3_rdempty	: std_logic;

-- inst4 signals
signal inst4_rdreq	: std_logic;
signal inst4_q			: std_logic_vector(rdwidth-1 downto 0);
signal inst4_rdempty	: std_logic;

--general signals
signal rdempty_all_fifo	: std_logic;
type state_type is (idle, rd_fifo0, rd_fifo1, rd_fifo2, rd_fifo3, rd_fifo4, wait_rdreq_low);
signal current_state, next_state : state_type;
signal rd_cnt		: unsigned(15 downto 0);
signal fifo_q_mux_sel	: std_logic_vector(2 downto 0);


component fifo_inst is
  generic(dev_family	     : string  := "Cyclone IV E";
          wrwidth         : integer := 24;
          wrusedw_witdth  : integer := 12; --12=2048 words 
          rdwidth         : integer := 48;
          rdusedw_width   : integer := 11;
          show_ahead      : string  := "ON"
  );  

  port (
      --input ports 
      reset_n       : in std_logic;
      wrclk         : in std_logic;
      wrreq         : in std_logic;
      data          : in std_logic_vector(wrwidth-1 downto 0);
      wrfull        : out std_logic;
		wrempty		  : out std_logic;
      wrusedw       : out std_logic_vector(wrusedw_witdth-1 downto 0);
      rdclk 	     : in std_logic;
      rdreq         : in std_logic;
      q             : out std_logic_vector(rdwidth-1 downto 0);
      rdempty       : out std_logic;
      rdusedw       : out std_logic_vector(rdusedw_width-1 downto 0)     

        );
end component;

begin

process(fifo_rdclk, fifo_rdclk_reset_n)begin
	if(fifo_rdclk_reset_n = '0')then
		rd_cnt <= (others=>'0');
	elsif(fifo_rdclk'event and fifo_rdclk = '1')then
		if  fifo_rdreq ='1' then 
			if rd_cnt < unsigned(fifo_cap_size) - 1 then 
				rd_cnt <= rd_cnt+1;
			else 
				rd_cnt <= (others=>'0');
			end if;
		else 
			rd_cnt<=rd_cnt;
		end if;
	end if;	
end process;



-- ----------------------------------------------------------------------------
--state machine for controlling capture signal
-- ----------------------------------------------------------------------------
fsm_f : process(fifo_rdclk, fifo_rdclk_reset_n)begin
	if(fifo_rdclk_reset_n = '0')then
		current_state <= idle;
	elsif(fifo_rdclk'event and fifo_rdclk = '1')then 
		current_state <= next_state;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, fifo_rdreq, rd_cnt, fifo_cap_size) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state 
			if rd_cnt = unsigned(fifo_cap_size)-1 AND fifo_rdreq='1' then 
				next_state <= rd_fifo1;
			else 
				next_state <= idle;
			end if;

		when rd_fifo1 =>
			if rd_cnt = unsigned(fifo_cap_size)-1 AND fifo_rdreq='1' then 
				next_state <= rd_fifo2;
			else 
				next_state <= rd_fifo1;
			end if;

		when rd_fifo2 =>
			if rd_cnt = unsigned(fifo_cap_size)-1 AND fifo_rdreq='1' then 
				next_state <= rd_fifo3;
			else 
				next_state <= rd_fifo2;
			end if;
			
		when rd_fifo3 =>
			if rd_cnt = unsigned(fifo_cap_size)-1 AND fifo_rdreq='1' then 
				next_state <= rd_fifo4;
			else 
				next_state <= rd_fifo3;
			end if;
			
		when rd_fifo4 =>
			if rd_cnt = unsigned(fifo_cap_size)-1 AND fifo_rdreq='1' then 
				next_state <= wait_rdreq_low;
			else 
				next_state <= rd_fifo4;
			end if;
		
		when wait_rdreq_low => 
			if fifo_rdreq = '0' then 
				next_state <= idle;
			else 
				next_state <= wait_rdreq_low;
			end if;
				 	
		when others => 
			next_state<=idle;
	end case;
end process;



process(current_state,fifo_rdreq)begin
	if(current_state = idle OR current_state = rd_fifo0)then
		inst0_rdreq<=fifo_rdreq;
	else 
		inst0_rdreq<='0';
	end if;
end process;

fifo_inst_inst0: fifo_inst
  generic map
			(dev_family	     => dev_family,
          wrwidth         => wrwidth,
          wrusedw_witdth  => wrusedw_witdth, 
          rdwidth         => rdwidth,
          rdusedw_width   => rdusedw_width,
          show_ahead      => show_ahead
  )  
  port map(
      reset_n       => fifo_0_reset_n, 
      wrclk         => fifo_0_wrclk,
      wrreq         => fifo_0_wrreq,
      data          => fifo_0_data,
      wrfull        => fifo_0_wrfull,
		wrempty		  => fifo_0_wrempty,
      wrusedw       => open,
      rdclk 	     => fifo_rdclk,
      rdreq         => inst0_rdreq,
      q             => inst0_q,
      rdempty       => inst0_rdempty,
      rdusedw       => open     
        );


process(current_state,fifo_rdreq)begin
	if(current_state = rd_fifo1)then
		inst1_rdreq<=fifo_rdreq;
	else 
		inst1_rdreq<='0';
	end if;
end process;

		  
fifo_inst_inst1: fifo_inst
  generic map
			(dev_family	     => dev_family,
          wrwidth         => wrwidth,
          wrusedw_witdth  => wrusedw_witdth, 
          rdwidth         => rdwidth,
          rdusedw_width   => rdusedw_width,
          show_ahead      => show_ahead
  )  
  port map(
      reset_n       => fifo_1_reset_n, 
      wrclk         => fifo_1_wrclk,
      wrreq         => fifo_1_wrreq,
      data          => fifo_1_data,
      wrfull        => fifo_1_wrfull,
		wrempty		  => fifo_1_wrempty,
      wrusedw       => open,
      rdclk 	     => fifo_rdclk,
      rdreq         => inst1_rdreq,
      q             => inst1_q,
      rdempty       => inst1_rdempty,
      rdusedw       => open     
        );		  
  

process(current_state,fifo_rdreq)begin
	if(current_state = rd_fifo2)then
		inst2_rdreq<=fifo_rdreq;
	else 
		inst2_rdreq<='0';
	end if;
end process;


fifo_inst_inst2: fifo_inst
  generic map
			(dev_family	     => dev_family,
          wrwidth         => wrwidth,
          wrusedw_witdth  => wrusedw_witdth, 
          rdwidth         => rdwidth,
          rdusedw_width   => rdusedw_width,
          show_ahead      => show_ahead
  )  
  port map(
      reset_n       => fifo_2_reset_n, 
      wrclk         => fifo_2_wrclk,
      wrreq         => fifo_2_wrreq,
      data          => fifo_2_data,
      wrfull        => fifo_2_wrfull,
		wrempty		  => fifo_2_wrempty,
      wrusedw       => open,
      rdclk 	     => fifo_rdclk,
      rdreq         => inst2_rdreq,
      q             => inst2_q,
      rdempty       => inst2_rdempty,
      rdusedw       => open     
        );
		  
		  
		  
process(current_state,fifo_rdreq)begin
	if(current_state = rd_fifo3)then
		inst3_rdreq<=fifo_rdreq;
	else 
		inst3_rdreq<='0';
	end if;
end process;


fifo_inst_inst3: fifo_inst
  generic map
			(dev_family	     => dev_family,
          wrwidth         => wrwidth,
          wrusedw_witdth  => wrusedw_witdth, 
          rdwidth         => rdwidth,
          rdusedw_width   => rdusedw_width,
          show_ahead      => show_ahead
  )  
  port map(
      reset_n       => fifo_3_reset_n, 
      wrclk         => fifo_3_wrclk,
      wrreq         => fifo_3_wrreq,
      data          => fifo_3_data,
      wrfull        => fifo_3_wrfull,
		wrempty		  => fifo_3_wrempty,
      wrusedw       => open,
      rdclk 	     => fifo_rdclk,
      rdreq         => inst3_rdreq,
      q             => inst3_q,
      rdempty       => inst3_rdempty,
      rdusedw       => open     
        );
		  
		  
process(current_state,fifo_rdreq)begin
	if(current_state = rd_fifo4)then
		inst4_rdreq<=fifo_rdreq;
	else 
		inst4_rdreq<='0';
	end if;
end process;


fifo_inst_inst4: fifo_inst
  generic map
			(dev_family	     => dev_family,
          wrwidth         => wrwidth,
          wrusedw_witdth  => wrusedw_witdth, 
          rdwidth         => rdwidth,
          rdusedw_width   => rdusedw_width,
          show_ahead      => show_ahead
  )  
  port map(
      reset_n       => fifo_4_reset_n, 
      wrclk         => fifo_4_wrclk,
      wrreq         => fifo_4_wrreq,
      data          => fifo_4_data,
      wrfull        => fifo_4_wrfull,
		wrempty		  => fifo_4_wrempty,
      wrusedw       => open,
      rdclk 	     => fifo_rdclk,
      rdreq         => inst4_rdreq,
      q             => inst4_q,
      rdempty       => inst4_rdempty,
      rdusedw       => open     
        );
		  



process(fifo_rdclk, fifo_rdclk_reset_n)begin
	if(fifo_rdclk_reset_n = '0')then
		fifo_q_mux_sel <= (others=> '0');
	elsif(fifo_rdclk'event and fifo_rdclk = '1')then 
		if inst0_rdreq = '1' then 
			fifo_q_mux_sel <= "000";
			
		elsif inst1_rdreq = '1' then 
			fifo_q_mux_sel <= "001";
			
		elsif inst2_rdreq = '1' then 
			fifo_q_mux_sel <= "010";
			
		elsif inst3_rdreq = '1' then 
			fifo_q_mux_sel <= "011";
			
		else 
			fifo_q_mux_sel <= "100";
		end if;			
	end if;	
end process;

fifo_q <= 	inst0_q when fifo_q_mux_sel="000" else 
				inst1_q when fifo_q_mux_sel="001" else 
				inst2_q when fifo_q_mux_sel="010" else
				inst3_q when fifo_q_mux_sel="011" else 
				inst4_q;

rdempty_all_fifo <= 	inst1_rdempty when current_state = rd_fifo1 else 
							inst2_rdempty when current_state = rd_fifo2 else
							inst3_rdempty when current_state = rd_fifo3 else
							inst4_rdempty when current_state = rd_fifo4 else
							inst0_rdempty;
							
fifo_rdempty<=rdempty_all_fifo;
  
end arch;   





