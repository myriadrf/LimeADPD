-- ----------------------------------------------------------------------------	
-- FILE:    fifo_bulk_read.vhd
-- DESCRIPTION:   read FIFO in determined size chunks
-- DATE: Jan 27, 2016
-- AUTHOR(s):  Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fifo_bulk_read is
   generic(
      fifo_rd_size   : integer := 12
   );
   port (

      clk            : in std_logic;
      reset_n        : in std_logic;
      --
      bulk_size      : in std_logic_vector(15 downto 0);
      bulk_buff_rdy  : in std_logic;
      fifo_rdusedw   : in std_logic_vector(fifo_rd_size-1 downto 0);
      fifo_rdreq     : out std_logic

        );
end fifo_bulk_read;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of fifo_bulk_read is
--declare signals,  components here
signal rd_cnt : unsigned (15 downto 0);

type state_type is (idle, rd_fifo);
signal current_state, next_state : state_type;
 
begin

-- ----------------------------------------------------------------------------
-- Read counter
-- ----------------------------------------------------------------------------
process(clk, reset_n)
   begin
   if reset_n = '0' then 
      rd_cnt <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if current_state = rd_fifo then
         if rd_cnt = unsigned(bulk_size)-1 then 
            rd_cnt <= (others=>'0');
         else 
            rd_cnt <= rd_cnt+1;
         end if;
      else 
         rd_cnt <= (others=>'0');
      end if;
   end if;
end process;

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
fsm : process(current_state, fifo_rdusedw, bulk_buff_rdy, bulk_size, rd_cnt) begin
   next_state <= current_state;
   case current_state is
   
      when idle =>                  -- wait for enough samples for one bulk transfer
         if unsigned(fifo_rdusedw) >= unsigned(bulk_size)  AND bulk_buff_rdy ='1'  then 
            next_state <= rd_fifo;
         else
            next_state <= idle;
         end if;
         
      when rd_fifo => 
         if rd_cnt = unsigned(bulk_size)-1 then
            if unsigned(fifo_rdusedw) >= unsigned(bulk_size)  AND bulk_buff_rdy ='1'  then
               next_state <= rd_fifo;
            else 
               next_state <= idle;
            end if;
         else 
            next_state <= rd_fifo;
         end if;
         
      when others => 
         next_state <= idle;
   end case;
end process;


-- ----------------------------------------------------------------------------
-- FIFO read signal
-- ----------------------------------------------------------------------------
process(current_state)
begin
   if current_state = rd_fifo then 
      fifo_rdreq <= '1';
   else
      fifo_rdreq <= '0';
   end if;
end process;
  
end arch;   





