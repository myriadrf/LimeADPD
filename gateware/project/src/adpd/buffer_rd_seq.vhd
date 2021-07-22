-- ----------------------------------------------------------------------------	
-- FILE: 	buffer_rd_seq.vhd.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
ENTITY buffer_rd_seq IS
	PORT (
		--input ports 
		clk : IN STD_LOGIC;
		reset_n : IN STD_LOGIC;
		ram_rd_done : IN STD_LOGIC;
		ram_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		ram_data_valid : IN STD_LOGIC;
		fifo_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		buff_size : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

		--output ports 
		fifo_read : OUT STD_LOGIC;
		fx3_buff_wr : OUT STD_LOGIC;
		fx3_buff_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		fx3_buff_wusedw : IN STD_LOGIC_VECTOR(10 DOWNTO 0)
	);
END buffer_rd_seq;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE arch OF buffer_rd_seq IS

	--state type declaration
	TYPE state_type IS (idle, wait_ramrd, wait_ramrd_done, begin_rd_fifo);
	SIGNAL current_state, next_state : state_type;
	SIGNAL fifo_rd_cnt : unsigned(15 DOWNTO 0);
	SIGNAL ram_wr_cnt : unsigned(15 DOWNTO 0);
BEGIN
	--state machine
	fsm_f : PROCESS (clk, reset_n) BEGIN
		IF (reset_n = '0') THEN
			current_state <= idle;
		ELSIF (clk'event AND clk = '1') THEN
			current_state <= next_state;
		END IF;
	END PROCESS;

	--state machine combo
	fsm : PROCESS (current_state) BEGIN
		next_state <= current_state;
		CASE current_state IS
			WHEN idle => --idle state
				IF ram_rd_done = '1' THEN
					next_state <= wait_ramrd;
				ELSE
					next_state <= idle;
				END IF;

			WHEN wait_ramrd =>
				IF ram_rd_done = '0' THEN
					next_state <= wait_ramrd_done;
				ELSE
					next_state <= wait_ramrd;
				END IF;

			WHEN wait_ramrd_done =>
				IF ram_rd_done = '1' THEN
					next_state <= begin_rd_fifo;
				ELSE
					next_state <= wait_ramrd_done;
				END IF;

			WHEN begin_rd_fifo =>

			WHEN OTHERS =>
				next_state <= idle;
		END CASE;
	END PROCESS;
	PROCESS (reset_n, clk)
	BEGIN
		IF reset_n = '0' THEN
			--reset  
		ELSIF (clk'event AND clk = '1') THEN
			--in process
		END IF;
	END PROCESS;

END arch;