-- ----------------------------------------------------------------------------	
-- FILE: 	ramfifo_ctrl.vhd
-- DESCRIPTION:	ram is used as buffer, fifo=>ram=>fifo
-- DATE:	May 27, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity ramfifo_ctrl is
  generic (
        --buff_size        : integer := 32768;
        ram_addr_size    	: integer := 24;
        ram_burst_size   	: integer := 2;
        raminfifo_size   	: integer := 7;
        ramoutfifo_size  	: integer := 7;
		  sampl_width			: integer := 14
        );
  port (
        --input ports 
        clk             : in std_logic;
        reset_n         : in std_logic;
        infifo_rdusedw  : in std_logic_vector(raminfifo_size-1 downto 0);
        outfifo_wruedw  : in std_logic_vector(ramoutfifo_size-2 downto 0);
        infifo_rdreq    : out std_logic;
        ram_init_done   : in std_logic;
        ram_local_ready : in std_logic;
        ram_burst_bg    : out std_logic;
        ram_wrreq       : out std_logic;
        ram_rdreq       : out std_logic;
        ram_addr        : out std_logic_vector(ram_addr_size-1 downto 0);
        ram_buffer_rdy  : out std_logic;
		  ram_rdata_valid	: in std_logic;
		  fx3_outfifo_empty : in std_logic;
		  infifo_rdempty	: in std_logic;
		  buffer_size		: in std_logic_vector(15 downto 0);
		  buff_limit_std	: out std_logic_vector(18 downto 0)

        --output ports 
        
        );
end ramfifo_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of ramfifo_ctrl is
--declare signals,  components here
signal my_sig_name      : std_logic_vector (7 downto 0);
signal fill_buffer      : std_logic;
signal ram_read_en      : std_logic;
signal ram_write_en     : std_logic;
signal ram_burst_cnt    : unsigned (2 downto 0);
signal ram_burst_max    : unsigned (2 downto 0);
signal ram_burst_bg_int : std_logic;
signal ram_burst_bg_intd : std_logic_vector(3 downto 0);
signal ram_write        : std_logic;
signal ram_burst_size2x : integer;
signal buffer_cnt       : unsigned(15 downto 0);
signal buffer_cnt_rst   : std_logic;
signal addr_cnt         : unsigned(ram_addr_size-1 downto 0);
signal addr_cnt_gen     : std_logic;

signal ram_addr_cnt     : unsigned (ram_addr_size-1 downto 0); 
type main_states   is (idle, check_infifo, check_infifo_delay, start_read_infifo, ram_write_burst_bg, ram_wr, ram_wr1, ram_write_wait, ram_read, ram_read_burst_bg, prep_read, ram_read_wait);
type ram_states    is (idle);
  
type state_type is (s0, s1, s2, s3, s4, s5);
signal wfifo_state  : state_type;
signal rdy_state	  : state_type;

signal current_main_state, next_main_state :   main_states;
signal current_ram_state, next_ram_state :   ram_states;

--for writting fifo
signal fifo_en_flg    : std_logic;
signal limit          : unsigned(ramoutfifo_size-2 downto 0);   
signal upper_limit    : unsigned(ramoutfifo_size-2 downto 0);
signal lower_limit    : unsigned(ramoutfifo_size-2 downto 0);
signal used_fifo      : unsigned(ramoutfifo_size-2 downto 0);

signal buff_limit		 : unsigned(18 downto 0);
signal buff_limit_in	 : integer;

begin



  buff_limit_std<=std_logic_vector(buff_limit); -- just for testing

  used_fifo <= unsigned(outfifo_wruedw); 
  ram_burst_size2x<=ram_burst_size*2;
  
  upper_limit <= to_unsigned(1500, upper_limit'length);    --limit ranges for fifo 
  lower_limit <= to_unsigned(1400, lower_limit'length);
  
  ram_burst_max <= to_unsigned(ram_burst_size, ram_burst_max'length);
  
  
  buff_limit_in<=to_integer(unsigned(buffer_size))*(sampl_width*4)/64;
  buff_limit<=to_unsigned(buff_limit_in, buff_limit'length);

  
  
  --ram control signal
process(current_main_state)begin
	if (current_main_state=ram_read) then
			ram_read_en <= '1'; 
	else
		  ram_read_en <= '0';
	end if;	
end process;

-- ram burst begin signal
process(current_main_state)begin
	if (current_main_state=ram_write_burst_bg or current_main_state=ram_read_burst_bg) then
			ram_burst_bg_int <= '1'; 
	else
		  ram_burst_bg_int <= '0';
	end if;	
end process;

process(current_main_state, ram_local_ready)begin
	if ((current_main_state=ram_write_burst_bg or current_main_state=ram_wr or current_main_state=ram_write_wait)and ram_local_ready='1') then
			infifo_rdreq <= '1'; 
	else
		  infifo_rdreq <= '0';
	end if;	
end process;


process(current_main_state)begin
	if (current_main_state=ram_wr or current_main_state=ram_write_burst_bg or current_main_state=ram_write_wait) then
			ram_write <= '1'; 
	else
		  ram_write <= '0';
	end if;	
end process;


process(current_main_state)begin
	if (current_main_state=ram_read_burst_bg or current_main_state=ram_read) then
			ram_rdreq <= '1'; 
	else
		  ram_rdreq <= '0';
	end if;	
end process;

--main state machine
main_fsm_f : process(clk, reset_n) begin
	if(reset_n = '0')then
		current_main_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_main_state <= next_main_state;
	end if;	
end process;

--main state machine combo
main_fsm : process(current_main_state, fill_buffer, ram_init_done, ram_local_ready, infifo_rdusedw, addr_cnt, fifo_en_flg, infifo_rdempty,
						ram_burst_size2x, buff_limit) begin
  next_main_state <= current_main_state;
  case current_main_state is
  when idle =>
      if ram_init_done='1' and ram_local_ready='1' then 
         next_main_state<=check_infifo;
      else 
         next_main_state<=idle;
      end if;
      
      
  when  check_infifo => 
        if unsigned(infifo_rdusedw) >= ram_burst_size2x  and infifo_rdempty='0' then 
            next_main_state<=ram_write_burst_bg;
        else 
            next_main_state<=check_infifo_delay;
        end if;
  
  when  check_infifo_delay => 
        if unsigned(infifo_rdusedw) >= ram_burst_size and infifo_rdempty='0' then 
            next_main_state<=ram_write_burst_bg;
        else 
            next_main_state<=check_infifo;
        end if;       
               
  when  ram_write_burst_bg =>
        if ram_local_ready='1' then 
         next_main_state <= ram_wr;
        else
          next_main_state <= ram_write_wait;
        end if; 
        
  when  ram_write_wait =>  
         if ram_local_ready='1' then 
          	   next_main_state <= ram_wr; 
	       else
	            next_main_state <= ram_write_wait;
	       end if;     
         
  when ram_wr =>
        if ram_local_ready='1' then
          if fill_buffer='1' and unsigned(infifo_rdusedw) >= ram_burst_size2x then   
            next_main_state <= ram_write_burst_bg;
          elsif fill_buffer='1' and unsigned(infifo_rdusedw) < ram_burst_size2x then 
            next_main_state<=check_infifo;
          else
            next_main_state<=prep_read;
          end if;
        else
           next_main_state <= ram_wr;
        end if;
        
  when prep_read => 
          if ram_local_ready='1' and fifo_en_flg='1' then
            next_main_state<=ram_read_burst_bg;
          else 
            next_main_state<=prep_read;
          end if;
        
  when ram_read_burst_bg => 
      if ram_local_ready='0' then 
          next_main_state <= ram_read;
      elsif ram_local_ready='1' and fifo_en_flg='0' then 
          next_main_state <= ram_read_wait;
      else 
        if addr_cnt>=buff_limit-ram_burst_size then 
            next_main_state<=idle;
        else
            next_main_state <= ram_read_burst_bg;
        end if;
      end if;
      
  when ram_read_wait => 
      if fifo_en_flg='1' then 
			 --if addr_cnt>=buff_size-ram_burst_size then --orig
				if addr_cnt>buff_limit-ram_burst_size then
            next_main_state<=idle;
			 else 
				next_main_state<=ram_read_burst_bg;
			 end if;
      else
        next_main_state <= ram_read_wait;
      end if;
      
    when ram_read => 
        if ram_local_ready='1' then 
			 if fifo_en_flg='1' then 
            if addr_cnt>=buff_limit-ram_burst_size then 
              next_main_state<=idle;
            else
              next_main_state <= ram_read_burst_bg;
            end if;
			else 
				next_main_state <= ram_read_wait;
			end if;
        else
            next_main_state <= ram_read;
        end if;   
      
    when others => 
  end case;
end process;

  process(reset_n, clk)
    begin
      if reset_n='0' then
        ram_burst_cnt<=(others=>'0');  
 	    elsif (clk'event and clk = '1') then
 	      if ram_write='1' and ram_local_ready='1' then 
 	        ram_burst_cnt<=ram_burst_cnt+1;
 	       end if;
 	    end if;
  end process;
    
    
--buffer cnt
buff_cnt : process(clk, reset_n) begin
	if(reset_n = '0')then
		buffer_cnt<=(others=>'0');
	elsif(clk'event and clk = '1')then
	  if  buffer_cnt_rst='1' then 
	    buffer_cnt<=(others=>'0');
	  elsif ram_write='1' and ram_local_ready='1' then 
	    buffer_cnt<=buffer_cnt+1;
	  else 
	    buffer_cnt<=buffer_cnt;
	  end if;
	end if;	
end process;



--addres cnt
addrcnt : process(clk, reset_n) begin
	if(reset_n = '0')then
      addr_cnt<=(others=>'0');
	elsif(clk'event and clk = '1')then
      if current_main_state=idle  or current_main_state=prep_read then  
        addr_cnt<=(others=>'0');
      else 
        if  ram_write='1' and  current_main_state=ram_wr and ram_local_ready='1'then 
          addr_cnt<=addr_cnt+ram_burst_size;
        elsif (current_main_state=ram_read_burst_bg or current_main_state=ram_read)and ram_local_ready='1' then 
          addr_cnt<=addr_cnt+ram_burst_size;
        else 
          addr_cnt<=addr_cnt;
    	   end if;
      end if;
	end if;	
end process;


-------------------------------------------------------------------------------
-- state machine for controling used fifo space
-------------------------------------------------------------------------------
process (clk, reset_n, upper_limit)
	begin
	  if reset_n='0' then
	     wfifo_state<=s0;
	     limit<=upper_limit;
	     fifo_en_flg<='0';
	  elsif (clk'event and clk = '1') then
	     case (wfifo_state) is 
	       when s0 =>
	         if used_fifo>limit then 
	           fifo_en_flg<='0';
	           limit<=lower_limit;
	           wfifo_state<=s1;
	         else 
	           fifo_en_flg<='1';
	           limit<=upper_limit;
	           wfifo_state<=s0;
	         end if;
	       when s1 =>
	            if used_fifo>limit then
	              fifo_en_flg<='0';
	              limit<=lower_limit;
	              wfifo_state<=s1;
	            else 
	              fifo_en_flg<='1';
	              limit<=upper_limit;
	              wfifo_state<=s0;
	            end if; 
	       when others =>
	      end case;
	  end if;
	  end process;
	  
	  rdy_states : process(clk, reset_n) begin
	if(reset_n = '0')then
		rdy_state<=s0;
	elsif(clk'event and clk = '1')then
	case (rdy_state) is 
		when s0=> 
				if current_main_state = check_infifo then 
					rdy_state<=s1;
				else 
					rdy_state<=s0;
				end if;
		when s1=> 
				if current_main_state = prep_read then 
					rdy_state<=s2;
				else 
					rdy_state<=s1;
				end if;
		when s2 =>
				if addr_cnt>=buff_limit-ram_burst_size then 
					rdy_state<=s3;
				else 
					rdy_state<=s2;
				end if;
		when s3=>
				if fx3_outfifo_empty='1' and ram_rdata_valid='0' and ram_local_ready='1' then 
					rdy_state<=s0;
				else 
					rdy_state<=s3;
				end if;
		when others => 
		end case;
		
	end if;	
end process;
	  

    
    ram_burst_bg<=ram_burst_bg_int;
    ram_wrreq<=ram_write;
    buffer_cnt_rst<='1' when current_main_state=ram_read or current_main_state=ram_read_burst_bg else '0';
    fill_buffer<='1' when buffer_cnt<buff_limit-ram_burst_size else '0';   
    ram_addr<=std_logic_vector(addr_cnt);
	 ram_buffer_rdy<='1' when rdy_state=s1 else '0';
	 
--    ram_buffer_rdy<='1' when ((current_main_state = check_infifo or 
--                              current_main_state = check_infifo_delay  or 
--                              current_main_state = ram_write_burst_bg or 
--                              current_main_state = ram_write_wait or 
--                              current_main_state = ram_wr) and fx3_outfifo_empty='1') else '0';
end arch;   

