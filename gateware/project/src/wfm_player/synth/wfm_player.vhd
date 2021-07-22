-- ----------------------------------------------------------------------------
-- FILE:          wfm_player.vhd
-- DESCRIPTION:   loads samples from FIFO to external memory and reads back 
--                from memory to FIFO
-- DATE:          1:34 PM Tuesday, October 31, 2017
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES: Currently read commands are executed only in non burst commands 
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_player is
   generic(
      dev_family                 : string  := "Cyclone V";
         
      avl_addr_width             : integer := 25;
      avl_data_width             : integer := 64;
      avl_burst_count_width      : integer := 2;
      avl_be_width               : integer := 4;
      avl_max_burst_count        : integer := 2; -- only 2 is for now
      avl_rd_latency_words       : integer := 32;
      avl_traffic_gen_buff_size  : integer := 16;
         
      wfm_infifo_rdusedw_width   : integer := 11;
      wfm_infifo_rdata_width     : integer := 32;
      
      wfm_outfifo_wrusedw_width  : integer := 9
   );
   port (

      clk                        : in  std_logic;
      reset_n                    : in  std_logic;
     
      --wfm player control signals
      wfm_load                   : in  std_logic;
      wfm_play_stop              : in  std_logic;
      wfm_sample_width           : in  std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
      
      --Avalon interface to external memory
      avl_ready                  : in  std_logic;
      avl_write_req              : out std_logic;
      avl_read_req               : out std_logic;
      avl_burstbegin             : out std_logic;
      avl_addr                   : out std_logic_vector(avl_addr_width-1 downto 0);
      avl_size                   : out std_logic_vector(avl_burst_count_width-1 downto 0);
      avl_wdata                  : out std_logic_vector(avl_data_width-1 downto 0);
      avl_be                     : out std_logic_vector(avl_be_width-1 downto 0);
      avl_rddata                 : in  std_logic_vector(avl_data_width-1 downto 0);
      avl_rddata_valid           : in  std_logic;
      
      --wfm infifo wfm_data -> wfm_infifo -> external memory
      wfm_infifo_rdata           : in  std_logic_vector(wfm_infifo_rdata_width-1 downto 0);
      wfm_infifo_rdreq           : out std_logic;
      wfm_infifo_rdempty         : in  std_logic;
      wfm_infifo_rdusedw         : in  std_logic_vector(wfm_infifo_rdusedw_width-1 downto 0);
      
      --wfm outfifo external memory -> wfm_outfifo -> wfm_data
      wfm_outfifo_reset_n        : out std_logic;
      wfm_outfifo_wrreq          : out std_logic;
      wfm_outfifo_data           : out std_logic_vector(127 downto 0);
      wfm_outfifo_wrusedw        : in  std_logic_vector(wfm_outfifo_wrusedw_width-1 downto 0)
      
      );
end wfm_player;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_player is
--declare signals,  components here
   
signal wfm_load_rising        : std_logic;
--inst0 signals   
signal inst0_rdempty          : std_logic;
signal inst0_q                : std_logic_vector(avl_data_width-1 downto 0);
                                                       
--inst2                                                      
signal inst2_do_write         : std_logic;
signal inst2_do_read          : std_logic;                                            
signal inst2_write_addr       : std_logic_vector(avl_addr_width-1 downto 0); 
signal write_max_words        : std_logic_vector(avl_addr_width-1 downto 0); 
signal inst2_write_burstcount : std_logic_vector(avl_burst_count_width-1 downto 0);                                                                                                           
signal inst2_be               : std_logic_vector(avl_be_width-1 downto 0);                                                      
signal inst2_read_addr        : std_logic_vector(avl_addr_width-1 downto 0);                                                      
signal inst2_read_burstcount  : std_logic_vector(avl_burst_count_width-1 downto 0);                                                  
signal inst2_ready            : std_logic;                                                      
signal inst2_wdata_req        : std_logic; 
signal inst2_read_addr_reset_n: std_logic;

--inst3

signal inst3_data_out_valid   : std_logic;
signal inst3_data_out         : std_logic_vector(127 downto 0);


type state_type is (idle, check_wfm_infifo, do_write, do_burst_write, do_write_idle, check_wfm_outfifo, do_read);
signal current_state, next_state : state_type;
                                                      
constant wfm_outfifo_wrwords_size   : integer := 2**(wfm_outfifo_wrusedw_width-1)-1;                                                      
                                                      
                                                      
constant wfm_outfifo_wrwords_limit  : integer := wfm_outfifo_wrwords_size - avl_rd_latency_words - avl_traffic_gen_buff_size;
                                                         
signal burst_cnt_max                : std_logic_vector(FIFORD_SIZE(wfm_infifo_rdata_width, 
                                                         avl_data_width, 
                                                         wfm_infifo_rdusedw_width)-1 downto 0);
                                                         
signal burst_wr_cnt                 : unsigned(FIFORD_SIZE(wfm_infifo_rdata_width, 
                                                         avl_data_width, 
                                                         wfm_infifo_rdusedw_width)-1 downto 0);
                                                         
signal do_write_idle_cnt            : unsigned(7 downto 0);

signal read_max_addr                : std_logic_vector(avl_addr_width-1 downto 0);
signal read_burst_max_addr          : std_logic_vector(avl_addr_width-1 downto 0);

--in this case component declaration is a must                                                     
COMPONENT avalon_traffic_gen
   GENERIC ( 
      DEVICE_FAMILY        : STRING; 
      ADDR_WIDTH           : integer; 
      BURSTCOUNT_WIDTH     : integer; 
      DATA_WIDTH           : integer;
      BE_WIDTH             : integer; 
      BUFFER_SIZE          : integer; 
      RANDOM_BYTE_ENABLE   : integer 
      );
   PORT
   (
      clk                  : IN STD_LOGIC;
      reset_n              : IN STD_LOGIC;
      avl_ready            : IN STD_LOGIC;
      avl_write_req        : OUT STD_LOGIC;
      avl_read_req         : OUT STD_LOGIC;
      avl_burstbegin       : OUT STD_LOGIC;
      avl_addr             : OUT STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
      avl_size             : OUT STD_LOGIC_VECTOR(BURSTCOUNT_WIDTH-1 DOWNTO 0);
      avl_wdata            : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
      avl_be               : OUT STD_LOGIC_VECTOR(BE_WIDTH-1 DOWNTO 0);
      do_write             : IN STD_LOGIC;
      do_read              : IN STD_LOGIC;
      write_addr           : IN STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
      write_burstcount     : IN STD_LOGIC_VECTOR(BURSTCOUNT_WIDTH-1 DOWNTO 0);
      wdata                : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
      be                   : IN STD_LOGIC_VECTOR(BE_WIDTH-1 DOWNTO 0);
      read_addr            : IN STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
      read_burstcount      : IN STD_LOGIC_VECTOR(BURSTCOUNT_WIDTH-1 DOWNTO 0);
      ready                : OUT STD_LOGIC;
      wdata_req            : OUT STD_LOGIC
   );
END COMPONENT; 

begin
-- ----------------------------------------------------------------------------   
   --wfm infifo buffer (wfm_data -> wfm_infifo -> external memory)
-- ----------------------------------------------------------------------------
   wfm_infifo_rdreq  <= inst2_wdata_req;

-- ----------------------------------------------------------------------------
   --converts commands to Avalon interface signals
-- ----------------------------------------------------------------------------
   avalon_traffic_gen_inst2 : avalon_traffic_gen
   generic map(
      DEVICE_FAMILY        => dev_family,
      ADDR_WIDTH           => avl_addr_width,
      BURSTCOUNT_WIDTH     => avl_burst_count_width,
      DATA_WIDTH           => avl_data_width,
      BE_WIDTH             => avl_be_width,
      BUFFER_SIZE          => avl_traffic_gen_buff_size,
      RANDOM_BYTE_ENABLE   => 0        
      )
   port map(
      clk                  => clk,
      reset_n              => reset_n,
      avl_ready            => avl_ready,
      avl_write_req        => avl_write_req,
      avl_read_req         => avl_read_req,
      avl_burstbegin       => avl_burstbegin,
      avl_addr             => avl_addr,
      avl_size             => avl_size,
      avl_wdata            => avl_wdata,
      avl_be               => avl_be,
      do_write             => inst2_do_write,
      do_read              => inst2_do_read,
      write_addr           => inst2_write_addr,
      write_burstcount     => inst2_write_burstcount,
      wdata                => wfm_infifo_rdata,
      be                   => inst2_be,
      read_addr            => inst2_read_addr,
      read_burstcount      => inst2_read_burstcount,
      ready                => inst2_ready,
      wdata_req            => inst2_wdata_req        
      );
    
   --always all bytes are enabled 
   inst2_be <= (others=>'1');
   
   edge_pulse_inst3 : entity work.edge_pulse(arch_rising)
   port map(
      clk         => clk,
      reset_n     => reset_n,
      sig_in      => wfm_load,
      pulse_out   => wfm_load_rising
   );
   
   
bit_unpack_64_inst3 : entity work.bit_unpack_64
  port map (
        --input ports 
        clk             => clk,
        reset_n         => wfm_play_stop,
        data_in         => avl_rddata,
        data_in_valid   => avl_rddata_valid,
        sample_width    => wfm_sample_width,
        --output ports
        data_out        => inst3_data_out,
        data_out_valid  => inst3_data_out_valid
        );

-- ----------------------------------------------------------------------------
--write logic part
-- ----------------------------------------------------------------------------
--write burst count is determined by FSM write states
process(current_state)
begin
   if (current_state = do_burst_write) then 
      inst2_write_burstcount <= std_logic_vector(to_unsigned(avl_max_burst_count,avl_burst_count_width));
   else 
      inst2_write_burstcount <= std_logic_vector(to_unsigned(1,avl_burst_count_width));
   end if;
end process;

process(clk, reset_n)
begin
   if reset_n = '0' then 
      burst_cnt_max <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      --by dropping LSb it is determined maximum burst transactions
      burst_cnt_max <= '0' & wfm_infifo_rdusedw(FIFORD_SIZE(wfm_infifo_rdata_width, 
                                                         avl_data_width, 
                                                         wfm_infifo_rdusedw_width)-1 downto 1);
   end if;
end process;

--increment write address each write operation and reset when wfm_load is detected
process(clk, reset_n)
begin
   if reset_n = '0' then 
      inst2_write_addr <= (others=>'0');
   elsif (clk'event AND clk='1') then
      if wfm_load_rising = '1' then
         inst2_write_addr <= (others=>'0');
      else
         if (current_state = do_write OR current_state = do_burst_write) AND inst2_ready = '1' then 
            inst2_write_addr <= std_logic_vector(unsigned(inst2_write_addr)+unsigned(inst2_write_burstcount));
         else 
            inst2_write_addr <= inst2_write_addr;
         end if;
      end if;
   end if;
end process;

--A write request can be issued only when avalon_traffic_gen module is ready
process(current_state, inst2_ready, wfm_infifo_rdempty)
begin
   if (current_state = do_write OR current_state = do_burst_write )AND inst2_ready = '1' then 
      inst2_do_write <= '1';
   else 
      inst2_do_write <= '0';
   end if;
end process;

--to count exact number of words written to external memory
process(clk, reset_n)
   begin
   if reset_n = '0' then 
      write_max_words <= (others=>'0');
   elsif (clk'event AND clk='1') then
      if wfm_load_rising = '1' then
         write_max_words <= (others=>'0');
      else
         if inst2_wdata_req = '1' then 
            write_max_words <= std_logic_vector(unsigned(write_max_words) + 1);
         else 
            write_max_words <= write_max_words;
         end if;
      end if;
   end if;
end process;

--Counters for FSM 
process(clk, reset_n)
   begin
   if reset_n = '0' then 
      burst_wr_cnt <= (others=>'0');
      do_write_idle_cnt <= (others=>'0');
   elsif (clk'event AND clk='1') then
   
      --burst write counter 
      if current_state = do_burst_write then 
         if inst2_ready = '1' then
            burst_wr_cnt <= burst_wr_cnt + 1;
         else
            burst_wr_cnt <= burst_wr_cnt;
         end if;
      else
         burst_wr_cnt <= (others=>'0');
      end if;
      
      --write idle cycle counter
      if current_state = do_write_idle then 
         do_write_idle_cnt <= do_write_idle_cnt + 1;
      else
         do_write_idle_cnt <= (others=>'0');
      end if;
      
   end if;
end process;

-- ----------------------------------------------------------------------------
-- read logic part
-- ----------------------------------------------------------------------------                        
process(clk, reset_n)
begin
   if reset_n = '0' then 
      inst2_read_addr_reset_n    <= '0';
      read_max_addr              <= (others=>'0');
      read_burst_max_addr        <= (others=>'0');
   elsif (clk'event AND clk='1') then
      --read_max_addr is used to know when last read command is executed in non burst cmd
      read_max_addr <= std_logic_vector(unsigned(write_max_words)- 1);
      --read_max_addr is used to know when last read burst command can be executed
      read_burst_max_addr <= std_logic_vector(unsigned(write_max_words)- 2);
      if wfm_load_rising = '0' then 
         inst2_read_addr_reset_n <= '1'; 
      else 
         inst2_read_addr_reset_n <= '0';
      end if;
   end if;
end process;

--increment read_addr, inst2_read_addr has asynchronous reset from previous process
process(clk, inst2_read_addr_reset_n)
   begin
   if inst2_read_addr_reset_n = '0' then 
      inst2_read_addr   <= (others=>'0');
   elsif (clk'event AND clk='1') then
      if wfm_play_stop = '0' then 
         inst2_read_addr   <= (others=>'0');
      elsif current_state = do_read AND inst2_ready = '1' then
         if unsigned(inst2_read_addr) < unsigned(read_burst_max_addr) then 
            inst2_read_addr <= std_logic_vector(unsigned(inst2_read_addr) + 2 );
         else 
            inst2_read_addr   <= (others=>'0');
         end if;
      else 
         inst2_read_addr <= inst2_read_addr;
      end if;
   end if;
end process;


--A read request can be issued only when avalon_traffic_gen module is ready
process(current_state, inst2_ready)
begin
   if (current_state = do_read AND inst2_ready = '1') then 
      inst2_do_read <= '1';
   else 
      inst2_do_read <= '0';
   end if;
end process;

--here it is decided read burst count value
process(current_state, write_max_words(0), inst2_read_addr, read_max_addr)
   begin
   --if we have uneven number of write_max_words then we know that last read 
   --will be with burst count of one
   if (inst2_read_addr = read_max_addr AND write_max_words(0) = '1') then 
      inst2_read_burstcount <= std_logic_vector(to_unsigned(1,avl_burst_count_width));
   else 
      inst2_read_burstcount <= std_logic_vector(to_unsigned(avl_max_burst_count,avl_burst_count_width));
   end if;
end process;



-- ----------------------------------------------------------------------------
--state machine to control when to read from FIFO
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
fsm : process(current_state,wfm_load, wfm_play_stop, wfm_infifo_rdempty, inst2_ready, 
               wfm_outfifo_wrusedw, burst_cnt_max, burst_wr_cnt, do_write_idle_cnt) begin
   next_state <= current_state;
   case current_state is
   
      --idle state
      when idle =>               
         if wfm_load = '1' OR wfm_infifo_rdempty = '0' then
            next_state <= check_wfm_infifo;             
         elsif wfm_play_stop = '1' then
            next_state <= check_wfm_outfifo;
         else 
            next_state <= idle;
         end if;
         
      --check if we have data for burst write or single write operation   
      when check_wfm_infifo =>    
         if wfm_infifo_rdempty = '0' AND inst2_ready = '1' then
            if unsigned(burst_cnt_max) > 0 then
               next_state <= do_burst_write;
            else 
               next_state <= do_write;
            end if;
         else 
            next_state <= idle;
         end if;
         
      --execute burst write  
      when do_burst_write =>     
         if inst2_ready = '1' then
            if burst_wr_cnt < unsigned(burst_cnt_max)-1 then 
               next_state <= do_burst_write;
            else
               next_state <= do_write_idle;
            end if;
         else 
            next_state <= do_burst_write;
         end if;
         
      --execute single write
      when do_write =>          
         next_state <= do_write_idle;
      
      -- it is essential to wait 2 cycles after write operation
      -- to know correct number of words in wfm_infifo
      when do_write_idle =>                                       
         if do_write_idle_cnt > 3 then  -- 2 cycle latency from rdreq to rdusedw + 1 aditional logic
            next_state <= check_wfm_infifo;
         else 
            next_state <= do_write_idle;
         end if;
      
      --check that there is enough space to read from memory to FIFO
      when check_wfm_outfifo =>   
         if unsigned(wfm_outfifo_wrusedw) < wfm_outfifo_wrwords_limit AND inst2_ready = '1' then 
            next_state <= do_read;
         else
            next_state <= idle;
         end if;
         
      --execute read command   
      when do_read =>            
         if wfm_load = '1' OR wfm_play_stop = '0' then 
            next_state <= idle;
         else 
            if unsigned(wfm_outfifo_wrusedw) < wfm_outfifo_wrwords_limit AND inst2_ready = '1' then 
               next_state <= do_read;
            else 
               next_state <= check_wfm_outfifo;
            end if;
         end if;
         
      when others => 
         next_state<=idle;
         
   end case;
end process;

-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
wfm_outfifo_reset_n <= wfm_play_stop;
wfm_outfifo_wrreq   <= inst3_data_out_valid;
wfm_outfifo_data    <= inst3_data_out;
  
end arch;   


